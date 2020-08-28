----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: AND2
-- Function: 2-input and gate
-- Input: A,B (1-bit)
-- Output: Y (1-bit)
-- Architecture: structural
-- Library/package: ieee.std_logic_ll64
-- Date: 02/08/2020
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity AND2 is
  port(
    A, B : in  std_logic;
    Y 	  : out std_logic
  );
end entity;

architecture STRUCTURAL of AND2 is
begin
  Y <= A and B;
end architecture;
