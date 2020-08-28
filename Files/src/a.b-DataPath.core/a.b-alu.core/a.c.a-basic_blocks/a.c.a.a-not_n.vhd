library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity not_n is
  generic(n : integer := 1);
  port (
    a : in  std_logic_vector(n - 1 downto 0);
    y : out std_logic_vector(n - 1 downto 0)
  );
end entity;

architecture structural of not_n is

  component not_1 is
    port(
      a : in  std_logic;
      y : out std_logic
    );
  end component;

begin

  not_loop : for i in 0 to n - 1 generate
    not_1_component : not_1
    port map(a(i), y(i));
  end generate;

end architecture;
