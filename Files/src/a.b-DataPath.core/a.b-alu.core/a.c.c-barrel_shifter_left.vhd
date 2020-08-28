library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.functions.all;
use work.all;

entity barrel_shifter_left is
  generic(
    n : integer := 2  -- number of bits
  );
  port(
    -- Inputs
    x   : in  std_logic_vector(n - 1 downto 0);
    pos : in  std_logic_vector(log2(n) - 1 downto 0); -- number of shifts
    -- Outputs
    y   : out std_logic_vector(n - 1 downto 0)
  );
end entity;

architecture structural of barrel_shifter_left is

  component mux21 is
  	port (
  		a	:	in	std_logic;
  		b	:	in	std_logic;
  		s	:	in	std_logic;
  		y	:	out	std_logic
  	);
  end component;

  type signalvector is array (log2(n) downto 0) of std_logic_vector (n - 1 downto 0);

  -- signal declaration
  signal temp : signalvector := ((others=> (others=>'0')));

begin

  temp(0) <= x;

  columns : for i in 0 to log2(n) - 1 generate
    mux21_0 : for j in 0 to pow2(i) - 1 generate
      mux21_j : mux21
      port map(temp(i)(j), '0', pos(i), temp(i + 1)(j));
    end generate;
    mux21_k : for k in 0 to n - pow2(i) - 1 generate
      mux21_k : mux21
      port map(temp(i)(pow2(i) + k), temp(i)(k), pos(i), temp(i + 1)(pow2(i) + k));
    end generate;
  end generate;

  y <= temp(log2(n));
end architecture;
