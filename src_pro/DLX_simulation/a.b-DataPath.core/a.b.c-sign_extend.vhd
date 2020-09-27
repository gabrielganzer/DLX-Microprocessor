----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: SIGN_EXTEND
-- Function: N to M sign-entend combinational logic
-- Input:
-- Output:
-- Architecture: behavioral
-- Library/package: ieee.std_logic_ll64, work.globals
-- Date: 12/08/2020
----------------------------------------------------------------------------------
library ieee;
library work;
use ieee.std_logic_1164.all;
use work.globals.all;

entity SIGN_EXTEND is
  generic (WIDTH:  integer := word_size;
           OPCODE: integer := op_size);
  port (IR   : in std_logic_vector(WIDTH-OPCODE-1 downto 0);  -- Instruction 
        SEL  : in std_logic_vector(2 downto 0);               -- Select from CU
        IMMS : out std_logic_vector(WIDTH-1 downto 0)         -- Sign extended immediate
  );
end entity;

architecture RTL of SIGN_EXTEND is
begin
  IMMS <= (WIDTH-1 downto inp2_up+1     => IR(inp2_up))&IR(inp2_up downto 0)         when SEL = "001" else
          (WIDTH-1 downto inp2_up+1     => '0')&IR(inp2_up downto 0)                 when SEL = "010" else
          (WIDTH-1 downto opcode_down+1 => IR(opcode_down))&IR(opcode_down downto 0) when SEL = "100" else
          (others => '0');
end architecture;
