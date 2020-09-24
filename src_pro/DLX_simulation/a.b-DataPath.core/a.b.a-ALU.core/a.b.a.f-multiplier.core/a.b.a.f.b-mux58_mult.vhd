----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: MUX21_GENERIC
-- Function: multiplexer 2x1 
-- Input: A, B (N-bit), SEL (1-bit)
-- Output: Y (N-bit)
-- Architecture: RTL
-- Library/package: ieee.std_logic_ll64
-- Date: 14/04/2020
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity MUX58_MULT is 
	generic(WIDTH: integer:= 4);
	port (S0   :	in std_logic_vector(WIDTH-1 downto 0);
	      S1   :	in	std_logic_vector(WIDTH-1 downto 0);
	      S2   :	in std_logic_vector(WIDTH-1 downto 0);
	      S3   :	in	std_logic_vector(WIDTH-1 downto 0);
	      S4   :	in	std_logic_vector(WIDTH-1 downto 0);
	      SEL  :	in	std_logic_vector(2 downto 0);
	      Y    :	out	std_logic_vector(WIDTH-1 downto 0));
end entity;

architecture RTL of MUX58_MULT is
begin

  Y <=  S1 when SEL = "001" or SEL = "010" else
        S2 when SEL = "101" or SEL = "110" else
        S3 when SEL = "011" else
        S4 when SEL = "100" else
        S0;

end architecture;


