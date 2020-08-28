library IEEE;
use IEEE.std_logic_1164.all;
--use work.all;

entity ffd_async is
  port (
  	clk   :	in	std_logic;
  	reset :	in	std_logic;
  	en 		: in  std_logic;
  	d     : in	std_logic;
  	q     : out	std_logic
  );
end entity;

architecture behavioral of ffd_async is
begin
  pasynch : process(clk, reset)
  begin
    if(reset = '0') then
      q <= '0';
    elsif(clk'EVENT and clk = '1') then
      q <= d;
    end if;
  end process;
end architecture;
