----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: DLX_CU
-- Function: DLX control unit
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

entity DLX_CU is
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
end entity;

architecture HARDWIRED of DLX_CU is
  -- Components
  -- Register
  component REGISTER_GENERIC
  generic (WIDTH: integer := 32);
    port (CLK  : in std_logic;
          RST  : in std_logic;
          EN   : in std_logic;
          DIN  : in std_logic_vector(WIDTH-1 downto 0);    
          DOUT : out std_logic_vector(WIDTH-1 downto 0));
  end component;
  -- Signals
  signal IR_OPCODE : std_logic_vector(OPCODE_SIZE-1 downto 0);  -- OpCode part of IR
  signal IR_FUNC   : std_logic_vector(FUNC_SIZE-1 downto 0);    -- Func part of IR when Rtype
  signal CW        : std_logic_vector(CW_SIZE-1 downto 0);      -- Full control word register
  signal CW1       : std_logic_vector(CW_SIZE-1 downto 0);      -- 1st stage (18-bt)
  signal CW2       : std_logic_vector(CW_SIZE-4 downto 0);      -- 2nd stage (15-bit)
  signal CW3       : std_logic_vector(CW_SIZE-8 downto 0);      -- 3rd stage (11-bit)
  signal CW4       : std_logic_vector(CW_SIZE-12 downto 0);     -- 4th stage (7-bit)
  signal CW5       : std_logic_vector(CW_SIZE-17 downto 0);     -- 5th stage (2-bit)
  signal OPCODE    : aluOp := nopOp; -- ALUOP defined in package
  signal REG_EN    : std_logic;
 
