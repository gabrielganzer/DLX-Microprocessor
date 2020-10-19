----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: NAND2
-- Function: 2-input nand logic gate, for accurate placement
-- Input: A,B (1-bit)
-- Output: Y (1-bit)
-- Architecture: rtl
-- Library/package: ieee.std_logic_ll64
-- Date: 02/08/2020
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity NAND2 is
  port(
    A, B : in  std_logic;
    Y 	: out std_logic
  );
end entity;

architecture RTL of NAND2 is
begin
  Y <= A nand B;
end architecture;
