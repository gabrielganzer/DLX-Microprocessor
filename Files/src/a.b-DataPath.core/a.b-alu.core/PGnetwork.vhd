----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: PGNET
-- Function: PG Network structure
-- Input: A, B (N-bit), Ci_array (N-bit)
-- Output: P, G (N-bit)
-- Architecture: behavioral
-- Library/package: ieee.std_logic_ll64
-- Date: 14/04/2020
----------------------------------------------------------------------------------
library IEEE; 
use IEEE.std_logic_1164.all;
use work.CONSTANTS.all;

entity PGNET is
    generic (NBIT: integer:= WIDTH);
    port (A:  in std_logic_vector(NBIT-1 downto 0);
          B:  in std_logic_vector(NBIT-1 downto 0);
          Ci: in std_logic;
          P:  out std_logic_vector(NBIT-1 downto 0);
          G:  out std_logic_vector(NBIT-1 downto 0));
end entity;

architecture STRUCTURAL of PGNET is
begin
    -- Structural description of PGnetwork
    NETWORK: for i in 0 to NBIT-1 generate
      -- If first PG, Ci must be taken into account
      COL0: if (i=0) generate
          P(i) <= '0';
          G(i) <= Ci;
      end generate; 
      -- Else generate PGnetwork
      COLi: if (i>0) generate
          P(i) <= A(i) xor B(i);
          G(i) <= A(i) and B(i);
      end generate;
    end generate;
end architecture;