----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: FA
-- Function: full-adder circuit
-- Input: A, B, Ci (1-bit)
-- Output: S, Co (1-bit)
-- Architecture: RTL
-- Library/package: ieee.std_logic_ll64
-- Date: 14/04/2020
----------------------------------------------------------------------------------
library IEEE; 
use IEEE.std_logic_1164.all; 

entity FA is 
    port (A	:	in	std_logic;
          B	:	in	std_logic;
          Ci	:	in	std_logic;
          S	:	out	std_logic;
          Co	:	out	std_logic);
end entity; 

architecture RTL of FA is
begin
  S <= A xor B xor Ci;
  Co <= (A and B) or (B and Ci) or (A and Ci);  
end architecture;
