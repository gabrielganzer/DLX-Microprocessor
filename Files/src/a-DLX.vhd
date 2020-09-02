----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: DLX
-- Function: DLX processor
-- Input:
-- Output:
-- Architecture: structural
-- Library/package: ieee.std_logic_ll64, work.globals
-- Date: 12/08/2020
----------------------------------------------------------------------------------
library ieee;
library work;
use ieee.std_logic_1164.all;
use work.globals.all;

entity DLX is
  generic (
    IR_SIZE      : integer := 32      -- Instruction Register Size
  );
  port (
    -- Inputs
    CLK               : in    std_logic;    -- Clock
    RST               : in    std_logic    -- Reset: Active-High
  );
end entity;

architecture STRUCTURAL of DLX is
  --------------------------------------------------------------------
  -- Components Declaration
  --------------------------------------------------------------------

  -- Control Unit
  component DLX_CU
  generic (
    FUNC_SIZE          :     integer := function_size;  -- Func Field Size for R-Type Ops
    OPCODE_SIZE        :     integer := op_size;   -- Op Code Size
    IR_SIZE            :     integer := instruction_size;  -- Instruction Register Size    
    CW_SIZE            :     integer := control_word_size);  -- Control Word Size
  port (
    CLK                : in  std_logic;  -- Clock
    RST                : in  std_logic;  -- Synchronous, active-high
    -- Instruction Register
    IR_IN              : in  std_logic_vector(IR_SIZE - 1 downto 0);    
    -- Stage 1: instruction fetch
    IRAM_LATCH_EN      : out std_logic;  -- Instruction Memory Latch Enable
    IR_LATCH_EN        : out std_logic;  -- Instruction Register Latch Enable
    NPC_LATCH_EN       : out std_logic;  -- Next Program Counter Register Latch Enable
    -- Stage 2: instruction decode/register fetch
    RF_LATCH_EN        : out std_logic;  -- New Program Counter Latch Enable
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
    DRAM_LATCH_EN      : out std_logic;  -- Data Memory Latch Enable
    DRAM_WE            : out std_logic;  -- Data RAM Write Enable
    LMD_LATCH_EN       : out std_logic;  -- LMD Register Latch Enable
    JUMP_EN            : out std_logic;  -- JUMP Enable Signal for PC input MUX
    PC_LATCH_EN        : out std_logic;  -- Program Counte Latch Enable
    -- Stage 5: write-back
    WB_MUX_SEL         : out std_logic;  -- Write Back MUX Sel
    RF_WE              : out std_logic   -- Register File Write Enable
  );
  end component;

  -- Datapath
  component DATAPATH
    generic (
      WIDTH     : integer := word_size;
      LENGTH    : integer := addr_size;
      DEPTH     : integer := mem_size;
      RADIX     : integer := radix_size;
      OPCODE    : integer:= op_size
    );
    port (
      CLK             : in  std_logic;
      RST             : in  std_logic; -- Synchronous, active-high
      -- Stage 1: instruction fetch
      IRAM_LATCH_EN   : in std_logic;  -- Instruction Memory Latch Enable
      IR_LATCH_EN     : in std_logic;  -- Instruction Register Latch Enable
      NPC_LATCH_EN    : in std_logic;  -- Next Program Counter Register Latch Enable
      -- Stage 2: instruction decode/register fetch
      RF_LATCH_EN     : in std_logic;  -- New Program Counter Latch Enable
      RegA_LATCH_EN   : in std_logic;  -- Register A Latch Enable
      RegB_LATCH_EN   : in std_logic;  -- Register B Latch Enable
      RegIMM_LATCH_EN : in std_logic;  -- Immediate Register Latch Enable
      -- Stage 3: execute/address calculation
      MUXA_SEL        : in std_logic;  -- MUX-A Sel
      MUXB_SEL        : in std_logic;  -- MUX-B Sel
      ALU_OUTREG_EN   : in std_logic;  -- ALU Output Register Enable
      EQ_COND         : in std_logic;  -- Branch if (not) Equal to Zero
      ALU_OPCODE      : in aluOp;      -- Implicit coding
      -- Stage 4: memory access
      DRAM_LATCH_EN   : in std_logic;  -- Data Memory Latch Enable
      DRAM_WE         : in std_logic;  -- Data RAM Write Enable
      LMD_LATCH_EN    : in std_logic;  -- LMD Register Latch Enable
      JUMP_EN         : in std_logic;  -- JUMP Enable Signal for PC input MUX
      PC_LATCH_EN     : in std_logic;  -- Program Counter Latch Enable
      -- Stage 5: write-back
      WB_MUX_SEL      : in std_logic;  -- Write Back MUX Sel
      RF_WE           : in std_logic;  -- Register File Write Enable
      -- Instruction Register
      IR_OUT          : out  std_logic_vector(WIDTH - 1 downto 0)
    ); 
  end component;

  ----------------------------------------------------------------
  -- Signals Declaration
  ----------------------------------------------------------------

  -- Instruction Register (IR) and ALU Opcode (ALU_OPCODE)
  signal w_IR                 : std_logic_vector(IR_SIZE - 1 downto 0);
  signal w_ALU_OPCODE         :  aluOp;

  -- Control Unit Bus signals   
  signal w_IRAM_LATCH_EN      :  std_logic;
  signal w_IR_LATCH_EN        :  std_logic;
  signal w_NPC_LATCH_EN       :  std_logic;
  signal w_RF_LATCH_EN        :  std_logic;
  signal w_RegA_LATCH_EN      :  std_logic;
  signal w_RegB_LATCH_EN      :  std_logic;
  signal w_RegIMM_LATCH_EN    :  std_logic;
  signal w_MUXA_SEL           :  std_logic;
  signal w_MUXB_SEL           :  std_logic;
  signal w_ALU_OUTREG_EN      :  std_logic;
  signal w_EQ_COND            :  std_logic;
  signal w_DRAM_LATCH_EN      :  std_logic;
  signal w_DRAM_WE            :  std_logic;
  signal w_LMD_LATCH_EN       :  std_logic;
  signal w_JUMP_EN            :  std_logic;
  signal w_PC_LATCH_EN        :  std_logic;
  signal w_WB_MUX_SEL         :  std_logic;
  signal w_RF_WE              :  std_logic;
    
  begin

    -- Control Unit Instantiation
    CU: DLX_CU
    generic map (function_size, op_size, instruction_size, control_word_size)
    port map (
      CLK,
      RST,
      w_IR,
      w_IRAM_LATCH_EN,
      w_IR_LATCH_EN,
      w_NPC_LATCH_EN,
      w_RF_LATCH_EN,
      w_RegA_LATCH_EN,
      w_RegB_LATCH_EN,
      w_RegIMM_LATCH_EN,
      w_MUXA_SEL,
      w_MUXB_SEL,
      w_ALU_OUTREG_EN,
      w_EQ_COND,
      w_ALU_OPCODE,
      w_DRAM_LATCH_EN,
      w_DRAM_WE,
      w_LMD_LATCH_EN,
      w_JUMP_EN,
      w_PC_LATCH_EN,
      w_WB_MUX_SEL,
      w_RF_WE
    );

  -- Datapath instantiation
  DP: datapath
  generic map (word_size, addr_size, mem_size, radix_size, op_size)
  port map(
      CLK,
      RST,
      w_IRAM_LATCH_EN,
      w_IR_LATCH_EN,
      w_NPC_LATCH_EN,
      w_RF_LATCH_EN,
      w_RegA_LATCH_EN,
      w_RegB_LATCH_EN,
      w_RegIMM_LATCH_EN,
      w_MUXA_SEL,
      w_MUXB_SEL,
      w_ALU_OUTREG_EN,
      w_EQ_COND,
      w_ALU_OPCODE,
      w_DRAM_LATCH_EN,
      w_DRAM_WE,
      w_LMD_LATCH_EN,
      w_JUMP_EN,
      w_PC_LATCH_EN,
      w_WB_MUX_SEL,
      w_RF_WE,
      w_IR
  );

end architecture;
