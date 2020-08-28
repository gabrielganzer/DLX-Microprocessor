library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity zero_comp is
  generic(n : integer := 1);
  port (x : in  std_logic_vector (n - 1 downto 0);
        y : out  std_logic
  );
end entity; -- zero_comp


architecture behavioral of zero_comp is
  component xnor_2 is
    port(a, b : in  std_logic;
         y    : out std_logic
        );
  end component;

  component and_n1 is
    generic(n : integer := 2);
    port(a : in  std_logic_vector(n - 1 downto 0);
         y : out std_logic
        );
  end component;

  signal res : std_logic_vector (n - 1 downto 0) := (others => '0');

begin

  bit_comp : for i in 0 to n - 1 generate
    xnor_i : xnor_2
    port map (x(i), '0', res(i));
  end generate; -- end for generate bit_comp

  big_and : and_n1
  generic map (n)
  port map (res, y);

end architecture; -- behavioral
