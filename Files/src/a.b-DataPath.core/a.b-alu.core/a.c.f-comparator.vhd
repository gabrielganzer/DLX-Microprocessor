library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity comparator is
  generic(
    n : integer := 2
  );
  port (
    a, b : in  std_logic_vector(n - 1 downto 0);
    cout : out std_logic;
    z    : out std_logic
  );
end entity;

architecture structural of comparator is

  component rca_n is
    generic(n : integer := 1);
    port(
      a, b  : in  std_logic_vector(n - 1 downto 0);
      c_in  : in  std_logic;
      sum   : out std_logic_vector(n - 1 downto 0);
      c_out : out std_logic
    );
  end component;

  component nor_n1 is
    generic(
      n : integer := 2
    );
    port(
      a : std_logic_vector(n - 1 downto 0);
      y : out std_logic
    );
  end component;

  component not_n is
    generic(n : integer := 1);
    port (
      a : in  std_logic_vector(n - 1 downto 0);
      y : out std_logic_vector(n - 1 downto 0)
    );
  end component;

  component not_1 is
    port(
      a : in  std_logic;
      y : out std_logic
    );
  end component;

  signal b_not : std_logic_vector(n - 1 downto 0);
  signal s     : std_logic_vector(n - 1 downto 0);

begin

  b_negate : not_n
  generic map(n)
  port map(b, b_not);

  sub : rca_n
  generic map(n)
  port map(a, b_not, '1', s, cout);

  big_nor : nor_n1
  generic map(n)
  port map(s, z);

end architecture;