begin

  IR_OPCODE <= IR_IN(opcode_up downto opcode_down);
  IR_FUNC   <= IR_IN(func_up downto func_down);

  -- Stage 1: instruction fetch
  IRAM_LATCH_EN   <= CW1(0);
  IR_LATCH_EN     <= CW1(1);
  NPC_LATCH_EN    <= CW1(2);
  -- Stage 2: instruction decode/register fetch
  RF_LATCH_EN     <= CW2(0);
  RegA_LATCH_EN   <= CW2(1);
  RegB_LATCH_EN   <= CW2(2);
  RegIMM_LATCH_EN <= CW2(3);
  -- Stage 3: execute/address calculation
  MUXA_SEL        <= CW3(0);
  MUXB_SEL        <= CW3(1);
  ALU_OUTREG_EN   <= CW3(2);
  EQ_COND         <= CW3(3);
  -- Stage 4: memory access
  DRAM_LATCH_EN   <= CW4(0);
  DRAM_WE         <= CW4(1);
  LMD_LATCH_EN    <= CW4(2);
  JUMP_EN         <= CW4(3);
  PC_LATCH_EN     <= CW4(4);
  -- Stage 5: write-back
  WB_MUX_SEL      <= CW5(0);
  RF_WE           <= CW5(1);

  -- process to pipeline control words
  PIPE1: process (CLK, IR_IN)
  begin
    if (CLK = '1' and CLK = '1') then
      if (RST = '1') then
        CW1 <= (others => '0');
        REG_EN <= '0';
        ALU_OPCODE <= nopOp;
      else
        CW1 <= CW;
        REG_EN <= '1';
        ALU_OPCODE <= OPCODE;
      end if;
    end if;
  end process;

  PIPE2: REGISTER_GENERIC
    generic map(CW2'length)
    port map(CLK, RST, REG_EN, CW1((CW1'length)-1 downto 2), CW2);
  
  PIPE3: REGISTER_GENERIC
    generic map(CW3'length)
    port map(CLK, RST, REG_EN, CW2((CW2'length)-1 downto 3), CW3);

  PIPE4: REGISTER_GENERIC
    generic map(CW4'length)
    port map(CLK, RST, REG_EN, CW3((CW3'length)-1 downto 3), CW4);
  
  PIPE5: REGISTER_GENERIC
    generic map(CW5'length)
    port map(CLK, RST, REG_EN, CW4((CW4'length)-1 downto 4), CW5);

  -- purpose: Generation of ALU OpCode
  LUT: process (IR_OPCODE, IR_FUNC)
  begin
    --TBD
    if    IR_OPCODE = J                           then CW <= "001100010001001111"; OPCODE <= addOp; -- J    
    elsif IR_OPCODE = J_JAL                       then CW <= "101100010001001111"; OPCODE <= addOp; -- JAL   
    elsif IR_OPCODE = J_BEQZ                      then CW <= "001101011011011111"; OPCODE <= addOp; -- J_BEQZ
    elsif IR_OPCODE = J_BNEZ                      then CW <= "001101001011011111"; OPCODE <= addOp; -- J_BNEZ
    elsif IR_OPCODE = NOP                         then CW <= "001001000000000111"; OPCODE <= nopOp; -- NOP    
    elsif (IR_OPCODE = RTYPE and IR_FUNC = R_ADD) then CW <= "101001001100111111"; OPCODE <= addOp; -- R_ADD
    elsif (IR_OPCODE = RTYPE and IR_FUNC = R_SUB) then CW <= "101001001100111111"; OPCODE <= subOp; -- R_SUB
    elsif (IR_OPCODE = RTYPE and IR_FUNC = R_AND) then CW <= "101001001100111111"; OPCODE <= andOp; -- R_AND
    elsif (IR_OPCODE = RTYPE and IR_FUNC = R_OR ) then CW <= "101001001100111111"; OPCODE <= orOp;  -- R_OR
    elsif (IR_OPCODE = RTYPE and IR_FUNC = R_XOR) then CW <= "101001001100111111"; OPCODE <= xorOp; -- R_XOR
    elsif (IR_OPCODE = RTYPE and IR_FUNC = R_SGE) then CW <= "101001001100111111"; OPCODE <= geOp;  -- R_SGE
    elsif (IR_OPCODE = RTYPE and IR_FUNC = R_SLE) then CW <= "101001001100111111"; OPCODE <= leOp;  -- R_SLE
    elsif (IR_OPCODE = RTYPE and IR_FUNC = R_SLL) then CW <= "101001001100111111"; OPCODE <= sllOp; -- R_SLL
    elsif (IR_OPCODE = RTYPE and IR_FUNC = R_SRL) then CW <= "101001001100111111"; OPCODE <= srlOp; -- R_SRL
    elsif (IR_OPCODE = RTYPE and IR_FUNC = R_SRA) then CW <= "101001001100111111"; OPCODE <= sraOp; -- R_SRA
    elsif (IR_OPCODE = RTYPE and IR_FUNC = R_SNE) then CW <= "101001001100111111"; OPCODE <= eqOp;  -- R_SNE    
    elsif IR_OPCODE = I_ADDI                      then CW <= "101001001001011111"; OPCODE <= addOp; -- I_ADDI
    elsif IR_OPCODE = I_SUBI                      then CW <= "101001001001011111"; OPCODE <= subOp; -- I_SUBI
    elsif IR_OPCODE = I_ANDI                      then CW <= "101001001001011111"; OPCODE <= andOp; -- I_ANDI
    elsif IR_OPCODE = I_ORI                       then CW <= "101001001001011111"; OPCODE <= orOp;  -- I_ORI
    elsif IR_OPCODE = I_XORI                      then CW <= "101001001001011111"; OPCODE <= xorOp; -- I_XOR
    elsif IR_OPCODE = I_SLLI                      then CW <= "101001001001011111"; OPCODE <= sllOp; -- I_SLLI
    elsif IR_OPCODE = I_SRLI                      then CW <= "101001001001011111"; OPCODE <= srlOp; -- I_SRLI
    elsif IR_OPCODE = I_SRAI                      then CW <= "101001001001011111"; OPCODE <= sraOp; -- I_SRAI
    elsif IR_OPCODE = I_SNEI                      then CW <= "101001001001011111"; OPCODE <= eqOp;  -- I_SNEI
    elsif IR_OPCODE = I_SLEI                      then CW <= "101001001001011111"; OPCODE <= leOp;  -- I_SLEI
    elsif IR_OPCODE = I_SGEI                      then CW <= "101001001001011111"; OPCODE <= geOp;  -- I_SGEI    
    elsif IR_OPCODE = I_LW                        then CW <= "101001001001011111"; OPCODE <= addOp; -- LW
    elsif IR_OPCODE = I_SW                        then CW <= "101001001001111111"; OPCODE <= addOp; -- SW
    else                                               CW <= (others => '0');
    end if;
	end process;

end architecture;
