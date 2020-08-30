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
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PC_INCREMENT is
  port (
    PC  : in std_logic_vector(31 downto 0);    
    NPC : out std_logic_vector(31 downto 0)
  );
end entity;

architecture RTL of PC_INCREMENT is
begin
  NPC <= std_logic_vector(unsigned(PC) + x"00000004");
end architecture;