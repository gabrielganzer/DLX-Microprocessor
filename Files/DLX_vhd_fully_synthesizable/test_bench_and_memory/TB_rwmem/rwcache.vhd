library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_misc.all;
use work.RWCACHE_PKG.all;

entity RWCACHE is
	generic (
		regaddrsize : integer
	);
	port (
		CLK						: in std_logic;
		RST						: in std_logic;  -- active high
		ENABLE_EX				: in std_logic;
		READNOTWRITE_EX			: in std_logic;

		ALU_OUT_REAL			: in std_logic_vector(DATA_SIZE - 1 downto 0);
		RS2_DATA_EX				: in std_logic_vector(DATA_SIZE - 1 downto 0);
		RS2_EX					: in std_logic_vector(regaddrsize-1 downto 0);
		RD_MEM					: in std_logic_vector(regaddrsize-1 downto 0);
		MEM_STALL				: in std_logic;
		LATCHER					: in std_logic;

		MEM_DATA				: out std_logic_vector(DATA_SIZE - 1 downto 0);
		STALL					: out std_logic;
		RAM_ISSUE				: out std_logic;
		RAM_READNOTWRITE		: out std_logic;
		RAM_ADDRESS				: out std_logic_vector(DATA_SIZE - 1 downto 0);
		RAM_DATA				: inout std_logic_vector(2*DATA_SIZE - 1 downto 0);
		RAM_READY				: in std_logic
	);
end RWCACHE;

architecture Behavioral of RWCACHE is
	signal CACHE,CACHE_REG							: RWCACHE_TYPE;
	signal STATE_CURRENT					: state_type;
	signal STATE_NEXT						: state_type;
	signal INT_ISSUE_RAM_READ				: std_logic;
	signal ENABLE							: std_logic;
	signal READNOTWRITE						: std_logic;
	signal INT_INOUT_DATA,int_address_data,address_to_mem	: std_logic_vector(DATA_SIZE -1 downto 0);
	signal ADDRESS							: std_logic_vector(DATA_SIZE -1 downto 0);
	signal IN_DATA							: std_logic_vector(DATA_SIZE -1 downto 0);
	signal INT_MEM_DATA							: std_logic_vector(DATA_SIZE -1 downto 0);
	signal INT_RAM_DATA						: std_logic_vector(2*DATA_SIZE -1 downto 0) := (others => 'Z');
	signal NOP_OUT							: std_logic;
	signal INT_STALL							: std_logic;
	signal rewrite							: std_logic:='0';
	signal INT_RAM_READNOTWRITE: std_logic;
begin
	--
	-- FSM Management
	--
	state_update: process(CLK, RST, STATE_NEXT, LATCHER)
		variable RS2_MEM_EQ_RD_WB : std_logic;
		variable LATCHED_RS2_DATA_EX : std_logic_vector(DATA_SIZE-1 downto 0);
		variable LATCHED_ALU_OUT_REAL : std_logic_vector(DATA_SIZE-1 downto 0);
	begin
		if RST = '1' then
			STATE_CURRENT <= STATE_FLUSH_MEM;
		elsif clk'event and clk = '1' then
			CACHE_REG <= CACHE;
			STATE_CURRENT <= STATE_NEXT;

			if INT_STALL = '0' then
				ENABLE <= ENABLE_EX;
				READNOTWRITE <= READNOTWRITE_EX;
			else
				ENABLE <= '1';
			end if;

			if LATCHER = '1' then
				LATCHED_RS2_DATA_EX := RS2_DATA_EX;
				LATCHED_ALU_OUT_REAL := ALU_OUT_REAL;
			end if;

			ADDRESS <= LATCHED_ALU_OUT_REAL;
			RS2_MEM_EQ_RD_WB := (not or_reduce( RS2_EX xor RD_MEM ) and ( not MEM_STALL ));

			if RS2_MEM_EQ_RD_WB = '1' then
				IN_DATA <= INT_MEM_DATA;
			else
				IN_DATA <= LATCHED_RS2_DATA_EX;
			end if;
		end if;
	end process;

	--
	-- The MONSTER
	main: process(STATE_CURRENT, ADDRESS, IN_DATA, READNOTWRITE, RAM_READY, int_address_data, ENABLE, CACHE_REG)
		variable HIT		 		: std_logic:='0';
		variable int_mem			: std_logic_vector(2*DATA_SIZE - 1 downto 0);
		variable currentLine		: natural range 0 to 2**RWCACHE_COUNTERSIZE;
		variable count_miss 		: natural range 0 to RWCACHE_NUMLINES;
		variable index				: natural range 0 to 2**RWCACHE_INDEXOFFSET - 1;
		variable lineIndex		: natural range 0 to RWCACHE_NUMLINES;

		variable address_stall		: std_logic_vector(DATA_SIZE - 1 downto 0);
		variable data_stall			: std_logic_vector(DATA_SIZE - 1 downto 0);
		variable readnotwrite_stall	: std_logic := '0';
		variable test : integer;

	begin
