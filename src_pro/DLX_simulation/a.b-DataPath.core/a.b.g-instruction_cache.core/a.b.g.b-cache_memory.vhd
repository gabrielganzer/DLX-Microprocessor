----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: MUX21_GENERIC
-- Function: multiplexer 2x1 
-- Input: A, B (N-bit), SEL (1-bit)
-- Output: Y (N-bit)
-- Architecture: behavioral
-- Library/package: ieee.std_logic_ll64
-- Date: 14/04/2020
----------------------------------------------------------------------------------
library IEEE;
library work;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.globals.all;

entity CACHE_MEMORY is
  generic (WIDTH  : integer := word_size;
           LENGTH : integer := index_size+word_cache_size);
	port (CLK      : in std_logic;
	      RST      : in std_logic;   -- Synchronous, active-low
	      EN       : in std_logic;   -- Active-high
	      WE       : in std_logic;   -- Write enable, read otherwise
	      ADDR     : in std_logic_vector(LENGTH-1 downto 0);
	      DIN      : in std_logic_vector(WIDTH-1 downto 0);
	      DOUT     : out std_logic_vector(WIDTH-1 downto 0)
	);
end entity;

architecture BEHAVIORAL of CACHE_MEMORY is
   type data_array is array (0 to (2**LENGTH)-1) of std_logic_vector(WIDTH-1 downto 0);
   signal mem: data_array := (others => (others => '0'));
begin
    
    process(CLK)
    begin
        if (CLK = '1' and CLK'event) then
            if (RST = '0') then
                mem <= (others => (others => '0'));
                DOUT  <= (others => '0');
            else
                if (EN = '1') then
                    if (WE = '1') then
                          mem(to_integer(unsigned(ADDR))) <= DIN;
                    else
                          DOUT <= mem(to_integer(unsigned(ADDR)));
                    end if;
                end if;
            end if;
        end if;
    end process;

end architecture;

