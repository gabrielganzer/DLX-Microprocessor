----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Description: constants used throughout the project
-- Date: 14/04/2020
----------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.all; 

package CONSTANTS is 
   constant NBIT : integer := 32;
   constant WIDTH : integer := 32;
   constant STEP : integer := 4;	
   subtype reg is std_logic_vector(NBIT downto 0); -- a byte 
        type reg_array is array ((NBIT/2)-1 downto 0) of reg; -- array of bytes 
end package; 

package body constants is 
end constants;
