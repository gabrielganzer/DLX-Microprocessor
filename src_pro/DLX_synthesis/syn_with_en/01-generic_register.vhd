----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: REGISTER_GENERIC
-- Function: Generic Register (Synchronous reset, active-high enable)
-- Input: CLK, RST, EN (1-bit)
--        DIN (N-bit)
-- Output: DOUT (N-bit)
-- Architecture: behavioral
-- Library/package: ieee.std_logic_ll64
-- Date: 05/08/2020
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity REGISTER_GENERIC is
  generic (WIDTH: integer := 32);
  port (
    -- Inputs
    CLK  : in std_logic;
    RST  : in std_logic;  -- Synchronous reset, active-low
    EN   : in std_logic;  -- Active-high enable
    DIN  : in std_logic_vector(WIDTH-1 downto 0);    
    -- Output
    DOUT : out std_logic_vector(WIDTH-1 downto 0)
  );
end entity;

architecture BEHAVIORAL of REGISTER_GENERIC is
begin
	
  process(CLK)
  begin	
    if(CLK = '1' and CLK'EVENT) then
      if(RST = '0') then
        DOUT <= (others => '0');
      else 
        if (EN = '1') then
          DOUT <= DIN;
        end if;
      end if;
    end if;
  end process;

end architecture;