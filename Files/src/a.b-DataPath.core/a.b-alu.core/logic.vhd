----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: LOGIC
-- Function: T2 logical unit to perform logic AND, NAND, OR, NOR, XOR, XNOR
-- Input: R1, R2 (32-bit)
-- Output: Y (32-bit)
-- Architecture: rtl
-- Library/package: ieee.std_logic_ll64
-- Date: 05/08/2020
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity LOGIC is
  generic (WIDTH: integer := 32);
  port (
    -- Inputs
    R1, R2         : in  std_logic_vector(WIDTH-1 downto 0); -- Operands
    S0, S1, S2, S3 : in  std_logic; -- Operation select signal
    -- Output
    Y              : out std_logic_vector(WIDTH-1 downto 0)
  );
end entity;

architecture RTL of LOGIC is
  -- Components
  component IVX
  port(
    A : in  std_logic;
    Y : out std_logic
  );
  end component;
  component NAND3
  port(
    A,B,C : in  std_logic;
    Y 	: out std_logic
  );
  end component;
  component NAND4
  port(
    A,B,C,D : in  std_logic;
    Y 	: out std_logic
  );
  end component;
  -- Signals
  signal negR1, negR2, L0, L1, L2, L3: std_logic_vector(WIDTH-1 downto 0);
begin
  
  -- Operators bitwise negation
  IVX_R1: for i in 0 to WIDTH-1 generate
    IVX_i: IVX port map(R1(i), negR1(i));
  end generate;
  IVX_R2: for i in 0 to WIDTH-1 generate
    IVX_i: IVX port map(R2(i), negR2(i));
  end generate;
  
  -- Bitwise nand between operators and selec signals
  NAND_L0: for i in 0 to WIDTH-1 generate
    NAND3_0i: NAND3 port map(negR1(i), negR2(i), S0, L0(i));
  end generate;
  NAND_L1: for i in 0 to WIDTH-1 generate
    NAND3_1i: NAND3 port map(negR1(i), R2(i), S1, L1(i));
  end generate;
  NAND_L2: for i in 0 to WIDTH-1 generate
    NAND3_2i: NAND3 port map(R1(i), negR2(i), S2, L2(i));
  end generate;
  NAND_L3: for i in 0 to WIDTH-1 generate
    NAND3_3i: NAND3 port map(R1(i), R2(i), S3, L3(i));
  end generate;
  
  -- Final bitwise nand between intermediate signals
  NAND_Y: for i in 0 to WIDTH-1 generate
    NAND4_i: NAND4 port map(L0(i), L1(i), L2(i), L3(i), Y(i));
  end generate;
end architecture;