----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: ENC
-- Function: Booth's encoder + MUX circuit
-- Input: A (N-bit), b (3-bit)
-- Output: vp (N-bit)
-- Architecture: behavioral
-- Library/package: ieee.std_logic_ll64
-- Date: 14/04/2020
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_signed.all;
use work.CONSTANTS.all;

entity ENC is
    port (A:    in std_logic_vector(NBIT-1 downto 0);
          b:    in std_logic_vector(2 downto 0);
          vp:   out std_logic_vector(NBIT downto 0));
end entity;

architecture RTL of ENC is 
	signal notA : std_logic_vector(NBIT-1 downto 0);
	signal multA : std_logic_vector(NBIT downto 0);
	signal multNotA : std_logic_vector(NBIT downto 0);
begin
    -- 2's complement of A
	notA		<= (not A) + '1';
	-- Shift left of A resulting in 2A
	multA		<= A & '0';
	-- Shift left of -A resulting in -2A
	multnotA	<= notA & '0';
	-- Look-Up-Table 
	vp <= (others => '0') when b="000" or b="111" else	
	       '1' & A        when ((b="001" or b="010") and A(NBIT-1)='1') else	
	       '0' & A        when ((b="001" or	b="010") and A(NBIT-1)='0') else	
	       multA          when b="011" else	
	       multnotA       when b="100" else	
	       '1' & notA     when ((b="101" or	b="110") and notA(NBIT-1)='1') else	
	       '0' & notA     when ((b="101" or	b="110") and notA(NBIT-1)='0') else
	       (others	=> '0');
end architecture;