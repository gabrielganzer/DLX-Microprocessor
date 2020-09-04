----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: DATAPATH
-- Function: DLX data-path
-- Input:
-- Output:
-- Architecture: structural
-- Library/package: ieee.std_logic_ll64, work.globals
-- Date: 12/08/2020
----------------------------------------------------------------------------------
library IEEE;
library work;
use IEEE.std_logic_1164.all;
use work.globals.all;

entity DATAPATH is
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
      IRAM_ADDR    			: out std_logic_vector(6 downto 0);
    		IRAM_DATA_OUT   : in std_logic_vector(WIDTH-1 downto 0);
		  -- DRAM signals
			DRAM_ADDR       : out std_logic_vector(6 downto 0);
			DRAM_DATA_IN    : out std_logic_vector(WIDTH-1 downto 0);
			DRAM_DATA_OUT   : in std_logic_vector(WIDTH-1 downto 0);
			-- Instruction Register Data Out
			IR_DATA         : out std_logic_vector(WIDTH-1 downto 0)
    ); 
end entity;

architecture STRUCTURAL of DATAPATH is
  
  -- Components
  -- Multiplexer 2x1
  component MUX21_GENERIC
    generic(NBIT: integer);
    port (S1  :	in 	std_logic_vector(NBIT-1 downto 0);
	        S0  :	in	std_logic_vector(NBIT-1 downto 0);
	        SEL :	in	std_logic;
	        Y   :	out	std_logic_vector(NBIT-1 downto 0));
  end component;
  -- Register
  component REGISTER_GENERIC
    generic (WIDTH: integer := 32);
    port (CLK  : in std_logic;
          RST  : in std_logic;
          EN   : in std_logic;
          DIN  : in std_logic_vector(WIDTH-1 downto 0);    
          DOUT : out std_logic_vector(WIDTH-1 downto 0));
  end component;
  -- PC increment
  component PC_INCREMENT
    generic (WIDTH : integer:= instruction_size);
    port (PC  : in std_logic_vector(WIDTH-1 downto 0);    
          NPC : out std_logic_vector(WIDTH-1 downto 0)
    );
  end component;
  -- Register file
  component REGISTER_FILE
    generic (
      WIDTH: integer:= word_size;
      LENGTH: integer:= addr_size);
    port (CLK     :IN std_logic;
          RST     :IN std_logic;
          EN      :IN std_logic;
          RD1     :IN std_logic;
          RD2     :IN std_logic;
          WR      :IN std_logic;
          DATAIN  :IN std_logic_vector(WIDTH-1 downto 0);
          OUT1    :OUT std_logic_vector(WIDTH-1 downto 0);
          OUT2    :OUT std_logic_vector(WIDTH-1 downto 0);
          ADD_WR  :IN std_logic_vector(LENGTH-1 downto 0);
          ADD_RD1 :IN std_logic_vector(LENGTH-1 downto 0);
          ADD_RD2 :IN std_logic_vector(LENGTH-1 downto 0));
  end component;
  -- Sign extend
  component SIGN_EXTEND
    port (IMMU : in std_logic_vector(15 downto 0);    
          IMMS : out std_logic_vector(31 downto 0));
  end component;
  -- Arithmetic Logic Unit
  component ALU
    generic (WIDTH: integer:= word_size;
             RADIX: integer:= radix_size;
             OPCODE: integer:= op_size);
    port (A  :  in	std_logic_vector(WIDTH-1 downto 0);
          B  :  in	std_logic_vector(WIDTH-1 downto 0);
          OP :  in	aluOp;                             
          Y  :  out	std_logic_vector(WIDTH-1 downto 0));
  end component;
  -- Zero Detector
  component ZERO_DETECTOR
    generic (WIDTH : integer:= word_size);
    port (A : in  std_logic_vector(WIDTH-1 downto 0);
          Y : out std_logic);
  end component;
  
  -- Signals
  signal w_PC_OUT : std_logic_vector(WIDTH-1 downto 0);
  signal w_NPC_IN, w_NPC_OUT : std_logic_vector(WIDTH-1 downto 0);
  signal w_IRAM_IN, w_IR_OUT : std_logic_vector(WIDTH-1 downto 0);
  signal w_RegA_IN, w_RegA_OUT : std_logic_vector(WIDTH-1 downto 0);
  signal w_RegB_IN, w_RegB_OUT : std_logic_vector(WIDTH-1 downto 0);
  signal w_RD1, w_RD2, w_RD: std_logic_vector(LENGTH-1 downto 0);
  signal w_IMMU_IN: std_logic_vector((WIDTH/2)-1 downto 0);
  signal w_IMMS_IN, w_RegIMM_OUT: std_logic_vector(WIDTH-1 downto 0);
  signal w_A_MUX_OUT, w_B_MUX_OUT: std_logic_vector(WIDTH-1 downto 0);
  signal w_ALU_OUT : std_logic_vector(WIDTH-1 downto 0);
  signal w_RegALU_OUT : std_logic_vector(WIDTH-1 downto 0);
  signal w_Z, w_CMP_OUT: std_logic;
  signal w_LMD_OUT : std_logic_vector(WIDTH-1 downto 0);
  signal w_MUX_MEM_SEL: std_logic;
  signal w_MEM_MUX_OUT: std_logic_vector(WIDTH-1 downto 0);
  signal w_WB_MUX_OUT: std_logic_vector(WIDTH-1 downto 0);
  
