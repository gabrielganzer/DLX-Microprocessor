----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: SUM_GENERATOR
-- Function: Carry select-like sum generator, used by Adder/Subtractor
-- Input: A, B (N-bit), Ci (N/4-bit)
-- Output: S (N-bit)
-- Architecture: structural
-- Library/package: ieee.std_logic_ll64, work.globals
-- Date: 14/04/2020
----------------------------------------------------------------------------------
library IEEE;
library work; 
use IEEE.std_logic_1164.all;
use work.globals.all;
 
entity SUM_GENERATOR is
    generic (
      WIDTH: integer:= word_size;
      RADIX: integer:= radix_size
    ); 
    port (A:    in	std_logic_vector(WIDTH-1 downto 0);
          B:    in	std_logic_vector(WIDTH-1 downto 0);
          Ci:   in	std_logic_vector((WIDTH/RADIX)-1 downto 0);
          S:    out	std_logic_vector(WIDTH-1 downto 0));
end entity; 

architecture STRUCTURAL of SUM_GENERATOR is
    -- Components
    component CSB is
        generic (RADIX: integer);
        port (A:    in	std_logic_vector(RADIX-1 downto 0);
              B:    in	std_logic_vector(RADIX-1 downto 0);
              Ci:   in	std_logic;
              S:    out	std_logic_vector(RADIX-1 downto 0));
    end component;
begin    
    GEN: for i in (WIDTH/RADIX)-1 downto 0 generate     
            CSBi: CSB
              generic map (RADIX)
              port map ( 
                A((3+RADIX*i) downto (RADIX*i)), B((3+RADIX*i) downto (RADIX*i)), Ci(i), S((3+RADIX*i) downto (RADIX*i)));
    end generate;
end architecture;