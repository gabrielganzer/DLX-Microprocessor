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
    CLK              : in  std_logic;  -- Clock
    RST              : in  std_logic;  -- Synchronous reset, active-low
    FLUSH            : in  std_logic;  -- Synchronous reset, active-low
    IR_IN            : in std_logic_vector(WIDTH-1 downto 0);
    -- Stage 1: Instruction Fetch (IF)
    IF_EN            : out std_logic;
    JUMP             : out std_logic;
    -- Stage 2: Instruction Decode (ID)
    ID_EN            : out std_logic;
    RF_LATCH_EN      : out std_logic;  -- (1 -> RF Access     0 -> otherwise)
    RF_RD1           : out std_logic;  -- (1 -> Operand A     0 -> otherwise)
    RF_RD2           : out std_logic;  -- (1 -> Operand B     0 -> otherwise)
    SIGN_EN          : out std_logic;  -- (1 -> Signed IMM16  0 -> Unsigned IMM16)          
    IMM_SEL          : out std_logic;  -- (1 -> IMM26         0 -> IMM16)
    RegImm_LATCH_EN  : out std_logic;  -- (1 -> I-Inst/J-Inst 0 -> R-Inst)
    RegRD1_LATCH_EN  : out std_logic;  -- (1 -> Write-Back    0 -> otherwise)
    RegPC1_LATCH_EN  : out std_logic;  -- (1 -> J-Instruction 0 -> otherwise)
    -- Stage 3: Execution (EX)
    EX_EN            : out std_logic;
    MuxA_SEL         : out std_logic;  -- (1 -> Operand A     0 -> NPC)
    MuxB_SEL         : out std_logic;  -- (1 -> Immediate     0 -> Operand B)
    ALU_OPCODE       : out aluOp;
    EQ_COND          : out std_logic;  -- (1 -> BEQZ          0 -> otherwise)
    JUMP_EN          : out std_logic;  -- (1 -> J-Instruction 0 -> otherwise)
    RegA1_LATCH_EN   : out std_logic;  -- (1 -> Jump Register 0 -> otherwise)
    RegME_LATCH_EN   : out std_logic;  -- (1 -> Memory Access 0 -> otherwise)
    RegRD2_LATCH_EN  : out std_logic;  -- (1 -> Write-Back    0 -> otherwise)
    RegPC2_LATCH_EN  : out std_logic;  -- (1 -> J-Instruction 0 -> otherwise)
    RF_WE_EX         : out std_logic;
    -- Stage 4: Memory Access (MEM)
    MEM_EN           : out std_logic;
    JUMP_REG         : out std_logic;  -- (1 -> Jump Register 0 -> otherwise)
    DATA_WE          : out std_logic;  -- (1 -> Memory write  0 -> Memory read)
    STORE_SIZE       : out std_logic_vector(2 downto 0);  -- (0 -> SW 1 -> SH     2 -> SB)
    SIGN_LD          : out std_logic;  -- (1 -> Signed load   0 -> Unsigned load)
    LOAD_SIZE        : out std_logic_vector(2 downto 0);  -- (0 -> LW 1 -> LH/LHU 2 -> LB/LBU)
    RegNPC3_LATCH_EN : out std_logic;  -- (1 -> Jump&Link     0 -> otherwise)
    RegALU2_LATCH_EN : out std_logic;  -- (1 -> Write-Back    0 -> otherwise)
    RegLMD_LATCH_EN  : out std_logic;  -- (1 -> Load          0 -> otherwise)
    RegRD3_LATCH_EN  : out std_logic;  -- (1 -> Write-Back    0 -> otherwise)
    RF_WE_MEM        : out std_logic;
    -- Stage 5: Write-Back (WB)
    WB_EN            : out std_logic;
    MuxWB_SEL        : out std_logic;  -- (1 -> Load          0 -> otherwise)
    RF_WE            : out std_logic;  -- (1 -> Write-Back    0 -> otherwise)
    JUMP_LINK        : out std_logic   -- (1 -> Jump&Link     0 -> otherwise)
  ); 
end entity;

