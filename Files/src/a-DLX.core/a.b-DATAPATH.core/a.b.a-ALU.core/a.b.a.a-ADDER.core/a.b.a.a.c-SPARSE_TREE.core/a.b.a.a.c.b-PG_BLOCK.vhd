----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: BLOCKPG
-- Function: General generate block
-- Input: pik, gik, gk_1j, pk_1j (1-bit)
-- Output: gij, pij (1-bit)
-- Architecture: dataflow
-- Library/package: ieee.std_logic_ll64
-- Date: 14/04/2020
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity BLOCKPG is  
    port (
      pik:    in std_logic;
      gik:    in std_logic;
      gk_1j:  in std_logic;
      pk_1j:  in std_logic;
      gij:    out std_logic;
      pij:    out std_logic
    );
end entity;

architecture RTL of BLOCKPG is
begin
    -- Bitwise sum and multiplication    
    gij <= gik or (pik and gk_1j);
    -- Bitwise multiplication   
    pij <= pik and pk_1j;
end architecture;