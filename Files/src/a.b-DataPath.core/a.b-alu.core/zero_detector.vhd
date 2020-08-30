----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: ZERO_DETECTOR
-- Function: Zero equivalence block
-- Input:  A (32-bit)
-- Output: Y (1-bit)
-- Architecture: rtl
-- Library/package: ieee.std_logic_ll64
-- Date: 05/08/2020
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity ZERO_DETECTOR is
  port (
    A              : in  std_logic_vector(31 downto 0);
    Y              : out std_logic
  );
end entity;

architecture RTL of ZERO_DETECTOR is
begin
  Y <= '1' when A = x"00000000" else '0';
end architecture;
