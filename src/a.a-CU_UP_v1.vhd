library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
--use work.all;

entity dlx_up is
  generic (
    INSTRUCTIONS_EXECUTION_CYCLES : integer := 5;    -- Instructions Execution Clock Cycles
    MICROCODE_MEM_SIZE            : integer := 164;  -- Microcode Memory Size
    RELOC_MEM_SIZE                : integer := 64;   -- Microcode Relocation
    OP_CODE_SIZE : integer := 6;        -- Op Code Size
    IR_SIZE      : integer := 32;       -- Instruction Register Size
    FUNC_SIZE    : integer := 11;       -- Func Field Size for R-Type Ops
    CW_SIZE      : integer := 15);      -- Control Word Size
  port (
    CLK             : in  std_logic;    -- Clock
    RST             : in  std_logic;    -- Reset:Active-Low
    -- Instruction Register
    IR_IN           : in std_logic_vector(IR_SIZE - 1 downto 0);
    -- Stage 1: IF Control Signal
    IR_LATCH_EN     : out std_logic;    -- Instruction Register Latch Enable
    NPC_LATCH_EN    : out std_logic;    -- Next Program Counter Register Latch Enable
    -- Stage 2: ID Control Signals
    RegA_LATCH_EN   : out std_logic;    -- Register A Latch Enable
    RegB_LATCH_EN   : out std_logic;    -- Register B Latch Enable
    RegIMM_LATCH_EN : out std_logic;    -- Immediate Register Latch Enable
    -- Stage 3: EX Control Signal
    MUXA_SEL        : out std_logic;    -- MUX-A Sel
    MUXB_SEL        : out std_logic;    -- MUX-B Sel
    ALU_OUTREG_EN   : out std_logic;    -- ALU Output Register Enable
    EQ_COND         : out std_logic;    -- Branch if (not) Equal to Zero
    ALU_OPCODE      : out aluOp;        -- ALU Operation Code
    -- Stage 4: MEM Control Signals
    DRAM_WE         : out std_logic;    -- Data RAM Write Enable
    LMD_LATCH_EN    : out std_logic;    -- LMD Register Latch Enable
    JUMP_EN         : out std_logic;    -- JUMP Enable Signal for PC input MUX
    PC_LATCH_EN     : out std_logic;    -- Program Counte Latch Enable
    -- Stage 5: WB Write Back  
    WB_MUX_SEL      : out std_logic;    -- Write Back MUX Sel
    RF_WE           : out std_logic);   -- Register File Write Enable

end entity;

