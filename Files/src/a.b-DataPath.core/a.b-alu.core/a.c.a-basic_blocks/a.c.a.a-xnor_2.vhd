library ieee;
use ieee.std_logic_1164.all;

entity xnor_2 is
  port(
    a, b : in  std_logic;
    y    : out std_logic
  );
end xnor_2;

architecture behavioral of xnor_2 is
  begin
    y <= a xnor b;
end behavioral;
