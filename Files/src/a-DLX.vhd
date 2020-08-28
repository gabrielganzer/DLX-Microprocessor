library IEEE;
use IEEE.std_logic_1164.all;
use work.ROCACHE_PKG.all;
use work.RWCACHE_PKG.all;
use work.globals.all;
--use work.myTypes.all;

entity DLX is
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
end DLX;

-- Architecture
architecture structural of DLX is
--------------------------------------------------------------------
-- Components Declaration
--------------------------------------------------------------------

  -- Control Unit
  component CU_HW is
    generic (
      OP_CODE_SIZE                  : integer := op_size;           -- Op Code Size
      IR_SIZE                       : integer := instruction_size;  -- Instruction Register Size
      FUNC_SIZE                     : integer := function_size;     -- Func Field Size for R-Type Ops
      CW_SIZE                       : integer := control_word_size  -- Control Word Size
    ); -- Control Word Size
    port (
      Clk                : in  std_logic;  -- Clock
      Rst                : in  std_logic;  -- Reset: Active-Low
      -- Instruction Register
      IR_IN              : in  std_logic_vector(IR_SIZE - 1 downto 0);
      -- Pipeline stage 1
      EN0                : out std_logic;
      -- Pipeline stage 2
      EN1                : out std_logic;  -- enables the register le and the pipeline registers
      RF1                : out std_logic;  -- enables the read port 1 of the register ﬁle
      RF2                : out std_logic;  -- enables the read port 2 of the register ﬁle
      -- Pipeline stage 3
      EN2                : out std_logic;  -- enables the pipe registers
      S1                 : out std_logic;  -- input selection of the first multiplexer
      S2                 : out std_logic;  -- input selection of the second multiplexer
      ALU1               : out std_logic;  -- alu control bit 1
      ALU2               : out std_logic;  -- alu control bit 2
      ALU3               : out std_logic;  -- alu control bit 3
      ALU4               : out std_logic;  -- alu control bit 4
      EQ_COND            : out std_logic;
      JUMP_EN            : out std_logic;
      -- Pipeline stage 4
      EN3                : out std_logic;  -- enables the memory and the pipeline register
      DEN                : out std_logic;  -- enables the ram memory
      RW                 : out std_logic;  -- enables the read-out (1) or the write-in (0) of the memory
      -- Pipeline stage 5
      S3                 : out std_logic;  -- input selection of the multiplexer
      WF1                : out std_logic   -- enables the write port of the register ﬁle
    );
  end component;

  -- Datapath
  component datapath is
    port (
    -- inputs
      -- control signals
      clk     : in  std_logic;  -- clock
      rst     : in  std_logic;  -- reset: active-low
      -- stage 1
      en0     : in  std_logic;
      ir      : in  std_logic_vector(instruction_size - 1 downto 0);
      pc_in   : in  std_logic_vector(word_size - 1 downto 0);
      -- stage 2
      en1     : in  std_logic;  -- enables the register file and the pipeline registers
      rf1     : in  std_logic;  -- enables the read port 1 of the register file
      rf2     : in  std_logic;  -- enables the read port 2 of the register file
      -- stage 3
      en2     : in  std_logic;  -- enables the pipe registers
      s1      : in  std_logic;  -- input selection of the first multiplexer
      s2      : in  std_logic;  -- input selection of the second multiplexer
      alu1    : in  std_logic;  -- alu control bit 1
      alu2    : in  std_logic;  -- alu control bit 2
      alu3    : in  std_logic;  -- alu control bit 3
      alu4    : in  std_logic;  -- alu control bit 4
      eq_cond : in  std_logic;
      jump_en : in  std_logic;
      -- stage 4
      en3     : in  std_logic;  -- enables the dram and the pipeline register
      rw      : in  std_logic;  -- enables the read-out (1) or the write-in (0) of the memory
      den     : in  std_logic;
      dram_data_in    : in std_logic_vector(word_size - 1 downto 0);      -- from dram output
      dram_rw_en      : out std_logic;
      dram_enable     : out std_logic;
      dram_data_out   : out  std_logic_vector(word_size - 1 downto 0);      -- from dram output
      dram_addr       : out std_logic_vector(dram_addr_size - 1 downto 0); -- to dram address
      -- dram_wr_data : out std_logic_vector(word_size - 1 downto 0);      -- to dram input
      pc_out          : out std_logic_vector(word_size - 1 downto 0);
      -- stage 5
      s3    : in  std_logic;  -- input selection of the multiplexer
      wf1   : in  std_logic   -- enables the write port of the register ﬁle
    );
  end component; -- datapath

  ----------------------------------------------------------------
  -- Signals Declaration
  ----------------------------------------------------------------

  -- Instruction Register (IR) and Program Counter (pc_in_i) declaration
  signal IR : std_logic_vector(IR_SIZE - 1 downto 0);
  signal pc_in_i : std_logic_vector(PC_SIZE - 1 downto 0);
  signal pc_out_i : std_logic_vector(PC_SIZE - 1 downto 0);
  signal iram_issue_i : std_logic := '0';

  -- Control Unit Bus signals
  signal EN0_int  : std_logic;
  signal EN1_int  : std_logic;
  signal RF1_int  : std_logic;
  signal RF2_int  : std_logic;
  signal EN2_int  : std_logic;
  signal S1_int   : std_logic;
  signal S2_int   : std_logic;
  signal ALU1_int : std_logic;
  signal ALU2_int : std_logic;
  signal ALU3_int : std_logic;
  signal ALU4_int : std_logic;
  signal EQ_COND_int : std_logic;
  signal JUMP_EN_int : std_logic;
  signal EN3_int  : std_logic;
  signal DEN_int  : std_logic;
  signal RW_int   : std_logic;
  signal S3_int   : std_logic;
  signal WF1_int  : std_logic;

  begin  -- DLX
    -- purpose: Instruction Register Process
    -- type   : sequential
    -- inputs : Clk, Rst, IRAM_DATA, EN0_int
    -- outputs: IR_IN_i
    IR_P: process (Clk, Rst)
    begin  -- process IR_P
      if Rst = '0' then                 -- asynchronous reset (active low)
        IR <= (others => '0');
      elsif Clk'event and Clk = '1' then  -- rising clock edge
        if (EN0_int = '1') then
          IR <= IRAM_DATA;
        end if;
      end if;
    end process IR_P;

    -- purpose: Program Counter Process
    -- type   : sequential
    -- inputs : Clk, Rst, pc_out_i
    -- outputs: IRAM_ADDRESS, pc_in_i
    PC_P: process (Clk, Rst)
    begin  -- process PC_P
      if Rst = '0' then                 -- asynchronous reset (active low)
        pc_in_i  <= (others => '0');
        IRAM_ADDRESS <= (others => '0');
      elsif Clk'event and Clk = '1' then  -- rising clock edge
        if (EN0_int = '1') then
          pc_in_i <= pc_out_i;
          IRAM_ADDRESS <= pc_out_i;
        end if;
      end if;
    end process PC_P;

    -- Control Unit Instantiation
    CU : CU_HW
    port map (
      Clk   => Clk,
      Rst   => Rst,
      IR_IN => IR,
      EN0   => EN0_int,
      EN1   => EN1_int,
      RF1   => RF1_int,
      RF2   => RF2_int,
      EN2   => EN2_int,
      S1    => S1_int ,
      S2    => S2_int ,
      ALU1  => ALU1_int,
      ALU2  => ALU2_int,
      ALU3  => ALU3_int,
      ALU4  => ALU4_int,
      EQ_COND => EQ_COND_int,
      JUMP_EN => JUMP_EN_int,
      EN3   => EN3_int,
      DEN   => DEN_int,
      RW    => RW_int ,
      S3    => S3_int ,
      WF1   => WF1_int
    );

  -- DATAPATH
  dp : datapath
  port map(
    clk           => Clk,
    rst           => Rst,
    -- stage 1
    en0           => EN0_int,
    ir            => IR,
    pc_in         => pc_in_i,
    -- stage 2
    en1           => EN1_int,
    rf1           => RF1_int,
    rf2           => RF2_int,
    -- stage 3
    en2           => EN2_int,
    s1            => S1_int ,
    s2            => S2_int ,
    alu1          => ALU1_int,
    alu2          => ALU2_int,
    alu3          => ALU3_int,
    alu4          => ALU4_int,
    eq_cond       => EQ_COND_int,
    jump_en       => JUMP_EN_int,
    -- stage 4
    en3           => EN3_int,
    rw            => RW_int,
    den           => DEN_int,
    dram_data_in  => DRAM_DATA_in,
    dram_rw_en    => DRAM_READNOTWRITE,
    dram_enable   => DRAM_ISSUE,
    dram_data_out => DRAM_DATA_out,
    dram_addr     => DRAM_ADDRESS,
    pc_out        => pc_out_i,
    -- stage 5
    s3            => S3_int,
    wf1           => WF1_int
  );

  IRAM_ISSUE <= iram_issue_i;

end structural;
