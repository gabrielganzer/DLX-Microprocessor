----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: BLOCKG
-- Function: General propagate block
-- Input: pik, gik, gk_1j (1-bit)
-- Output: gij (1-bit)
-- Architecture: dataflow
-- Library/package: ieee.std_logic_ll64
-- Date: 14/04/2020
----------------------------------------------------------------------------------
library IEEE; 
use IEEE.std_logic_1164.all; 

entity BLOCKG is 
    port (pik:    in std_logic;
        gik:    in std_logic;
        gk_1j:  in std_logic;
        gij:    out std_logic);
end entity;

architecture RTL of BLOCKG is  
begin
    -- Bitwise sum and multiplication    
    gij <= gik or (pik and gk_1j);
end architecture;