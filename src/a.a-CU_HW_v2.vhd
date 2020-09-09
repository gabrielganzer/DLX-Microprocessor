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
    FUNC_SIZE          :     integer := function_size;      -- Func Field Size for R-Type Ops
    OPCODE_SIZE        :     integer := op_size;            -- Op Code Size
    IR_SIZE            :     integer := instruction_size;   -- Instruction Register Size    
    CW_SIZE            :     integer := control_word_size); -- Control Word Size
  port (
    CLK                : in  std_logic;  -- Clock
    RST                : in  std_logic;  -- Synchronous, active-high
    -- Instruction Register
    IR_IN              : in  std_logic_vector(IR_SIZE - 1 downto 0);    
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
 -- Signals
  signal IR_OPCODE : std_logic_vector(OPCODE_SIZE-1 downto 0);  -- OpCode part of IR
  signal IR_FUNC   : std_logic_vector(FUNC_SIZE-1 downto 0);    -- Func part of IR when Rtype
  -- Full control word  
  signal CW        : std_logic_vector(CW_SIZE-1 downto 0);    
  -- Partitioned control word
  signal CW1       : std_logic_vector(CW_SIZE-1 downto 0);    -- 1st stage (16-bit)
  signal CW2       : std_logic_vector(CW_SIZE-3 downto 0);    -- 2nd stage (13-bit)
  signal CW3       : std_logic_vector(CW_SIZE-6 downto 0);    -- 3rd stage (10-bit)
  signal CW4       : std_logic_vector(CW_SIZE-10 downto 0);   -- 4th stage (6-bit)
  signal CW5       : std_logic_vector(CW_SIZE-14 downto 0);   -- 5th stage (2-bit)
  signal OPCODE    : aluOp := nopOp; -- ALUOP defined in package
  signal OPCODE1   : aluOp := nopOp; 
  signal OPCODE2   : aluOp := nopOp; 
  signal OPCODE3   : aluOp := nopOp;
 
begin
  
  -- Opcode and Function fields extraction
  IR_OPCODE <= IR_IN(opcode_up downto opcode_down);
  IR_FUNC   <= IR_IN(func_up downto func_down);
  
  -- Stage 1: instruction fetch
  IR_LATCH_EN     <= CW1(CW_SIZE-1);
  NPC_LATCH_EN    <= CW1(CW_SIZE-2);
  -- Stage 2: instruction decode/register fetch
  RegA_LATCH_EN   <= CW2(CW_SIZE-3);
  RegB_LATCH_EN   <= CW2(CW_SIZE-4);
  RegIMM_LATCH_EN <= CW2(CW_SIZE-5);
  -- Stage 3: execute/address calculation
  MUXA_SEL        <= CW3(CW_SIZE-6);
  MUXB_SEL        <= CW3(CW_SIZE-7);
  ALU_OUTREG_EN   <= CW3(CW_SIZE-8);
  EQ_COND         <= CW3(CW_SIZE-9);
  ALU_OPCODE      <= OPCODE3;
  -- Stage 4: memory access
  DRAM_WE         <= CW4(CW_SIZE-10);
  LMD_LATCH_EN    <= CW4(CW_SIZE-11);
  JUMP_EN         <= CW4(CW_SIZE-12);
  PC_LATCH_EN     <= CW4(CW_SIZE-13);
  -- Stage 5: write-back
  WB_MUX_SEL      <= CW5(CW_SIZE-14);
  RF_WE           <= CW5(CW_SIZE-15);

  PIPE: process (CLK)
  begin
    if (CLK = '1' and CLK'event) then
      if (RST = '1') then
        CW1 <= (others => '0');
        CW2 <= (others => '0');
        CW3 <= (others => '0');
        CW4 <= (others => '0');
        CW5 <= (others => '0');
        OPCODE1 <= nopOp; 
        OPCODE2 <= nopOp; 
        OPCODE3 <= nopOp; 
      elsif (CLK = '1' and CLK'event) then
        CW1 <= CW;
        CW2 <= CW1(CW_SIZE-3 downto 0);
        CW3 <= CW2(CW_SIZE-6 downto 0);
        CW4 <= CW3(CW_SIZE-10 downto 0);
        CW5 <= CW4(CW_SIZE-14 downto 0);
        OPCODE1 <= OPCODE; 
        OPCODE2 <= OPCODE1; 
        OPCODE3 <= OPCODE2;
      end if;
    end if;
  end process;

  LUT: process (IR_OPCODE, IR_FUNC)
  begin
    --TBD
    if    IR_OPCODE = J                           then CW <= "110011010001100"; OPCODE <= addOp; -- J    
    elsif IR_OPCODE = J_JAL                       then CW <= "110011010001101"; OPCODE <= addOp; -- JAL   
    elsif IR_OPCODE = J_BEQZ                      then CW <= "111011011001100"; OPCODE <= addOp; -- J_BEQZ
    elsif IR_OPCODE = J_BNEZ                      then CW <= "111011010001100"; OPCODE <= addOp; -- J_BNEZ      
    elsif IR_OPCODE = NOP                         then CW <= "110000000000100"; OPCODE <= nopOp; -- NOP      
    elsif (IR_OPCODE = RTYPE and IR_FUNC = R_ADD) then CW <= "111100110000101"; OPCODE <= addOp; -- R_ADD
    elsif (IR_OPCODE = RTYPE and IR_FUNC = R_SUB) then CW <= "111100110000101"; OPCODE <= subOp; -- R_SUB
    elsif (IR_OPCODE = RTYPE and IR_FUNC = R_AND) then CW <= "111100110000101"; OPCODE <= andOp; -- R_AND
    elsif (IR_OPCODE = RTYPE and IR_FUNC = R_OR ) then CW <= "111100110000101"; OPCODE <= orOp;  -- R_OR
    elsif (IR_OPCODE = RTYPE and IR_FUNC = R_XOR) then CW <= "111100110000101"; OPCODE <= xorOp; -- R_XOR
    elsif (IR_OPCODE = RTYPE and IR_FUNC = R_SGE) then CW <= "111100110000101"; OPCODE <= geOp;  -- R_SGE
    elsif (IR_OPCODE = RTYPE and IR_FUNC = R_SLE) then CW <= "111100110000101"; OPCODE <= leOp;  -- R_SLE
    elsif (IR_OPCODE = RTYPE and IR_FUNC = R_SLL) then CW <= "111100110000101"; OPCODE <= sllOp; -- R_SLL
    elsif (IR_OPCODE = RTYPE and IR_FUNC = R_SRL) then CW <= "111100110000101"; OPCODE <= srlOp; -- R_SRL
    elsif (IR_OPCODE = RTYPE and IR_FUNC = R_SRA) then CW <= "111100110000101"; OPCODE <= sraOp; -- R_SRA
    elsif (IR_OPCODE = RTYPE and IR_FUNC = R_SNE) then CW <= "111100110000101"; OPCODE <= eqOp;  -- R_SNE        
    elsif IR_OPCODE = I_ADDI                      then CW <= "111010010000101"; OPCODE <= addOp; -- I_ADDI
    elsif IR_OPCODE = I_SUBI                      then CW <= "111010010000101"; OPCODE <= subOp; -- I_SUBI
    elsif IR_OPCODE = I_ANDI                      then CW <= "111010010000101"; OPCODE <= andOp; -- I_ANDI
    elsif IR_OPCODE = I_ORI                       then CW <= "111010010000101"; OPCODE <= orOp;  -- I_ORI
    elsif IR_OPCODE = I_XORI                      then CW <= "111010010000101"; OPCODE <= xorOp; -- I_XOR
    elsif IR_OPCODE = I_SLLI                      then CW <= "111010010000101"; OPCODE <= sllOp; -- I_SLLI
    elsif IR_OPCODE = I_SRLI                      then CW <= "111010010000101"; OPCODE <= srlOp; -- I_SRLI
    elsif IR_OPCODE = I_SRAI                      then CW <= "111010010000101"; OPCODE <= sraOp; -- I_SRAI
    elsif IR_OPCODE = I_SNEI                      then CW <= "111010010000101"; OPCODE <= eqOp;  -- I_SNEI
    elsif IR_OPCODE = I_SLEI                      then CW <= "111010010000101"; OPCODE <= leOp;  -- I_SLEI
    elsif IR_OPCODE = I_SGEI                      then CW <= "111010010000101"; OPCODE <= geOp;  -- I_SGEI        
    elsif IR_OPCODE = I_LW                        then CW <= "111010010010111"; OPCODE <= addOp; -- LW
    elsif IR_OPCODE = I_SW                        then CW <= "111110010100100"; OPCODE <= addOp; -- SW     
    else                                               CW <= "110000000000100"; OPCODE <= nopOp; -- NOP
    end if;
	end process;

end architecture;
