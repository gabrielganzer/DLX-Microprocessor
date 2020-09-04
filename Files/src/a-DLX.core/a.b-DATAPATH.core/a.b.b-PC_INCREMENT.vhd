----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: PC_INCREMENT
-- Function: Increment program counter by 4
-- Input: PC (32-bit)
-- Output: NPC (32-bit)
-- Architecture: rtl
-- Library/package: ieee.std_logic_ll64
-- Date: 05/08/2020
----------------------------------------------------------------------------------
library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.globals.all;

entity PC_INCREMENT is
  generic (WIDTH : integer:= instruction_size);
  port (
    PC  : in std_logic_vector(WIDTH-1 downto 0);    
    NPC : out std_logic_vector(WIDTH-1 downto 0)
  );
end entity;

architecture RTL of PC_INCREMENT is
begin
  NPC <= std_logic_vector(unsigned(PC) + 4);
end architecture;