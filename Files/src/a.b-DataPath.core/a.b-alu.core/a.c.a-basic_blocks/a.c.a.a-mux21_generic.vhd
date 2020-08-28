----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: MUX21_GENERIC
-- Function: multiplexer 2x1 
-- Input: A, B (N-bit), SEL (1-bit)
-- Output: Y (N-bit)
-- Architecture: behavioral
-- Library/package: ieee.std_logic_ll64
--		    work.contansts
-- Date: 14/04/2020
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use work.CONSTANTS.all;


entity MUX21_GENERIC is
	generic(NBIT: integer);
	port (S1:	in 	std_logic_vector(NBIT-1 downto 0);
	      S0:	in	std_logic_vector(NBIT-1 downto 0);
	      SEL:	in	std_logic;
	      Y:	out	std_logic_vector(NBIT-1 downto 0));
end entity;

architecture BEHAVIORAL of MUX21_GENERIC is
begin
        process (S1, S0, SEL)
        begin
        	if (SEL='1') then
        		Y <= S1;
        	else
        		Y <= S0;
       		end if;	
        end process;
end architecture;
