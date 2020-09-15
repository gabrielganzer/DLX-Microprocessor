library ieee;
library work;
use ieee.std_logic_1164.all;
use work.globals.all;

entity SIGN_EXTEND is
  generic (WIDTH_IN: integer := word_size/2;
           WIDTH_OUT: integer := word_size);
  port (A: in std_logic_vector(WIDTH_IN-1 downto 0);   -- Unsigned immediate
        S: in std_logic;                               -- Active-high signed output, active-low unsigned output
        Y: out std_logic_vector (WIDTH_OUT-1 downto 0) -- Sign extended immediate
  );
end entity;

architecture RTL of SIGN_EXTEND is
  -- Constants
	constant POS : std_logic_vector(WIDTH_OUT-1 downto WIDTH_IN) := (others => '0');
	constant NEG : std_logic_vector(WIDTH_OUT-1 downto WIDTH_IN) := (others => '1');

begin
  Y <= NEG&A when (A(WIDTH_IN-1) = '1' and S = '1') else POS&A;
end architecture;
