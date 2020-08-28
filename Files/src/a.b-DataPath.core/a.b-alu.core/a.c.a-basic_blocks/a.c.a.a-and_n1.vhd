library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity and_n1 is
  generic(n : integer := 2);
  port(a : in  std_logic_vector(n - 1 downto 0);
       y : out std_logic
      );
end entity;

architecture behavioral of and_n1 is
  signal tmp : std_logic_vector(n - 1 downto 0);
begin
  tmp <= (others => '1');
  y   <= '1' when a = tmp else '0';
end architecture;
