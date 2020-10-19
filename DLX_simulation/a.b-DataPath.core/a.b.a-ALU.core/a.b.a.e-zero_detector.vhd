----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: ZERO_DETECTOR
-- Function: Zero equivalence block
-- Input:  A (32-bit)
-- Output: Y (1-bit)
-- Architecture: rtl
-- Library/package: ieee.std_logic_ll64, ieee.numeric_std, work.globals
-- Date: 05/08/2020
----------------------------------------------------------------------------------
library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.globals.all;

entity ZERO_DETECTOR is
  generic (WIDTH : integer:= word_size);
  port (
    A              : in  std_logic_vector(WIDTH-1 downto 0);
    Y              : out std_logic
  );
end entity;

architecture RTL of ZERO_DETECTOR is
begin
  Y <= '1' when A = std_logic_vector(to_unsigned(0, A'length)) else '0';
end architecture;
