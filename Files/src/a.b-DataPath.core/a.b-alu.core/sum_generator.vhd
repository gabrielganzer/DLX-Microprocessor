----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: CARRYSEL
-- Function: Carry select-like sum generator circuit
-- Input: A, B (M-bit), Ci_array (M-bit)
-- Output: S (N-bit)
-- Architecture: structural
-- Library/package: ieee.std_logic_ll64
-- Date: 14/04/2020
----------------------------------------------------------------------------------
library IEEE; 
use IEEE.std_logic_1164.all; 
use work.CONSTANTS.all;
 
entity SUMGEN is
    generic (NBIT: integer:= WIDTH;
             RADIX: integer := STEP); 
    port (A:    in	std_logic_vector(NBIT-1 downto 0);
          B:    in	std_logic_vector(NBIT-1 downto 0);
          Ci:   in	std_logic_vector((NBIT/RADIX)-1 downto 0);
          S:    out	std_logic_vector(NBIT-1 downto 0));
end entity; 

architecture STRUCTURAL of SUMGEN is
    -- Components
    component CSB is
        generic (RADIX: integer := STEP);
        port (A:    in	std_logic_vector(RADIX-1 downto 0);
              B:    in	std_logic_vector(RADIX-1 downto 0);
              Ci:   in	std_logic;
              S:    out	std_logic_vector(RADIX-1 downto 0));
    end component;
begin    
    CSB_i: for i in (NBIT/RADIX)-1 downto 0 generate     
            GENi: CSB
              generic map (RADIX)
              port map ( 
                A((3+RADIX*i) downto (RADIX*i)), B((3+RADIX*i) downto (RADIX*i)), Ci(i), S((3+RADIX*i) downto (RADIX*i)));
    end generate;
end architecture;