----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: NAND3
-- Function: 3-input nand logic gate, used by Logic Unit
-- Input: A,B,C (1-bit)
-- Output: Y (1-bit)
-- Architecture: structural
-- Library/package: ieee.std_logic_ll64
-- Date: 02/08/2020
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity NAND3 is
  port(
    A,B,C : in  std_logic;
    Y 	   : out std_logic
  );
end entity;

architecture STRUCTURAL of NAND3 is
  -- Components
  component IVX
  port(
    A : in  std_logic;
    Y : out std_logic
  );
  end component;
  component NAND2
  port(
    A,B : in  std_logic;
    Y 	: out std_logic
  );
  end component;
  -- Signals
  signal D, E: std_logic;
begin
  NAND_D  : NAND2 port map (A, B, D);
  IVX_E   : IVX port map (D, E);
  NAND_Y  : NAND2 port map (E, C, Y);
end architecture;
