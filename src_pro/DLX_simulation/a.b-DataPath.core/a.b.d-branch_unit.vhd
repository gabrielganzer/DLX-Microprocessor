----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: BRANCH_UNIT
-- Function: Static branch predictor always taken
-- Input:
-- Output:
-- Architecture: behavioral
-- Library/package: ieee.std_logic_ll64, work.globals
-- Date: 12/08/2020
----------------------------------------------------------------------------------
library ieee;
library work;
use ieee.std_logic_1164.all;
use work.globals.all;

entity BRANCH_UNIT is
  generic(WIDTH : integer := word_size);
  port( Z       : in std_logic;	-- Zero? Block Result
        EQ_COND : in std_logic; -- 1 for BEQZ, 0 for BNEZ
        JUMP_EN : in std_logic;
        BRANCH  : out std_logic);
end entity;

architecture RTL of BRANCH_UNIT is
begin
 
  BRANCH <= (Z xnor EQ_COND) and JUMP_EN;

end architecture;
