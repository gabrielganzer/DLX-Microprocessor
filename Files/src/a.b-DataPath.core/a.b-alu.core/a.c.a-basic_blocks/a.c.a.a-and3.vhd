----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: AND3
-- Function: 3-input and gate
-- Input: A,B,C (1-bit)
-- Output: Y (1-bit)
-- Architecture: rtl
-- Library/package: ieee.std_logic_ll64
-- Date: 02/08/2020
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity AND3 is
  port(
    A,B,C : in  std_logic;
    Y 	: out std_logic
  );
end entity;

architecture RTL of AND3 is
begin
  Y <= A and B and C;
end architecture;