architecture behavioral of dlx_up is

  -- Microcode memory
  type mem_array is array (integer range 0 to MICROCODE_MEM_SIZE - 1) of std_logic_vector(CW_SIZE - 1 downto 0);
  signal microcode : mem_array :=("000000000000000",  -- (0x00) -> (RESET)
                                  "110000000000000",  -- (0x01) -> (IF)                                  
                                  "000011000000000",  -- (0x02) -> (ID) J
                                  "000001010001000",  -- (0x03)  
                                  "000000000001100",  -- (0x04)                                   
                                  "000011010000000",  -- (0x05) -> (ID) JAL
                                  "000011010001011",  -- (0x06)  
                                  "000000000001100",  -- (0x07)                                                                                                       
                                  "001011000000000",  -- (0x08) -> (ID) BEQZ
                                  "000001011001000",  -- (0x09) 
                                  "000000000001100",  -- (0x0A)                                   
                                  "001011000000000",  -- (0x0B) -> (ID) BNEZ
                                  "000001010001000",  -- (0x0C) 
                                  "000000000001100",  -- (0x0D)                                  
                                  "000000000000000",  -- (0x0E) -> (ID) BFPT
                                  "000000000000000",  -- (0x0F) 
                                  "000000000000000",  -- (0x10)                                   
                                  "000000000000000",  -- (0x11) -> (ID) BFPF
                                  "000000000000000",  -- (0x12) 
                                  "000000000000000",  -- (0x13)                                   
                                  "001010000000000",  -- (0x14) -> (ID) ADDI
                                  "000000010000000",  -- (0x15) 
                                  "000000000000100",  -- (0x16) 
                                  "000000000000001",  -- (0x17) 
                                  
                                  "000000000000000",  -- (0x18) -> (ID) LHI
                                  "000000000000000",  -- (0x19) 
                                  "000000000000000",  -- (0x1A) 
                                  "000000000000000",  -- (0x1B) 
                                  
                                  "001010000000000",  -- (0x1C) -> (ID) NOP
                                  
                                  "000000010000000",  -- (0x1D) -> (ID) TRAP 
                                  "000000000000100",  -- (0x1E) 
                                  "000000000000001",  -- (0x1F) 
                                  
                                  "000000000000000",  -- (0x20) -> (ID) JR 
                                  "000000000000000",  -- (0x21) 
                                  "000000000000000",  -- (0x22)
                                   
                                  "000000000000000",  -- (0x23) -> (ID) JARL 
                                  "001010000000000",  -- (0x24) 
                                  "000000010000000",  -- (0x25)
                                   
                                  "000000000000100",  -- (0x26) 
                                  "000000000000001",  -- (0x27) 
                                  "001010000000000",  -- (0x28)
                                   
                                  "000000010000000",  -- (0x29) -> LW
                                  "000000000000100",  -- (0x2A) 
                                  "000000000000000",  -- (0x2B) 
                                  
                                  "001010000000000",  -- (0x2C) 
                                  "000000010000000",  -- (0x2D) 
                                  "000000000000100",  -- (0x2E) 
                                  "000000000000001",  -- (0x2F) 
                                  
                                  "000000000000000",  -- (0x30) 
                                  "000000000000000",  -- (0x31) 
                                  "000000000000000",  -- (0x32) 
                                  "000000000000000",  -- (0x33) 
                                  
                                  "000000000000000",  -- (0x34)
                                  
                                  "000000000000000",  -- (0x35) 
                                  "000000000000000",  -- (0x36) -> SW
                                  "000000000000000",  -- (0x37) 
                                  
                                  "000000000000000",  -- (0x38) -> (ID) JR                              
                                  "000000000000000",  -- (0x39) 
                                  "000000000000000",  -- (0x3A) 
                                  
                                  "000000000000000",  -- (0x3B) -> (ID) JALR 
                                  "000000000000000",  -- (0x3C) 
                                  "000000000000000",  -- (0x3D) 
                                  
                                  "001010000000000",  -- (0x3E) -> (ID) SLLI
                                  "000000010000000",  -- (0x3F) 
                                  "000000000000100",  -- (0x40) 
                                  "000000000000001",  -- (0x41) 
                                  
                                  "000000000000000",  -- (0x42) -> (ID) NOP
                                  
                                  "001010000000000",  -- (0x43) -> (ID) SRLI
                                  "000000010000000",  -- (0x44) 
                                  "000000000000100",  -- (0x45) 
                                  "000000000000001",  -- (0x46) 
                                  
                                  "001010000000000",  -- (0x47) -> (ID) SRAI
                                  "000000010000000",  -- (0x48) 
                                  "000000000000100",  -- (0x49) 
                                  "000000000000001",  -- (0x4A) 
                                  
                                  "001010000000000",  -- (0x4B) -> (ID) SEQI
                                  "000000010000000",  -- (0x4C) 
                                  "000000000000100",  -- (0x4D) 
                                  "000000000000001",  -- (0x4E) 
                                  
                                  "001010000000000",  -- (0x4F) -> (ID) SNEI
                                  "000000010000000",  -- (0x50) 
                                  "000000000000100",  -- (0x51) 
                                  "000000000000001",  -- (0x52) 
                                  
                                  "001010000000000",  -- (0x53) -> (ID) SLTI
                                  "000000010000000",  -- (0x54) 
                                  "000000000000100",  -- (0x55) 
                                  "000000000000001",  -- (0x56) 
                                  
                                  "001010000000000",  -- (0x57) -> (ID) SGTI
                                  "000000010000000",  -- (0x58) 
                                  "000000000000100",  -- (0x59) 
                                  "000000000000001",  -- (0x5A) 
                                  
                                  "001010000000000",  -- (0x5B) -> (ID) SLEI
                                  "000000010000000",  -- (0x5C) 
                                  "000000000000100",  -- (0x5D) 
                                  "000000000000000",  -- (0x5E) 
                                  
                                  "001010000000000",  -- (0x5F) -> (ID) SGEI
                                  "000000010000000",  -- (0x60) 
                                  "000000000000100",  -- (0x61) 
                                  "000000000000001",  -- (0x62) 
                                  
                                  "000000000000000",  -- (0x63)
                                  "000000000000000",  -- (0x64) 
                                  "000000000000000",  -- (0x65) 
                                  "000000000000000",  -- (0x66) 
                                  
                                  "000000000000000",  -- (0x67) -> (ID) LH
                                  "000000000000000",  -- (0x68) 
                                  "000000000000000",  -- (0x69) 
                                  "000000000000000",  -- (0x6A) 
                                  "000000000000000",  -- (0x6B)
                                  
                                  "000000000000000",  -- (0x6C) -> (ID) LW
                                  "000000000000000",  -- (0x6D) 
                                  "000000000000000",  -- (0x6E) 
                                  "000000000000000",  -- (0x6F) 
                                  
                                  "000000000000000",  -- (0x70) -> (ID) LBU
                                  "000000000000000",  -- (0x71)
                                  "000000000000000",  -- (0x72)
                                  "000000000000000",  -- (0x73)
                                  
                                  "000000000000000",  -- (0x74) -> (ID) LHU
                                  "000000000000000",  -- (0x75)
                                  "000000000000000",  -- (0x76)
                                  "000000000000000",  -- (0x77)
                                  
                                  "000000000000000",  -- (0x78)
                                  "000000000000000",  -- (0x79)
                                  "000000000000000",  -- (0x7A)
                                  "000000000000000",  -- (0x7B)
                                  
                                  "000000000000000",  -- (0x7C)
                                  "000000000000000",  -- (0x7D)
                                  "000000000000000",  -- (0x7E)
                                  "000000000000000",  -- (0x7F)
                                  
                                  "000000000000000",  -- (0x80)
                                  "000000000000000",  -- (0x81)
                                  "000000000000000",  -- (0x82)
                                  "000000000000000",  -- (0x83)
                                  
                                  "000000000000000",  -- (0x84)
                                  "000000000000000",  -- (0x85)
                                  "000000000000000",  -- (0x86)
                                  "000000000000000",  -- (0x87)
                                  
                                  "000000000000000",  -- (0x88)
                                  "000000000000000",  -- (0x89)
                                  "000000000000000",  -- (0x8A)
                                  "000000000000000",  -- (0x8B)
                                  
                                  "000000000000000",  -- (0x8C)
                                  "000000000000000",  -- (0x8D)
                                  "000000000000000",  -- (0x8E)
                                  "000000000000000",  -- (0x8F)
                                  
                                  "000000000000000",  -- (0x90)
                                  "000000000000000",  -- (0x91)
                                  "000000000000000",  -- (0x92)
                                  "000000000000000",  -- (0x93)
                                  
                                  "000000000000000",  -- (0x94)
                                  "000000000000000",  -- (0x95)
                                  "000000000000000",  -- (0x96)
                                  "000000000000000",  -- (0x97)
                                  
                                  "000000000000000",  -- (0x98)
                                  "000000000000000",  -- (0x99)
                                  "000000000000000",  -- (0x9A)
                                  "000000000000000",  -- (0x9B)
                                  "000000000000000",  -- (0x9C)
                                  "000000000000000",  -- (0x9D)
                                  "000000000000000",  -- (0x9E)
                                  "000000000000000",  -- (0x9F)
                                  "000000000000000",  -- (0xA0)
                                  "000000000000000",  -- (0xA1)
                                  "000000000000000",  -- (0xA2)
                                  "000000000000000"); -- (0xA3)

  -- Reloc memory
  type reloc_mem_array is array (0 to RELOC_MEM_SIZE - 1) of unsigned(OP_CODE_SIZE +1 downto 0);
  signal reloc_mem : reloc_mem_array :=(x"00",
                                        x"00",
                                        x"02",  -- j      (0x02) -> (0x02)    Basic DONE
                                        x"05",  -- jal    (0x03) -> (0x05)    Basic DONE                                    
                                        x"08",  -- beqz   (0x04) -> (0x08)    Basic DONE
                                        x"0B",  -- bnez   (0x05) -> (0x0B)    Basic DONE
                                        x"00",  -- bfpt   (0x06) -> (0x00)
                                        x"00",  -- bfpf   (0x07) -> (0x00)
                                        x"14",  -- addi   (0x08) -> (0x14)    Basic DONE
                                        x"00",  -- addui  (0x09) -> (0x00)
                                        x"14",  -- subi   (0x0a) -> (0x14)    Basic DONE
                                        x"00",  -- subui  (0x0b) -> (0x00)
                                        x"14",  -- andi   (0x0c) -> (0x14)    Basic DONE
                                        x"14",  -- ori    (0x0d) -> (0x14)    Basic DONE
                                        x"14",  -- xori   (0x0e) -> (0x14)    Basic DONE
                                        x"00",  -- lhi    (0x0f) -> (0x00)
                                        x"00",  -- rfe    (0x10) -> (0x00)
                                        x"00",  -- trap   (0x11) -> (0x00)
                                        x"00",  -- jr     (0x12) -> (0x00)
                                        x"00",  -- jalr   (0x13) -> (0x00)
                                        x"14",  -- slli   (0x14) -> (0x14)    Basic DONE
                                        x"1C",  -- nop    (0x15) -> (0x1C)    Basic DONE
                                        x"14",  -- srli   (0x16) -> (0x14)    Basic DONE
                                        x"14",  -- srai   (0x17) -> (0x14)    Basic DONE
                                        x"00",  -- seqi   (0x18) -> (0x00)    
                                        x"14",  -- snei   (0x19) -> (0x14)    Basic DONE
                                        x"00",  -- slti   (0x1a) -> (0x00)
                                        x"00",  -- sgti   (0x1b) -> (0x00)
                                        x"14",  -- slei   (0x1c) -> (0x14)    Basic DONE
                                        x"14",  -- sgei   (0x1d) -> (0x14)    Basic DONE
                                        x"00",
                                        x"00",
                                        x"63",  -- lb     (0x20) -> (0x00)
                                        x"67",  -- lh     (0x21) -> (0x00)
                                        x"00",
                                        x"6C",  -- lw     (0x23) -> (0x00)    Basic DONE
                                        x"24",  -- lbu    (0x24) -> (0x00)
                                        x"25",  -- lhu    (0x25) -> (0x00)
                                        x"26",  -- lf     (0x26) -> (0x00)
                                        x"27",  -- ld     (0x27) -> (0x00)
                                        x"28",  -- sb     (0x28) -> (0x00)
                                        x"29",  -- sh     (0x29) -> (0x00)
                                        x"00",
                                        x"2b",  -- sw     (0x2b) -> (0x00)    Basic
                                        x"00",
                                        x"00",
                                        x"2e",  -- sf     (0x2e) -> (0x00)
                                        x"2f",  -- sd     (0x2f) -> (0x00)
                                        x"00",
                                        x"00",
                                        x"00",
                                        x"00",
                                        x"00",
                                        x"00",
                                        x"00",
                                        x"00",
                                        x"38",  -- itlb   (0x38) -> (0x00)
                                        x"00",
                                        x"3a",  -- sltui  (0x3a) -> (0x00)
                                        x"3b",  -- sgtui  (0x3b) -> (0x00)
                                        x"3c",  -- sleui  (0x3c) -> (0x00)
                                        x"3d",  -- sgeui  (0x3d) -> (0x00)
                                        x"00",
                                        x"00");
  
  -- Full Control Word
  signal cw : std_logic_vector(CW_SIZE - 1 downto 0);
  -- Microcode Program Counter
  signal uPC : integer range 0 to 131072;
  -- Instruction Count Register
  signal ICount : integer range 0 to INSTRUCTIONS_EXECUTION_CYCLES;
  -- Original Opcode Field
  signal OpCode : unsigned(OP_CODE_SIZE -1 downto 0);
  -- Relocated Opcode
  signal OpCode_Reloc : unsigned(OP_CODE_SIZE + 1 downto 0);
  -- Function Field                                 
  signal func : unsigned(FUNC_SIZE - 1 downto 0);
  
  
  

