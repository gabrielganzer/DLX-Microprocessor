----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: WINDOWED_REGISTER_FILE
-- Function: Windowed register file behavioral implementation
-- Inputs: CLK, RST, EN, RD1, RD2, WR, CALL, RET: (1-bit) control signals
--         DATAIN, BUSIN: (64-bit) data in
--         ADD_RD1, ADD_RD2, ADD_WR: (4-bit) addresses
-- Outputs: FILL, SPILL: (1-bit) control signals
--	    OUT1, OUT2, BUSOUT: (64-bit) data out
-- Architecture: behavioral
-- Library/package: ieee.std_logic_ll64, ieee.numeric_std
--                  work.constants, work.functions
-- Date: 05/05/2020
----------------------------------------------------------------------------------
library IEEE;
library WORK;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.globals.all;

entity WINDOWED_REGISTER_FILE is
	generic(WIDTH:	positive := word_size;
		M:		positive := 5; --5
		N:		positive := 3; --3
		F:		positive := 2     --2
	);
	port(
	  -- Synchronous reset, active-high enable	
	  CLK     :IN std_logic;
		RST     :IN std_logic;
		EN      :IN std_logic;
		-- Synchronous R/W, active-high signals
		RD1     :IN std_logic;
		RD2     :IN std_logic;
		WR      :IN std_logic;
		-- Ports addresses 
	  	ADD_WR  :IN std_logic_vector(log2(3*N+M)-1 downto 0);
		ADD_RD1 :IN std_logic_vector(log2(3*N+M)-1 downto 0);
		ADD_RD2 :IN std_logic_vector(log2(3*N+M)-1 downto 0);
		-- Single write port
		DATAIN  :IN std_logic_vector(WIDTH-1 downto 0);
		-- Double read ports
		OUT1    :OUT std_logic_vector(WIDTH-1 downto 0);
		OUT2    :OUT std_logic_vector(WIDTH-1 downto 0);
		-- Subroutine control signals (CALL and RETURN), active-high
		CALL    :IN std_logic;
		RET     :IN std_logic;
		-- MMU control signals (FILL and SPILL), active-high
		FILL    :OUT std_logic;
		SPILL   :OUT std_logic;
		-- BUS to/from used when spilling/filling registers
		BUSIN   :IN std_logic_vector(WIDTH-1 downto 0);
		BUSOUT  :OUT std_logic_vector(WIDTH-1 downto 0)
	);
  end entity;

