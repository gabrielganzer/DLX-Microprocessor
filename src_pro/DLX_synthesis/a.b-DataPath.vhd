----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: DLX_DP
-- Function: DLX data-path
-- Input:
-- Output:
-- Architecture: structural
-- Library/package: ieee.std_logic_ll64, work.globals
-- Date: 12/08/2020
----------------------------------------------------------------------------------
library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.globals.all;

entity DLX_DP is
    generic (
      WIDTH     : integer := word_size;
      LENGTH    : integer := addr_size;
      RADIX     : integer := radix_size;
      OPCODE    : integer:= op_size
    );
    port (
      CLK             : in std_logic;
      RST             : in std_logic;  -- Synchronous, active-low
      -- Stage 1: Instruction Fetch (IF)
      -- Control
      EN1             : in std_logic;
      -- Data
      PC_IN           : in std_logic_vector(WIDTH-1 downto 0);
      -- Stage 2: Instruction Decode (ID)
      -- Control
      EN2             : in std_logic;
      RF_RD1          : in std_logic;
      RF_RD2          : in std_logic;
      MuxIMM_SEL      : in std_logic;
      SIGN_EN         : in std_logic;            
      -- Data
      RD              : in std_logic_vector(LENGTH-1 downto 0);
      RS1             : in std_logic_vector(LENGTH-1 downto 0);
      RS2             : in std_logic_vector(LENGTH-1 downto 0);
      IMM16           : in std_logic_vector((WIDTH/2)-1 downto 0);
      IMM26           : in std_logic_vector(WIDTH-OPCODE-1 downto 0);
      -- Stage 3: Execution (EX)
      -- Control
      EN3             : in std_logic;
      MuxA_SEL        : in std_logic;
      MuxB_SEL        : in std_logic;
      EQ_COND         : in std_logic;
      JUMP_EN         : in std_logic;
      RF_WE3          : in std_logic;
      -- Data
      ALU_OPCODE      : in aluOp;
      -- Stage 4: Memory Access (MEM)
      -- Control
      EN4             : in std_logic;
      RF_WE4          : in std_logic;
      SIGN_LD_EN      : in std_logic;
      MuxLD_SEL       : in std_logic_vector(2 downto 0);
      MuxSW_SEL       : in std_logic_vector(2 downto 0); 
      -- Data
      NPC_OUT         : out std_logic_vector(WIDTH-1 downto 0);
      DRAM_ADDR       : out std_logic_vector(dram_addr_size-1 downto 0);
      DRAM_IN         : in std_logic_vector(WIDTH-1 downto 0);
      DRAM_OUT        : out std_logic_vector(WIDTH-1 downto 0);
      -- Stage 5: Write-Back (WB)
      -- Control
      MuxWB_SEL       : in std_logic;
      RF_WE           : in std_logic;
      JUMP_LINK       : in std_logic
    ); 
end entity;

