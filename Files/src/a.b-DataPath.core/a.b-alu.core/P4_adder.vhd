----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: P4ADDER
-- Function: P4 adder circuit
-- Input: A, B (N-bit), Ci_array (1-bit)
-- Output: Co (1-bit)
-- Architecture: structural
-- Library/package: ieee.std_logic_ll64, work.CONSTANTS
-- Date: 14/04/2020
----------------------------------------------------------------------------------
library IEEE; 
use IEEE.std_logic_1164.all;
use work.CONSTANTS.all;

entity P4ADDER is
    generic (NBIT: integer:= WIDTH);
    port (A:    in	std_logic_vector(NBIT-1 downto 0);
          B:    in	std_logic_vector(NBIT-1 downto 0);
          Ci:   in	std_logic;
          S:    out	std_logic_vector(NBIT-1 downto 0);
          Co:   out std_logic);
end entity;

architecture STRUCTURAL of P4ADDER is
    -- Components
    component SPARSETREE is
        generic (NBIT: integer:= WIDTH;
                 RADIX: integer := STEP);
        port(A:   in std_logic_vector(NBIT-1 downto 0);
             B:   in std_logic_vector(NBIT-1 downto 0);
             Ci:  in std_logic;
             Co:  out std_logic_vector((NBIT/RADIX)-1 downto 0));		  
    end component;
    component SUMGEN is
        generic (NBIT: integer:= WIDTH;
                 RADIX: integer := STEP);
        port (A:    in	std_logic_vector(NBIT-1 downto 0);
              B:    in	std_logic_vector(NBIT-1 downto 0);
              Ci:   in	std_logic_vector((NBIT/RADIX)-1 downto 0);
              S:    out	std_logic_vector(NBIT-1 downto 0));
    end component;
    -- Constants
    constant RADIX: integer := STEP; 
    -- Signals   
	signal carry_ST : std_logic_vector(NBIT/RADIX-1 downto 0);
	signal carry_SG : std_logic_vector(NBIT/RADIX-1 downto 0);
begin
 	-- Instantiation of sparse tree
	SPARSETREE0: SPARSETREE
	  generic map (WIDTH, STEP)  
	  port map (A, B, Ci, carry_ST);
	-- Carry out assignment and carry array passed to the sum generator
	Co <= carry_ST((NBIT/RADIX)-1);
  carry_SG <= carry_ST((NBIT/RADIX)-2 downto 0)&Ci;
  -- Instantiation of carry select
	SUMGEN0: SUMGEN
	  generic map (WIDTH, STEP) 
    port map (A, B, carry_SG, S);
   
end architecture;