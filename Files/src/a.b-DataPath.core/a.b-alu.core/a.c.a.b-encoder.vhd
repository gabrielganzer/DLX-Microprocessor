library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity encoder is
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
end entity;

architecture behavioral of encoder is

  signal le, ne : std_logic_vector(n - 1 downto 0) := (others => '0');

begin

  le(0) <= not out_cmp(0) or out_eq(0);
  ne(0) <= not out_eq(0);

  o <= out_add                      when sel = "0000" else -- add
       out_sub                      when sel = "1111" else -- sub
       out_sl                       when sel = "0010" else -- sll
       out_sr                       when sel = "0100" else -- srl
       out_sr                       when sel = "0101" else -- sra
       out_cmp                      when sel = "1010" else -- ge
       le                           when sel = "1011" else -- le
       ne                           when sel = "0011" else -- equality
       out_log                      when sel = "1000" else -- and
       out_log                      when sel = "0111" else -- nand
       out_log                      when sel = "1110" else -- or
       out_log                      when sel = "0001" else -- nor
       out_log                      when sel = "0110" else -- xor     
       out_log                      when sel = "1001" else -- xnor
       (others => 'X');

end architecture; -- behavioral
