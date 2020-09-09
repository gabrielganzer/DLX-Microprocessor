library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.globals.all;

entity TB_CU is
end TB_CU;

architecture TESTBENCH of TB_CU is
  --------------------------------------------------------------------
  -- Components Declaration
  --------------------------------------------------------------------
  -- CU
  component DLX_CU is
  generic (
    FUNC_SIZE          :     integer := function_size;      -- Func Field Size for R-Type Ops
    OPCODE_SIZE        :     integer := op_size;            -- Op Code Size
    IR_SIZE            :     integer := instruction_size;   -- Instruction Register Size    
    CW_SIZE            :     integer := control_word_size); -- Control Word Size
  port (
    CLK                : in  std_logic;  -- Clock
    RST                : in  std_logic;  -- Synchronous, active-high
    -- Instruction Register
    IR_DATA_IN         : in  std_logic_vector(IR_SIZE - 1 downto 0);    
    -- Stage 1: instruction fetch
    IR_LATCH_EN        : out std_logic;  -- Instruction Register Latch Enable
    NPC_LATCH_EN       : out std_logic;  -- Next Program Counter Register Latch Enable
    -- Stage 2: instruction decode/register fetch
    RegA_LATCH_EN      : out std_logic;  -- Register A Latch Enable
    RegB_LATCH_EN      : out std_logic;  -- Register B Latch Enable
    RegIMM_LATCH_EN    : out std_logic;  -- Immediate Register Latch Enable
    -- Stage 3: execute/address calculation
    MUXA_SEL           : out std_logic;  -- MUX-A Sel
    MUXB_SEL           : out std_logic;  -- MUX-B Sel
    ALU_OUTREG_EN      : out std_logic;  -- ALU Output Register Enable
    EQ_COND            : out std_logic;  -- Branch if (not) Equal to Zero
    ALU_OPCODE         : out aluOp;      -- Implicit coding
    -- Stage 4: memory access
    DRAM_RW            : out std_logic;  -- Data RAM Write Enable
    LMD_LATCH_EN       : out std_logic;  -- LMD Register Latch Enable
    JUMP_EN            : out std_logic;  -- JUMP Enable Signal for PC input MUX
    PC_LATCH_EN        : out std_logic;  -- Program Counte Latch Enable
    -- Stage 5: write-back
    WB_MUX_SEL         : out std_logic;  -- Write Back MUX Sel
    RF_WE              : out std_logic   -- Register File Write Enable
  );
  end component;
  
  ----------------------------------------------------------------
  -- Signal Declaration
  ----------------------------------------------------------------
  signal CLK, RST : std_logic;
  signal INST     : std_logic_vector(instruction_size-1 downto 0);  
  signal CW1      : std_logic_vector(1 downto 0);     -- 1st stage (2-bit)
  signal CW2      : std_logic_vector(3 downto 0);     -- 2nd stage (4-bit)
  signal CW3      : std_logic_vector(3 downto 0);     -- 3rd stage (4-bit)
  signal CW4      : std_logic_vector(3 downto 0);     -- 4th stage (4-bit)
  signal CW5      : std_logic_vector(1 downto 0);     -- 5th stage (2-bit)
  signal OPCODE   : aluOp;

begin
  
  ----------------------------------------------------------------
  -- Unit Under Test (UUT)
  ----------------------------------------------------------------
  UUT: DLX_CU
    generic map (function_size, op_size, instruction_size, control_word_size)
    port map (CLK, RST, INST, CW1(1), CW1(0), CW2(2), CW2(1), CW2(0), CW3(3), CW3(2), CW3(1), CW3(0), 
                      OPCODE, CW4(3), CW4(2), CW4(1), CW4(0), CW5(1), CW5(0));

  -- Clock Process
	CLOCK: process
	begin
		CLK<='0';
		wait for 5 ns;
		CLK<='1';
		wait for 5 ns;
	end process;
	
  -- Stimuli process
  STIMULI: process
  begin
    -- RST
    RST   <= '1';
    INST  <= (others => '0');
    wait for 2.5 ns;
    RST   <= '0';
    INST  <= RTYPE&"00001"&"00010"&"00100"&R_ADD;
    wait until (CLK = '1' and CLK'event);
    INST  <= I_ANDI&"00001"&"00010"&x"0001";
    wait;
  end process;

end architecture;
