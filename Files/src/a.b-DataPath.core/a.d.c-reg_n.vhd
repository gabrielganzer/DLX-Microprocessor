library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg_n is
  generic(n : integer := 1);
  port (
    clock  : in  std_logic;
    reset  : in  std_logic;
    enable : in  std_logic;
    x      : in  std_logic_vector (n - 1 downto 0);
    y      : out std_logic_vector (n - 1 downto 0)
  );
end entity; -- reg_n

architecture structural of reg_n is

  component ffd_async is
    port (
    	clk   :	in	std_logic;
    	reset :	in	std_logic;
    	en 		: in  std_logic;
    	d     : in	std_logic;
    	q     : out	std_logic
    );
  end component;

begin

  ff_i : for i in 0 to n-1 generate
    ff : ffd_async
    port map(clock, reset, enable, x(i), y(i));
  end generate; -- ff_i

end architecture; -- structural
