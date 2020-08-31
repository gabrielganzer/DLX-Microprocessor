----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: ADDER_SUBTRACTOR
-- Function: P4 adder circuit
-- Input: A, B (N-bit), Ci_array (1-bit)
-- Output: Co (1-bit)
-- Architecture: structural
-- Library/package: ieee.std_logic_ll64, work.CONSTANTS
-- Date: 14/04/2020
----------------------------------------------------------------------------------
library IEEE;
library work;
use IEEE.std_logic_1164.all;
use work.globals.all;

entity ADDER_SUBTRACTOR is
    generic (
      WIDTH: integer:= word_size;
      RADIX: integer:= radix_size
    );
    port (A:    in	std_logic_vector(WIDTH-1 downto 0);
          B:    in	std_logic_vector(WIDTH-1 downto 0);
          Ci:   in	std_logic;
          S:    out	std_logic_vector(WIDTH-1 downto 0);
          Co:   out std_logic);
end entity;

architecture STRUCTURAL of ADDER_SUBTRACTOR is
    -- Components
    component SPARSE_TREE is
        generic (WIDTH: integer:= 32;
                 RADIX: integer := 4);
        port(A:   in std_logic_vector(WIDTH-1 downto 0);
             B:   in std_logic_vector(WIDTH-1 downto 0);
             Ci:  in std_logic;
             Co:  out std_logic_vector((WIDTH/RADIX)-1 downto 0));		  
    end component;
    component SUM_GENERATOR is
        generic (WIDTH: integer:= 32;
                 RADIX: integer := 4);
        port (A:    in	std_logic_vector(WIDTH-1 downto 0);
              B:    in	std_logic_vector(WIDTH-1 downto 0);
              Ci:   in	std_logic_vector((WIDTH/RADIX)-1 downto 0);
              S:    out	std_logic_vector(WIDTH-1 downto 0));
    end component;
    -- Signals   
	signal carry_ST : std_logic_vector(WIDTH/RADIX-1 downto 0);
	signal carry_SG : std_logic_vector(WIDTH/RADIX-1 downto 0);
begin
 	-- Instantiation of sparse tree
	SPARSETREE: SPARSE_TREE
	  generic map (32, 4)  
	  port map (A, B, Ci, carry_ST);
	-- Carry out assignment and carry array passed to the sum generator
	Co <= carry_ST((WIDTH/RADIX)-1);
  carry_SG <= carry_ST((WIDTH/RADIX)-2 downto 0)&Ci;
  -- Instantiation of carry select
	SUMGEN: SUM_GENERATOR
	  generic map (32, 4) 
    port map (A, B, carry_SG, S);
   
end architecture;