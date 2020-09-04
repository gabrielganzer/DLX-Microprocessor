----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: FULL_ADDER
-- Function: full-adder circuit
-- Input: A, B, Ci (1-bit)
-- Output: S, Co (1-bit)
-- Architecture: behavioral
-- Library/package: ieee.std_logic_ll64
-- Date: 14/04/2020
----------------------------------------------------------------------------------
library IEEE; 
use IEEE.std_logic_1164.all; 

entity FULL_ADDER is 
    port (A:	in	std_logic;
          B:	in	std_logic;
          Ci:	in	std_logic;
          S:	out	std_logic;
          Co:	out	std_logic);
end FULL_ADDER; 

architecture BEHAVIORAL of FULL_ADDER is
begin
  S <= A xor B xor Ci;
  Co <= (A and B) or (B and Ci) or (A and Ci);  
end BEHAVIORAL;
