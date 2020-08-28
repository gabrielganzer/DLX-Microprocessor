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
use IEEE.std_logic_1164.all;
use work.CONSTANTS.all; 

entity RCA is
    generic (NBIT: integer := STEP);
    port (A:    in	std_logic_vector(NBIT-1 downto 0);
          B:    in	std_logic_vector(NBIT-1 downto 0);
          Ci:   in	std_logic;
          S:    out	std_logic_vector(NBIT-1 downto 0);
          Co:	out	std_logic);
end entity; 

architecture STRUCTURAL of RCA is
    -- Components
    component FA 
        port (A:	in	std_logic;
              B:	in	std_logic;
              Ci:	in	std_logic;
              S:	out	std_logic;
              Co:	out	std_logic);
    end component; 
    --Signals
    signal STMP : std_logic_vector(NBIT-1 downto 0);
    signal CTMP : std_logic_vector(NBIT downto 0);
begin
    -- Instatiations
    CTMP(0) <= Ci;
    S <= STMP;
    Co <= CTMP(NBIT);
    -- Full-adders row
    ADDER1: for i in 1 to NBIT generate
    FAI : FA port map (
        A(i-1), B(i-1), CTMP(i-1), STMP(i-1), CTMP(i)); 
    end generate;
end architecture;
