library ieee;
use ieee.std_logic_1164.all;

-- unit to do AND, NAND, OR, NOR, XOR, XNOR on n-bits
entity logic_n is
  generic (n : integer := 2);
  port (
    -- inputs
    r1, r2         : in  std_logic_vector(n - 1 downto 0); -- operands
    s0, s1, s2, s3 : in  std_logic; -- signal for select the operation
    -- output
    y              : out std_logic_vector(n - 1 downto 0)
  );
end entity;

architecture structural of logic_n is

  component logic is
    port (
      -- inputs
      r1, r2         : in  std_logic; -- operands
      s0, s1, s2, s3 : in  std_logic; -- signal for select the operation
      -- output
      y              : out std_logic
    );
  end component;

begin

  -- bitwise
  logic_block : for i in 0 to n - 1 generate
    logic_i : logic
    port map(r1(i), r2(i), s0, s1, s2, s3, y(i));
  end generate;

end architecture;
