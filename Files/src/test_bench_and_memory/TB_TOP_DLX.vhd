library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.ROCACHE_PKG.all;
use work.RWCACHE_PKG.all;

entity DLX_TestBench is
end DLX_TestBench;

architecture tb of DLX_TestBench is
  component ROMEM is
    generic (
      file_path : -- string(1 to 37) := "C://DLX//dlx-master//rocache//hex.txt";
            string;
      ENTRIES   : integer := 128;
      WORD_SIZE : integer := 32;
      data_delay  : natural := 0
    );
    port (
      CLK         : in std_logic;
      RST         : in std_logic;
      ADDRESS     : in std_logic_vector(WORD_SIZE - 1 downto 0);
      ENABLE      : in std_logic;
      DATA_READY  : out std_logic;
      DATA        : out std_logic_vector(WORD_SIZE - 1 downto 0)
    );
  end component;

  component RWMEM is
		generic(
	      file_path: string;
	      file_path_init: string;
	      Data_size : natural := 32;
	      Instr_size: natural := 32;
	      RAM_DEPTH:  natural := 128
	    );
	  port (
	      CLK             : in std_logic;
	      RST             : in std_logic;
	      ADDR            : in std_logic_vector(Instr_size - 1 downto 0);
	      ENABLE          : in std_logic;
	      READNOTWRITE    : in std_logic;
	      DATA_IN         : in std_logic_vector(Data_size-1 downto 0);
	      DATA_READY      : out std_logic;
	      DATA_OUT        : out std_logic_vector(Data_size-1 downto 0)
	    );
  end component;

  component DLX is
    generic (
      IR_SIZE      : integer := 32;      -- Instruction Register Size
      PC_SIZE      : integer := 32       -- Program Counter Size
    );
    port (
      -- Inputs
      CLK               : in    std_logic;    -- Clock
      RST               : in    std_logic;    -- Reset: Active-High
      -- Instr_size = 32, Data_size = 32
      IRAM_ADDRESS      : out   std_logic_vector(Instr_size - 1 downto 0);
      IRAM_ISSUE        : out   std_logic;
      IRAM_READY        : in    std_logic;
      IRAM_DATA         : in    std_logic_vector(Data_size - 1 downto 0);

      DRAM_ADDRESS      : out   std_logic_vector(Instr_size - 1 downto 0);
      DRAM_READNOTWRITE : out   std_logic;
      DRAM_ISSUE        : out   std_logic;
      DRAM_DATA_in      : in    std_logic_vector(Data_size - 1 downto 0);
      DRAM_READY        : in    std_logic;
      DRAM_DATA_out     : out   std_logic_vector(Data_size - 1 downto 0)
    );
  end component;

  signal CLK                : std_logic := '0';   -- Clock
  signal RST                : std_logic;    -- Reset : Active-Low
  signal IRAM_ADDRESS       : std_logic_vector(Instr_size - 1 downto 0);
  signal IRAM_ENABLE        : std_logic := '1';
  signal IRAM_READY         : std_logic;
  signal IRAM_DATA          : std_logic_vector(Data_size-1 downto 0);
  signal IRAM_ISSUE         : std_logic;

  signal DRAM_ADDRESS       : std_logic_vector(Instr_size-1 downto 0);
  signal DRAM_ENABLE        : std_logic;
  signal DRAM_READNOTWRITE  : std_logic;
  signal DRAM_READY         : std_logic;
  signal DRAM_DATA_in       : std_logic_vector(Data_size-1 downto 0);
  signal DRAM_DATA_out      : std_logic_vector(Data_size-1 downto 0);

begin
  -- IRAM
  IRAM : ROMEM
    generic map ("C:/Workspace/DLX/src/test_bench_and_memory/TB_romem/hex.txt")
    port map (CLK, RST, IRAM_ADDRESS, IRAM_ENABLE, IRAM_READY, IRAM_DATA);

  -- DRAM
  DRAM : RWMEM
    generic map("C:/Workspace/DLX/src/test_bench_and_memory/TB_rwmem/hex.txt", "C:/Workspace/DLX/src/test_bench_and_memory/TB_rwmem/hex_init.txt")
    port map (CLK, RST, DRAM_ADDRESS, DRAM_ENABLE, DRAM_READNOTWRITE, DRAM_DATA_out, DRAM_READY, DRAM_DATA_in);

  -- DLX
  DLX_PD : DLX
    port map (
      CLK               => CLK,
      RST               => RST,
      IRAM_ADDRESS      => IRAM_ADDRESS,
      IRAM_ISSUE        => IRAM_ISSUE,
      IRAM_READY        => IRAM_READY,
      IRAM_DATA         => IRAM_DATA,
      DRAM_ADDRESS      => DRAM_ADDRESS,
      DRAM_READNOTWRITE => DRAM_READNOTWRITE,
      DRAM_ISSUE        => DRAM_ENABLE,
      DRAM_DATA_in      => DRAM_DATA_in,
      DRAM_READY        => DRAM_READY,
      DRAM_DATA_out     => DRAM_DATA_out
    );

  Clk <= not Clk after 10 ns;
  Rst <= '0', '1' after 5 ns;

end tb;
