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
  generic (
    WIDTH     : integer := word_size
  );
  port (
    CLK       : in    std_logic;
    RST       : in    std_logic;
		IRAM_ADDR : out std_logic_vector(6 downto 0);
		IRAM_DATA	: in std_logic_vector(WIDTH-1 downto 0);
		DRAM_RW		 : out std_logic;
		DRAM_ADDR : out std_logic_vector(6 downto 0);
		DRAM_DIN  : out std_logic_vector(WIDTH-1 downto 0);
		DRAM_DOUT : in std_logic_vector(WIDTH-1 downto 0)
  );
  end component;
  
  -- IRAM
  component ROMEM
	generic (
		FILE_PATH   : string;
		ENTRIES		   : integer := 128;
		WIDTH       : integer := 32
	);
	port (
		CLK	        : in std_logic; 
		RST					  : in std_logic;
		EN				    : in std_logic;
		ADDR   				 : in std_logic_vector((log2(ENTRIES))-1 downto 0);
		DATA				    : out std_logic_vector(WIDTH-1 downto 0)
	);
  end component;
  
  -- DRAM
  component RWMEM
	generic (
		FILE_PATH       : string;
		ENTRIES         : integer := 128;
		WIDTH           : integer := 32
	);
	port (
			CLK  : in std_logic;
			RST		: in std_logic;
			EN		 : in std_logic;
			RW		 : in std_logic;
			ADDR : in std_logic_vector((log2(ENTRIES))-1 downto 0);
			DIN  : in std_logic_vector(WIDTH-1 downto 0);
			DOUT : out std_logic_vector(WIDTH-1 downto 0)
		);
  end component;
  
  ----------------------------------------------------------------
  -- Signal Declaration
  ----------------------------------------------------------------
  
  signal s_CLK       : std_logic;
  signal s_RST       : std_logic;
 	signal s_EN		      : std_logic;
	signal s_IRAM_ADDR : std_logic_vector(6 downto 0);
	signal s_IRAM_DATA	: std_logic_vector(word_size-1 downto 0);
	signal s_DRAM_RW		 : std_logic;
	signal s_DRAM_ADDR : std_logic_vector(6 downto 0);
	signal s_DRAM_DIN  : std_logic_vector(word_size-1 downto 0);
	signal s_DRAM_DOUT : std_logic_vector(word_size-1 downto 0);

begin
  
  ----------------------------------------------------------------
  -- Unit Under Test (UUT)
  ----------------------------------------------------------------
  UUT: DLX
    generic map (word_size)
    port map (s_CLK, s_RST, s_IRAM_ADDR, s_IRAM_DATA, s_DRAM_RW, s_DRAM_ADDR, s_DRAM_DIN, s_DRAM_DOUT);
  
  IRAM: ROMEM
    generic map("Y:/Microelectronic_Systems/DLX-Project/src/test_bench/hex_iram.txt", 128, word_size)
    port map (s_CLK, s_RST, s_EN, s_IRAM_ADDR, s_IRAM_DATA);
  
  DRAM: RWMEM
    generic map("Y:/Microelectronic_Systems/DLX-Project/src/test_bench/hex_dram.txt", 128, word_size)
    port map (s_CLK, s_RST, s_EN, s_DRAM_RW, s_DRAM_ADDR, s_DRAM_DIN, s_DRAM_DOUT);

  -- Clock Process
	CLOCK: process
	begin
		s_CLK<='0';
		wait for 5 ns;
		s_CLK<='1';
		wait for 5 ns;
	end process;
	
  -- Stimuli process
  STIMULI: process
  begin
    -- RST
    s_RST     <= '1';
    s_EN      <= '0';
    wait for 10 ns;
    s_RST     <= '0';
    s_EN      <= '1';
    wait;
  end process;

end architecture;