begin
  
  -- Control Word RTL assignment
  cw <= microcode(uPC);
  
  -- Stage 1
  IR_LATCH_EN       <= cw(CW_SIZE - 1);
  NPC_LATCH_EN      <= cw(CW_SIZE - 2);
  -- Stage 2
  RegA_LATCH_EN     <= cw(CW_SIZE - 3);
  RegB_LATCH_EN     <= cw(CW_SIZE - 4);
  RegIMM_LATCH_EN   <= cw(CW_SIZE - 5);  
  -- Stage 3
  MUXA_SEL          <= cw(CW_SIZE - 6);
  MUXB_SEL          <= cw(CW_SIZE - 7);
  ALU_OUTREG_EN     <= cw(CW_SIZE - 8);
  EQ_COND           <= cw(CW_SIZE - 9);
  -- Stage 4
  DRAM_WE           <= cw(CW_SIZE - 10);
  LMD_LATCH_EN      <= cw(CW_SIZE - 11);
  JUMP_EN           <= cw(CW_SIZE - 12);
  PC_LATCH_EN       <= cw(CW_SIZE - 13);
  -- Stage 5
  WB_MUX_SEL        <= cw(CW_SIZE - 14);
  RF_WE             <= cw(CW_SIZE - 15);

  OpCode            <= unsigned(IR_IN(IR_SIZE -1 downto 26));
  OpCode_Reloc      <= reloc_mem(conv_integer(OpCode));
  func              <= unsigned(IR_IN(FUNC_SIZE - 3 downto 0)) & "00";  -- Multiply func value by 4 (
                                                 -- Shift left)

  -- purpose: Generation of ALU OpCode
  -- type   : combinational
  -- inputs : OpCode,func
  -- outputs: ALU_OPCODE
  ALU_OP_CODE_P: process (OpCode,func)
  begin  -- process ALU_OP_CODE_P
    ALU_OPCODE <= (others => '0');
    if (OpCode = R_OPCODE) then         -- R-Type Instructions
      if (conv_integer(func) = 128) then -- ADD
        ALU_OPCODE <= "01";
      elsif (conv_integer(func) = 136) then
        ALU_OPCODE <= "10";              -- SUB
      end if;
    end if;
  end process ALU_OP_CODE_P;

  -- purpose: Update the uPC value depending on the instruction Op Code
  -- type   : sequential
  -- inputs : Clk, Rst, IR_IN
  -- outputs: CW Control Signals
  uPC_Proc: process (Clk, Rst)
  begin  -- process uPC_Proc
    if Rst = '0' then                   -- asynchronous reset (active low)
      uPC <= 0;
      ICount <= 0;
    elsif Clk'event and Clk = '1' then  -- rising clock edge
      if (ICount < 1) then
        uPC <= 1;
        ICount <= ICount + 1;
      elsif (ICount < 2) then
        if (OpCode = R_OPCODE) then
          uPC <= conv_integer(func);
        else
          uPC <= conv_integer(OpCode_Reloc);
        end if;
        ICount <= ICount + 1;
      elsif (ICount < INSTRUCTIONS_EXECUTION_CYCLES) then
        upc <= upc + 1;
        ICount <= ICount + 1;
      else
        ICount <= 1;
        uPC <= 1;
      end if;
      
    end if;
  end process uPC_Proc;
  

  

end architecture;
