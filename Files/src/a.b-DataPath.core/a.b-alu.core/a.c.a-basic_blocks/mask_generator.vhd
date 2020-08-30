----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: MASK_GEN
-- Function: T2 shifter 1st level mask generator (32-bit)
-- 00 SLL SLLI
-- 01 SRL SRLI
-- 10 SRA SRAI
-- Input: op (32-bit), sel (2-bit)
-- Output: mask00, mask08, mask16 (39-bit)
-- Architecture: behavioral
-- Library/package: ieee.std_logic_ll64
-- Date: 14/04/2020
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity MASK_GEN is
  port (
    -- Inputs
    op     : in std_logic_vector(31 downto 0);  -- Operand to be shifted
    sel    : in std_logic_vector(1 downto 0);   -- Right, Left, Logic, Arithmetic
    -- Outputs
    mask00 : out std_logic_vector(38 downto 0); -- Mask shifted by 8 positions
    mask08 : out std_logic_vector(38 downto 0); -- Mask shifted by 16 positions
    mask16 : out std_logic_vector(38 downto 0)  -- Mask shifted by 32 positions
  );
end entity;

architecture BEHAVIORAL of MASK_GEN is
begin 

  MASK_GENERATION: process(sel, op)
	begin		
		case sel is
		  -- Masks SLL (logic left shift)
			when "00" =>
				mask00 <= op & "0000000";
				mask08 <= op(23 downto 0) & x"000" & "000";
				mask16 <= op(15 downto 0) & x"00000" & "000";
			-- Masks SRL (logic right shift)
			when "01" =>
				mask00 <= "0000000" & op;
				mask08 <= x"000" & "000" & op(31 downto 8);
				mask16 <= x"00000" & "000" & op(31 downto 16);
			-- Masks SRA (arithmetic right shift)
			when "10" =>
				mask00 <= (38 downto 32 => op(31)) & op;
				mask08 <= (38 downto 24 => op(31)) & op(31 downto 8);
				mask16 <= (38 downto 16 => op(31)) & op(31 downto 16);
			-- Idle
			when others =>
			  mask00 <= (others => '0');
				mask08 <= (others => '0');
				mask16 <= (others => '0');
		end case;
	end process;

end architecture;