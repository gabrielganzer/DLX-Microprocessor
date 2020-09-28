----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: FORWARDING_UNIT
-- Function: Data Hazard control and forwarding
-- Input:
-- Output:
-- Architecture: behavioral
-- Library/package: ieee.std_logic_ll64, work.globals
-- Date: 12/08/2020
----------------------------------------------------------------------------------
library IEEE;
library work;
use IEEE.std_logic_1164.all;
use work.globals.all;

entity STACK is
  generic (WIDTH : integer := word_size;
           DEPTH : integer := stack_size);
  port (CLK  : in std_logic;
        RST  : in std_logic; -- Synchronous, active-low
        EN   : in std_logic; -- Active-high
        PUSH : in std_logic;
        POP  : in std_logic;
        DIN  : in std_logic_vector (WIDTH-1 downto 0);
        DOUT : out std_logic_vector (WIDTH-1 downto 0)
  );
end entity;

architecture BEHAVIORAL of STACK is
  
  type reg_array is array(0 to DEPTH-1) of std_logic_vector(WIDTH-1 downto 0);
 	signal mem : reg_array;

begin
	
  STACK_PROC: process(CLK)
    -- Stack Pointer (SP)
    variable SP : integer := 0;
  begin
    if (CLK = '1' and CLK'event) then
      if (RST = '0') then
        -- SP points to the first empty memory location
        SP := 0;
        mem <= (others => (others => '0')); 
      else
        if (EN = '1') then
          if (POP = '1' and PUSH = '0') then
            -- since sp points at empty, first decrement then read
            SP := SP-1;
            DOUT <= mem(SP);
          end if;
          if (POP = '0' and PUSH = '1') then
            -- since sp points at empty, first write then increment
            mem(SP) <= DIN;
            SP := SP+1;
          end if;
        end if;
      end if;
    end if;
  end process;
 
end architecture;
