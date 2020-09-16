----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: COARSE_SHIFT
-- Function: T2 shifter 2nd level coarse grain shift, mask select (32-bit)
-- 00 SLL SLLI
-- 01 SRL SRLI
-- 10 SRA SRAI
-- Input: sel (2-bit), mask00, mask08, mask16 (39-bit)
-- Output: y (39-bit)
-- Architecture: behavioral
-- Library/package: ieee.std_logic_ll64
-- Date: 14/04/2020
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity COARSE_SHIFT is
  port (
    SEL    : in std_logic_vector(1 downto 0);
    MASK00 : in std_logic_vector(38 downto 0);
    MASK08 : in std_logic_vector(38 downto 0);
    MASK16 : in std_logic_vector(38 downto 0);
    Y      : out std_logic_vector(38 downto 0)
  );
end entity;

architecture BEHAVIORAL of COARSE_SHIFT is
begin 

  -- Select appropriate mask according to select signal, extracted
  -- from the operand R2
  MASK_SELECTION: process(SEL, MASK00, MASK08, MASK16)
	begin		
		case SEL is
			when "00" =>
				Y <= MASK00;
			when "01" =>
				Y <= MASK08;
			when "10" =>
				Y <= MASK16;
			when others => 
			  Y <= (others => '0');
		end case;
	end process;
	
end architecture;