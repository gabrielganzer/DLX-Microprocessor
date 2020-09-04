----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: SIGN_EXTEND
-- Function: Immediate sign extension from 16-bit into 32-bit
-- Input: IMMU (16-bit)
-- Output: IMMS (32-bit)
-- Architecture: rtl
-- Library/package: ieee.std_logic_ll64
-- Date: 05/08/2020
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity SIGN_EXTEND is
  port (
    IMMU : in std_logic_vector(15 downto 0);    
    IMMS : out std_logic_vector(31 downto 0)
  );
end entity;

architecture RTL of SIGN_EXTEND is
begin
	IMMS <= (31 downto 16 => IMMU(15)) & IMMU;
end architecture;
