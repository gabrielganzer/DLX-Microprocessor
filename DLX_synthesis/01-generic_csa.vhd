----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: CSA
-- Function: Carry-save adder circuit
-- Input: A, B (N-bit), Ci (N-bit)
-- Output: S (N-bit), Co (N-bit)
-- Architecture: structural
-- Library/package: ieee.std_logic_ll64, work.globals
-- Date: 14/04/2020
----------------------------------------------------------------------------------
library IEEE;
library work;
use IEEE.std_logic_1164.all;
use work.globals.all;

entity CSA is
    generic (WIDTH: integer := radix_size);
    port (A	 :	in	std_logic_vector(WIDTH-1 downto 0);  -- Operand A
          B	 :	in	std_logic_vector(WIDTH-1 downto 0);  -- Operand B
          Ci	:	in	std_logic_vector(WIDTH-1 downto 0);  -- Carry incoming array
          S	 :	out	std_logic_vector(WIDTH-1 downto 0); -- Sum
          Co	:	out	std_logic_vector(WIDTH-1 downto 0)  -- Carry outgoing array
    );
end entity; 

architecture STRUCTURAL of CSA is
    -- Components
    component FA 
        port (A		:	in	std_logic;
              B		:	in	std_logic;
              Ci	:	in	std_logic;
              S		:	out	std_logic;
              Co	:	out	std_logic);
    end component; 
begin
    -- Co LSB always '0'
    Co(0) <= '0';
    -- Generate full-adders from LSB to MSB-1
    GEN: for i in 0 to WIDTH-2 generate
      FAi : FA 
        port map (A(i), B(i), Ci(i), S(i), Co(i+1)); 
    end generate;
    -- MSB full-adder
    FAth : FA 
        port map (A(WIDTH-1), B(WIDTH-1), Ci(WIDTH-1), S(WIDTH-1), open); 
end architecture;
