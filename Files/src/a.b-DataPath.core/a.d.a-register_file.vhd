----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: REGISTER_FILE
-- Function: implementation of a simple register file without windowing
-- Inputs: CLK, RST, EN, RD1, RD2, WR: (1-bit) control signals
--         DATAIN: (64-bit) data in
--         ADD_RD1, ADD_RD2, ADD_WR: (5-bit) addresses
-- Outputs: OUT1, OUT2: (64-bit) data out
-- Architecture: behavioral
-- Library/package: ieee.std_logic_ll64, ieee.numeric_std
--                  work.constants, work.functions
-- Date: 05/05/2020
----------------------------------------------------------------------------------
library IEEE;
library WORK;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.functions.all; 
use WORK.constants.all;

entity REGISTER_FILE is
  generic (
    NBIT: integer:= WIDTH;
    NREG: integer:= DEPTH;
    NADDR: integer:= log2(DEPTH)
  );
  port(
    -- Synchronous reset, active-high enable
    CLK     :IN std_logic;
    RST     :IN std_logic;
    EN      :IN std_logic;
    -- Synchronous R/W, active-high signals
    RD1     :IN std_logic;
    RD2     :IN std_logic;
    WR      :IN std_logic;
    -- Single write port
    DATAIN  :IN std_logic_vector(NBIT-1 downto 0);
    -- Double read ports
    OUT1    :OUT std_logic_vector(NBIT-1 downto 0);
    OUT2    :OUT std_logic_vector(NBIT-1 downto 0);
    -- Ports addresses 
    ADD_WR  :IN std_logic_vector(NADDR-1 downto 0);
    ADD_RD1 :IN std_logic_vector(NADDR-1 downto 0);
    ADD_RD2 :IN std_logic_vector(NADDR-1 downto 0)
  );
end entity;

architecture BEHAVIORAL of REGISTER_FILE is

  -- Internal registers
  subtype REG_ADDR is natural range 0 to NREG-1; -- using natural type
  type REG_ARRAY is array(REG_ADDR) of std_logic_vector(NBIT-1 downto 0); 
  signal REGISTERS : REG_ARRAY;
	-- 
	
begin
 
  RegFile: process (CLK)
  begin
    if (CLK = '1' and CLK'event) then
      if (RST = '1') then
        -- Write 0's to each internal register
        REGISTERS <= (others => (others => '0'));
        OUT1 <= (others => '0');
        OUT2 <= (others => '0');
      else
        if (EN = '1') then
          -- Read address in ADD_RD1 and bypass to OUT1
          if (RD1 = '1') then
            OUT1 <= REGISTERS(to_integer(unsigned(ADD_RD1)));
          end if;
          -- Read address in ADD_RD2 and bypass to OUT2
          if (RD2 = '1') then
            OUT2 <= REGISTERS(to_integer(unsigned(ADD_RD2)));
          end if;
          -- Write and bypass in case read address = write address
          if (WR = '1') then
            REGISTERS(to_integer(unsigned(ADD_WR))) <= DATAIN;
            -- Bypass DATAIN to OUT1 (simultaneous read/write)
            if ((ADD_RD1 = ADD_WR) and (RD1 = '1')) then
              OUT1 <= DATAIN;
            end if;
            -- Bypass DATAIN to OUT2 (simultaneous read/write)
            if (ADD_RD2 = ADD_WR and (RD2 = '1')) then
              OUT2 <= DATAIN;
            end if;
          end if;
        end if;
      end if;
    end if;
  end process;
  
end architecture;