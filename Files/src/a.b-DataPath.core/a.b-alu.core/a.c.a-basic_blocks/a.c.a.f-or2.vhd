----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: OR2
-- Function: 2-input or gate
-- Input: A,B (1-bit)
-- Output: Y (1-bit)
-- Architecture: rtl
-- Library/package: ieee.std_logic_ll64
-- Date: 02/08/2020
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity OR2 is
  port(
    A,B : in  std_logic;
    Y 	: out std_logic
  );
end entity;

architecture RTL of OR2 is
begin
  Y <= A or B;
end architecture;
