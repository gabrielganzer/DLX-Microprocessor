----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: REGISTER_FILE
-- Function: implementation of a simple register file without windowing
-- Inputs: CLK, RST, EN, RD1, RD2, WR (1-bit); DATAIN (32-bit)
--         ADD_RD1, ADD_RD2, ADD_WR: (5-bit)
-- Outputs: OUT1, OUT2 (32-bit)
-- Architecture: behavioral
-- Library/package: ieee.std_logic_ll64, ieee.numeric_std, work.globals
-- Date: 05/05/2020
----------------------------------------------------------------------------------
library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.globals.all;

entity REGISTER_FILE is
  generic (
    WIDTH: integer:= word_size;
    LENGTH: integer:= addr_size);
  port(
    -- Synchronous reset active-low, active-high enable
    CLK     :IN std_logic;
    RST     :IN std_logic;
    EN      :IN std_logic;
    -- Synchronous R/W, active-high signals
    RD1     :IN std_logic;
    RD2     :IN std_logic;
    WR      :IN std_logic;
    -- Single write port
    DATAIN  :IN std_logic_vector(WIDTH-1 downto 0);
    -- Double read ports
    OUT1    :OUT std_logic_vector(WIDTH-1 downto 0);
    OUT2    :OUT std_logic_vector(WIDTH-1 downto 0);
    -- Ports addresses 
    ADD_WR  :IN std_logic_vector(LENGTH-1 downto 0);
    ADD_RD1 :IN std_logic_vector(LENGTH-1 downto 0);
    ADD_RD2 :IN std_logic_vector(LENGTH-1 downto 0)
  );
end entity;

architecture BEHAVIORAL of REGISTER_FILE is

  -- Internal registers
  subtype REG_ADDR is natural range 0 to (2**LENGTH)-1; -- using natural type
  type REG_ARRAY is array(REG_ADDR) of std_logic_vector(WIDTH-1 downto 0); 
  signal REGISTERS: REG_ARRAY;
	
begin
 
  WRITE: process (CLK)
  begin
    if (CLK = '1' and CLK'event) then
      if (RST = '0') then
        -- Write 0's to each internal register
        REGISTERS <= (others => (others => '0'));
      else
        if (EN = '1') then
          -- Write and bypass in case read address = write address
          if (WR = '1') then
            REGISTERS(to_integer(unsigned(ADD_WR))) <= DATAIN;
          end if;
        end if;
      end if;
    end if;
  end process;
  
  READ: process (EN, RD1, RD2, WR, ADD_RD1, ADD_RD2, ADD_WR, DATAIN)
  begin
    if (EN = '1') then
      if (RD1 = '1') then
        if (WR = '1' and ADD_RD1 = ADD_WR) then
          -- Bypass from input if same address and write enable
          OUT1 <= DATAIN;
        else
          -- Read from registers otherwise
          OUT1 <= REGISTERS(to_integer(unsigned(ADD_RD1)));
        end if;
      end if;
      if (RD2 = '1') then
        if (WR = '1' and ADD_RD2 = ADD_WR) then
          OUT2 <= DATAIN;
        else
          OUT2 <= REGISTERS(to_integer(unsigned(ADD_RD2)));
        end if;
      end if;
    end if;

  end process;
end architecture;