architecture STRUCTURAL of DLX_DP is
  
  --------------------------------------------------------------------
  -- Components
  --------------------------------------------------------------------
  -- Multiplexer 2x1
  component MUX21_GENERIC
    generic(NBIT: integer);
    port (S1  :	in 	std_logic_vector(NBIT-1 downto 0);
	        S0  :	in	std_logic_vector(NBIT-1 downto 0);
	        SEL :	in	std_logic;
	        Y   :	out	std_logic_vector(NBIT-1 downto 0));
  end component;
  
  -- Multiplexer 3x1
  component MUX31_GENERIC
	generic(NBIT: integer:= 4);
	port (S2:	in 	std_logic_vector(NBIT-1 downto 0);
	      S1:	in 	std_logic_vector(NBIT-1 downto 0);
	      S0:	in	std_logic_vector(NBIT-1 downto 0);
	      SEL:	in	std_logic_vector(2 downto 0);
	      Y:	out	std_logic_vector(NBIT-1 downto 0));
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
  
  -- Sign Extend
  component SIGN_EXTEND
    generic (WIDTH_IN: integer := word_size/2;
             WIDTH_OUT: integer := word_size);
    port (A: in std_logic_vector(WIDTH_IN-1 downto 0);
          S: in std_logic;
          Y: out std_logic_vector (WIDTH_OUT-1 downto 0));
  end component;
  
  -- Arithmetic Logic Unit
  component ALU
    generic (WIDTH: integer:= word_size;
             RADIX: integer:= radix_size);
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
  
  -- Branch Condition
  component BRANCH_UNIT
  generic(WIDTH : integer := word_size);
    port(Z       : in std_logic;	-- Zero? Block Result
         EQ_COND : in std_logic; -- 1 for BEQZ, 0 for BNEZ
         JUMP_EN : in std_logic;
         BRANCH  : out std_logic);
  end component;
  
  -- Forwarding Control Unit
  component FORWARDING_UNIT
  generic (WIDTH : integer := 32;
           LENGTH : integer := 5);
  port (
    CLK : in std_logic;
    RST : in std_logic; --active low
    RS1 : in std_logic_vector(LENGTH - 1 downto 0);
    RS2 : in std_logic_vector(LENGTH - 1 downto 0);
    RD3  : in std_logic_vector(LENGTH - 1 downto 0);
    RD4  : in std_logic_vector(LENGTH - 1 downto 0);
    RF_WE3 : in std_logic;
    RF_WE4 : in std_logic;
    ForwardA : out std_logic_vector (2 downto 0);
    ForwardB : out std_logic_vector (2 downto 0);
    ForwardC : out std_logic_vector (2 downto 0);
    ForwardD : out std_logic);
  end component;
  
  --------------------------------------------------------------------
  -- Signals
  --------------------------------------------------------------------
  -- Stage 1
  signal NPC         : std_logic_vector(WIDTH-1 downto 0);
  signal NPC1        : std_logic_vector(WIDTH-1 downto 0);
  -- Stage 2
  signal WR_DATA     : std_logic_vector(WIDTH-1 downto 0);
  signal RegA_IN     : std_logic_vector(WIDTH-1 downto 0);
  signal RegB_IN     : std_logic_vector(WIDTH-1 downto 0);
  signal RegA_OUT    : std_logic_vector(WIDTH-1 downto 0);
  signal RegB_OUT    : std_logic_vector(WIDTH-1 downto 0);
  signal IMMS16      : std_logic_vector(WIDTH-1 downto 0);
  signal IMMS26      : std_logic_vector(WIDTH-1 downto 0);
  signal IMM         : std_logic_vector(WIDTH-1 downto 0);
  signal RegIMM_OUT  : std_logic_vector(WIDTH-1 downto 0);
  signal NPC2        : std_logic_vector(WIDTH-1 downto 0);
  signal RD2         : std_logic_vector(LENGTH-1 downto 0);
  -- Stage 3
  signal Z           : std_logic;
  signal MuxMEM_SEL  : std_logic;
  signal MuxA_OUT    : std_logic_vector(WIDTH-1 downto 0);
  signal MuxB_OUT    : std_logic_vector(WIDTH-1 downto 0);
  signal A           : std_logic_vector(WIDTH-1 downto 0);
  signal B           : std_logic_vector(WIDTH-1 downto 0);
  signal Y           : std_logic_vector(WIDTH-1 downto 0);
  signal Z_IN        : std_logic_vector(WIDTH-1 downto 0);
  signal RegALU3_OUT : std_logic_vector(WIDTH-1 downto 0);
  signal RegME_OUT   : std_logic_vector(WIDTH-1 downto 0);
  signal NPC3        : std_logic_vector(WIDTH-1 downto 0);
  signal RD3         : std_logic_vector(LENGTH-1 downto 0);
  -- Stage 4
  signal MuxMEM_OUT  : std_logic_vector(WIDTH-1 downto 0);
  signal LMD_8       : std_logic_vector(WIDTH-1 downto 0);
  signal LMD_16      : std_logic_vector(WIDTH-1 downto 0);
  signal MEM_8       : std_logic_vector(WIDTH-1 downto 0);
  signal MEM_16      : std_logic_vector(WIDTH-1 downto 0);
  signal RegLMD_OUT  : std_logic_vector(WIDTH-1 downto 0);
  signal MuxFWD_OUT  : std_logic_vector(WIDTH-1 downto 0);
  signal MuxLD_OUT   : std_logic_vector(WIDTH-1 downto 0);
  signal RegALU4_OUT : std_logic_vector(WIDTH-1 downto 0);
  signal NPC4        : std_logic_vector(WIDTH-1 downto 0);
  signal RD4         : std_logic_vector(LENGTH-1 downto 0);
  -- Stage 5
  signal MuxWB_OUT   : std_logic_vector(WIDTH-1 downto 0);
  signal RetADDR     : std_logic_vector(WIDTH-1 downto 0);
  -- Forwardin
  signal FwdA_SEL    : std_logic_vector(2 downto 0);
  signal FwdB_SEL    : std_logic_vector(2 downto 0);
  signal FwdC_SEL    : std_logic_vector(2 downto 0);
  signal FwdD_SEL    : std_logic;  
  
