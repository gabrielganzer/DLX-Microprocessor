library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.functions.all;
use work.all;

entity alu is
  generic(nbit : integer := 32);
  port (
    a, b      : in  std_logic_vector(nbit - 1 downto 0);
    unit_sel  : in  std_logic_vector(3 downto 0);
    y         : out std_logic_vector(nbit - 1 downto 0)
  );
end entity;

architecture structural of alu is

  component barrel_shifter_left is
    generic(
      n : integer := 2  -- number of bits
    );
    port(
      -- Inputs
      x   : in  std_logic_vector(n - 1 downto 0);
      pos : in  std_logic_vector(log2(n) - 1 downto 0); -- number of shifts
      -- Outputs
      y   : out std_logic_vector(n - 1 downto 0)
    );
  end component;

  component barrel_shifter_right is
    generic(
      n : integer := 2
    );
    port (
      -- Inputs
      x          : in  std_logic_vector(n - 1 downto 0);
      pos        : in  std_logic_vector(log2(n) - 1 downto 0); -- number of shifts
      shift_type : in  std_logic;                              -- logic or arithmetic
      -- Outputs
      y          : out std_logic_vector(n - 1 downto 0)
    );
  end component;

  component p4 is
    generic(n : integer := 4);
    port (
      -- inputs
      a, b : in  std_logic_vector(n - 1 downto 0);
      cin  : in std_logic;
      -- outputs
      s    : out std_logic_vector(n - 1 downto 0);
      cout : out std_logic
    );
  end component;

  component subtractor is
  generic(n : integer := 2);
  port (
    -- inputs
    a    : in  std_logic_vector (n - 1 downto 0);
    b    : in  std_logic_vector (n - 1 downto 0);
    cin  : in  std_logic;
    -- outputs
    y    : out std_logic_vector (n - 1 downto 0);
    cout : out std_logic
  );
  end component; -- subtractor

  component comparator is
  generic(
    n : integer := 2
  );
  port (
    a, b : in  std_logic_vector(n - 1 downto 0);
    cout : out std_logic;
    z    : out std_logic
  );
  end component;

  component encoder is
    generic(n : integer := 2);
    port (
      out_add     : in  std_logic_vector(n - 1 downto 0);
      out_sub     : in  std_logic_vector(n - 1 downto 0);
      out_sl      : in  std_logic_vector(n - 1 downto 0);
      out_sr      : in  std_logic_vector(n - 1 downto 0);
      out_log     : in  std_logic_vector(n - 1 downto 0);
      out_cmp     : in  std_logic_vector(n - 1 downto 0);
      out_eq      : in  std_logic_vector(n - 1 downto 0);
      sel         : in  std_logic_vector(3 downto 0);
      o           : out std_logic_vector(n - 1 downto 0)
    );
  end component;

  component logic_n is
    generic (n : integer := 2);
    port (
      -- inputs
      r1, r2         : in  std_logic_vector(n - 1 downto 0); -- operands
      s0, s1, s2, s3 : in  std_logic; -- signal for select the operation
      -- output
      y              : out std_logic_vector(n - 1 downto 0)
    );
  end component;

  component xor_2 is
    port(
      a, b : in  std_logic;
      y    : out std_logic
    );
  end component;

  signal out_add, out_sub, out_sl, out_sr, out_log : std_logic_vector(nbit - 1 downto 0);
  signal type_sr                                   : std_logic;
  signal pos_s                                     : std_logic_vector(log2(nbit) - 1 downto 0);
  signal cmp_out, eq_out                           : std_logic_vector(nbit - 1 downto 0) := (others => '0');
  signal cmp_bit, eq_bit                           : std_logic;

begin

  pos_s <= b(log2(nbit) - 1 downto 0);


  add : p4
  generic map(nbit)
  port map(a, b, '0', out_add);

  sub : subtractor
  generic map(nbit)
  port map(a, b, '0', out_sub);

  sl : barrel_shifter_left
  generic map(nbit)
  port map(a, pos_s, out_sl);

  sr : barrel_shifter_right
  generic map(nbit)
  port map(a, pos_s, type_sr, out_sl);

  comp : comparator
  generic map(nbit)
  port map(a, b, cmp_bit, eq_bit);

  cmp_out(0) <= cmp_bit;
  eq_out(0) <= eq_bit;

  sh : xor_2
  port map(unit_sel(2), unit_sel(0), type_sr);

  logi : logic_n
  generic map(nbit)
  port map(a, b, unit_sel(0), unit_sel(1), unit_sel(2), unit_sel(3), out_log);

  enc : encoder
  generic map(nbit)
  port map(out_add, out_sub, out_sl, out_sr, out_log, cmp_out, eq_out, unit_sel, y);

end architecture;
