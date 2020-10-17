----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: ROMEM
-- Function: Single-port ROM memory
-- Input:
-- Output:
-- Architecture: behavioral
-- Library/package: ieee.std_logic_ll64, work.globals
-- Date: 12/08/2020
----------------------------------------------------------------------------------

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
entity ROM is
	generic (FILE_PATH   : string;
		       ENTRIES		   : integer := 128;
		       WIDTH       : integer := 32);
	port (CS			: in std_logic; -- Active-high
		    ADDR : in std_logic_vector((log2(ENTRIES))-1 downto 0);
		    DATA	: out std_logic_vector(WIDTH-1 downto 0));
end entity;

architecture BEHAVIORAL of ROM is
	type ROM is array (0 to ENTRIES-1) of std_logic_vector(WIDTH-1 downto 0);
	signal memory : ROM := (others => (others => '0'));
begin
  
  WRITE: process
  		file mem_fp        : text;
		variable fline     : line;
		variable index     : natural range 0 to ENTRIES:= 0;
		variable tmp_data  : std_logic_vector(WIDTH-1 downto 0);
  begin
 		file_open(mem_fp, FILE_PATH, READ_MODE);
	  -- Read content
    while (not endfile(mem_fp)) loop
		  readline(mem_fp,fline);
		  hread(fline,tmp_data);
		  memory(index) <= tmp_data;
		  index := index + 1;
	  end loop;
	  -- Close file
    file_close(mem_fp);
    wait;
  end process;
  
	-- Instruction ROM behavioral description
	ROM_PROC: process (CS, ADDR)
	begin
		  if (CS = '0') then
			  DATA <= (others => 'Z');   
		  else
				DATA <= memory(to_integer(unsigned(ADDR)));
			end if;
  end process;
  
end architecture;