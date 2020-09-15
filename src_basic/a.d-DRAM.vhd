library ieee;
library std;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;
use work.globals.all;

entity RWMEM is
	generic (
		FILE_PATH       : string;
		ENTRIES         : integer := 128;
		WIDTH           : integer := 32
	);
	port (
			CLK  : in std_logic;
			RST		: in std_logic;  -- Synchronous, active-low
			EN		 : in std_logic;  -- Active-high
			RW		 : in std_logic;  -- Write active-high
			ADDR : in std_logic_vector((log2(ENTRIES))-1 downto 0);
			DIN  : in std_logic_vector(WIDTH-1 downto 0);
			DOUT : out std_logic_vector(WIDTH-1 downto 0)
		);
end entity;

architecture BEHAVIORAL of RWMEM is
	type RAM is array (0 to ENTRIES-1) of std_logic_vector(WIDTH-1 downto 0);
	signal memory: RAM := (others => (others => '0'));
	signal tmp_data: std_logic_vector(WIDTH-1 downto 0);
  
  -- TBD
  -- Refresh memory content
	procedure refresh(data: in RAM; path_file: string) is
		file mem_fp     : text;
		variable index  : natural range 0 to ENTRIES := 0;
		variable fline  : line;
	begin
	  -- Open file
		file_open(mem_fp, path_file, WRITE_MODE);
		-- Rewrite content
		while index < ENTRIES loop
			hwrite(fline, data(index));
			writeline(mem_fp, fline);
			index := index + 1;
		end loop;
		-- Close file
    file_close(mem_fp);
	end procedure;
	
begin
  
  -- Data RAM behavioral description
	RAM_PROC: process (CLK)
	begin
    --if (CLK = '1' and CLK'event) then
      if RST = '0' then
        tmp_data <= (others => '0');
      elsif (CLK = '1' and CLK'event) then
        if (EN = '1') then
          if (RW = '1') then
            memory(to_integer(unsigned(ADDR))) <= DIN;
          else
            tmp_data <= memory(to_integer(unsigned(ADDR)));
          end if;
        end if;
      end if;
    --end if;
  end process;

	refresh(memory, FILE_PATH);
	DOUT <= tmp_data;

end architecture;