architecture BEHAVIORAL of WINDOWED_REGISTER_FILE is
  -- Number of physical registers
	constant NREG: positive := M+2*N*F;
	-- Subtype that specifies physical address lenght
	subtype PHYSICAL_LENGTH is std_logic_vector (log2(NREG)-1 downto 0);
	-- Type that specifies an array of registers to be used internally
	type REG_ARRAY is array (0 to NREG-1) of std_logic_vector(WIDTH-1 downto 0);
	-- Index of first global register (GLOBAL0), first register from the firt window (WINDOW0), and first register from last window (WINDOWth)
	   -- Indexes WINDOW0 and WINDOWth are used to manage the circular buffer update
	constant GLOBAL0: PHYSICAL_LENGTH := std_logic_vector(to_unsigned(2*N*F, PHYSICAL_LENGTH'length));
	constant WINDOW0: PHYSICAL_LENGTH := std_logic_vector(to_unsigned(0, PHYSICAL_LENGTH'length));
	constant WINDOWth: PHYSICAL_LENGTH := std_logic_vector(to_unsigned(2*N*(F-1), PHYSICAL_LENGTH'length));
  -- Current Window Pointer (CWP) and Saved Window Pointer (SWP)
	signal CWP: PHYSICAL_LENGTH;
	signal SWP: PHYSICAL_LENGTH;
	-- Auxiliar registers/flags
	   -- CANSAVE stores 0 when subroutine call requires the spilling of next window, 1 otherwise
	signal CANSAVE : std_logic;					--low when a subroutine call requires a spill of the next window, high otherwise
	   -- CANRESTORE stores 0 when subroutine return requires the filling of previous window, 1 otherwise
	signal CANRESTORE : std_logic;
	   -- Flag that is active-high when register file is busy spilling a window
	signal SPILLING : std_logic;
	   -- Flag that is active-high when register file is busy filling a window
	signal FILLING : std_logic;
	   -- Register that stores how many registers have to be spilled/filled
	signal COUNT : natural range 0 to 2*N-1;
	-- Physical registers instantiation
	signal REGISTERS: REG_ARRAY;
  
  -- Corversion of the virtual external address received as input into the physical internal one
    -- Arguments: virtual address, current window pointer
    -- Return: physical address
	function virtual2physical_address(VADDR: std_logic_vector(log2(3*N+M)-1 downto 0); CWP: PHYSICAL_LENGTH) return PHYSICAL_LENGTH is
	  -- Variable used to store the global register offset
		variable OFFSET: natural range 0 to M-1;
		begin
		  -- Virtual address does not correspond to a global register, simply add CWP to VADDR 
			if (to_integer(unsigned(VADDR)) < 3*N) then
				return std_logic_vector(unsigned(VADDR) + unsigned(CWP));
			else
			  -- Virtual address corresponds to a global register
			     -- Offset indicating which global register is extracted
				OFFSET:= to_integer(unsigned(VADDR)) - 3*N;
				   -- Add index for the first global register into the offset
				return std_logic_vector(unsigned(GLOBAL0) + to_unsigned(OFFSET, PHYSICAL_LENGTH'length));
			end if;
	end function virtual2physical_address;

	-- Computation of next window index taking into account a circular buffer implementation
	function next_window(P: PHYSICAL_LENGTH) return PHYSICAL_LENGTH is
	begin
	  -- Pointer stores the last window index, simply rewrite the index for the first one
		if (P = WINDOWth) then
			return WINDOW0;
		else
		-- Otherwise, increment 2*N to the stored value
			return std_logic_vector(unsigned(P) + to_unsigned(2*N, PHYSICAL_LENGTH'length));
		end if;
	end function next_window;
	
	-- Computation of previous window index taking into account a circular buffer implementation
	function previous_window(P: PHYSICAL_LENGTH) return PHYSICAL_LENGTH is
	begin
	  -- Pointer stores the first window index, simply rewrite the index for the last one
		if (P = WINDOW0) then
			return WINDOWth;
		else
		-- Otherwise, decrement 2*N to the stored value
			return std_logic_vector(unsigned(P) - to_unsigned(2*N, PHYSICAL_LENGTH'length));
		end if;
	end function previous_window;
  
begin
  
  WinRegFile: process (CLK)
  begin
    if (CLK = '1' and CLK'event) then
      if (RST = '1') then
        -- Write 0's to each internal register
        REGISTERS <= (others => (others => '0'));
        OUT1 <= (others => '0');
        OUT2 <= (others => '0');
        BUSOUT <= (others => '0');
        -- Clear CWP and SWP registers
    				SWP <= (others=>'0');
				CWP <= (others=>'0');
				-- Clear internal flags
				SPILLING <= '0';
				FILLING <= '0';
				COUNT <= 0;
      else
  				-- Within SPILL
        if (SPILLING = '1') then
				  -- Write all the registers of the spilled window into the memory bus, one at each clock cycle
					BUSOUT <= REGISTERS(to_integer(unsigned(CWP)) + COUNT);
					-- All registers were spilled, clear COUNT register and SPILLING flag
					if (COUNT = (2*N) - 1) then
						SPILLING <= '0';
						COUNT <= 0;
					else
					-- Otherwise increment counter
						COUNT <= COUNT + 1;
					end if;
				-- Within FILL	
				elsif (FILLING = '1') then
				  -- Read from memory bus all the registers of the window that needs to be filled, one at each clock cycle
					REGISTERS(to_integer(unsigned(CWP)) + COUNT) <= BUSIN;
					-- All registers were spilled, clear COUNT register and SPILLING flag
					if (COUNT = (2*N) - 1) then
						FILLING <= '0';
						COUNT <= 0;
					else
					-- Otherwise increment counter
						COUNT <= COUNT + 1;
          end if;
        -- Within SUB
        elsif (EN = '1') then
          -- Read address in ADD_RD1 and bypass to OUT1
          if (RD1 = '1') then
            OUT1 <= REGISTERS(to_integer(unsigned(virtual2physical_address(ADD_RD1, CWP))));
          end if;
          -- Read address in ADD_RD2 and bypass to OUT2
          if (RD2 = '1') then
            OUT2 <= REGISTERS(to_integer(unsigned(virtual2physical_address(ADD_RD2, CWP))));
          end if;
          -- Write and bypass in case read address = write address
          if (WR = '1') then
            REGISTERS(to_integer(unsigned(virtual2physical_address(ADD_WR, CWP)))) <= DATAIN;
            -- Bypass DATAIN to OUT1 (simultaneous read/write)
            if ((virtual2physical_address(ADD_RD1, CWP) = virtual2physical_address(ADD_WR, CWP)) and (RD1 = '1')) then
              OUT1 <= DATAIN;
            end if;
            -- Bypass DATAIN to OUT2 (simultaneous read/write)
            if ((virtual2physical_address(ADD_RD2, CWP) = virtual2physical_address(ADD_WR, CWP))and (RD2 = '1')) then
              OUT2 <= DATAIN;
            end if;
          end if;
          -- Subroutine is called
          if (CALL = '1') then
            -- Change current window pointer to the next window
					  CWP <= next_window(CWP);
					  -- Verify if spilling is necessary
						if (CANSAVE = '0') then
						  -- RF is kept busy during operation and SWP is increment so it points to the next window
							SPILLING <= '1';
							SWP <= next_window(SWP);
						end if;
					elsif (RET = '1') then
						CWP <= previous_window(CWP);
						-- Verify if filling is necessary
						if (CANRESTORE = '0') then
						  -- RF is kept busy during operation and SWP is decrement so it points to the previous window
							FILLING <= '1';
							SWP <= previous_window(SWP);
					  end if;
					end if;
        end if;
      end if;
    end if;
  end process;
  
	--CANSAVE and CANRESTORE assignments
	CANSAVE <= '0' when (SWP = next_window(CWP)) else '1';
	CANRESTORE <= '0' when (SWP = CWP) else '1';
	
  -- SPILL and FILL outputs are directly connected to the internal flags
	SPILL <= SPILLING;
	FILL <= FILLING;
	
end architecture behavioral;
