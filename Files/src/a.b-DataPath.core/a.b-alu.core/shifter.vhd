----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: SHIFTER
-- Function: T2 3-level shifter
-- Input: R1, R2 (32-bit), SEL (2-bit)
-- Output: Y (32-bit)
-- Architecture: structural
-- Library/package: ieee.std_logic_ll64
-- Date: 05/08/2020
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity SHIFTER is
  generic (WIDTH: integer := 32);
  port (
    -- Inputs
    R1, R2         : in  std_logic_vector(WIDTH-1 downto 0);
    SEL            : in std_logic_vector(1 downto 0);
    -- Output
    Y              : out std_logic_vector(WIDTH-1 downto 0)
  );
end entity;

architecture STRUCTURAL of SHIFTER is
  -- Components
  component MASK_GEN
  port (
    op     : in std_logic_vector(31 downto 0);
    sel    : in std_logic_vector(1 downto 0);
    mask00 : out std_logic_vector(38 downto 0);
    mask08 : out std_logic_vector(38 downto 0);
    mask16 : out std_logic_vector(38 downto 0)
  );
  end component;
  component COARSE_SHIFT
  port (
    sel    : in std_logic_vector(1 downto 0);
    mask00 : in std_logic_vector(38 downto 0);
    mask08 : in std_logic_vector(38 downto 0);
    mask16 : in std_logic_vector(38 downto 0);
    y      : out std_logic_vector(38 downto 0)
  );
  end component;
  component FINE_SHIFT
  port (
    op      : in std_logic_vector(38 downto 0);
    sel     : in std_logic_vector(2 downto 0);
    shifted : out std_logic_vector(31 downto 0)
  );
  end component;
  -- Signals
  signal m0, m8, m16, y2 : std_logic_vector(38 downto 0);
  signal s3: std_logic_vector(2 downto 0);

begin

	SEL_3: process(SEL, s3, R2, R1)
	begin
		case SEL is
		  when "00" => s3 <= R2(2 downto 0);
		  when "01" => s3 <= not(R2(2 downto 0));
		  when "10" => s3 <= not(R2(2 downto 0));
		  when others => s3 <= "XXX";
		end case;
	end process;

  level_1 : MASK_GEN     port map(R1, SEL, m0, m8, m16);
  level_2 : COARSE_SHIFT port map(R2(4 downto 3), m0, m8, m16, y2);
  level_3 : FINE_SHIFT   port map(y2, s3, Y);

end architecture;