library ieee;
use ieee.std_logic_1164.all;

entity or_2 is
  port(
    a, b : in  std_logic;
    y    : out std_logic
  );
end or_2;

architecture behavioral of or_2 is
  begin
    y <= a or b;
end behavioral;
