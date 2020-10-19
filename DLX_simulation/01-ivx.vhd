----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: IVX
-- Function: Inverter logic gate, for accurate placement
-- Input: A (1-bit)
-- Output: Y (1-bit)
-- Architecture: RTL
-- Library/package: ieee.std_logic_ll64
-- Date: 02/08/2020
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity IVX is
  port(
    A : in  std_logic;
    Y : out std_logic
  );
end entity;

architecture RTL of IVX is
  begin
    Y <= not A;
end architecture;
