library ieee;
use ieee.std_logic_1164.all;

-- unit to do AND, NAND, OR, NOR, XOR, XNOR
entity logic is
  port (
    -- inputs
    r1, r2         : in  std_logic; -- operands
    s0, s1, s2, s3 : in  std_logic; -- signal for select the operation
    -- output
    y              : out std_logic
  );
end entity;

architecture behavioral of logic is

--  signal l0, l1, l2, l3 : std_logic := '0';

begin
  -- -- first stage
  -- l0 <= not ((s0) and (not r1) and (not r2));
  -- l1 <= not ((s1) and (not r1) and (r2));
  -- l2 <= not ((s2) and (r1)     and (not r2));
  -- l3 <= not ((s3) and (r1)     and (r2));
  -- -- second stage
  -- y <= not (l0 and l1 and l2 and l3);

  y <=  (s0 and (not R1) and (not R2)) or
        (s1 and (not R1) and (    R2)) or
        (s2 and (    R1) and (not R2)) or
        (s3 and (    R1) and (    R2));

end architecture;
