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

entity TB_LOGIC is
end entity;

architecture BEHAVIORAL of TB_LOGIC is
  -- Components
  component LOGIC
  generic (WIDTH: integer := 32);
  port (
    R1, R2         : in  std_logic_vector(WIDTH-1 downto 0);
    S0, S1, S2, S3 : in  std_logic;
    Y              : out std_logic_vector(WIDTH-1 downto 0)
  );
  end component;
  -- Constants
  constant WIDTH: integer := 32;
  -- Signals
  signal s_R1, s_R2, s_Y        : std_logic_vector(WIDTH-1 downto 0);
  signal s_S0, s_S1, s_S2, s_S3 : std_logic;
begin
  --UUT
  LOGIC_UNIT: LOGIC
    generic map(32)
    port map(s_R1, s_R2, s_S0, s_S1, s_S2, s_S3, s_Y);

  STIMULI: process
    begin
      s_R1 <= x"00000000";
      s_R2 <= x"00000000";
      s_S0 <= '0';
      s_S1 <= '0'; 
      s_S2 <= '0'; 
      s_S3 <= '0';
      wait for 10 ns;
      -- AND
      s_R1 <= x"00000001";
      s_R2 <= x"00000002";
      s_S0 <= '0';
      s_S1 <= '0'; 
      s_S2 <= '0'; 
      s_S3 <= '1';
      wait for 10 ns;
      -- NAND
      s_S0 <= '1';
      s_S1 <= '1'; 
      s_S2 <= '1'; 
      s_S3 <= '0';
      wait for 10 ns;
      -- OR
      s_S0 <= '0';
      s_S1 <= '1'; 
      s_S2 <= '1'; 
      s_S3 <= '1';
      wait for 10 ns;
      -- NOR
      s_S0 <= '1';
      s_S1 <= '0'; 
      s_S2 <= '0'; 
      s_S3 <= '0';
      wait for 10 ns;
      -- XOR
      s_S0 <= '0';
      s_S1 <= '1'; 
      s_S2 <= '1'; 
      s_S3 <= '0';
      wait for 10 ns;
      -- XNOR
      s_S0 <= '1';
      s_S1 <= '0'; 
      s_S2 <= '0'; 
      s_S3 <= '1';
      wait for 10 ns;
      s_R1 <= x"00000000";
      s_R2 <= x"00000000";
      s_S0 <= '0';
      s_S1 <= '0'; 
      s_S2 <= '0'; 
      s_S3 <= '0';
      wait;
  end process;

end architecture;