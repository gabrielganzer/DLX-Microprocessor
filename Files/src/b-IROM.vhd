library ieee;
library std;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;
use work.globals.all;

-- Instruction memory for DLX
-- Memory filled by a process which reads from a file
-- file name is "test.asm.mem"
entity ROMEM is
	generic (
		FILE_PATH   : string;
		ENTRIES		   : integer := 128;
		WIDTH       : integer := 32
	);
	port (
		CLK	        : in std_logic; 
		RST					  : in std_logic; -- Synchronous, active-high
		EN				    : in std_logic; -- Active-high
		ADDR   				 : in std_logic_vector((log2(ENTRIES))-1 downto 0);
		DATA				    : out std_logic_vector(WIDTH-1 downto 0)
	);
end entity;

architecture BEHAVIORAL of ROMEM is
	type ROM is array (0 to ENTRIES-1) of std_logic_vector(WIDTH-1 downto 0);
	signal memory : ROM;
begin

	-- Instruction ROM behavioral description
	ROM_PROC: process (CLK, EN, ADDR)
		file mem_fp        : text;
		variable fline     : line;
		variable index     : natural range 0 to ENTRIES:= 0;
		variable tmp_data  : std_logic_vector(WIDTH-1 downto 0);
	begin
	  if (CLK = '1' and CLK'event) then
		  if (RST = '1') then
		    -- Write content from hex file into ROM memory if reset enable
			  -- Open file
			  file_open(mem_fp, file_path, READ_MODE);
			  -- Read content
        while (not endfile(mem_fp)) loop
				  readline(mem_fp,fline);
				  hread(fline,tmp_data);
				  memory(index) <= tmp_data;
				  index := index + 1;
			  end loop;
			  -- Close file
        file_close(mem_fp);    
		  else
		    -- Read content from memory if enable
			  if (EN = '1' ) then
					 DATA <= memory(to_integer(unsigned(ADDR)));
			  end if;
			end if;
		end if;
  end process;
  
end architecture;