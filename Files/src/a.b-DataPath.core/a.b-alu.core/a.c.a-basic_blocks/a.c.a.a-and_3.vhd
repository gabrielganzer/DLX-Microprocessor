library ieee;
use ieee.std_logic_1164.all;

entity and_3 is
  port(
    a, b, c : in  std_logic;
    y       : out std_logic
  );
end and_3;

architecture behavioral of and_3 is
begin
  y <= a and b and c;
end behavioral;
