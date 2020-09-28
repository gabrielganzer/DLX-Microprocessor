----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: MMU
-- Function: Memory Management Unit
-- Input:
-- Output:
-- Architecture: behavioral
-- Library/package: ieee.std_logic_ll64, work.globals
-- Date: 12/08/2020
----------------------------------------------------------------------------------
library IEEE;
library work;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.globals.all;

entity MMU is
  generic (WIDTH : integer := word_size;
           LENGTH : integer := dram_addr_size);
  port (CLK         : in std_logic;
        RST         : in std_logic; -- Active-low
        DRAM_WE     : in std_logic;
        MMU_CTRL    : in mmuOp;    
        ADDR        : in std_logic_vector(LENGTH-1 downto 0);
        DRAM_DOUT   : in std_logic_vector(WIDTH-1 downto 0);
        ME_DOUT     : in std_logic_vector(WIDTH-1 downto 0);
        DRAM_ADDR   : out std_logic_vector(LENGTH-1 downto 0);
        DRAM_DIN    : out std_logic_vector(WIDTH-1 downto 0);
        LMD_DIN     : out std_logic_vector(WIDTH-1 downto 0);
        MISALIGNED  : out std_logic
  );
end entity;

architecture BEHAVIORAL of MMU is
begin
  
  REG_PROC: process (CLK, RST, DRAM_WE, MMU_CTRL, ADDR, DRAM_DOUT, ME_DOUT)
  begin
    if (RST = '1') then
      DRAM_ADDR   <= (others => '0');
      DRAM_DIN    <= (others => '0');
      LMD_DIN     <= (others => '0');
      MISALIGNED  <= '0';
    elsif (CLK = '1' and CLK'event) then
      if (DRAM_WE = '1') then 
        if (MMU_CTRL = SB and (ME_DOUT(WIDTH-1 downto 8) = x"000000")) then
          DRAM_ADDR  <= ADDR;
          DRAM_DIN   <= ME_DOUT;
          MISALIGNED <= '0';
        elsif (MMU_CTRL = SB and (ME_DOUT(WIDTH-1 downto 8) = x"111111")) then
          DRAM_ADDR  <= ADDR;
          DRAM_DIN   <= ME_DOUT;
          MISALIGNED <= '0';
        elsif (MMU_CTRL = SH and (ME_DOUT(WIDTH-1 downto 16) = x"0000") and (unsigned(ADDR) mod 2 = 0)) then
          DRAM_ADDR  <= ADDR;
          DRAM_DIN   <= ME_DOUT;
          MISALIGNED <= '0';
        elsif (MMU_CTRL = SH and (ME_DOUT(WIDTH-1 downto 16) = x"1111") and (unsigned(ADDR) mod 2 = 0)) then
          DRAM_ADDR  <= ADDR;
          DRAM_DIN   <= ME_DOUT;
          MISALIGNED <= '0';
        elsif (MMU_CTRL = SW and (unsigned(ADDR) mod 4 = 0)) then
          DRAM_ADDR  <= ADDR;
          DRAM_DIN   <= ME_DOUT;
          MISALIGNED <= '0';
        else
          DRAM_ADDR  <= (others => '0');
          DRAM_DIN   <= (others => '0');
          MISALIGNED <= '1';
        end if;
      else
        if ((MMU_CTRL = LB or MMU_CTRL = LBU) and (DRAM_DOUT(WIDTH-1 downto 8) = x"000000")) then
          DRAM_ADDR  <= ADDR;
          LMD_DIN    <= DRAM_DOUT;
          MISALIGNED <= '0';
        elsif (MMU_CTRL = LB and (DRAM_DOUT(WIDTH-1 downto 8) = x"111111")) then
          DRAM_ADDR  <= ADDR;
          LMD_DIN    <= DRAM_DOUT;
          MISALIGNED <= '0';
        elsif (MMU_CTRL = LBU and (DRAM_DOUT(WIDTH-1 downto 8) = x"000000")) then
          DRAM_ADDR  <= ADDR;
          LMD_DIN    <= DRAM_DOUT;
          MISALIGNED <= '0';
        elsif ((MMU_CTRL = LH or MMU_CTRL = LHU) and (DRAM_DOUT(WIDTH-1 downto 16) = x"0000") and (unsigned(ADDR) mod 2 = 0)) then
          DRAM_ADDR  <= ADDR;
          LMD_DIN    <= DRAM_DOUT;
          MISALIGNED <= '0';
        elsif (MMU_CTRL = LH and (DRAM_DOUT(WIDTH-1 downto 16) = x"1111") and (unsigned(ADDR) mod 2 = 0)) then
          DRAM_ADDR  <= ADDR;
          LMD_DIN    <= DRAM_DOUT;
          MISALIGNED <= '0';
        elsif (MMU_CTRL = LW and (unsigned(ADDR) mod 4 = 0)) then
          DRAM_ADDR  <= ADDR;
          LMD_DIN    <= DRAM_DOUT;
          MISALIGNED <= '0';
        else
          LMD_DIN    <= (others => '0');
          MISALIGNED <= '1';
        end if;
      end if;
    end if;
  end process;
  
end architecture;
