----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: MUX21_GENERIC
-- Function: multiplexer 2x1 
-- Input: A, B (N-bit), SEL (1-bit)
-- Output: Y (N-bit)
-- Architecture: behavioral
-- Library/package: ieee.std_logic_ll64
-- Date: 14/04/2020
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;


entity MUX31_GENERIC is
	generic(NBIT: integer:= 4);
	port (S2:	in 	std_logic_vector(NBIT-1 downto 0);
	      S1:	in 	std_logic_vector(NBIT-1 downto 0);
	      S0:	in	std_logic_vector(NBIT-1 downto 0);
	      SEL:	in	std_logic_vector(2 downto 0);
	      Y:	out	std_logic_vector(NBIT-1 downto 0));
end entity;

architecture BEHAVIORAL of MUX31_GENERIC is
begin
        process (S1, S0, SEL)
        begin
        	if (SEL = "001") then
        		Y <= S0;
        	elsif (SEL = "010") then
        		Y <= S1;
 		     elsif (SEL = "100") then
        		Y <= S2;
  		     else
 		      Y <= (others => '0');
       		end if;	
        end process;
end architecture;
