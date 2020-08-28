library ieee;
use ieee.std_logic_1164.all;

entity not_1 is
  port(
    a : in  std_logic;
    y : out std_logic
  );
end not_1;

architecture behavioral of not_1 is
  begin
    y <= not a;
end behavioral;