begin
  -------------------------------------------------------------------------------
  --                           RTL SIGNAL ASSIGNMENT                           --
  -------------------------------------------------------------------------------
  
  -- IRAM signals
  IRAM_ADDR <= w_PC_OUT(6 downto 0);
  IR_DATA <= w_IR_OUT;
  
  -- Register File Address Signal
  REG_FILE_ADDR: process(w_IR_OUT)
  begin
    if w_IR_OUT(opcode_up downto opcode_down) = RTYPE then
      w_RD1     <= w_IR_OUT(r1_up downto r1_down);
      w_RD2     <= w_IR_OUT(r2_up downto r2_down);
      w_RD      <= w_IR_OUT(r3_up downto r3_down);
      w_IMMU_IN <= (others => '0');
    elsif w_IR_OUT(opcode_up downto opcode_down) = I_SW then
      w_RD1     <= w_IR_OUT(r1_up downto r1_down);
      w_RD2     <= w_IR_OUT(r2_up downto r2_down);
      w_RD      <= (others => '0');
      w_IMMU_IN <= w_IR_OUT(inp2_up downto inp2_down);
    else
      w_RD1     <= w_IR_OUT(r1_up downto r1_down);
      w_RD2     <= (others => '0');
      w_RD      <= w_IR_OUT(r2_up downto r2_down);
      w_IMMU_IN <= w_IR_OUT(inp2_up downto inp2_down);
    end if;
  end process;
  
  -- Branch Condition Signal
  w_CMP_OUT <= w_Z xnor EQ_COND; 
  
  -- Mux Memory Access Select Signal
  w_MUX_MEM_SEL <= w_CMP_OUT and JUMP_EN;
  
  -- DRAM signals
  DRAM_ADDR <= w_RegALU_OUT(6 downto 0);
	DRAM_DATA_IN <= w_RegB_OUT;
  
  -------------------------------------------------------------------------------
  --                                  Stage 1                                  --
  -------------------------------------------------------------------------------
  
  -- Program Counter (PC)
  PC: REGISTER_GENERIC
    generic map(WIDTH)
    port map(CLK, RST, PC_LATCH_EN, w_MEM_MUX_OUT, w_PC_OUT);
  
  -- Instruction Register (IR)
  IR: REGISTER_GENERIC
    generic map(WIDTH)
    port map(CLK, RST, IR_LATCH_EN, IRAM_DATA_OUT, w_IR_OUT);
  
  -- Program Counter Increment (INC)
  INC: PC_INCREMENT
    generic map(WIDTH)
    port map(w_PC_OUT, w_NPC_IN);
  
  -- Next Program Counter (NPC)
  NPC: REGISTER_GENERIC
    generic map(WIDTH)
    port map(CLK, RST, NPC_LATCH_EN, w_NPC_IN, w_NPC_OUT); 

  -------------------------------------------------------------------------------
  --                                  Stage 2                                  --
  -------------------------------------------------------------------------------
  
  -- Register File (RF)
  RF: REGISTER_FILE
    generic map (WIDTH, LENGTH)
    port map (CLK, RST, RF_LATCH_EN, RegA_LATCH_EN, RegB_LATCH_EN, RF_WE, w_WB_MUX_OUT, w_RegA_IN, w_RegB_IN, w_RD, w_RD1, w_RD2);
  
  -- Register A
  REG_A: REGISTER_GENERIC
    generic map(WIDTH)
    port map(CLK, RST, RegA_LATCH_EN, w_RegA_IN, w_RegA_OUT);
  
  -- Register B
  REG_B: REGISTER_GENERIC
    generic map(WIDTH)
    port map(CLK, RST, RegA_LATCH_EN, w_RegB_IN, w_RegB_OUT);
  
  -- Sign extend    
  SIGN_EXT: SIGN_EXTEND
    port map(w_IMMU_IN, w_IMMS_IN);
  
  -- Register Immediate
  IMM: REGISTER_GENERIC
    generic map(WIDTH)
    port map(CLK, RST, RegIMM_LATCH_EN, w_IMMS_IN, w_RegIMM_OUT);
  
  -------------------------------------------------------------------------------
  --                                  Stage 3                                  --
  -------------------------------------------------------------------------------
  
  -- Mux A
  MUX_A: MUX21_GENERIC
    generic map(WIDTH)
    port map(w_NPC_OUT, w_RegA_OUT, MUXA_SEL, w_A_MUX_OUT);
  
  -- Mux B
  MUX_B: MUX21_GENERIC
    generic map(WIDTH)
    port map(w_RegB_OUT, w_RegIMM_OUT, MUXB_SEL, w_B_MUX_OUT);
  
  -- Arithmetic Logic Unit
  ALU1: ALU
    generic map(WIDTH, RADIX, OPCODE)
    port map(w_A_MUX_OUT, w_B_MUX_OUT, ALU_OPCODE, w_ALU_OUT);
  
  -- Register ALU
  ALU_REG: REGISTER_GENERIC
    generic map(WIDTH)
    port map(CLK, RST, ALU_OUTREG_EN, w_ALU_OUT, w_RegALU_OUT);
  
  -- Zero Detector Branch Condition
  COND: ZERO_DETECTOR
    generic map(WIDTH)
    port map(w_A_MUX_OUT, w_Z);
  
  -------------------------------------------------------------------------------
  --                                  Stage 4                                  --
  -------------------------------------------------------------------------------
  
  -- Load Memory Data (LMD)
  LMD: REGISTER_GENERIC
    generic map(WIDTH)
    port map(CLK, RST, LMD_LATCH_EN, DRAM_DATA_OUT, w_LMD_OUT);
  
  -- Mux Memory Access
  MUX_MEM: MUX21_GENERIC
    generic map(WIDTH)
    port map(w_RegALU_OUT, w_NPC_OUT, w_MUX_MEM_SEL, w_MEM_MUX_OUT);

  -------------------------------------------------------------------------------
  --                                  Stage 5                                  --
  -------------------------------------------------------------------------------
  
  -- Write-Back Mux
  MUX_WB: MUX21_GENERIC
    generic map(WIDTH)
    port map(w_LMD_OUT, w_RegALU_OUT, WB_MUX_SEL, w_WB_MUX_OUT);

end architecture;