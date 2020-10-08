----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: FORWARDING_UNIT
-- Function: Data Hazard control and forwarding
-- Input:
-- Output:
-- Architecture: behavioral
-- Library/package: ieee.std_logic_ll64, work.globals
-- Date: 12/08/2020
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity FORWARDING_UNIT is
  generic (WIDTH : integer := 32;
           LENGTH : integer := 5);
  port (
    CLK : in std_logic;
    RST : in std_logic; --active low
    RS1 : in std_logic_vector(LENGTH - 1 downto 0);
    RS2 : in std_logic_vector(LENGTH - 1 downto 0);
    RD3  : in std_logic_vector(LENGTH - 1 downto 0);
    RD4  : in std_logic_vector(LENGTH - 1 downto 0);
    RF_WE3 : in std_logic;
    RF_WE4 : in std_logic;
    ForwardA : out std_logic_vector (2 downto 0);
    ForwardB : out std_logic_vector (2 downto 0);
    ForwardC : out std_logic_vector (2 downto 0);
    ForwardD : out std_logic);
end entity;

architecture BEHAVIORAL of FORWARDING_UNIT is

  signal RS1_ID, RS1_EX : std_logic_vector (LENGTH -1 downto 0);
  signal RS2_ID, RS2_EX : std_logic_vector (LENGTH -1 downto 0);
  constant ZERO: std_logic_vector(LENGTH -1 downto 0) := (others => '0');

begin

    REG_PROC: PROCESS (CLK, RST)
    begin
        if (RST = '0') then
          RS1_ID <= (others => '0');
          RS2_ID <= (others => '0');
        elsif (CLK = '1' and CLK'event) then
          RS1_ID <= RS1;
          RS2_ID <= RS2;
          RS1_EX <= RS1_ID;
          RS2_EX <= RS2_ID;
        end if;
    end process;


    ForwardA <= "001" when ((RF_WE3 = '1') and (RS1_ID = RD3) and (RS1_ID /= ZERO)) else
                "010" when ((RF_WE4 = '1') and (RS1_ID = RD4) and (RS1_ID /= ZERO) and ((RS1_ID /= RD3) or (RF_WE3 = '0'))) else
                "100"; 
    ForwardB <= "001" when ((RF_WE3 = '1') and (RS2_ID = RD3) and (RS2_ID /= ZERO)) else
                "010" when ((RF_WE4 = '1') and (RS2_ID = RD4) and (RS2_ID /= ZERO) and ((RS2_ID /= RD3) or (RF_WE3 = '0'))) else
                "100"; 
    ForwardC <= "001" when ((RF_WE3 = '1') and (RS1 = RD3) and (RS1 /= ZERO)) else
                "010" when ((RF_WE4 = '1') and (RS1 = RD4) and (RS1 /= ZERO) and ((RS1 /= RD3) or (RF_WE3 ='0'))) else
                "100";
    ForwardD <= '1' when ((RF_WE4 = '1') and (RS2_EX = RD4) and (RS2_EX /= ZERO)) else '0';

end architecture;
