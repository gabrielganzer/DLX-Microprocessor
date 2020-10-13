----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: RCA
-- Function: ripple-carry adder circuit
-- Input: A,B (4-bit), Ci (1-bit)
-- Output: S (4-bit), Co (1-bit)
-- Architecture: structural
-- Library/package: ieee.std_logic_ll64
-- Date: 14/04/2020
----------------------------------------------------------------------------------
library IEEE;
library work;
use IEEE.std_logic_1164.all;
use work.globals.all;

entity CSA is
    generic (WIDTH: integer := radix_size);
    port (A	 :	in	std_logic_vector(WIDTH-1 downto 0);
          B	 :	in	std_logic_vector(WIDTH-1 downto 0);
          Ci	:	in	std_logic_vector(WIDTH-1 downto 0);
          S	 :	out	std_logic_vector(WIDTH-1 downto 0);
          Co	:	out	std_logic_vector(WIDTH-1 downto 0));
end entity; 

architecture STRUCTURAL of CSA is
    -- Components
    component FA 
        port (A		:	in	std_logic;
              B		:	in	std_logic;
              Ci	:	in	std_logic;
              S		:	out	std_logic;
              Co	:	out	std_logic);
    end component; 
begin
    Co(0) <= '0';
    GEN: for i in 0 to WIDTH-2 generate
      FAi : FA 
        port map (A(i), B(i), Ci(i), S(i), Co(i+1)); 
    end generate;
    FAth : FA 
        port map (A(WIDTH-1), B(WIDTH-1), Ci(WIDTH-1), S(WIDTH-1), open); 
end architecture;
