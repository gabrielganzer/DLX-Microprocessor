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
  generic (WIDTH     : integer := word_size;
           LENGTH    : integer := addr_size;
           RADIX     : integer := radix_size;
           OPCODE    : integer:= op_size
  );
  port (CLK              : in  std_logic;  -- Clock
        RST              : in  std_logic;  -- Synchronous reset, active-low
        -- INPUTS
        -- Control signals
        IF_EN            : in std_logic;
        ID_EN            : in std_logic;
        RF_LATCH_EN      : in std_logic;
        RF_RD1           : in std_logic;
        RF_RD2           : in std_logic;
        SIGN_EN          : in std_logic;
        IMM_SEL          : in std_logic;
        RegImm_LATCH_EN  : in std_logic;
        RegRD1_LATCH_EN  : in std_logic;
        RegPC1_LATCH_EN  : in std_logic;
        EX_EN            : in std_logic;
        MuxA_SEL         : in std_logic;
        MuxB_SEL         : in std_logic;
        ALU_OPCODE       : in aluOp;
        EQ_COND          : in std_logic;
        JUMP_EN          : in std_logic;
        RegA1_LATCH_EN   : in std_logic;
        RegME_LATCH_EN   : in std_logic;
        RegRD2_LATCH_EN  : in std_logic;
        RegPC2_LATCH_EN  : in std_logic;
        RF_WE_EX         : in std_logic;
        MEM_EN           : in std_logic;
        JUMP_REG         : in std_logic;
        DATA_WE          : in std_logic;
        STORE_SIZE       : in std_logic_vector(2 downto 0);
        SIGN_LD          : in std_logic;
        LOAD_SIZE        : in std_logic_vector(2 downto 0);
        RegNPC3_LATCH_EN : in std_logic;
        RegALU2_LATCH_EN : in std_logic;
        RegLMD_LATCH_EN  : in std_logic;
        RegRD3_LATCH_EN  : in std_logic;
        RF_WE_MEM        : in std_logic;
        WB_EN            : in std_logic;
        MuxWB_SEL        : in std_logic;
        RF_WE            : in std_logic;
        JUMP_LINK        : in std_logic;
        -- Data bus
        IROM_DATA        : in std_logic_vector(WIDTH-1 downto 0);
        DRAM_OUT         : in std_logic_vector(WIDTH-1 downto 0);
        -- OUTPUTS
        -- Control signals
        STALL            : out std_logic;
        FLUSH            : out std_logic;
        DRAM_WE          : out std_logic;
        -- Data bus
        IR               : out std_logic_vector(WIDTH-1 downto 0);
        IROM_ADDR        : out std_logic_vector(iram_addr_size-1 downto 0);
        DRAM_ADDR        : out std_logic_vector(dram_addr_size-1 downto 0);
        DRAM_IN          : out std_logic_vector(WIDTH-1 downto 0)
  ); 
end entity;

