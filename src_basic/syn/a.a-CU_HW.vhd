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
use ieee.numeric_std.all;
use work.globals.all;

entity DLX_CU is
  generic (WIDTH  : integer := word_size;
           LENGTH : integer := addr_size);
  port (
    CLK             : in  std_logic;  -- Clock
    RST             : in  std_logic;  -- Synchronous reset, active-low
    IR_IN           : in std_logic_vector(WIDTH-1 downto 0);
    -- Control
    -- Stage 1: Instruction Fetch (IF)
    EN1             : out std_logic;
    -- Stage 2: Instruction Decode (ID)
    EN2             : out std_logic;
    RF_RD1          : out std_logic;
    RF_RD2          : out std_logic;
    MuxIMM_SEL      : out std_logic;
    -- Stage 3: Execution (EX)
    EN3             : out std_logic;
    MuxA_SEL        : out std_logic;
    MuxB_SEL        : out std_logic;
    EQ_COND         : out std_logic;
    JUMP_EN         : out std_logic;
    ALU_OPCODE      : out aluOp;
    -- Stage 4: Memory Access (MEM)
    EN4             : out std_logic;
    DRAM_WE         : out std_logic; 
    -- Stage 5: Write-Back (WB)
    MuxWB_SEL       : out std_logic;
    RF_WE           : out std_logic;
    JUMP_LINK       : out std_logic
    ); 
end entity;

architecture HARDWIRED of DLX_CU is

  signal IR_opcode : std_logic_vector(op_size-1 downto 0);              -- OpCode part of IR
  signal IR_func   : std_logic_vector(function_size -1 downto 0);       -- Func part of IR when Rtype
  signal cw        : std_logic_vector(control_word_size - 1 downto 0);  -- Full Control Word
  -- Shifted Control Word
  signal cw1 : std_logic_vector(control_word_size-1 downto 0);  -- 1st stage
  signal cw2 : std_logic_vector(control_word_size-2 downto 0);  -- 2nd stage
  signal cw3 : std_logic_vector(control_word_size-6 downto 0);  -- 3rd stage
  signal cw4 : std_logic_vector(control_word_size-11 downto 0); -- 4th stage
  signal cw5 : std_logic_vector(control_word_size-13 downto 0); -- 5th stage
  -- Shifted ALU Opcode
  signal aluOpcodei : aluOp := nopOp; -- ALUOP defined in package
  signal aluOpcode1 : aluOp := nopOp;
  signal aluOpcode2 : aluOp := nopOp;
  signal aluOpcode3 : aluOp := nopOp;

