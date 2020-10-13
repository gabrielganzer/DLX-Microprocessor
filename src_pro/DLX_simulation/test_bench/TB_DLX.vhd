----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Function: DLX testbench
-- Library/package: ieee.std_logic_ll64, work.globals
-- Date: 12/08/2020
----------------------------------------------------------------------------------
library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.globals.all;

entity DLX_TB is
end DLX_TB;

architecture TESTBENCH of DLX_TB is
  --------------------------------------------------------------------
  -- Components Declaration
  --------------------------------------------------------------------
  -- DLX
  component DLX is
    generic (WIDTH     : integer := word_size);
    port (CLK               : in std_logic;
          RST               : in std_logic;
		      IROM_ADDR   	     : out std_logic_vector(iram_addr_size-1 downto 0);
		      IROM_DATA				     : in std_logic_vector(WIDTH-1 downto 0);
		      DRAM_EN		         : out std_logic;
		      DRAM_RW		         : out std_logic;
		      DRAM_ADDR         : out std_logic_vector(dram_addr_size-1 downto 0);
		      DRAM_DATA_IN      : in std_logic_vector(WIDTH-1 downto 0);
		      DRAM_DATA_OUT     : out std_logic_vector(WIDTH-1 downto 0));
  end component;
  
  -- IROM
  component ROM
  	 generic (FILE_PATH   : string;
		         ENTRIES		   : integer := 128;
		         WIDTH       : integer := 32);
  	 port (CS			: in std_logic;
  		      ADDR : in std_logic_vector((log2(ENTRIES))-1 downto 0);
  		      DATA	: out std_logic_vector(WIDTH-1 downto 0));
  end component;
  
  -- DRAM
  component SDRAM
	  generic (FILE_READ       : string;
	           FILE_PATH       : string;
		         ENTRIES         : integer := 128;
		         WIDTH           : integer := 32);
	  port (CLK  : in std_logic;
			    RST		: in std_logic;
			    EN		 : in std_logic;
			    RW		 : in std_logic;
			    ADDR : in std_logic_vector((log2(ENTRIES))-1 downto 0);
			    DIN  : in std_logic_vector(WIDTH-1 downto 0);
			    DOUT : out std_logic_vector(WIDTH-1 downto 0));
  end component;
  
  ----------------------------------------------------------------
  -- Signal Declaration
  ----------------------------------------------------------------
  
  signal s_CLK          : std_logic;
  signal s_RST          : std_logic;
  signal s_IRAM_EN				  : std_logic;
	signal s_IRAM_ADDR   	: std_logic_vector(iram_addr_size-1 downto 0);
  signal s_IRAM_DATA				: std_logic_vector(word_size-1 downto 0);
  signal s_DRAM_EN		    : std_logic;
  signal s_DRAM_RW		    : std_logic;
  signal s_DRAM_ADDR    : std_logic_vector(dram_addr_size-1 downto 0);
  signal s_DRAM_DATA_IN : std_logic_vector(word_size-1 downto 0);
  signal s_DRAM_DATA_OUT: std_logic_vector(word_size-1 downto 0);

begin
  
  ----------------------------------------------------------------
  -- Unit Under Test (UUT)
  ----------------------------------------------------------------
  UUT: DLX
    generic map (word_size)
    port map (s_CLK, s_RST, s_IRAM_ADDR, s_IRAM_DATA, s_DRAM_EN, s_DRAM_RW, s_DRAM_ADDR, s_DRAM_DATA_OUT, s_DRAM_DATA_IN);
      
  --------------------------------------------------------------------
  -- IRAM (Read-Only)
  --------------------------------------------------------------------   
  IRAM: ROM
    generic map("Y:/Microelectronic_Systems/DLX-Project/src_pro/DLX_simulation/test_bench/all_general_test.asm.mem", 2**iram_addr_size, word_size)
    port map (s_IRAM_EN, s_IRAM_ADDR, s_IRAM_DATA);
  
  --------------------------------------------------------------------
  -- DRAM
  --------------------------------------------------------------------
  DRAM: SDRAM
	 generic map("Y:/Microelectronic_Systems/DLX-Project/src_pro/DLX_simulation/test_bench/hex_load.txt", 
	             "Y:/Microelectronic_Systems/DLX-Project/src_pro/DLX_simulation/test_bench/hex_sdram.txt",
	             2**dram_addr_size, word_size)
	 port map (s_CLK, s_RST, s_DRAM_EN, s_DRAM_RW, s_DRAM_ADDR, s_DRAM_DATA_IN, s_DRAM_DATA_OUT);

  -- Clock Process
	CLOCK: process
	begin
		s_CLK<='0';
		wait for 0.5 ns;
		s_CLK<='1';
		wait for 0.5 ns;
	end process;

  -- Reset
  s_RST <= '0', '1' after 1.4 ns;

end architecture;
