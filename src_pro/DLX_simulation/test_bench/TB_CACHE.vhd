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
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TB_CACHE is
end entity;

architecture TESTBENCH of TB_CACHE is
  -- Components
  component DATA_CACHE is
  generic (WIDTH: integer := 32);
	port (CLK          : in std_logic;
 	      RST          : in std_logic;                            -- Synchronous, active-low
 	      EN           : in std_logic;                            -- Active-high
 	      WE           : in std_logic;                            -- Write enable, read otherwise
 	      FWD          : in std_logic;                            -- Forwarding signal enable
 	      ADDR         : in std_logic_vector(WIDTH-1 downto 0);   -- Address from ALU
 	      DRAM_WE      : out std_logic;                           -- Cache write enable, read otherwise
 	      DRAM_SRC     : out std_logic;                           -- Data memory address source select
 	      DRAM_ADDR    : out std_logic_vector(11 downto 0);  -- TAG & INDEX & 0's
 	      CACHE_DIN    : in std_logic_vector(WIDTH-1 downto 0);
 	      CACHE_DOUT   : out std_logic_vector(WIDTH-1 downto 0);
 	      CACHE_SRC    : out std_logic_vector(2 downto 0);        -- Cache data source select
 	      STALL        : out std_logic                            -- Pipeline stall 	        
	);
  end component;
  
  component SDRAM is
	generic (
		FILE_PATH       : string;
		ENTRIES         : integer := 4095;
		WIDTH           : integer := 32);
	port (
			CLK   : in std_logic;
			RST		 : in std_logic;  -- Synchronous, active-low
			EN		  : in std_logic;  -- Active-high
			WE		  : in std_logic;  -- Write enable, read otherwise
			ADDR  : in std_logic_vector(11 downto 0);
			DIN   : in std_logic_vector(WIDTH-1 downto 0);
			DOUT  : out std_logic_vector(WIDTH-1 downto 0));
  end component;
  
  -- Constants
  constant WIDTH : integer := 32;
  
  -- Signals
  signal CLK          : std_logic;
  signal RST          : std_logic;
  signal EN           : std_logic;
  signal WE           : std_logic;
  signal FWD          : std_logic;
  signal ADDR         : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
  signal DRAM_WE      : std_logic;
  signal DRAM_SRC     : std_logic;
  signal DRAM_ADDR    : std_logic_vector(11 downto 0);
  signal CACHE_DIN    : std_logic_vector(WIDTH-1 downto 0);
  signal CACHE_DOUT   : std_logic_vector(WIDTH-1 downto 0);
  signal DRAM_DOUT    : std_logic_vector(WIDTH-1 downto 0);
  signal REG_ALU      : std_logic_vector(WIDTH-1 downto 0);
  signal REG_ME       : std_logic_vector(WIDTH-1 downto 0);
  signal CACHE_SRC    : std_logic_vector(2 downto 0);
  signal STALL        : std_logic;
  
begin
  
  UUT: DATA_CACHE
    generic map (32)
	  port map(CLK, RST, EN, WE, FWD, ADDR, DRAM_WE, DRAM_SRC, DRAM_ADDR, CACHE_DIN, CACHE_DOUT, CACHE_SRC, STALL);

  DRAM: SDRAM
	  generic map ("C:/Users/gabrielganzer/Desktop/cache/dram.txt", 4095, 32)
	  port map (CLK, RST, EN, DRAM_WE, DRAM_ADDR, CACHE_DOUT, DRAM_DOUT);
  
  CACHE_DIN <= DRAM_DOUT when CACHE_SRC = "001" else
               REG_ALU   when CACHE_SRC = "010" else
               REG_ME    when CACHE_SRC = "100" else
               (others => '0');
               
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
    WE   <= '0';
    FWD  <= '0'; 
    ADDR <= (others => '0');
    wait for 6 ns;
    RST  <= '1';
    EN   <= '1';
    wait until (CLK = '1' and CLK'event);
    WE   <= '1';
    FWD  <= '0'; 
    ADDR <= (31 downto 12 => '0')&"111111010100";
    REG_ME <= std_logic_vector(to_unsigned(2, REG_ME'length));
    wait until (CLK = '1' and CLK'event);
    WE   <= '0';
    wait;
  end process;
  
end architecture;