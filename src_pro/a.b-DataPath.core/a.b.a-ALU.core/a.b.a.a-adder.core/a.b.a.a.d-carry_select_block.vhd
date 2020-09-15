----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: CARRY_SELECT_BLOCK
-- Function: carry select block
-- Input: A,B (4-bit), Ci (1-bit)
-- Output: S (4-bit)
-- Architecture: structural
-- Library/package: ieee.std_logic_ll64
-- Date: 14/04/2020
----------------------------------------------------------------------------------
library IEEE;
library work; 
use IEEE.std_logic_1164.all;
use work.globals.all; 

entity CSB is
    generic (RADIX: integer := radix_size);
    port (A:    in	std_logic_vector(RADIX-1 downto 0);
          B:    in	std_logic_vector(RADIX-1 downto 0);
          Ci:   in	std_logic;
          S:    out	std_logic_vector(RADIX-1 downto 0));
end entity; 

architecture STRUCTURAL of CSB is
    -- Components
    component RCA
        generic (WIDTH: integer := word_size);
        port (A:    in	std_logic_vector(WIDTH-1 downto 0);
              B:    in	std_logic_vector(WIDTH-1 downto 0);
              Ci:   in	std_logic;
              S:    out	std_logic_vector(WIDTH-1 downto 0);
              Co:	out	std_logic);
    end component;
    component MUX21_GENERIC
	      generic (NBIT: integer:= 4);
	      port (S1:	in 	std_logic_vector(NBIT-1 downto 0);
	            S0:	in	std_logic_vector(NBIT-1 downto 0);
	            SEL:	in	std_logic;
	            Y:	out	std_logic_vector(NBIT-1 downto 0));
    end component;
    --Signals
    signal S0, S1: std_logic_vector(RADIX-1 downto 0) := (others => '0');
begin
    -- Instatiations
    RCA0: RCA
      generic map(RADIX) 
      port map(A, B, '0', S0);
    RCA1: RCA
      generic map(RADIX) 
      port map(A, B, '1', S1);
    MUX21_SUM: MUX21_GENERIC 
      generic map(RADIX)
      port map(S1, S0, Ci, S);
end architecture;