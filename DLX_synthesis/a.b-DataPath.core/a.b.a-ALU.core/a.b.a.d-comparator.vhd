----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: COMPARATOR
-- Function: ALU-based comparator
-- Input: Z, C (1-bit)
-- Output: LE, LT, GE, GT, EQ (1-bit)
-- Architecture: RTL
-- Library/package: ieee.std_logic_ll64
-- Date: 05/08/2020
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity COMPARATOR is
  port (
    Z  : in  std_logic; -- Zero detector input
    C  : in  std_logic; -- Carry outgoing from adder
    LE : out std_logic; -- A <= B
    LT : out std_logic; -- A < B
    GE : out std_logic; -- A >= B
    GT : out std_logic; -- A > B
    EQ : out std_logic; -- A == B
    NE : out std_logic  -- A /= B
  );
end entity;

architecture RTL of COMPARATOR is
begin
  -- Output assignment
  LE <= ((not C) or Z);
  LT <= not C;
  GE <= C;
  GT <= (C and (not Z));
  EQ <= Z;
  NE <= not Z;
end architecture;
