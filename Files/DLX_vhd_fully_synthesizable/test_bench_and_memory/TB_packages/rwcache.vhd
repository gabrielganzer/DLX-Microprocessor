library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use ieee.std_logic_misc.all;

package RWCACHE_PKG is
constant RWCACHE_WAYS			: natural := 2;
constant RWCACHE_NUMSETS		: natural := 4;  --Depth of ICache
constant RWCACHE_WORDS			: natural := 2;
constant DATA_SIZE				: natural := 32;
constant RWCACHE_SETINDEXSIZE	: natural := 2;
constant RWCACHE_NUMLINES		: natural := RWCACHE_WAYS;
constant RWCACHE_INDEXSIZE		: natural := 1;
constant RWCACHE_TAGSIZE		: natural := DATA_SIZE - RWCACHE_INDEXSIZE - RWCACHE_SETINDEXSIZE;
constant RWCACHE_TAGOFFSET		: natural := DATA_SIZE - RWCACHE_TAGSIZE;
constant RWCACHE_SETOFFSET		: natural := RWCACHE_TAGOFFSET - RWCACHE_SETINDEXSIZE;
constant RWCACHE_INDEXOFFSET	: natural := RWCACHE_INDEXSIZE;
constant RWCACHE_COUNTERSIZE	: natural := 8;

subtype RWCACHE_LINES is natural range 0 to RWCACHE_NUMLINES - 1;
subtype RWCACHE_SETS is natural range 0 to 2**RWCACHE_SETINDEXSIZE - 1;
subtype RWCACHE_INDEX is natural range 0 to 2**RWCACHE_INDEXSIZE - 1;

type DATA_WORDS is array (RWCACHE_INDEX) of std_logic_vector(DATA_SIZE - 1 downto 0);

type RWCACHE_RECORD is
	record
		tag : std_logic_vector(RWCACHE_TAGSIZE-1 downto 0);
		words : DATA_WORDS;
		counter : integer range 0 to 2**RWCACHE_COUNTERSIZE;
		valid : std_logic;
end record;

type RWCACHE_LINE is array (RWCACHE_LINES) of RWCACHE_RECORD;
type RWCACHE_TYPE is array (RWCACHE_SETS) of RWCACHE_LINE;

subtype state_type is std_logic_vector(2 downto 0);
constant STATE_FLUSH_MEM			: state_type := "000";
constant STATE_MISS 				: state_type := "001";
constant STATE_COMPARE_TAGS			: state_type := "010";
constant STATE_WRITE_MISS			: state_type := "011";
constant STATE_IDLE					: state_type := "100";

function COMPARE_TAGS(
	x : std_logic_vector(RWCACHE_TAGSIZE - 1 downto 0 );
	y : std_logic_vector(RWCACHE_TAGSIZE - 1 downto 0 )
) return std_logic;

function GET_SET(
	x : std_logic_vector(DATA_SIZE - 1 downto 0)
) return integer;

function GET_REPLACEMENT_LINE(
	pc : std_logic_vector(DATA_SIZE - 1 downto 0);
	cache: RWCACHE_TYPE
) return natural;

end RWCACHE_PKG;

package body RWCACHE_PKG is
	function COMPARE_TAGS(
			x : std_logic_vector(RWCACHE_TAGSIZE-1 downto 0);
			y : std_logic_vector(RWCACHE_TAGSIZE-1 downto 0)
		) return std_logic is

	begin
		return and_reduce(x xnor y);
end COMPARE_TAGS;

function GET_SET (
		x : std_logic_vector(DATA_SIZE - 1 downto 0)
	) return integer is

	variable ret	: integer :=0;
	variable y		: std_logic_vector(RWCACHE_TAGOFFSET-1 downto RWCACHE_SETOFFSET);

	begin
		y		:= x(RWCACHE_TAGOFFSET-1 downto RWCACHE_SETOFFSET);
		ret		:= conv_integer(unsigned (y));
		return ret;
end GET_SET;

function GET_REPLACEMENT_LINE (
		pc : std_logic_vector(DATA_SIZE - 1 downto 0);
		cache: RWCACHE_TYPE
	) return natural is

	variable count			: natural range 0 to 2**RWCACHE_COUNTERSIZE;
	variable min_found		: std_logic;
	variable i				: natural := 0;
	variable to_evict		: natural range 0 to 2**RWCACHE_COUNTERSIZE;
	variable countValid		: std_logic;

	begin
--		count := cache( GET_SET(pc) )(i).counter;
		to_evict := i;
		countValid := '0';
		count:=0;
		-- Iterate
--		while i < (RWCACHE_NUMLINES - 2) loop
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
		for i in 0 to RWCACHE_NUMLINES - 1 loop
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
