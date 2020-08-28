----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: XNOR2
-- Function: 2-input xnor gate
-- Input: A,B (1-bit)
-- Output: Y (1-bit)
-- Architecture: rtl
-- Library/package: ieee.std_logic_ll64
-- Date: 02/08/2020
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity XNOR2 is
  port(
    A,B : in  std_logic;
    Y 	: out std_logic
  );
end entity;

architecture RTL of XNOR2 is
begin
  Y <= A xnor B;
end architecture;
