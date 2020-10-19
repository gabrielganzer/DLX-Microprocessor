----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: FORWARDING_UNIT
-- Function: Forward operands as a data hazard solution
-- Input: RS1, RS2, RD_EX, RD_MEM (N-bit); RF_WE_EX, RF_WE_MEM (1-bit)
-- Output: ForwardA, ForwardB, ForwardC (3-bit); ForwardD (1-bit)
-- Architecture: RTL
-- Library/package: ieee.std_logic_ll64
-- Date: 14/04/2020
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity FORWARDING_UNIT is
  generic (LENGTH : integer := 5);
  port (RS1       : in std_logic_vector(LENGTH - 1 downto 0); -- Source address Operand A
        RS2       : in std_logic_vector(LENGTH - 1 downto 0); -- Source address Operand B
        RD_EX     : in std_logic_vector(LENGTH - 1 downto 0); -- Destination address at execution stage
        RD_MEM    : in std_logic_vector(LENGTH - 1 downto 0); -- Destination address at memory access stage
        RF_WE_EX  : in std_logic;                             -- Write to RF control signal at execution stage
        RF_WE_MEM : in std_logic;                             -- Write to RF control signal at memory accesss stage
        ForwardA  : out std_logic_vector (2 downto 0);        -- Forward operand A
        ForwardB  : out std_logic_vector (2 downto 0);        -- Forward operand B
        ForwardC  : out std_logic_vector (2 downto 0);        -- Forward operand A to branch unit
        ForwardD  : out std_logic);                           -- Forward operand B to data memory
end entity;

architecture RTL of FORWARDING_UNIT is

  constant ZERO: std_logic_vector(LENGTH -1 downto 0) := (others => '0');

begin

    ForwardA <= "100" when (RF_WE_EX = '1' and RS1 = RD_EX and RD_EX /= ZERO) else                      -- Forward from ALU result at write-back stage
                "010" when (RF_WE_MEM = '1' and RD_MEM /= ZERO and RS1 /= RD_EX and RS1 = RD_MEM) else  -- Forward from ALU result at memory access stage
                "001";                                                                                  -- Forward from RF (regular case)
    ForwardB <= "100" when (RF_WE_EX = '1' and RS2 = RD_EX and RD_EX /= ZERO) else
                "010" when (RF_WE_MEM = '1' and RD_MEM /= ZERO and RS2 /= RD_EX and RS2 = RD_MEM) else
                "001"; 
    ForwardC <= "100" when (RF_WE_EX = '1' and RS1 = RD_EX and RD_EX /= ZERO) else
                "010" when (RF_WE_MEM = '1' and RD_MEM /= ZERO and RS1 /= RD_EX and RS1 = RD_MEM) else
                "001"; 
    ForwardD <= '1' when (RF_WE_MEM = '1' and RS2 = RD_MEM and RD_MEM /= ZERO) else '0';

end architecture;
