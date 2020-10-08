----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: RWMEM
-- Function: Single-port RAM memory
-- Input:
-- Output:
-- Architecture: behavioral
-- Library/package: ieee.std_logic_ll64, work.globals
-- Date: 12/08/2020
----------------------------------------------------------------------------------
library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.globals.all;

entity TB_ICACHE is
end entity;

architecture TESTBENCH of TB_ICACHE is
  
  -- Components
  component INSTRUCTION_CACHE
    generic (WIDTH        : integer := word_size);
    	port (CLK          : in std_logic;
    	      RST          : in std_logic;                                  -- Synchronous, active-low
    	      EN           : in std_logic;                                  -- Active-high
    	      ADDR         : in std_logic_vector(WIDTH-1 downto 0);         -- PC address
           DIN          : in std_logic_vector(WIDTH-1 downto 0);         -- Instruction from ROM
           WORD         : out std_logic_vector(1 downto 0);              -- Word select
           DOUT         : out std_logic_vector(WIDTH-1 downto 0);        -- Instruction to IR
    	      STALL        : out std_logic                                  -- Pipeline stall
    	);
  end component;
  
  component ROM
  	generic (FILE_PATH   : string;
  		        ENTRIES		   : integer := 128;
  		        WIDTH       : integer := 32);
  	port (CS   : in std_logic;
		     OE		 : in std_logic;
		     ADDR : in std_logic_vector((log2(ENTRIES))-1 downto 0);
         DATA : out std_logic_vector(WIDTH-1 downto 0));
  end component;
  
  -- Constants
  constant WIDTH : integer := 32;
  
  -- Signals
  signal CLK          : std_logic;
  signal RST          : std_logic;
  signal EN           : std_logic;
  signal ADDR         : std_logic_vector(WIDTH-1 downto 0);
  signal IROM_ADDR    : std_logic_vector(iram_addr_size-1 downto 0);
  signal DIN          : std_logic_vector(WIDTH-1 downto 0);
  signal WORD         : std_logic_vector(1 downto 0);
  signal DOUT         : std_logic_vector(WIDTH-1 downto 0);
  signal STALL        : std_logic;
  
begin
  
  IROM_ADDR <= ADDR(iram_addr_size-1 downto word_offset)&WORD;
  
  ICACHE: INSTRUCTION_CACHE
    generic map (word_size)
  	 port map (CLK, RST, EN, ADDR, DIN, WORD, DOUT, STALL);
  
  IROM: ROM
    generic map("C:/Users/gabrielganzer/Desktop/DLX/test_bench/test.asm.mem", 2**iram_addr_size, word_size)
  	 port map(RST, EN, IROM_ADDR, DIN);
     
  CLK_PROC: process
  begin
    CLK <= '0';
    wait for 5 ns;
    CLK <= '1';
    wait for 5 ns;
  end process;
  
  STIMULI: process
  begin
    -- Reset
    RST  <= '0';
    EN   <= '0'; 
    wait for 4 ns;
    RST  <= '1';
    EN   <= '1'; 
    ADDR <= (others => '0');
    wait until (CLK = '1' and CLK'event);
    wait until STALL = '0';
    ADDR <=  std_logic_vector(to_unsigned(1, ADDR'length));
    wait until (CLK = '1' and CLK'event);
    ADDR <=  std_logic_vector(to_unsigned(2, ADDR'length));
    wait until (CLK = '1' and CLK'event);
    ADDR <=  std_logic_vector(to_unsigned(3, ADDR'length));
    wait until (CLK = '1' and CLK'event);
    ADDR <=  std_logic_vector(to_unsigned(4, ADDR'length));
    wait until (CLK = '1' and CLK'event);
    wait until STALL = '0';
    ADDR <=  std_logic_vector(to_unsigned(5, ADDR'length));
    wait until (CLK = '1' and CLK'event);
    ADDR <=  std_logic_vector(to_unsigned(6, ADDR'length));
    wait until (CLK = '1' and CLK'event);
    ADDR <=  std_logic_vector(to_unsigned(7, ADDR'length));
    wait;
  end process;
  
end architecture;