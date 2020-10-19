----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: SDRAM
-- Function: Dual-port SDRAM memory
-- Input: CLK, RST, EN, RW (1-bit); ADDR, DIN (N-bit)
-- Output: DOUT (N-bit)
-- Architecture: behavioral
-- Library/package: ieee.std_logic_ll64, ieee.numeric_std, ieee.std_logic_textio
--                  std.textio, work.globals
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

entity SDRAM is
	generic (FILE_READ   : string;
	         FILE_PATH   : string;
		       ENTRIES     : integer := 128;
		       WIDTH       : integer := 32);
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

architecture BEHAVIORAL of SDRAM is
	type RAM is array (0 to ENTRIES-1) of std_logic_vector(WIDTH-1 downto 0);
	signal memory: RAM := (others => (others => '0'));
	signal tmp_data: std_logic_vector(WIDTH-1 downto 0);
  
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
	  file mem_fp        : text;
		variable fline     : line;
		variable index     : natural range 0 to ENTRIES:= 0;
		variable tmp_data_u: std_logic_vector(WIDTH-1 downto 0);
	begin
    if (CLK = '1' and CLK'event) then
      if RST = '0' then
        file_open(mem_fp, FILE_READ, READ_MODE);
	  -- Read content
    while (not endfile(mem_fp)) loop
		  readline(mem_fp,fline);
		  hread(fline,tmp_data_u);
		  memory(index) <= tmp_data_u;
		  index := index + 1;
	  end loop;
	  -- Close file
    file_close(mem_fp);
        tmp_data <= (others => '0');
      else
        if (EN = '1') then
          if (RW = '1') then
            memory(to_integer(unsigned(ADDR))) <= DIN;
          else
            tmp_data <= memory(to_integer(unsigned(ADDR)));
          end if;
        end if;
      end if;
    end if;
  end process;

	refresh(memory, FILE_PATH);
  DOUT <= tmp_data;
  
end architecture;