architecture HARDWIRED of DLX_CU is

  -- Instruction Register Fields
  signal IR_opcode : std_logic_vector(op_size-1 downto 0);              -- OpCode part of IR
  signal IR_func   : std_logic_vector(function_size -1 downto 0);       -- Func part of IR when Rtype
  -- Shifted Control Word
  signal cwi : std_logic_vector(control_word_size-1 downto 0);    -- Full Control Word
  signal cw1 : std_logic_vector(control_word_size-1 downto 0);    -- 1st stage
  signal cw2 : std_logic_vector(control_word_size-2 downto 0);    -- 2nd stage
  signal cw3 : std_logic_vector(control_word_size-11 downto 0);   -- 3rd stage
  signal cw4 : std_logic_vector(control_word_size-20 downto 0);   -- 4th stage
  signal cw5 : std_logic_vector(control_word_size-34 downto 0);   -- 5th stage
  -- Shifted ALU Opcode
  signal aluOpcodei : aluOp := nopOp; -- ALUOP defined in package
  signal aluOpcode1 : aluOp := nopOp; -- 1st stage
  signal aluOpcode2 : aluOp := nopOp; -- 2nd stage
  signal aluOpcode3 : aluOp := nopOp; -- 3rd stage
  
  -- Testbench only
  subtype stageTYPE is integer range 0 to 5;
  signal STAGE : stageTYPE;

