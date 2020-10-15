library IEEE;
use IEEE.std_logic_1164.all;

entity FORWARDING_UNIT is
  generic (LENGTH : integer := 5);
  port (RS1       : in std_logic_vector(LENGTH - 1 downto 0);
        RS2       : in std_logic_vector(LENGTH - 1 downto 0);
        RD_EX     : in std_logic_vector(LENGTH - 1 downto 0);
        RD_MEM    : in std_logic_vector(LENGTH - 1 downto 0);
        RF_WE_EX  : in std_logic;
        RF_WE_MEM : in std_logic;
        ForwardA  : out std_logic_vector (2 downto 0);
        ForwardB  : out std_logic_vector (2 downto 0);
        ForwardC  : out std_logic_vector (2 downto 0);
        ForwardD  : out std_logic);
end entity;

architecture BEHAVIORAL of FORWARDING_UNIT is

  constant ZERO: std_logic_vector(LENGTH -1 downto 0) := (others => '0');

begin

    ForwardA <= "100" when (RF_WE_EX = '1' and RS1 = RD_EX and RD_EX /= ZERO) else
                "010" when (RF_WE_MEM = '1' and RD_MEM /= ZERO and RS1 /= RD_EX and RS1 = RD_MEM) else
                "001"; 
    ForwardB <= "100" when (RF_WE_EX = '1' and RS2 = RD_EX and RD_EX /= ZERO) else
                "010" when (RF_WE_MEM = '1' and RD_MEM /= ZERO and RS2 /= RD_EX and RS2 = RD_MEM) else
                "001"; 
    ForwardC <= "100" when (RF_WE_EX = '1' and RS1 = RD_EX and RD_EX /= ZERO) else
                "010" when (RF_WE_MEM = '1' and RD_MEM /= ZERO and RS1 /= RD_EX and RS1 = RD_MEM) else
                "001"; 
    ForwardD <= '1' when (RF_WE_MEM = '1' and RS2 = RD_MEM and RD_MEM /= ZERO) else '0';

end architecture;
