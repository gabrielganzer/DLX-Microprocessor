library ieee;
use ieee.std_logic_1164.all;

entity xor_2 is
  port(
    a, b : in  std_logic;
    y    : out std_logic
  );
end xor_2;

architecture behavioral of xor_2 is
  begin
    y <= a xor b;
end behavioral;
