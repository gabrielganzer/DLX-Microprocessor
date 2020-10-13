----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: PG_NETWORK
-- Function: PG Network structure
-- Input: A, B (N-bit), Ci_array (N-bit)
-- Output: P, G (N-bit)
-- Architecture: behavioral
-- Library/package: ieee.std_logic_ll64
-- Date: 14/04/2020
----------------------------------------------------------------------------------
library IEEE;
library work;
use IEEE.std_logic_1164.all;
use work.globals.all;

entity PG_NETWORK is
    generic (WIDTH: integer:= word_size);
    port (A:  in std_logic_vector(WIDTH-1 downto 0);
          B:  in std_logic_vector(WIDTH-1 downto 0);
          Ci: in std_logic;
          P:  out std_logic_vector(WIDTH-1 downto 0);
          G:  out std_logic_vector(WIDTH-1 downto 0));
end entity;

architecture STRUCTURAL of PG_NETWORK is
  -- Signals
  signal p0: std_logic;
begin
    -- Structural description of PG network
    NETWORK: for i in 0 to WIDTH-1 generate
      -- If first PG, Ci must be taken into account
      COL0: if (i=0) generate
          p0 <= A(i) xor B(i);
          P(i) <= p0;
          G(i) <= (A(i) and B(i)) or (Ci and p0);
      end generate; 
      -- Else generate PG network
      COLi: if (i>0) generate
          P(i) <= A(i) xor B(i);
          G(i) <= A(i) and B(i);
      end generate;
    end generate;
end architecture;