begin

  -- OpCode and Func extraction
  IR_opcode <= IR_IN(opcode_up downto opcode_down);
  IR_func   <= IR_IN(func_up downto func_down);
  
  -- Stage 1: Instruction Fetch (IF)
  EN1             <= cw1(control_word_size-1);
  -- Stage 2: Instruction Decode (ID)
  EN2             <= cw2(control_word_size-2);
  RF_RD1          <= cw2(control_word_size-3);
  RF_RD2          <= cw2(control_word_size-4);
  MuxIMM_SEL      <= cw2(control_word_size-5);  
  -- Stage 3: Execution (EX)
  EN3             <= cw3(control_word_size-6);
  MuxA_SEL        <= cw3(control_word_size-7);
  MuxB_SEL        <= cw3(control_word_size-8);
  EQ_COND         <= cw3(control_word_size-9);
  JUMP_EN         <= cw3(control_word_size-10);
  ALU_OPCODE      <= aluOpcode3;
  -- Stage 4: Memory Access (MEM)
  EN4             <= cw4(control_word_size-11);
  DRAM_WE         <= cw4(control_word_size-12);
  -- Stage 5: Write-Back (WB)
  MuxWB_SEL       <= cw5(control_word_size-13);
  RF_WE           <= cw5(control_word_size-14);
  JUMP_LINK       <= cw5(control_word_size-15);

  -- Pipeline control words
  PIPE: process (CLK, RST)
  begin
      if (RST = '0') then
        cw1 <= (others => '0');
        cw2 <= (others => '0');
        cw3 <= (others => '0');
        cw4 <= (others => '0');
        cw5 <= (others => '0');
        aluOpcode1 <= nopOp; 
        aluOpcode2 <= nopOp; 
        aluOpcode3 <= nopOp; 
      elsif (CLK = '1' and CLK'event) then
        cw1 <= cw;
        cw2 <= cw1(control_word_size-2 downto 0);
        cw3 <= cw2(control_word_size-6 downto 0);
        cw4 <= cw3(control_word_size-11 downto 0);
        cw5 <= cw4(control_word_size-13 downto 0);
        aluOpcode1 <= aluOpcodei; 
        aluOpcode2 <= aluOpcode1; 
        aluOpcode3 <= aluOpcode2;
      end if;
  end process;

  CW_LUT: process(IR_opcode, IR_func)
  begin
 	  case IR_opcode is
 	    when RTYPE      => 
 	    case IR_func is
          when R_SLL  => CW <= "111101010010010";
          when R_SRL  => CW <= "111101010010010";
          when R_SRA  => CW <= "111101010010010";
          when R_ADD  => CW <= "111101010010010";
          when R_SUB  => CW <= "111101010010010";
          when R_AND  => CW <= "111101010010010";
          when R_OR   => CW <= "111101010010010";
          when R_XOR  => CW <= "111101010010010";
          when R_SNE  => CW <= "111101010010010";
          when R_SLE  => CW <= "111101010010010";
          when R_SGE  => CW <= "111101010010010";
          when others => CW <= "100000000000000";
        end case;
  		  when NOP        => CW <= "100000000000000";
      when J          => CW <= "110001100110000";
      when J_JAL      => CW <= "110001100110011";
      when J_BEQZ     => CW <= "111011101110000";
      when J_BNEZ     => CW <= "111011100110000";
      when I_ADDI     => CW <= "111011000010010";
      when I_SUBI     => CW <= "111011000010010";
      when I_ANDI     => CW <= "111011000010010";
      when I_ORI      => CW <= "111011000010010";
      when I_XORI     => CW <= "111011000010010";
      when I_SLLI     => CW <= "111011000010010";
      when I_SRLI     => CW <= "111011000010010";
      when I_SRAI     => CW <= "111011000010010";
      when I_SNEI     => CW <= "111011000010010";
      when I_SLEI     => CW <= "111011000010010";
      when I_SGEI     => CW <= "111011000010010";
      when I_LW       => CW <= "111011000010110";
      when I_SW       => CW <= "111111000011100";
  		  when others     => CW <= "100000000000000";
	 end case;
  end process;

  OPCODE_LUT: process (IR_opcode, IR_func)
  begin
	  case IR_opcode is
  		  when RTYPE =>
  		    case IR_func is
          when R_SLL  => aluOpcodei <= sllOp;
          when R_SRL  => aluOpcodei <= srlOp;
          when R_SRA  => aluOpcodei <= sraOp;
          when R_ADD  => aluOpcodei <= addOp;
          when R_SUB  => aluOpcodei <= subOp;
          when R_AND  => aluOpcodei <= andOp;
          when R_OR   => aluOpcodei <= orOp;
          when R_XOR  => aluOpcodei <= xorOp;
          when R_SNE  => aluOpcodei <= neOp;
          when R_SLE  => aluOpcodei <= leOp;
          when R_SGE  => aluOpcodei <= geOp;
          when others => aluOpcodei <= nopOp;
        end case;
  		  when NOP        => aluOpcodei <= nopOp;
      when J          => aluOpcodei <= addOp;
      when J_JAL      => aluOpcodei <= addOp;
      when J_BEQZ     => aluOpcodei <= addOp;
      when J_BNEZ     => aluOpcodei <= addOp;
      when I_ADDI     => aluOpcodei <= addOp;
      when I_SUBI     => aluOpcodei <= subOp;
      when I_ANDI     => aluOpcodei <= andOp;
      when I_ORI      => aluOpcodei <= orOp;
      when I_XORI     => aluOpcodei <= xorOp;
      when I_SLLI     => aluOpcodei <= sllOp;
      when I_SRLI     => aluOpcodei <= srlOp;
      when I_SRAI     => aluOpcodei <= sraOp;
      when I_SNEI     => aluOpcodei <= neOp;
      when I_SLEI     => aluOpcodei <= leOp;
      when I_SGEI     => aluOpcodei <= geOp;
      when I_LW       => aluOpcodei <= addOp;
      when I_SW       => aluOpcodei <= addOp;
  		  when others     => aluOpcodei <= nopOp;
	 end case;
	end process;

end architecture HARDWIRED;