--		report "addr" & integer'image(conv_integer(unsigned(ADDRESS))) & " rnw " & std_logic'image(READNOTWRITE) & "inout" & integer'image(conv_integer(unsigned(IN_DATA))) & " indata " & integer'image(conv_integer(unsigned(IN_DATA))) & " enable " & std_logic'image(ENABLE) & " state " & integer'image(conv_integer(unsigned(STATE_CURRENT))) & " ram ready " & std_logic'image(RAM_READY);

		count_miss := 0;
		CACHE <= CACHE_REG;
		INT_INOUT_DATA <= (others => '0');
		case (STATE_CURRENT) is

		when  STATE_FLUSH_MEM =>
--			ADDRESS <= (others => '0');
			INT_INOUT_DATA <= (others =>'0');
			for i in 0 to RWCACHE_NUMSETS - 1 loop
				for j in 0 to RWCACHE_NUMLINES - 1 loop

					CACHE(i)(j).tag( RWCACHE_TAGSIZE - 1 downto 0 ) <= (others => '0');
					CACHE(i)(j).valid <= '0'; -- dirty bit
					CACHE(i)(j).counter <= 0;

					for k in 0 to RWCACHE_WORDS - 1 loop
						CACHE(i)(j).words(k) <= (others => '1');
					end loop;

				end loop;
			end loop;

			NOP_OUT <= '1';
			HIT := '0';
			INT_ISSUE_RAM_READ <= '0';
			STATE_NEXT <= STATE_IDLE;

		when STATE_IDLE => STATE_NEXT <= STATE_COMPARE_TAGS;

		when STATE_WRITE_MISS =>

			if(RAM_READY = '1') then
				STATE_NEXT <= STATE_MISS;
				INT_ISSUE_RAM_READ <= '1';

			else
				STATE_NEXT <= STATE_WRITE_MISS;
			end if;

		-- MISS STATE
		-- Probe the RAM and wait until RAM_READY
		when STATE_MISS =>
			-- I gots the data
			rewrite <= '0';

			INT_ISSUE_RAM_READ <= '1';
			INT_RAM_READNOTWRITE <= '1';

			if (RAM_READY = '1' and rewrite='0') then

				-- Identify line to hold the new data
				currentLine := GET_REPLACEMENT_LINE(int_address_data, CACHE_REG);

				-- Identify word index inside the line

		--		report "----------------- Instr " & integer'image(conv_integer(unsigned(int_address_data))) & "-> Writing TAG " & integer'image(conv_integer(unsigned(int_address_data(DATA_SIZE-1 downto RWCACHE_TAGOFFSET)))) & " in set " & integer'image(GET_SET(int_address_data)) & " line " & integer'image(currentLine);

				-- Store TAG
				CACHE(GET_SET(int_address_data))(currentLine).tag <= int_address_data(DATA_SIZE - 1 downto RWCACHE_TAGOFFSET);

				-- Reset LFU counter
				CACHE(GET_SET(int_address_data))(currentLine).counter <= 0;

				-- Set valid bit
				CACHE(GET_SET(int_address_data))(currentLine).valid <= '1';

				-- Fetch the line from memory data bus and write it into the cache data
				for i in 0 to RWCACHE_WORDS - 1 loop
					if( readnotwrite_stall = '0' and i = conv_integer(unsigned(int_address_data(RWCACHE_INDEXOFFSET - 1 downto 0)))) then
						CACHE(GET_SET(int_address_data))(currentLine).words(i) <= data_stall;
					else
						CACHE(GET_SET(int_address_data))(currentLine).words(i)
							<= RAM_DATA(((i+1)*DATA_SIZE - 1) downto i*DATA_SIZE);
					end if;
				end loop;

				-- Write the DATA_OUT
				if(readnotwrite_stall = '1' ) then
					if((conv_integer(unsigned(int_address_data(RWCACHE_INDEXOFFSET - 1 downto 0)))) = 0) then
						INT_INOUT_DATA <= RAM_DATA(DATA_SIZE - 1 downto 0);
					else
						INT_INOUT_DATA <= RAM_DATA(2*DATA_SIZE - 1 downto DATA_SIZE);
					end if;
				end if;

				STATE_NEXT <= STATE_COMPARE_TAGS;
				NOP_OUT <= '0';
			end if;

		-- Fetch instruction and print it if HIT
		when STATE_COMPARE_TAGS =>
			if(ENABLE = '1') then
				NOP_OUT <= '1';
				INT_ISSUE_RAM_READ <= '0';

				if(READNOTWRITE = '0') then
					INT_INOUT_DATA <= RS2_DATA_EX;