begin
  
  -------------------------------------------------------------------------------
  --                                  Stage 1                                  --
  -------------------------------------------------------------------------------
  
  -- Nex Program Counter Increment
  NPC <= std_logic_vector(unsigned(PC_IN) + 4);
  
  -- Next Program Counter (NPC)
  RegNPC1: REGISTER_GENERIC
    generic map(WIDTH)
    port map(CLK, RST, EN1, NPC, NPC1); 

  -------------------------------------------------------------------------------
  --                                  Stage 2                                  --
  -------------------------------------------------------------------------------
  
  -- Mux WD
  MuxWR: MUX21_GENERIC
    generic map(WIDTH)
    port map(RetADDR, MuxWB_OUT, JUMP_LINK, WR_DATA);
  
  -- Register File (RF)
  RegFILE: REGISTER_FILE
    generic map (WIDTH, LENGTH)
    port map (CLK, RST, EN2, RF_RD1, RF_RD2, RF_WE, WR_DATA, RegA_IN, RegB_IN, RD4, RS1, RS2);
  
  -- Register A
  RegA: REGISTER_GENERIC
    generic map(WIDTH)
    port map(CLK, RST, EN2, RegA_IN, RegA_OUT);
  
  -- Register B
  RegB: REGISTER_GENERIC
    generic map(WIDTH)
    port map(CLK, RST, EN2, RegB_IN, RegB_OUT);
  
  -- Sign Extend Imm16
  SignImm16: SIGN_EXTEND
    generic map((WIDTH/2), WIDTH)
    port map (IMM16, SIGN_EN, IMMS16);
      
  -- Sign Extend Imm26
  SignImm26: SIGN_EXTEND
    generic map((WIDTH-OPCODE), WIDTH)
    port map (IMM26, '1', IMMS26);
  
  -- Mux Immediate
  MuxIMM: MUX21_GENERIC
    generic map(WIDTH)
    port map(IMMS16, IMMS26, MuxIMM_SEL, IMM);
  
  -- Immediate Register
  RegIMM: REGISTER_GENERIC
    generic map(WIDTH)
    port map(CLK, RST, EN2, IMM, RegIMM_OUT);
      
  -- RD2 Pipeline Register
  RegRD2: REGISTER_GENERIC
    generic map(LENGTH)
    port map(CLK, RST, EN2, RD, RD2);      
    
  -- NPC Pipeline Register
  RegNPC2: REGISTER_GENERIC
    generic map(WIDTH)
    port map(CLK, RST, EN2, NPC1, NPC2); 
  
  -------------------------------------------------------------------------------
  --                                  Stage 3                                  --
  ------------------------------------------------------------------------------- 
  
  -- Mux A
  MuxA: MUX21_GENERIC
    generic map(WIDTH)
    port map(NPC2, RegA_OUT, MuxA_SEL, MuxA_OUT);
  
  -- Mux B
  MuxB: MUX21_GENERIC
    generic map(WIDTH)
    port map(RegB_OUT, RegIMM_OUT, MuxB_SEL, MuxB_OUT);
      
  -- Forwarding Mux A
  FwdA: MUX31_GENERIC
	   generic map(WIDTH)
	   port map(RegALU3_OUT, MuxWB_OUT, MuxA_OUT, FwdA_SEL, A);
	
	-- Forwarding Mux B
  FwdB: MUX31_GENERIC
	   generic map(WIDTH)
	   port map(RegALU3_OUT, MuxWB_OUT, MuxB_OUT, FwdB_SEL, B);
  
  -- Arithmetic Logic Unit
  ALU0: ALU
    generic map(WIDTH, RADIX)
    port map(A, B, ALU_OPCODE, Y);
  
  -- Register ALU
  RegALU3: REGISTER_GENERIC
    generic map(WIDTH)
    port map(CLK, RST, EN3, Y, RegALU3_OUT);
  
 	-- Forwarding Mux C (Branch)
  FwdC: MUX31_GENERIC
	   generic map(WIDTH)
	   port map(RegALU3_OUT, MuxWB_OUT, RegA_OUT, FwdC_SEL, Z_IN);
  
  -- Zero?
  ZERO: ZERO_DETECTOR
    generic map (WIDTH)
    port map (Z_IN, Z);
      
  -- Branch Condition
  COND: BRANCH_UNIT
    port map (Z, EQ_COND, JUMP_EN, MuxMEM_SEL);
  
  -- Register Pipeline Data Memory Input
  RegME: REGISTER_GENERIC
    generic map(WIDTH)
    port map(CLK, RST, EN3, RegB_OUT, RegME_OUT);
  
  -- RD3 Register Pipeline
  RegRD3: REGISTER_GENERIC
    generic map(LENGTH)
    port map(CLK, RST, EN3, RD2, RD3);
  
  -- NPC3 Pipeline Register
  RegNPC3: REGISTER_GENERIC
    generic map(WIDTH)
    port map(CLK, RST, EN3, NPC2, NPC3);
  
  -------------------------------------------------------------------------------
  --                                  Stage 4                                  --
  -------------------------------------------------------------------------------
  
  -- Sign Extend Data8
  SignLD8: SIGN_EXTEND
    generic map(8, WIDTH)
    port map (RegLMD_OUT(7 downto 0), SIGN_LD_EN, LMD_8);
      
  -- Sign Extend Data16
  SignLD16: SIGN_EXTEND
    generic map(16, WIDTH)
    port map (RegLMD_OUT(15 downto 0), SIGN_LD_EN, LMD_16);
  
 	-- Mux Load
  MuxLD: MUX31_GENERIC
	   generic map(WIDTH)
	   port map(LMD_8, LMD_16, RegLMD_OUT, MuxLD_SEL, MuxLD_OUT);
  
  -- Mux Memory Access
  MuxMEM: MUX21_GENERIC
    generic map(WIDTH)
    port map(RegALU3_OUT, NPC3, MuxMEM_SEL, MuxMEM_OUT);
  
  -- Forwarding Mux D (Data Memory)
  FwdD: MUX21_GENERIC
    generic map(WIDTH)
    port map(RegME_OUT, MuxWB_OUT, FwdD_SEL, MuxFWD_OUT);
      
  -- Sign Extend Data8
  SignSW8: SIGN_EXTEND
    generic map(8, WIDTH)
    port map (MuxFWD_OUT(WIDTH-1 downto WIDTH-8), '1', MEM_8);
      
  -- Sign Extend Data16
  SignSW16: SIGN_EXTEND
    generic map(16, WIDTH)
    port map (MuxFWD_OUT(WIDTH-1 downto WIDTH-16), '1', MEM_16);
      
 	-- Mux Store
  MuxSW: MUX31_GENERIC
	   generic map(WIDTH)
	   port map(MEM_8, MEM_16, MuxFWD_OUT, MuxSW_SEL, DRAM_OUT);
  
  -- Load Memory Data (LMD)
  RegLMD: REGISTER_GENERIC
    generic map(WIDTH)
    port map(CLK, RST, EN4, DRAM_IN, RegLMD_OUT);
      
  -- DRAM signals
  DRAM_ADDR <= RegALU3_OUT(dram_addr_size-1 downto 0);
	
	-- RD4 Register Pipeline
  RegRD4: REGISTER_GENERIC
    generic map(LENGTH)
    port map(CLK, RST, EN4, RD3, RD4);
  
  -- NPC4 Pipeline Register
  RegNPC4: REGISTER_GENERIC
    generic map(WIDTH)
    port map(CLK, RST, EN4, NPC3, NPC4);
      
  -- ALU Pipeline Register
  RegALU4: REGISTER_GENERIC
    generic map(WIDTH)
    port map(CLK, RST, EN4, RegALU3_OUT, RegALU4_OUT);
      
  -- NPC
  NPC_OUT <= MuxMEM_OUT;
  
  -------------------------------------------------------------------------------
  --                                  Stage 5                                  --
  -------------------------------------------------------------------------------
  
  RetADDR <= std_logic_vector(unsigned(NPC4) + 4);
  
  -- Write-Back Mux
  MuxWB: MUX21_GENERIC
    generic map(WIDTH)
    port map(MuxLD_OUT, RegALU4_OUT, MuxWB_SEL, MuxWB_OUT);
      
  -------------------------------------------------------------------------------
  --                                FORWARDING                                 --
  -------------------------------------------------------------------------------
  FU: FORWARDING_UNIT
    generic map (WIDTH, LENGTH)
    port map (CLK, RST, RS1, RS2, RD3, RD4, RF_WE3, RF_WE4, FwdA_SEL, FwdB_SEL, FwdC_SEL, FwdD_SEL);

end architecture;
