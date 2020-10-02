----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: SHIFTER_MULT
-- Function: multiplexer 2x1 
-- Input: A, B (N-bit), SEL (1-bit)
-- Output: Y (N-bit)
-- Architecture: RTL
-- Library/package: ieee.std_logic_ll64
-- Date: 14/04/2020
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity SHIFTER_MULT is 
	generic(WIDTH: integer:= 4; SHIFT : integer := 1);
	port (A    :	in std_logic_vector(WIDTH-1 downto 0);
	      S1   :	out	std_logic_vector(2*WIDTH-1 downto 0);
	      S2   :	out std_logic_vector(2*WIDTH-1 downto 0);
	      S3   :	out	std_logic_vector(2*WIDTH-1 downto 0);
	      S4   :	out	std_logic_vector(2*WIDTH-1 downto 0)
	);
end entity; 

architecture RTL of SHIFTER_MULT is
begin
   
   S1 <= (others => '0')                             when unsigned(A) = 0 else
         (2*WIDTH-1 downto WIDTH => A(WIDTH-1))&A    when SHIFT = 0 else
  	      (2*WIDTH-1 downto WIDTH+SHIFT => A(WIDTH-1))&A&(SHIFT-1 downto 0 => '0');

   S2 <= (others => '0')	                                                                   when unsigned(A) = 0 else
         (2*WIDTH-1 downto WIDTH => not(A(WIDTH-1)))&std_logic_vector(not(unsigned(A))+1)   when SHIFT = 0 else
	       (2*WIDTH-1 downto WIDTH+SHIFT => not(A(WIDTH-1)))&std_logic_vector(not(unsigned(A))+1)&(SHIFT-1 downto 0 => '0');

   S3 <= (others => '0')	when unsigned(A) = 0 else 
         (2*WIDTH-1 downto WIDTH+SHIFT+1=> A(WIDTH-1))&A&(SHIFT downto 0 => '0');
   
   S4 <= (others => '0') when unsigned(A) = 0 else 
         (2*WIDTH-1 downto WIDTH+SHIFT+1=> not(A(WIDTH-1)))&std_logic_vector(not(unsigned(A))+1)&(SHIFT downto 0 => '0');
        
end architecture;
