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

entity TB_SHIFTER is
end entity;

architecture BEHAVIORAL of TB_SHIFTER is
  -- Components
  component SHIFTER
  generic (WIDTH: integer := 32);
  port (
    R1, R2         : in  std_logic_vector(WIDTH-1 downto 0);
    SEL            : in std_logic_vector(1 downto 0);
    Y              : out std_logic_vector(WIDTH-1 downto 0)
  );
  end component;
  -- Constants
  constant WIDTH: integer := 32;
  -- Signals
  signal s_R1, s_R2, s_Y : std_logic_vector(WIDTH-1 downto 0);
  signal s_SEL           : std_logic_vector(1 downto 0);
begin
  --UUT
  SHIFTER_UNIT: SHIFTER
    generic map(32)
    port map(s_R1, s_R2, s_SEL, s_Y);

  STIMULI: process
    begin
      -- Initial condition
      s_R1  <= x"00000000";
      s_R2  <= x"00000000";
      s_SEL <= "11";
      wait for 10 ns;
      s_R1  <= x"700000F0";
      s_R2  <= x"0000001F";
      s_SEL <= "00";
      wait for 10 ns;
      s_SEL <= "01";
      wait for 10 ns;
      s_SEL <= "10";
      wait for 10 ns;
      s_R1  <= x"800000F0";
      s_R2  <= x"0000001F";
      s_SEL <= "00";
      wait for 10 ns;
      s_SEL <= "01";
      wait for 10 ns;
      s_SEL <= "10";
      wait for 10 ns;
      wait;
  end process;

end architecture;