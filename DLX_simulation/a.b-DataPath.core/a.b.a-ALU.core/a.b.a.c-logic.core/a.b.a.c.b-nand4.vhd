----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: NAND4
-- Function: 4-input nand logic gate, used by Logic Unit
-- Input: A,B,C,D (1-bit)
-- Output: Y (1-bit)
-- Architecture: structural
-- Library/package: ieee.std_logic_ll64
-- Date: 02/08/2020
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity NAND4 is
  port(
    A,B,C,D : in  std_logic;
    Y 	: out std_logic
  );
end entity;

architecture STRUCTURAL of NAND4 is
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
  signal E, F, G, H: std_logic;
begin
  NAND_E  : NAND2 port map (A, B, E);
  NAND_F  : NAND2 port map (C, D, F);
  IVX_G   : IVX port map (E, G);
  IVX_H   : IVX port map (F, H);
  NAND_Y  : NAND2 port map (G, H, Y);
end architecture;
