----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: BOOTH_MULTIPLIER
-- Function: booth's multiplier circuit
-- Input: A, B (N-bit)
-- Output: P (2N-bit)
-- Architecture: structural
-- Library/package: ieee.std_logic_ll64
-- Date: 14/04/2020
----------------------------------------------------------------------------------
library IEEE;
library work;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_signed.all;
use work.globals.all; 

entity BOOTH_MULTIPLIER is
    generic (WIDTH: integer := word_size/2);
    port (A:   in std_logic_vector(WIDTH-1 downto 0);
          B:   in std_logic_vector(WIDTH-1 downto 0);
          P:   out std_logic_vector((2*WIDTH)-1 downto 0));
end entity;

architecture STRUCTURAL of BOOTH_MULTIPLIER is 
	-- Components	
    component RCA is
        port (A:        in std_logic_vector (WIDTH downto 0); 
              B:        in std_logic_vector (WIDTH downto 0);
              Ci:       in std_logic;
              S:        out std_logic_vector (WIDTH downto 0);
              Partial:  out std_logic_vector (1 downto 0);
              Co:       out std_logic);
    end component;	
    component ENC is
        port (A:    in std_logic_vector(WIDTH-1 downto 0);
              b:    in std_logic_vector(2 downto 0);
              vp:   out std_logic_vector(WIDTH downto 0));
    end component;
	-- Signals
	signal outEnc : mul_array;
	signal outSum : mul_array;
	signal inBooth: std_logic_vector(2 downto 0);
begin
    -- Bit -1 of B used as input b[-1] of Booth's encoder
	inBooth <= B(1 downto 0) & '0';
    -- First iteration of Booth's encoder
	enc0: ENC port map (
		A, inBooth, outEnc(0) 
	);
	-- Remaining iterations
	GENC: for i IN 0 TO (WIDTH/2)-2 generate
		encoders: ENC port map (
			A, B(((i*2)+3) downto ((i*2)+1)), outEnc(i+1)
		);
	end generate;
	-- First sum
	adder0: RCA port map (
		(others => '0'), outEnc(0), '0', outSum(0), P(1 downto 0)
	);
	-- Reciprocal sums
	GSOM: for i IN 0 TO (WIDTH/2)-2 generate
		adders: RCA PORT MAP (
			outSum(i), outEnc(i+1), '0', outSum(i+1), P(((i*2)+3) downto ((i*2)+2))
		);
	end generate;
	-- Final product
	P((2*WIDTH)-1 downto WIDTH) <= outSum((WIDTH/2)-1)(WIDTH-1 downto 0);
	
end architecture;