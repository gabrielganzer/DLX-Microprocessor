----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: COMPARATOR
-- Function: ALU-based comparator
-- Input: Z, C (1-bit)
-- Output: LE, LT, GE, GT, EQ (1-bit)
-- Architecture: rtl
-- Library/package: ieee.std_logic_ll64
-- Date: 05/08/2020
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity COMPARATOR is
  generic (WIDTH: integer := 32);
  port (
    Z, C               : in  std_logic;
    LE, LT, GE, GT, EQ : out std_logic
  );
end entity;

architecture RTL of COMPARATOR is
  -- Components
  component IVX
  port(
    A : in  std_logic;
    Y : out std_logic
  );
  end component;
  component AND2
  port(
    A, B : in  std_logic;
    Y 	  : out std_logic
  );
  end component;
  component OR2
  port(
    A, B : in  std_logic;
    Y 	  : out std_logic
  );
  end component;
  -- Signals
  signal negZ, negC: std_logic;
begin
  -- Component instantiation
  IVX_Z: IVX port map (Z, negZ);
  IVX_C: IVX port map (C, negC);
  OR_LE: OR2 port map (negC, Z, LE);
  AND_GT: AND2 port map (C, negZ, GT);
  -- Output assignment
  LT <= negC;
  GE <= C;
  EQ <= Z;
end architecture;
