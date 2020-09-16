----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: RCA_MUL
-- Function: modified RCA_MUL circuit
-- Input: A, B (N-bit), Ci (N-bit)
-- Output: S (N-bit), Partial (2-bit), Co (1-bit)
-- Architecture: dataflow
-- Library/package: ieee.std_logic_ll64
-- Date: 14/04/2020
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use work.globals.all;

entity RCA_MUL is
	  generic (WIDTH: integer := radix_size);
    port (A:        in std_logic_vector (WIDTH downto 0); 
          B:        in std_logic_vector (WIDTH downto 0);
          Ci:       in std_logic;
          S:        out std_logic_vector (WIDTH downto 0);
          Partial:  out std_logic_vector (1 downto 0);  -- Partial is used in the lower bits of P after A is shifted
          Co:       out std_logic);
end entity;
    	
architecture STRUCTURAL of RCA_MUL is
    -- Components	
    component FA is
        port (	
            Ci, A, B: in std_logic;
            S, Co: out std_logic 
        );
    end component;
    -- Signals
    signal carry: std_logic_vector (32 downto 1);
	signal res: std_logic_vector (32 downto 0);
begin
    -- Sum of first bit
	sum0: FA PORT MAP ( 
		Ci, 
		A(0), 
		B(0), 
		res(0), 
		carry(1)
	);	
	
	sum: FOR i IN 1 TO WIDTH-1 GENERATE
		sumI: FA PORT MAP ( 
			carry(i),
			A(i),
			B(i),
			res(i),
			carry(i+1)
		);
	END GENERATE;
	
	sumTH: FA PORT MAP (
		carry(WIDTH),
		A(WIDTH),
		B(WIDTH),
		res(WIDTH),
		Co
	);

	S <= "00" & res(WIDTH downto 2) when	res(WIDTH) = '0' else
	     "11" & res(WIDTH downto 2) when res(WIDTH) = '1';
	Partial <= res(1 downto 0);
	
end architecture ;