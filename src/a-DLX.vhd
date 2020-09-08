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
    WIDTH     : integer := word_size
  );
  port (
    -- Inputs
    CLK       : in    std_logic;    -- Clock
    RST       : in    std_logic;    -- Synchronous, active-high
		-- IRAM signals
		IRAM_ADDR : out std_logic_vector(iram_addr_size-1 downto 0);
		IRAM_DATA	: in std_logic_vector(WIDTH-1 downto 0);
		-- DRAM signals
		DRAM_RW		 : out std_logic;
		DRAM_ADDR : out std_logic_vector(dram_addr_size-1 downto 0);
		DRAM_DIN  : out std_logic_vector(WIDTH-1 downto 0);
		DRAM_DOUT : in std_logic_vector(WIDTH-1 downto 0)
  );
end entity;

architecture STRUCTURAL of DLX is
  --------------------------------------------------------------------
  -- Component Declaration
  --------------------------------------------------------------------

  -- Control Unit
  component DLX_CU
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
    DRAM_RW            : out std_logic;  -- Data RAM Write Enable
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
      RADIX     : integer := radix_size;
      OPCODE    : integer:= op_size
    );
    port (
      CLK             : in  std_logic;
      RST             : in  std_logic; -- Synchronous, active-high
      -- Stage 1: instruction fetch
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
      LMD_LATCH_EN    : in std_logic;  -- LMD Register Latch Enable
      JUMP_EN         : in std_logic;  -- JUMP Enable Signal for PC input MUX
      PC_LATCH_EN     : in std_logic;  -- Program Counter Latch Enable
      -- Stage 5: write-back
      WB_MUX_SEL      : in std_logic;  -- Write Back MUX Sel
      RF_WE           : in std_logic;  -- Register File Write Enable
      -- IRAM signals
      IRAM_ADDR    			: out std_logic_vector(iram_addr_size-1 downto 0);
    		IRAM_DATA_OUT   : in std_logic_vector(WIDTH-1 downto 0);
		  -- DRAM signals
			DRAM_ADDR       : out std_logic_vector(dram_addr_size-1 downto 0);
			DRAM_DATA_IN    : out std_logic_vector(WIDTH-1 downto 0);
			DRAM_DATA_OUT   : in std_logic_vector(WIDTH-1 downto 0)
    ); 
  end component;

  ----------------------------------------------------------------
  -- Signal Declaration
  ----------------------------------------------------------------

  -- Instruction Register (IR) and ALU Opcode (ALU_OPCODE)
  signal w_IR_DATA            : std_logic_vector(WIDTH-1 downto 0);
  signal w_ALU_OPCODE         :  aluOp;

  -- Control Unit Bus signals   
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
  signal w_LMD_LATCH_EN       :  std_logic;
  signal w_JUMP_EN            :  std_logic;
  signal w_PC_LATCH_EN        :  std_logic;
  signal w_WB_MUX_SEL         :  std_logic;
  signal w_RF_WE              :  std_logic;
    
begin
  
  --------------------------------------------------------------------
  -- Control Unit
  --------------------------------------------------------------------
  CU: DLX_CU
    generic map (function_size, op_size, instruction_size, control_word_size)
    port map (
      CLK             => CLK,
      RST             => RST,
      IR_DATA_IN      => w_IR_DATA,  
      IR_LATCH_EN     => w_IR_LATCH_EN,
      NPC_LATCH_EN    => w_NPC_LATCH_EN,
      RF_LATCH_EN     => w_RF_LATCH_EN,
      RegA_LATCH_EN   => w_RegA_LATCH_EN,
      RegB_LATCH_EN   => w_RegB_LATCH_EN,
      RegIMM_LATCH_EN => w_RegIMM_LATCH_EN,
      MUXA_SEL        => w_RegIMM_LATCH_EN,
      MUXB_SEL        => w_MUXB_SEL,
      ALU_OUTREG_EN   => w_ALU_OUTREG_EN,
      EQ_COND         => w_EQ_COND,
      ALU_OPCODE      => w_ALU_OPCODE,
      DRAM_RW         => DRAM_RW,
      LMD_LATCH_EN    => w_LMD_LATCH_EN,
      JUMP_EN         => w_JUMP_EN,
      PC_LATCH_EN     => w_PC_LATCH_EN,
      WB_MUX_SEL      => w_WB_MUX_SEL,
      RF_WE           => w_RF_WE
    );

  --------------------------------------------------------------------
  -- Datapath
  --------------------------------------------------------------------
  DP: datapath
    generic map (word_size, addr_size, radix_size, op_size)
    port map(
        CLK             => CLK,
        RST             => RST,
        IR_LATCH_EN     => w_IR_LATCH_EN,
        NPC_LATCH_EN    => w_NPC_LATCH_EN,
        RF_LATCH_EN     => w_RF_LATCH_EN,
        RegA_LATCH_EN   => w_RegA_LATCH_EN,
        RegB_LATCH_EN   => w_RegB_LATCH_EN,
        RegIMM_LATCH_EN => w_RegIMM_LATCH_EN,
        MUXA_SEL        => w_MUXA_SEL,
        MUXB_SEL        => w_MUXB_SEL,
        ALU_OUTREG_EN   => w_ALU_OUTREG_EN,
        EQ_COND         => w_EQ_COND,
        ALU_OPCODE      => w_ALU_OPCODE,
        LMD_LATCH_EN    => w_LMD_LATCH_EN,
        JUMP_EN         => w_JUMP_EN,
        PC_LATCH_EN     => w_PC_LATCH_EN,
        WB_MUX_SEL      => w_WB_MUX_SEL,
        RF_WE           => w_RF_WE,
        IRAM_ADDR    			=> IRAM_ADDR,
      		IRAM_DATA_OUT   => IRAM_DATA,
			  DRAM_ADDR       => DRAM_ADDR,
			  DRAM_DATA_IN    => DRAM_DIN,
			  DRAM_DATA_OUT   => DRAM_DOUT
  );

end architecture;
