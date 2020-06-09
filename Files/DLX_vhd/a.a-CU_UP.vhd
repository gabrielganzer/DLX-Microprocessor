library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
--use work.all;

entity dlx_cu is
  generic (
    INSTRUCTIONS_EXECUTION_CYCLES : integer := 5;  -- Instructions Execution
                                                   -- Clock Cycles
    MICROCODE_MEM_SIZE            : integer := 164;  -- Microcode Memory Size
    RELOC_MEM_SIZE                : integer := 64;  -- Microcode Relocation
                                                   -- Memory Size
    OP_CODE_SIZE : integer := 6;        -- Op Code Size
    ALU_OPC_SIZE : integer := 2;        -- ALU Op Code Word Size
    IR_SIZE      : integer := 32;       -- Instruction Register Size
    FUNC_SIZE    : integer := 11;       -- Func Field Size for R-Type Ops
    CW_SIZE      : integer := 15);      -- Control Word Size
  port (
    Clk             : in  std_logic;    -- Clock
    Rst             : in  std_logic;    -- Reset:Active-Low
    -- Instruction Register
    IR_IN           : in std_logic_vector(IR_SIZE - 1 downto 0);
    -- IF Control Signal
    IR_LATCH_EN     : out std_logic;    -- Instruction Register Latch Enable
    NPC_LATCH_EN    : out std_logic;
                                        -- NextProgramCounter Register Latch Enable
    -- ID Control Signals
    RegA_LATCH_EN   : out std_logic;    -- Register A Latch Enable
    RegB_LATCH_EN   : out std_logic;    -- Register B Latch Enable
    RegIMM_LATCH_EN : out std_logic;    -- Immediate Register Latch Enable
    -- EX Control Signal
    EQ_COND         : out std_logic;    -- Branch if (not) Equal to Zero
    JUMP_EN         : out std_logic;    -- JUMP Enable Signal for PC input MUX
    ALU_OPCODE      : out std_logic_vector(ALU_OPC_SIZE -1 downto 0); -- CHANGE IN DLX TOP the component declaration!
                                        -- ALU Operation Code
    MUXA_SEL        : out std_logic;    -- MUX-A Sel
    MUXB_SEL        : out std_logic;    -- MUX-B Sel
    ALU_OUTREG_EN   : out std_logic;    -- ALU Output Register Enable
    -- MEM Control Signals
    DRAM_WE         : out std_logic;    -- Data RAM Write Enable
    LMD_LATCH_EN    : out std_logic;    -- LMD Register Latch Enable
    PC_LATCH_EN     : out std_logic;    -- Program Counte Latch Enable
    WB_MUX_SEL      : out std_logic;    -- Write Back MUX Sel
    RF_WE           : out std_logic);   -- Register File Write Enable

end dlx_cu;

