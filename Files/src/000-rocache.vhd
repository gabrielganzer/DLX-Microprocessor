library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use ieee.std_logic_misc.all;

package ROCACHE_PKG is
constant ROCACHE_WAYS			: natural := 2;
constant ROCACHE_NUMSETS		: natural := 4;  --Depth of ICache
constant ROCACHE_WORDS			: natural := 2;
constant INSTR_SIZE 			: natural := 32;
constant ROCACHE_SETINDEXSIZE	: natural := 2;
constant ROCACHE_NUMLINES		: natural := ROCACHE_WAYS;
constant ROCACHE_INDEXSIZE		: natural := 1;
constant ROCACHE_TAGSIZE		: natural := INSTR_SIZE - ROCACHE_INDEXSIZE - ROCACHE_SETINDEXSIZE;
constant ROCACHE_TAGOFFSET		: natural := INSTR_SIZE - ROCACHE_TAGSIZE;
constant ROCACHE_SETOFFSET		: natural := ROCACHE_TAGOFFSET - ROCACHE_SETINDEXSIZE;
constant ROCACHE_INDEXOFFSET	: natural := ROCACHE_INDEXSIZE;
constant ROCACHE_COUNTERSIZE	: natural := 8;

subtype ROCACHE_LINES is natural range 0 to ROCACHE_NUMLINES - 1;
subtype ROCACHE_SETS is natural range 0 to 2**ROCACHE_SETINDEXSIZE - 1;
subtype ROCACHE_INDEX is natural range 0 to 2**ROCACHE_INDEXSIZE - 1;

type INSTR_WORDS is array (ROCACHE_INDEX) of std_logic_vector(INSTR_SIZE - 1 downto 0);

type ROCACHE_RECORD is
	record
		tag : std_logic_vector(ROCACHE_TAGSIZE-1 downto 0);
		words : INSTR_WORDS;
		counter : natural range 0 to 2**ROCACHE_COUNTERSIZE;
		valid : std_logic;
end record;

type ROCACHE_LINE is array (ROCACHE_LINES) of ROCACHE_RECORD;
type ROCACHE_TYPE is array (ROCACHE_SETS) of ROCACHE_LINE;

subtype state_type is std_logic_vector(1 downto 0);
constant STATE_FLUSH_MEM			: state_type := "00";
constant STATE_MISS 				: state_type := "01";
constant STATE_COMPARE_TAGS			: state_type := "10";
constant STATE_IDLE					: state_type := "11";

function COMPARE_TAGS(
	x : std_logic_vector(ROCACHE_TAGSIZE - 1 downto 0 );
	y : std_logic_vector(ROCACHE_TAGSIZE - 1 downto 0 )
) return std_logic;

function GET_SET(
	x : std_logic_vector(INSTR_SIZE - 1 downto 0)
) return integer;

function GET_REPLACEMENT_LINE(
	pc : std_logic_vector(INSTR_SIZE - 1 downto 0);
	cache: ROCACHE_TYPE
) return natural;

end ROCACHE_PKG;

package body ROCACHE_PKG is
	function COMPARE_TAGS(
			x : std_logic_vector(ROCACHE_TAGSIZE-1 downto 0);
			y : std_logic_vector(ROCACHE_TAGSIZE-1 downto 0)
		) return std_logic is

	begin
		return and_reduce(x xnor y);
end COMPARE_TAGS;

function GET_SET (
		x : std_logic_vector(INSTR_SIZE - 1 downto 0)
	) return integer is

	variable ret	: integer :=0;
	variable y		: std_logic_vector(ROCACHE_TAGOFFSET-1 downto ROCACHE_SETOFFSET);

	begin
		y		:= x(ROCACHE_TAGOFFSET-1 downto ROCACHE_SETOFFSET);
		ret		:= conv_integer(unsigned (y));
		return ret;
end GET_SET;

function GET_REPLACEMENT_LINE (
		pc : std_logic_vector(INSTR_SIZE - 1 downto 0);
		cache: ROCACHE_TYPE
	) return natural is

	variable count			: natural range 0 to 2**ROCACHE_COUNTERSIZE;
	variable min_found		: std_logic;
	variable i				: natural := 0;
	variable to_evict		: natural range 0 to 2**ROCACHE_COUNTERSIZE;
	variable countValid		: std_logic;

	begin
--		count := cache( GET_SET(pc) )(i).counter;
		to_evict := i;
		countValid := '0';

		-- Iterate
--		while i < (ROCACHE_NUMLINES - 2) loop
			-- Check counter value
--			if(cache( GET_SET(pc) )(i+1).valid = '0') then
--				to_evict := i + 1;
--				exit;
--			elsif(cache( GET_SET(pc) )(i+1).counter < count) then
--				-- New least frequently used -> save its index and counter value
--				count := cache( GET_SET(pc) )(i+1).counter;
--				to_evict := i + 1;
--			end if;

--			i := i + 1 ;
--		end loop;

		-- Iterate
		for i in 0 to ROCACHE_NUMLINES - 1 loop
			-- If not valid -> USE IT
			if(cache( GET_SET(pc) )(i).valid = '0') then
				to_evict := i;
				exit;

			-- Line is busy, but counter not initialized
			elsif(countValid = '0') then
				count := cache(GET_SET(pc))(i).counter;
				countValid := '1';
				to_evict := i;

			-- Line is busy, and counter initialized: check if lower
			elsif(cache( GET_SET(pc) )(i).counter < count) then
				-- New least frequently used -> save its index and counter value
				count := cache( GET_SET(pc) )(i).counter;
				to_evict := i;
			end if;

		end loop;

		return to_evict;
end GET_REPLACEMENT_LINE;

end package body;