begin
  
  -- OpCode and Func extraction
  IR_opcode <= IR_IN(opcode_up downto opcode_down);
  IR_func   <= IR_IN(func_up downto func_down);
  
  -- Stage 1: Instruction Fetch (IF)
  IF_EN            <= cw1(control_word_size-1);
  JUMP             <= cw1(control_word_size-15);        
  -- Stage 2: Instruction Decode (ID)
  ID_EN            <= cw2(control_word_size-2);
  RF_LATCH_EN      <= cw2(control_word_size-3);
  RF_RD1           <= cw2(control_word_size-4);
  RF_RD2           <= cw2(control_word_size-5);
  SIGN_EN          <= cw2(control_word_size-6);
  IMM_SEL          <= cw2(control_word_size-7);
  RegImm_LATCH_EN  <= cw2(control_word_size-8);
  RegRD1_LATCH_EN  <= cw2(control_word_size-9);
  RegPC1_LATCH_EN  <= cw2(control_word_size-10);
  -- Stage 3: Execution (EX)
  EX_EN            <= cw3(control_word_size-11);
  MuxA_SEL         <= cw3(control_word_size-12);
  MuxB_SEL         <= cw3(control_word_size-13);
  ALU_OPCODE       <= aluOpcode3;
  EQ_COND          <= cw3(control_word_size-14);
  JUMP_EN          <= cw3(control_word_size-15);
  RegA1_LATCH_EN   <= cw3(control_word_size-16);
  RegME_LATCH_EN   <= cw3(control_word_size-17);
  RegRD2_LATCH_EN  <= cw3(control_word_size-18);
  RegPC2_LATCH_EN  <= cw2(control_word_size-19); 
  RF_WE_EX         <= cw3(control_word_size-36);
  -- Stage 4: Memory Access (MEM)
  MEM_EN           <= cw4(control_word_size-20);
  JUMP_REG         <= cw4(control_word_size-21);
  DATA_WE          <= cw4(control_word_size-22);
  STORE_SIZE       <= cw4(control_word_size-23 downto control_word_size-25);
  SIGN_LD          <= cw4(control_word_size-26);
  LOAD_SIZE        <= cw4(control_word_size-27 downto control_word_size-29);
  RegNPC3_LATCH_EN <= cw4(control_word_size-30);
  RegALU2_LATCH_EN <= cw4(control_word_size-31);
  RegLMD_LATCH_EN  <= cw4(control_word_size-32);
  RegRD3_LATCH_EN  <= cw4(control_word_size-33);
  RF_WE_MEM        <= cw4(control_word_size-36);
  -- Stage 5: Write-Back (WB)
  WB_EN            <= cw5(control_word_size-34);
  MuxWB_SEL        <= cw5(control_word_size-35);
  RF_WE            <= cw5(control_word_size-36);
  JUMP_LINK        <= cw5(control_word_size-37);

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
        STAGE      <= 0;
      elsif (CLK = '1' and CLK'event) then
        cw1  <= cwi;
        aluOpcode1 <= aluOpcodei;
        if (FLUSH = '1') then
          cw2 <= (others => '0');
          cw3 <= (others => '0');
          cw4 <= (others => '0');
          cw5 <= (others => '0');
          aluOpcode2 <= nopOp; 
          aluOpcode3 <= nopOp;
          STAGE      <= 1;
        else
          cw2 <= cw1(control_word_size-2 downto 0);
          cw3 <= cw2(control_word_size-11 downto 0);
          cw4 <= cw3(control_word_size-20 downto 0);
          cw5 <= cw4(control_word_size-34 downto 0);
          aluOpcode2 <= aluOpcode1; 
          aluOpcode3 <= aluOpcode2;
          if (STAGE < 5) then
            STAGE      <= STAGE + 1;
          else
            STAGE      <= 1;
          end if;
        end if;
      end if;
  end process;

  CW_LUT: process(IR_opcode, IR_func)
  begin
 	  case IR_opcode is
 	    when RTYPE      => if (IR_func /= (func_up downto func_down => '0')) then
 	                          cwi <= '1'&"111100010"&"110000100"&"00000000000101"&"1010";
 	                       else
 	                          cwi <= '1'&"000000000"&"000000000"&"00000000000000"&"0000";
 	                       end if;
  		  when NOP        => cwi <= '1'&"000000000"&"000000000"&"00000000000000"&"0000";
      when J          => cwi <= '1'&"100001101"&"101010001"&"00000000000000"&"0000";
      when J_JAL      => cwi <= '1'&"100001101"&"101010001"&"00000000001000"&"1011";
      when J_BEQZ     => cwi <= '1'&"111000101"&"101110001"&"00000000000000"&"0000";
      when J_BNEZ     => cwi <= '1'&"111000101"&"101010001"&"00000000000000"&"0000";
      when J_JR       => cwi <= '1'&"111000001"&"100011001"&"01000000000000"&"0000";
      when J_JALR     => cwi <= '1'&"111000001"&"100011001"&"01000000001000"&"1011";
      when I_ADDI     => cwi <= '1'&"111010110"&"111000010"&"00000000000101"&"1010";
      when I_ADDUI    => cwi <= '1'&"111000110"&"111000010"&"00000000000101"&"1010";
      when I_SUBI     => cwi <= '1'&"111010110"&"111000010"&"00000000000101"&"1010";
      when I_SUBUI    => cwi <= '1'&"111000110"&"111000010"&"00000000000101"&"1010";
      when I_ANDI     => cwi <= '1'&"111000110"&"111000010"&"00000000000101"&"1010";
      when I_ORI      => cwi <= '1'&"111000110"&"111000010"&"00000000000101"&"1010";
      when I_XORI     => cwi <= '1'&"111000110"&"111000010"&"00000000000101"&"1010";
      when I_LHI      => cwi <= '1'&"100010110"&"101000010"&"00000000000101"&"1010";  
      when I_SLLI     => cwi <= '1'&"111000110"&"111000010"&"00000000000101"&"1010";
      when I_SRLI     => cwi <= '1'&"111000110"&"111000010"&"00000000000101"&"1010";
      when I_SRAI     => cwi <= '1'&"111000110"&"111000010"&"00000000000101"&"1010";
      when I_SEQI     => cwi <= '1'&"111010110"&"111000010"&"00000000000101"&"1010";
      when I_SNEI     => cwi <= '1'&"111010110"&"111000010"&"00000000000101"&"1010";
      when I_SLTI     => cwi <= '1'&"111010110"&"111000010"&"00000000000101"&"1010";
      when I_SGTI     => cwi <= '1'&"111010110"&"111000010"&"00000000000101"&"1010";
      when I_SLEI     => cwi <= '1'&"111010110"&"111000010"&"00000000000101"&"1010";
      when I_SGEI     => cwi <= '1'&"111010110"&"111000010"&"00000000000101"&"1010";
      when I_LB       => cwi <= '1'&"111010110"&"111000010"&"10000011000011"&"1110";
      when I_LH       => cwi <= '1'&"111010110"&"111000010"&"10000010100011"&"1110";
      when I_LW       => cwi <= '1'&"111010110"&"111000010"&"10000000010011"&"1110";
      when I_SB       => cwi <= '1'&"111110100"&"111000100"&"10110000000000"&"0000";
      when I_SH       => cwi <= '1'&"111110100"&"111000100"&"10101000000000"&"0000";
      when I_SW       => cwi <= '1'&"111110100"&"111000100"&"10100100000000"&"0000";
      when I_LBU      => cwi <= '1'&"111010110"&"111000010"&"10000001000011"&"1110";
      when I_LHU      => cwi <= '1'&"111010110"&"111000010"&"10000000100011"&"1110";
      when I_SLTUI    => cwi <= '1'&"111000110"&"111000010"&"00000000000101"&"1010";
      when I_SGTUI    => cwi <= '1'&"111000110"&"111000010"&"00000000000101"&"1010";
      when I_SLEUI    => cwi <= '1'&"111000110"&"111000010"&"00000000000101"&"1010";
      when I_SGEUI    => cwi <= '1'&"111000110"&"111000010"&"00000000000101"&"1010";
  		  when others     => cwi <= '1'&"000000000"&"000000000"&"00000000000000"&"0000";
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
          when R_MULT => aluOpcodei <= multOp;
          when R_ADD  => aluOpcodei <= addOp;
          when R_ADDU => aluOpcodei <= addOp;
          when R_SUB  => aluOpcodei <= subOp;
          when R_SUBU => aluOpcodei <= subOp;
          when R_AND  => aluOpcodei <= andOp;
          when R_OR   => aluOpcodei <= orOp;
          when R_XOR  => aluOpcodei <= xorOp;
          when R_SEQ  => aluOpcodei <= eqOp;
          when R_SNE  => aluOpcodei <= neOp;
          when R_SLT  => aluOpcodei <= ltOp;
          when R_SGT  => aluOpcodei <= gtOp;
          when R_SLE  => aluOpcodei <= leOp;
          when R_SGE  => aluOpcodei <= geOp;
          when R_SLTU => aluOpcodei <= ltUOp;
          when R_SGTU => aluOpcodei <= gtUOp;
          when R_SLEU => aluOpcodei <= leUOp;
          when R_SGEU => aluOpcodei <= geUOp;
          when others => aluOpcodei <= nopOp;
        end case;
  		  when NOP        => aluOpcodei <= nopOp;
      when J          => aluOpcodei <= addOp;
      when J_JAL      => aluOpcodei <= addOp;
      when J_BEQZ     => aluOpcodei <= addOp;
      when J_BNEZ     => aluOpcodei <= addOp;
      when J_JR       => aluOpcodei <= addOp;
      when J_JALR     => aluOpcodei <= addOp;
      when I_ADDI     => aluOpcodei <= addOp;
      when I_ADDUI    => aluOpcodei <= addOp;
      when I_SUBI     => aluOpcodei <= subOp;
      when I_SUBUI    => aluOpcodei <= subOp;
      when I_ANDI     => aluOpcodei <= andOp;
      when I_ORI      => aluOpcodei <= orOp;
      when I_XORI     => aluOpcodei <= xorOp;
      when I_LHI      => aluOpcodei <= lhiOp;    
      when I_SLLI     => aluOpcodei <= sllOp;
      when I_SRLI     => aluOpcodei <= srlOp;
      when I_SRAI     => aluOpcodei <= sraOp;
      when I_SEQI     => aluOpcodei <= eqOp;
      when I_SNEI     => aluOpcodei <= neOp;
      when I_SLTI     => aluOpcodei <= ltOp;
      when I_SGTI     => aluOpcodei <= gtOp;
      when I_SLEI     => aluOpcodei <= leOp;
      when I_SGEI     => aluOpcodei <= geOp;
      when I_LB       => aluOpcodei <= addOp;
      when	I_LH       => aluOpcodei <= addOp;
      when I_LW       => aluOpcodei <= addOp;
      when I_LBU      => aluOpcodei <= addOp;
      when I_LHU      => aluOpcodei <= addOp;
      when I_SB       => aluOpcodei <= addOp;
      when I_SH       => aluOpcodei <= addOp;
      when I_SW       => aluOpcodei <= addOp;
      when I_SLTUI    => aluOpcodei <= ltUOp;
      when I_SGTUI    => aluOpcodei <= gtUOp;
      when I_SLEUI    => aluOpcodei <= leUOp;
      when I_SGEUI    => aluOpcodei <= geUOp;
  		  when others     => aluOpcodei <= nopOp;
	 end case;
	end process;

end architecture;

