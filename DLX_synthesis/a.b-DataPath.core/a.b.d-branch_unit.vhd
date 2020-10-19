----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: BRANCH_UNIT
-- Function: Static branch predictor, always taken
-- Input: ENABLE, Z, JUMP_EN, JUMP_EQ, JUMP_REG, JUMP_LINK (1-bit)
-- Output: BRANCH (1-bit)
-- Architecture: RTL
-- Library/package: ieee.std_logic_ll64, work.globals
-- Date: 12/08/2020
----------------------------------------------------------------------------------
library ieee;
library work;
use ieee.std_logic_1164.all;
use work.globals.all;

entity BRANCH_UNIT is
  port(ENABLE	   : in std_logic; -- Flush signal from CU
       Z         : in std_logic; -- Zero? block result
       JUMP_EN   : in std_logic; -- 1 J, 0 otherwise
       JUMP_EQ   : in std_logic; -- 1 BEQZ, 0 BNEZ
       JUMP_REG  : in std_logic; -- 1 JR and JALR, 0 otherwise
       JUMP_LINK : in std_logic; -- 1 JAL and JALR, 0 otherwise
       BRANCH    : out std_logic);
end entity;

architecture RTL of BRANCH_UNIT is
begin
  
  -- Branch T/NT assignment
  BRANCH <= '1' when (JUMP_EN = '1' and ENABLE = '1') else
            '1' when (JUMP_EQ = '1' and Z = '0' and ENABLE = '1') else
            '1' when (JUMP_EQ = '0' and Z = '1' and ENABLE = '1') else
            '1' when (JUMP_REG = '1' and ENABLE = '1') or (JUMP_LINK = '1' and ENABLE = '1') else
            '0';
end architecture;
