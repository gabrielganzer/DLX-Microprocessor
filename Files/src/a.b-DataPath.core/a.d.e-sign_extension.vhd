library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity sign_extension is
  generic(s : integer := 2; f : integer := 3);
  port(
    x : in  std_logic_vector(s - 1 downto 0);
    y : out std_logic_vector(f - 1 downto 0)
  );
end entity; -- end sign_extension

architecture behavioral of sign_extension is

  signal temp : std_logic_vector(f - 1 downto 0);

begin

  sign : process(x)
  begin
    if x(s - 1) = '0' then
      temp <= (others => '0');
    else
      temp <= (others => '1');
    end if; -- end if

    temp(s - 1 downto 0) <= x;
  end process; -- end sign
  
  y <= temp;

end architecture; -- end behavioral