architecture STRUCTURAL of DLX_DP is
  
  --------------------------------------------------------------------
  -- Components
  --------------------------------------------------------------------
  component MUX21_GENERIC
    generic(NBIT: integer:= 4);
    port (S0:	in	std_logic_vector(NBIT-1 downto 0);
          S1:	in 	std_logic_vector(NBIT-1 downto 0);
          SEL:	in	std_logic;
          Y:	out	std_logic_vector(NBIT-1 downto 0));
  end component;

  
  -- Multiplexer 3x1
  component MUX31_GENERIC
    generic(NBIT: integer:= 4);
    port (S0:	in 	std_logic_vector(NBIT-1 downto 0);
          S1:	in 	std_logic_vector(NBIT-1 downto 0);
          S2:	in	std_logic_vector(NBIT-1 downto 0);
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
  
  -- D-Type Flip-Flop
  component FFD
    port (CLK : in std_logic;
          RST : in std_logic;  -- Synchronous reset, active-low
          EN  : in std_logic;  -- Active-high enable
          D   : in std_logic;    
          Q   : out std_logic);
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
  
  -- Branch Condition
  component BRANCH_UNIT
    generic(WIDTH : integer := word_size);
    port(Z       : in std_logic;
         EQ_COND : in std_logic;
         JUMP_EN : in std_logic;
         BRANCH  : out std_logic);
  end component;
  
  -- Forwarding Control Unit
  component FORWARDING_UNIT
    generic (WIDTH : integer := 32;
             LENGTH : integer := 5);
    port (CLK : in std_logic;
          RST : in std_logic;
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
  
  -- Data Cache
  component DATA_CACHE
    generic (WIDTH  : integer := word_size;
             LENGTH : integer := dram_addr_size);
     port (CLK          : in std_logic;
           RST          : in std_logic;
           EN           : in std_logic;
           WE           : in std_logic;
           FWD          : in std_logic;
           ADDR         : in std_logic_vector(WIDTH-1 downto 0);
           SDRAM_WE     : out std_logic;
           SDRAM_SRC    : out std_logic;
           SDRAM_ADDR   : out std_logic_vector(LENGTH-1 downto 0);
           CACHE_DIN    : in std_logic_vector(WIDTH-1 downto 0);
           CACHE_DOUT   : out std_logic_vector(WIDTH-1 downto 0);
           CACHE_SRC    : out std_logic_vector(2 downto 0);
           STALL        : out std_logic);
  end component;
  
  -- Instruction Cache
  component INSTRUCTION_CACHE
    generic (WIDTH        : integer := word_size);
     port (CLK          : in std_logic;
          RST          : in std_logic;
          EN           : in std_logic;
          ADDR         : in std_logic_vector(WIDTH-1 downto 0);
          DIN          : in std_logic_vector(WIDTH-1 downto 0);
          WORD         : out std_logic_vector(1 downto 0);
          DOUT         : out std_logic_vector(WIDTH-1 downto 0);
          STALL        : out std_logic);
  end component;
  
  -- Branch Target Buffer
  component BTB
    generic (WIDTH: integer := word_size;
             LENGTH: integer := btb_size);
     port (CLK           : in std_logic;
          RST           : in std_logic;
          EN            : in std_logic;
          OUTCOME       : in std_logic;
          PC_READ       : in std_logic_vector(WIDTH-1 downto 0);
          PC_WRITE      : in std_logic_vector(WIDTH-1 downto 0);
          TARG_IN       : in std_logic_vector(WIDTH-1 downto 0);
          TARG_OUT      : out std_logic_vector(WIDTH-1 downto 0);
          FLUSH         : out std_logic;
          PREDICT       : out std_logic);
  end component;
  
  --------------------------------------------------------------------
  -- Signals
  --------------------------------------------------------------------
  signal ISTALL      : std_logic;
  signal DSTALL      : std_logic;
  signal FLUSH_BTB   : std_logic;
  signal PC_SEL      : std_logic;
  signal OUTCOME     : std_logic;
  signal PREDICT     : std_logic;
  signal RF_EN       : std_logic;
  signal FwdD        : std_logic;
  signal Z_out       : std_logic;
  signal COND_out    : std_logic;
  signal DRAM_SRC    : std_logic;
  signal WORD        : std_logic_vector(1 downto 0);
  signal FwdA        : std_logic_vector(2 downto 0);
  signal FwdB        : std_logic_vector(2 downto 0);
  signal FwdC        : std_logic_vector(2 downto 0);
  signal CACHE_SRC   : std_logic_vector(2 downto 0);
  signal CACHE_ADDR  : std_logic_vector(iram_addr_size-1 downto 0);
  signal PC_write    : std_logic_vector(WIDTH-1 downto 0);
  signal PC_in       : std_logic_vector(WIDTH-1 downto 0);
  signal PC_out      : std_logic_vector(WIDTH-1 downto 0);
  signal IR_in       : std_logic_vector(WIDTH-1 downto 0);
  signal IR_out      : std_logic_vector(WIDTH-1 downto 0);
  signal TARG_in     : std_logic_vector(WIDTH-1 downto 0);
  signal TARG_out    : std_logic_vector(WIDTH-1 downto 0);
  signal NPC         : std_logic_vector(WIDTH-1 downto 0);
  signal MuxNPC_out  : std_logic_vector(WIDTH-1 downto 0);
  signal NPC1        : std_logic_vector(WIDTH-1 downto 0);
  signal NPC2        : std_logic_vector(WIDTH-1 downto 0);
  signal NPC3        : std_logic_vector(WIDTH-1 downto 0);
  signal NPC_out     : std_logic_vector(WIDTH-1 downto 0);
  signal MuxWB_out   : std_logic_vector(WIDTH-1 downto 0);
  signal RetADDR     : std_logic_vector(WIDTH-1 downto 0);
  signal RF_DATA     : std_logic_vector(WIDTH-1 downto 0);
  signal RegA_in     : std_logic_vector(WIDTH-1 downto 0);
  signal RegB_in     : std_logic_vector(WIDTH-1 downto 0);
  signal RegA_out    : std_logic_vector(WIDTH-1 downto 0);
  signal RegB_out    : std_logic_vector(WIDTH-1 downto 0);
  signal IMM16ext    : std_logic_vector(WIDTH-1 downto 0);
  signal IMM26ext    : std_logic_vector(WIDTH-1 downto 0);
  signal RegIMM_in   : std_logic_vector(WIDTH-1 downto 0);
  signal RegIMM_out  : std_logic_vector(WIDTH-1 downto 0);
  signal PC1         : std_logic_vector(WIDTH-1 downto 0);
  signal MuxA_out    : std_logic_vector(WIDTH-1 downto 0);
  signal MuxB_out    : std_logic_vector(WIDTH-1 downto 0);
  signal A           : std_logic_vector(WIDTH-1 downto 0);
  signal B           : std_logic_vector(WIDTH-1 downto 0);
  signal RES         : std_logic_vector(WIDTH-1 downto 0);
  signal Z_in        : std_logic_vector(WIDTH-1 downto 0);
  signal RegALU1_out : std_logic_vector(WIDTH-1 downto 0);
  signal RegME_out   : std_logic_vector(WIDTH-1 downto 0);
  signal RegA1_out   : std_logic_vector(WIDTH-1 downto 0);
  signal MuxJR_out   : std_logic_vector(WIDTH-1 downto 0);
  signal STORE8      : std_logic_vector(WIDTH-1 downto 0);
  signal STORE16     : std_logic_vector(WIDTH-1 downto 0);
  signal STORE32     : std_logic_vector(WIDTH-1 downto 0);
  signal LOAD8       : std_logic_vector(WIDTH-1 downto 0);
  signal LOAD16      : std_logic_vector(WIDTH-1 downto 0);
  signal LOAD32      : std_logic_vector(WIDTH-1 downto 0);
  signal CACHE_in    : std_logic_vector(WIDTH-1 downto 0);
  signal MuxLOAD_out : std_logic_vector(WIDTH-1 downto 0);
  signal RegLMD_out  : std_logic_vector(WIDTH-1 downto 0);
  signal RegALU2_out : std_logic_vector(WIDTH-1 downto 0);
  signal RF_ADDR     : std_logic_vector(LENGTH-1 downto 0);
  signal RD          : std_logic_vector(LENGTH-1 downto 0);
  signal RD1         : std_logic_vector(LENGTH-1 downto 0);
  signal RD2         : std_logic_vector(LENGTH-1 downto 0);
  signal RD3         : std_logic_vector(LENGTH-1 downto 0);
  signal RD_out      : std_logic_vector(LENGTH-1 downto 0);
  signal RS1         : std_logic_vector(LENGTH-1 downto 0);
  signal RS2         : std_logic_vector(LENGTH-1 downto 0);
  signal IMM16       : std_logic_vector((WIDTH/2)-1 downto 0);
  signal DATAST16      : std_logic_vector((WIDTH/2)-1 downto 0);
  signal DATAST8       : std_logic_vector((WIDTH/4)-1 downto 0);
  signal DATALD16      : std_logic_vector((WIDTH/2)-1 downto 0);
  signal DATALD8       : std_logic_vector((WIDTH/4)-1 downto 0);
  signal IMM26       : std_logic_vector(WIDTH-OPCODE-1 downto 0);
  
begin
  
  -------------------------------------------------------------------------------
  --                                  Stage 1                                  --
  -------------------------------------------------------------------------------
  
  -- Hazard Control
  STALL  <= ISTALL or DSTALL;
  PC_SEL <= not(FLUSH_BTB);
  FLUSH  <= FLUSH_BTB;
  
  -- Mux PC
  MuxPC: MUX21_GENERIC
    generic map(WIDTH)
    port map(PC_write, TARG_in, PC_SEL, PC_in);
  
  -- Program Counter
  RegPC: REGISTER_GENERIC
    generic map(WIDTH)
    port map(CLK, RST, IF_EN, PC_in, PC_out);   
  
  -- Instruction Cache
  ICACHE: INSTRUCTION_CACHE
    generic map(WIDTH)
    port map(CLK, RST, IF_EN, PC_out, IROM_DATA, WORD, IR_in, ISTALL);
  
  IROM_ADDR <= PC_out(iram_addr_size-1 downto word_offset)&WORD;
  
  -- Instruction Register
  RegIR: REGISTER_GENERIC
    generic map(WIDTH)
    port map(CLK, RST, IF_EN, IR_in, IR_out);
  
  IR <= IR_out;
  
  -- Branch target buffer
  BTB0: BTB
    generic map(WIDTH, LENGTH)
    port map (CLK, RST, IF_EN, OUTCOME, PC_out, PC_write, TARG_in, TARG_out, FLUSH_BTB, PREDICT);
  
  -- Nex Program Counter Increment
  NPC <= std_logic_vector(unsigned(PC_IN) + 1);
  
  -- Mux NPC
  MuxNPC: MUX21_GENERIC
    generic map(WIDTH)
    port map(NPC, TARG_out, PREDICT, MuxNPC_out);
  
  -- Next Program Counter
  RegNPC: REGISTER_GENERIC
    generic map(WIDTH)
    port map(CLK, RST, IF_EN, MuxNPC_out, NPC1);

  -------------------------------------------------------------------------------
  --                                  Stage 2                                  --
  -------------------------------------------------------------------------------
  
  RD      <= IR_out(r3_up downto r3_down) when (IR_out(opcode_up downto opcode_down) = RTYPE)   else
             (others => '1')              when (IR_out(opcode_up downto opcode_down) = J_JAL)   else
             (others => '1')              when (IR_out(opcode_up downto opcode_down) = J_JALR)  else
             IR_out(r2_up downto r2_down);            
  RS1     <= IR_out(r1_up downto r1_down); 
  RS2     <= IR_out(r2_up downto r2_down) when (IR_out(opcode_up downto opcode_down) = RTYPE)   else
             IR_out(r2_up downto r2_down) when (IR_out(opcode_up downto opcode_down) = I_SW)    else
             (others => '0');
  IMM16   <= (others => '0')              when (IR_out(opcode_up downto opcode_down) = J_JALR)  else 
             (others => '0')              when (IR_out(opcode_up downto opcode_down) = J_JAL)   else
             IR_out(inp2_up downto inp2_down);
  IMM26   <= IR_out(opcode_down-1 downto 0);
  
  RF_EN   <= RF_LATCH_EN or WB_EN;
  
  RetADDR <= std_logic_vector(unsigned(NPC_out) + 1);
  
  -- Mux Register File Data-in
  MuxRFDATA: MUX21_GENERIC
    generic map(WIDTH)
    port map(RetADDR, MuxWB_out, JUMP_LINK, RF_DATA);
  
  -- Mux Register File Address-write
  MuxRFADDR: MUX21_GENERIC
    generic map(LENGTH)
    port map((others => '1'), RD_out, JUMP_LINK, RF_ADDR);
  
  -- Register file
  RF0: REGISTER_FILE
    generic map(WIDTH, LENGTH)
    port map(CLK, RST, RF_EN, RF_RD1, RF_RD2, RF_WE, RF_DATA, RegA_in, RegB_in, RF_ADDR, RS1, RS2);
      
  -- Sign Extend IMM16
  SignExtIMM16: SIGN_EXTEND
    generic map (word_size/2, word_size)
    port map (IMM16, SIGN_EN, IMM16ext);

  -- Sign Extend IMM26
  SignExtIMM26: SIGN_EXTEND
    generic map (word_size-op_size, word_size)
    port map (IMM26, '1', IMM26ext);
      
  -- Mux Immediate
  MuxIMM: MUX21_GENERIC
    generic map(WIDTH)
    port map(IMM16ext, IMM26ext, IMM_SEL, RegIMM_in);
  
  -- Pipeline Register PC
  RegPC1: REGISTER_GENERIC
    generic map(WIDTH)
    port map(CLK, RST, RegPC1_LATCH_EN, PC_out, PC1);
  
  -- Pipeline Register NPC
  RegNPC1: REGISTER_GENERIC
    generic map(WIDTH)
    port map(CLK, RST, ID_EN, NPC1, NPC2);
  
  -- Pipeline Register A
  RegA: REGISTER_GENERIC
    generic map(WIDTH)
    port map(CLK, RST, RF_RD1, RegA_in, RegA_out);
      
  -- Pipeline Register B
  RegB: REGISTER_GENERIC
    generic map(WIDTH)
    port map(CLK, RST, RF_RD2, RegB_in, RegB_out);
      
  -- Pipeline Register IMM
  RegIMM: REGISTER_GENERIC
    generic map(WIDTH)
    port map(CLK, RST, RegIMM_LATCH_EN, RegIMM_in, RegIMM_out);
      
  -- Pipeline Register RD1
  RegRD1: REGISTER_GENERIC
    generic map(LENGTH)
    port map(CLK, RST, RegRD1_LATCH_EN, RD, RD1);
  
  
  -------------------------------------------------------------------------------
  --                                  Stage 3                                  --
  ------------------------------------------------------------------------------- 
  
  -- Mux Operand A
  MuxA: MUX21_GENERIC
    generic map(WIDTH)
    port map(NPC2, RegA_out, MuxA_SEL, MuxA_out);
  
  -- Mux Operand B
  MuxB: MUX21_GENERIC
    generic map(WIDTH)
    port map(RegB_out, RegIMM_out, MuxB_SEL, MuxB_out);
      
  -- Mux Forwarding A
  MuxFWDA: MUX31_GENERIC
    generic map(WIDTH)
    port map(MuxWB_out, RegALU1_out, MuxA_out, FwdA, A);
  
  -- Mux Forwarding B
  MuxFWDB: MUX31_GENERIC
    generic map(WIDTH)
    port map(MuxWB_out, RegALU1_out, MuxB_out, FwdB, B);
      
  -- Mux Forwarding C
  MuxFWDC: MUX31_GENERIC
    generic map(WIDTH)
    port map(MuxWB_out, RegALU1_out, RegA_out, FwdC, Z_in);
      
  -- Arithmetic Logic Unit
  ALU0: ALU
    generic map(WIDTH, RADIX, OPCODE)
    port map(A, B, ALU_OPCODE, RES);
  
  -- Zero?
  ZERO: ZERO_DETECTOR
    generic map(WIDTH)
    port map(Z_in, Z_out);
  
  -- Branch Condition
  COND: BRANCH_UNIT
    generic map(WIDTH)
    port map(Z_out, EQ_COND, JUMP_EN, COND_out);
      
  -- Pipeline Register PC
  RegPC2: REGISTER_GENERIC
    generic map(WIDTH)
    port map(CLK, RST, RegPC2_LATCH_EN, PC1, PC_write);
      
  -- Pipeline Register NPC
  RegNPC2: REGISTER_GENERIC
    generic map(WIDTH)
    port map(CLK, RST, EX_EN, NPC2, NPC3);
      
  -- Pipeline Register ALU1
  RegALU1: REGISTER_GENERIC
    generic map(WIDTH)
    port map(CLK, RST, EX_EN, RES, RegALU1_out);
      
  -- Pipeline Register ME
  RegME: REGISTER_GENERIC
    generic map(WIDTH)
    port map(CLK, RST, RegME_LATCH_EN, RegB_out, RegME_out);
      
  -- Pipeline Register RD2
  RegRD2: REGISTER_GENERIC
    generic map(LENGTH)
    port map(CLK, RST, RegRD2_LATCH_EN, RD2, RD3);
      
  -- Pipeline Register Operand A
  RegA1: REGISTER_GENERIC
    generic map(WIDTH)
    port map(CLK, RST, RegA1_LATCH_EN, RegA_out, RegA1_out);
      
  RegOUTCOME: FFD
    port map(CLK, RST, JUMP_EN, COND_out, OUTCOME);
  
  -------------------------------------------------------------------------------
  --                                  Stage 4                                  --
  -------------------------------------------------------------------------------
  
  -- Mux Jump Register
  MuxJR: MUX21_GENERIC
    generic map(WIDTH)
    port map(RegALU1_out, RegA1_out, JUMP_REG, MuxJR_out);
      
  -- Mux Jump
  MuxJUMP: MUX21_GENERIC
    generic map(WIDTH)
    port map(NPC3, MuxJR_out, OUTCOME, TARG_in);
      
  -- Mux Cache Source
  MuxCACHESRC: MUX31_GENERIC
    generic map(WIDTH)
    port map(DRAM_OUT, MuxWB_out, RegME_out, CACHE_SRC, STORE32);
      
  DATAST16 <= STORE32((word_size/2)-1 downto 0);
  
  DATAST8 <= STORE32((word_size/4)-1 downto 0);
  
  SignExtSH: SIGN_EXTEND
    generic map (word_size/2, word_size)
    port map (DATAST16, '1', STORE16);
  
  -- Sign Extend Store
  SignExtSB: SIGN_EXTEND
    generic map (word_size/4, word_size)
    port map (DATAST8, '1', STORE8);
      
  -- Mux Store
  MuxSTORE: MUX31_GENERIC
    generic map(WIDTH)
    port map(STORE32, STORE16, STORE8, STORE_SIZE, CACHE_in);
      
  -- Data Cache
  DCACHE: DATA_CACHE
    generic map (WIDTH, dram_addr_size)
    port map(CLK, RST, MEM_EN, DATA_WE, FwdD, RegALU1_out, DRAM_WE, DRAM_SRC, CACHE_ADDR, CACHE_in, LOAD32, CACHE_SRC, DSTALL);
  
  DATALD16 <= LOAD32((word_size/2)-1 downto 0);
  
  DATALD8 <= LOAD32((word_size/4)-1 downto 0);
  
  -- Mux DRAM source
  MuxDRAMSRC: MUX21_GENERIC
    generic map(dram_addr_size)
    port map(CACHE_ADDR, RegALU1_out(dram_addr_size-1 downto 0), DRAM_SRC, DRAM_ADDR);
  
  -- Sign Extend Load
  SignExtLH: SIGN_EXTEND
    generic map (word_size/2, word_size)
    port map (DATALD16, SIGN_LD, LOAD16);
  
  -- Sign Extend Load
  SignExtLB: SIGN_EXTEND
    generic map (word_size/4, word_size)
    port map (DATALD8, SIGN_LD, LOAD8);
      
  -- Mux Load
  MuxLOAD: MUX31_GENERIC
    generic map(WIDTH)
    port map(LOAD32, LOAD16, LOAD8, LOAD_SIZE, MuxLOAD_out);
  
  DRAM_IN <= MuxLOAD_out;
  
  -- Pipeline Register LMD
  RegALU2: REGISTER_GENERIC
    generic map(WIDTH)
    port map(CLK, RST, RegALU2_LATCH_EN, RegALU1_out, RegALU2_out); 
    
  -- Pipeline Register LMD
  RegLMD: REGISTER_GENERIC
    generic map(WIDTH)
    port map(CLK, RST, RegLMD_LATCH_EN, MuxLOAD_out, RegLMD_out);   
      
  -- Pipeline Register RD3
  RegRD3: REGISTER_GENERIC
    generic map(LENGTH)
    port map(CLK, RST, RegRD3_LATCH_EN, RD3, RD_out);
  
  -- Pipeline Register NPC
  RegNPC3: REGISTER_GENERIC
    generic map(WIDTH)
    port map(CLK, RST, EX_EN, NPC3, NPC_out);
      
  -------------------------------------------------------------------------------
  --                                  Stage 5                                  --
  -------------------------------------------------------------------------------
  
  -- Mux Write-Back
  MuxWB: MUX21_GENERIC
    generic map(WIDTH)
    port map(RegALU2_out, RegLMD_out, MuxWB_SEL, MuxWB_out);
      
  -- Forwarding Control Unit
  FU0: FORWARDING_UNIT
    generic map(WIDTH, LENGTH)
    port map(CLK, RST, RS1, RS2, RD1, RD2, RF_WE_EX, RF_WE_MEM, FwdA, FwdB, FwdC, FwdD);
  
end architecture;

