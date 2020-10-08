----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: FINE_SHIFT
-- Function: T2 shifter 3rd level fine grain shift, bitwise
-- Input: op (39-bit), sel (3-bit)
-- Output: shifted (32-bit)
-- Architecture: structural
-- Library/package: ieee.std_logic_ll64
-- Date: 14/04/2020
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity FINE_SHIFT is
  port (
    -- Inputs
    op      : in std_logic_vector(38 downto 0); -- Operand to be shifted R1
    sel     : in std_logic_vector(2 downto 0);  -- Number of bits to shift R2
    -- Output
    shifted : out std_logic_vector(31 downto 0) -- Result
  );
end entity;

architecture BEHAVIORAL of FINE_SHIFT is
begin 

  -- Shift bit by bit according to select signal, extracted
  -- from the operand R2
  BITWISE_SHIFT: process(sel, op)
	begin
		case sel is
			when "000" =>
				shifted <= op(38 downto 7);
			when "001" =>
				shifted <= op(37 downto 6);
			when "010" =>
				shifted <= op(36 downto 5);
			when "011" => 
				shifted <= op(35 downto 4);
			when "100" => 
				shifted <= op(34 downto 3);
			when "101" => 
				shifted <= op(33 downto 2);
			when "110" => 
				shifted <= op(32 downto 1);
			when "111" => 
				shifted <= op(31 downto 0);
		end case;
	end process;

end architecture;