--					report "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Writing " & integer'image(conv_integer(unsigned(IN_DATA))) & " into " & integer'image(conv_integer(unsigned(ADDRESS)));
				end if;

				-- Look in the CACHE
				for i in 0 to RWCACHE_NUMLINES - 1 loop

					-- Is it a HIT ?
					HIT := COMPARE_TAGS(
						ADDRESS(DATA_SIZE - 1 downto RWCACHE_TAGOFFSET),
						CACHE_REG(GET_SET(ADDRESS))(i).tag(RWCACHE_TAGSIZE - 1 downto 0)
					);

					-- HIT!
					if (HIT = '1') then

						-- Is the entry valid?
						if(CACHE_REG(GET_SET(ADDRESS))(i).valid = '1') then
							lineIndex:= i;

				--		report string'("STATE: ") & integer'image(conv_integer(unsigned(STATE_CURRENT))) & string'(" || ADDRESS: ") & integer'image(conv_integer(unsigned(ADDRESS))) & string'(" || HIT: ") & integer'image(conv_integer(conv_integer(HIT))) & string'(" || i: ") & integer'image(i) & string'(" || offset: ") & integer'image(GET_SET(ADDRESS)) & string'(" || count_miss = ") & integer'image(count_miss);

							HIT := '0'; -- Reset HIT

							CACHE(GET_SET(ADDRESS))(lineIndex).counter <= CACHE_REG(GET_SET(ADDRESS))(lineIndex).counter + 1;
							if(READNOTWRITE = '1') then
								-- Print out the instruction
								INT_INOUT_DATA <= CACHE_REG(
									GET_SET(ADDRESS))(lineIndex).words(
										conv_integer(unsigned(ADDRESS(RWCACHE_INDEXOFFSET - 1 downto 0))
									)
								);

								test := conv_integer(unsigned(CACHE_REG(
									GET_SET(ADDRESS))(lineIndex).words(
										conv_integer(unsigned(ADDRESS(RWCACHE_INDEXOFFSET - 1 downto 0))
									)
								)));
--								report "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Reading " & integer'image(test) & " into " & integer'image(conv_integer(unsigned(ADDRESS)));
							else
								CACHE(
									GET_SET(ADDRESS))(lineIndex).words(
										conv_integer(unsigned(ADDRESS(RWCACHE_INDEXOFFSET - 1 downto 0))
									)
								) <= IN_DATA;
							end if;

							NOP_OUT <= '0';

							-- Next state: the same
							STATE_NEXT <= STATE_COMPARE_TAGS;

							count_miss := 0;
							exit;

						-- The entry is not valid. Count as miss, save its index
						else
							count_miss := count_miss + 1;
						end if;

					-- Miss :(
					else
						count_miss := count_miss + 1;
					end if;

				end loop;

				-- Miss?
				if(count_miss = RWCACHE_NUMLINES) then
					int_address_data <= ADDRESS;
					readnotwrite_stall := READNOTWRITE;
					data_stall := IN_DATA;
					currentLine := GET_REPLACEMENT_LINE(ADDRESS, CACHE_REG);
					if(CACHE_REG(GET_SET(ADDRESS))(currentLine).valid = '1') then
						address_stall := CACHE_REG(GET_SET(ADDRESS))(currentLine).tag & ADDRESS(RWCACHE_TAGOFFSET-1 downto RWCACHE_SETOFFSET) & '0';
						rewrite <= '1';
						address_to_mem <= address_stall;
					--	report "ADDRESS TO MEM: "& integer'image(conv_integer(unsigned(address_stall)));
						INT_RAM_DATA <= CACHE_REG(GET_SET(address_stall))(currentLine).words(0) & CACHE_REG(GET_SET(address_stall))(currentLine).words(1);
						CACHE(GET_SET(ADDRESS))(currentLine).valid <= '0';
						INT_RAM_READNOTWRITE <= '0';
						STATE_NEXT <= STATE_WRITE_MISS;
					else
						STATE_NEXT <= STATE_MISS;
					end if;
				end if;

				-- Reset the counter
				count_miss := 0;
			else
				INT_ISSUE_RAM_READ <= '0';
				INT_INOUT_DATA <= ALU_OUT_REAL;
				STATE_NEXT <= STATE_COMPARE_TAGS;
			end if;
				count_miss := 0;
		when OTHERS => null;
		end case;
	end process;


	INT_STALL				<= NOP_OUT when ENABLE = '1' else '0';
	STALL				<= INT_STALL;
	RAM_ISSUE		<= INT_ISSUE_RAM_READ or rewrite;
	RAM_READNOTWRITE <= INT_RAM_READNOTWRITE;
	RAM_ADDRESS		<= address_to_mem when (rewrite = '1') else
						int_address_data  when (INT_ISSUE_RAM_READ='1') else (others=> 'Z') ;
	RAM_DATA <= INT_RAM_DATA when rewrite = '1' else (others =>'Z');
	INT_MEM_DATA		<= INT_INOUT_DATA;
	MEM_DATA		<= INT_MEM_DATA;
end Behavioral;