architecture dlx_cu_pu of dlx_cu is
  -- R-Type OpCode: 0x00
  --    ADD func Code: 0x20
  --    SUB func Code: 0x22
  -- I-Type OpCode
  --    LW : 0x23
  --    SW : 0x2b
  -- J-Type OpCode
  --    J    : 0x02
  --    BEQZ : 0x04

  type mem_array is array (integer range 0 to MICROCODE_MEM_SIZE - 1) of std_logic_vector(CW_SIZE - 1 downto 0);
  type reloc_mem_array is array (0 to RELOC_MEM_SIZE - 1) of unsigned(OP_CODE_SIZE +1 downto 0);

  signal reloc_mem : reloc_mem_array := (X"00",  -- All R-Type Instructions are not Relocated                                               
                                         X"00",
                                         X"02",  -- J(0x02) -> 0x02
                                         X"00",
                                         X"08",  -- BEQZ(0x04) -> 0x08
                                         X"00",
                                         X"00",
                                         X"00",
                                         X"00",
                                         X"00",
                                         X"00",
                                         X"00",
                                         X"00",
                                         X"00",
                                         X"00",
                                         X"00",
                                         X"00",
                                         X"00",
                                         X"00",
                                         X"00",
                                         X"00",
                                         X"00",
                                         X"00",
                                         X"00",
                                         X"00",
                                         X"00",
                                         X"00",
                                         X"00",
                                         X"00",
                                         X"00",
                                         X"00",
                                         X"00",
                                         X"00", 
                                         X"00",
                                         X"00", 
                                         X"29",  -- LW(0x23) -> 0x29
                                         X"00",
                                         X"00",
                                         X"00",
                                         X"00",
                                         X"00",
                                         X"00",
                                         X"00",
                                         X"36",  -- SW(0x2b) -> 0x36
                                         X"00",
                                         X"00",
                                         X"00",
                                         X"00",
                                         X"00",
                                         X"00",
                                         X"00",
                                         X"00",
                                         X"00",
                                         X"00",
                                         X"00",
                                         X"00",
                                         X"00",
                                         X"00",
                                         X"00",
                                         X"00",
                                         X"00",
                                         X"00",
                                         X"00",
                                         X"00");

  signal microcode : mem_array := ("000000000000000",  -- RESET
                                   "110000000000000",  -- (IF)
                                   "001010110000000",  -- (ID) 'J' (0x02)
                                   "000000111000100",  -- (EX)
                                   "000000000000101",  -- (MEM)
                                   "000000000000000",  -- (WB)
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",  -- (ID) 'BEQZ' (0x04)
                                   "000000000000000",  -- (EX)
                                   "000000000000000",  -- (MEM)
                                   "000000000000000",  -- (WB)
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000", 
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",  
                                   "000000000000000",
                                   "000000000000000",  
                                   "000000000000000",  
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",  -- (ID) 'LW' (0x23)
                                   "000000000000000",
                                   "000000000000000",  
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",  -- (ID) 'SW' (0x2b)
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",  -- (ID) 'ADD' (0x00,0x20)
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",  -- (ID) 'SUB' (0x00,0x22)
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000",
                                   "000000000000000");

  signal cw : std_logic_vector(CW_SIZE - 1 downto 0);

  signal uPC : integer range 0 to 131072;
  signal ICount : integer range 0 to INSTRUCTIONS_EXECUTION_CYCLES;
  signal OpCode : unsigned(OP_CODE_SIZE -1 downto 0);
  signal OpCode_Reloc : unsigned(OP_CODE_SIZE + 1 downto 0);
  
  constant R_OPCODE : unsigned(OP_CODE_SIZE -1 downto 0) := "000000";
                                                        
  signal func : unsigned(FUNC_SIZE - 1 downto 0);
  
  
  

begin  -- dlx_cu_rtl

  cw <= microcode(uPC);

  IR_LATCH_EN <= cw(CW_SIZE - 1);
  NPC_LATCH_EN <= cw(CW_SIZE - 2);

  RegA_LATCH_EN <= cw(CW_SIZE - 3);
  RegB_LATCH_EN <= cw(CW_SIZE - 4);
  RegIMM_LATCH_EN <= cw(CW_SIZE - 5);
  RF_WE <= cw(CW_SIZE - 6);

  MUXA_SEL <= cw(CW_SIZE - 7);
  MUXB_SEL <= cw(CW_SIZE - 8);
  ALU_OUTREG_EN <= cw(CW_SIZE - 9);
  EQ_COND <= cw(CW_SIZE - 10);

  DRAM_WE <= cw(CW_SIZE - 11);
  LMD_LATCH_EN <= cw(CW_SIZE - 12);
  JUMP_EN <= cw(CW_SIZE - 13);

  WB_MUX_SEL <= cw(CW_SIZE - 14);

  PC_LATCH_EN <= cw(CW_SIZE - 15);

  OpCode <= unsigned(IR_IN(IR_SIZE -1 downto 26));
  OpCode_Reloc <= reloc_mem(conv_integer(OpCode));
  func <= unsigned(IR_IN(FUNC_SIZE - 3 downto 0)) & "00";  -- Multiply func value by 4 (
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
  

  

end dlx_cu_pu;
