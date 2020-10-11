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
    IR_IN            : in std_logic_vector(WIDTH-1 downto 0);
    -- Stage 2: Instruction Decode (ID)
    ID_EN            : out std_logic;
    RF_LATCH_EN      : out std_logic;  -- (1 -> RF Access     0 -> otherwise)
    RF_RD1           : out std_logic;  -- (1 -> Operand A     0 -> otherwise)
    RF_RD2           : out std_logic;  -- (1 -> Operand B     0 -> otherwise)
    SIGN_EN          : out std_logic;  -- (1 -> Signed IMM16  0 -> Unsigned IMM16)          
    IMM_SEL          : out std_logic;  -- (1 -> IMM26         0 -> IMM16)
    RegImm_LATCH_EN  : out std_logic;  -- (1 -> I-Inst/J-Inst 0 -> R-Inst)
    RegRD1_LATCH_EN  : out std_logic;  -- (1 -> Write-Back    0 -> otherwise)
    -- Stage 3: Execution (EX)
    EX_EN            : out std_logic;
    MuxA_SEL         : out std_logic;  -- (1 -> Operand A     0 -> NPC)
    MuxB_SEL         : out std_logic;  -- (1 -> Immediate     0 -> Operand B)
    ALU_OPCODE       : out aluOp;
    JUMP_EN          : out std_logic;  -- (1 -> J             0 -> otherwise)
    JUMP_EQ          : out std_logic;  -- (1 -> BEQZ          0 -> otherwise)
    JUMP_REG         : out std_logic;  -- (1 -> JR, JALR      0 -> otherwise)
    JUMP_LINK        : out std_logic;  -- (1 -> JAL, JALR     0 -> otherwise)
    RegME_LATCH_EN   : out std_logic;  -- (1 -> Memory Access 0 -> otherwise)
    RegRD2_LATCH_EN  : out std_logic;  -- (1 -> Write-Back    0 -> otherwise)
    RF_WE_EX         : out std_logic;
    -- Stage 4: Memory Access (MEM)
    MEM_EN           : out std_logic;
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
    RF_WE            : out std_logic
  ); 
end entity;

architecture HARDWIRED of DLX_CU is

  -- Instruction Register Fields
  signal IR_opcode : std_logic_vector(op_size-1 downto 0);              -- OpCode part of IR
  signal IR_func   : std_logic_vector(function_size -1 downto 0);       -- Func part of IR when Rtype
  -- Shifted Control Word
  signal cw : std_logic_vector(control_word_size-1 downto 0);    -- Full Control Word
  signal cw1 : std_logic_vector(control_word_size-9 downto 0);    -- 1st stage
  signal cw2 : std_logic_vector(control_word_size-18 downto 0);    -- 2nd stage
  signal cw3 : std_logic_vector(control_word_size-31 downto 0);   -- 3rd stage
  -- Shifted ALU Opcode
  signal aluOpcode : aluOp := nopOp; -- ALUOP defined in package
  signal aluOpcode1 : aluOp := nopOp; -- 1st stage
  
begin
  
  -- OpCode and Func extraction
  IR_opcode <= IR_IN(opcode_up downto opcode_down);
  IR_func   <= IR_IN(func_up downto func_down);
  
  -- Stage 2: Instruction Decode (ID)
  ID_EN            <= cw(control_word_size-1);
  RF_LATCH_EN      <= cw(control_word_size-2);
  RF_RD1           <= cw(control_word_size-3);
  RF_RD2           <= cw(control_word_size-4);
  SIGN_EN          <= cw(control_word_size-5);
  IMM_SEL          <= cw(control_word_size-6);
  RegImm_LATCH_EN  <= cw(control_word_size-7);
  RegRD1_LATCH_EN  <= cw(control_word_size-8);
  -- Stage 3: Execution (EX)
  EX_EN            <= cw1(control_word_size-9);
  MuxA_SEL         <= cw1(control_word_size-10);
  MuxB_SEL         <= cw1(control_word_size-11);
  ALU_OPCODE       <= aluOpcode1;
  JUMP_EN          <= cw1(control_word_size-12);
  JUMP_EQ          <= cw1(control_word_size-13);
  JUMP_REG         <= cw1(control_word_size-14);
  JUMP_LINK        <= cw1(control_word_size-15);
  RegME_LATCH_EN   <= cw1(control_word_size-16);
  RegRD2_LATCH_EN  <= cw1(control_word_size-17); 
  RF_WE_EX         <= cw1(control_word_size-33);
  -- Stage 4: Memory Access (MEM)
  MEM_EN           <= cw2(control_word_size-18);
  DATA_WE          <= cw2(control_word_size-19);
  STORE_SIZE       <= cw2(control_word_size-20 downto control_word_size-22);
  SIGN_LD          <= cw2(control_word_size-23);
  LOAD_SIZE        <= cw2(control_word_size-24 downto control_word_size-26);
  RegNPC3_LATCH_EN <= cw2(control_word_size-27);
  RegALU2_LATCH_EN <= cw2(control_word_size-28);
  RegLMD_LATCH_EN  <= cw2(control_word_size-29);
  RegRD3_LATCH_EN  <= cw2(control_word_size-30);
  RF_WE_MEM        <= cw2(control_word_size-33);
  -- Stage 5: Write-Back (WB)
  WB_EN            <= cw3(control_word_size-31);
  MuxWB_SEL        <= cw3(control_word_size-32);
  RF_WE            <= cw3(control_word_size-33);

  -- Pipeline control words
  PIPE: process (CLK)
  begin
    if (CLK = '1' and CLK'event) then
      if (RST = '0') then
        cw1 <= (others => '0');
        cw2 <= (others => '0');
        cw3 <= (others => '0');
        aluOpcode1 <= nopOp; 
      else
        cw1 <= cw(control_word_size-9 downto 0);
        cw2 <= cw1(control_word_size-18 downto 0);
        cw3 <= cw2(control_word_size-31 downto 0);
        aluOpcode1 <= aluOpcode;
      end if;
    end if;
  end process;

  CW_LUT: process(IR_opcode, IR_FUNC)
  begin
 	  case IR_opcode is
 	    when RTYPE      => 
 	      case IR_FUNC is
 	        when "00000000000" => cw <= "00000000"&"000000000"&"0000000000000"&"000";
 	        when others => cw <= "11110001"&"110000011"&"0000000000101"&"101";
 	      end case;
  		  when NOP        => cw <= "00000000"&"000000000"&"0000000000000"&"000";
      when J          => cw <= "10000110"&"101100000"&"0000000000000"&"000";
      when J_JAL      => cw <= "10000110"&"101100100"&"0000000001000"&"101";
      when J_BEQZ     => cw <= "11100010"&"101110000"&"0000000000000"&"000";
      when J_BNEZ     => cw <= "11100010"&"101100000"&"0000000000000"&"000";
      when J_JR       => cw <= "11100000"&"100101000"&"0000000000000"&"000";
      when J_JALR     => cw <= "11100000"&"100101100"&"0000000001000"&"101";
      when I_ADDI     => cw <= "11101011"&"111000001"&"0000000000101"&"101";
      when I_ADDUI    => cw <= "11100011"&"111000001"&"0000000000101"&"101";
      when I_SUBI     => cw <= "11101011"&"111000001"&"0000000000101"&"101";
      when I_SUBUI    => cw <= "11100011"&"111000001"&"0000000000101"&"101";
      when I_ANDI     => cw <= "11100011"&"111000001"&"0000000000101"&"101";
      when I_ORI      => cw <= "11100011"&"111000001"&"0000000000101"&"101";
      when I_XORI     => cw <= "11100011"&"111000001"&"0000000000101"&"101";
      when I_LHI      => cw <= "10001011"&"101000001"&"0000000000101"&"101";  
      when I_SLLI     => cw <= "11100011"&"111000001"&"0000000000101"&"101";
      when I_SRLI     => cw <= "11100011"&"111000001"&"0000000000101"&"101";
      when I_SRAI     => cw <= "11100011"&"111000001"&"0000000000101"&"101";
      when I_SEQI     => cw <= "11101011"&"111000001"&"0000000000101"&"101";
      when I_SNEI     => cw <= "11101011"&"111000001"&"0000000000101"&"101";
      when I_SLTI     => cw <= "11101011"&"111000001"&"0000000000101"&"101";
      when I_SGTI     => cw <= "11101011"&"111000001"&"0000000000101"&"101";
      when I_SLEI     => cw <= "11101011"&"111000001"&"0000000000101"&"101";
      when I_SGEI     => cw <= "11101011"&"111000001"&"0000000000101"&"101";
      when I_LB       => cw <= "11101011"&"111000001"&"1000011000011"&"111";
      when I_LH       => cw <= "11101011"&"111000001"&"1000010100011"&"111";
      when I_LW       => cw <= "11101011"&"111000001"&"1000000010011"&"111";
      when I_SB       => cw <= "11111010"&"111000010"&"1110000000000"&"000";
      when I_SH       => cw <= "11111010"&"111000010"&"1101000000000"&"000";
      when I_SW       => cw <= "11111010"&"111000010"&"1100100000000"&"000";
      when I_LBU      => cw <= "11101011"&"111000001"&"1000001000011"&"111";
      when I_LHU      => cw <= "11101011"&"111000001"&"1000000100011"&"111";
      when I_SLTUI    => cw <= "11100011"&"111000001"&"0000000000101"&"101";
      when I_SGTUI    => cw <= "11100011"&"111000001"&"0000000000101"&"101";
      when I_SLEUI    => cw <= "11100011"&"111000001"&"0000000000101"&"101";
      when I_SGEUI    => cw <= "11100011"&"111000001"&"0000000000101"&"101";
  		  when others     => cw <= "00000000"&"000000000"&"0000000000000"&"000";
	 end case;
  end process;

  OPCODE_LUT: process (IR_opcode, IR_func)
  begin
	  case IR_opcode is
  		  when RTYPE =>
  		    case IR_func is
          when R_SLL  => aluOpcode <= sllOp;
          when R_SRL  => aluOpcode <= srlOp;
          when R_SRA  => aluOpcode <= sraOp;
          when R_MULT => aluOpcode <= multOp;
          when R_ADD  => aluOpcode <= addOp;
          when R_ADDU => aluOpcode <= addOp;
          when R_SUB  => aluOpcode <= subOp;
          when R_SUBU => aluOpcode <= subOp;
          when R_AND  => aluOpcode <= andOp;
          when R_OR   => aluOpcode <= orOp;
          when R_XOR  => aluOpcode <= xorOp;
          when R_SEQ  => aluOpcode <= eqOp;
          when R_SNE  => aluOpcode <= neOp;
          when R_SLT  => aluOpcode <= ltOp;
          when R_SGT  => aluOpcode <= gtOp;
          when R_SLE  => aluOpcode <= leOp;
          when R_SGE  => aluOpcode <= geOp;
          when R_SLTU => aluOpcode <= ltUOp;
          when R_SGTU => aluOpcode <= gtUOp;
          when R_SLEU => aluOpcode <= leUOp;
          when R_SGEU => aluOpcode <= geUOp;
          when others => aluOpcode <= nopOp;
        end case;
  		  when NOP        => aluOpcode <= nopOp;
      when J          => aluOpcode <= addOp;
      when J_JAL      => aluOpcode <= addOp;
      when J_BEQZ     => aluOpcode <= addOp;
      when J_BNEZ     => aluOpcode <= addOp;
      when J_JR       => aluOpcode <= addOp;
      when J_JALR     => aluOpcode <= addOp;
      when I_ADDI     => aluOpcode <= addOp;
      when I_ADDUI    => aluOpcode <= addOp;
      when I_SUBI     => aluOpcode <= subOp;
      when I_SUBUI    => aluOpcode <= subOp;
      when I_ANDI     => aluOpcode <= andOp;
      when I_ORI      => aluOpcode <= orOp;
      when I_XORI     => aluOpcode <= xorOp;
      when I_LHI      => aluOpcode <= lhiOp;    
      when I_SLLI     => aluOpcode <= sllOp;
      when I_SRLI     => aluOpcode <= srlOp;
      when I_SRAI     => aluOpcode <= sraOp;
      when I_SEQI     => aluOpcode <= eqOp;
      when I_SNEI     => aluOpcode <= neOp;
      when I_SLTI     => aluOpcode <= ltOp;
      when I_SGTI     => aluOpcode <= gtOp;
      when I_SLEI     => aluOpcode <= leOp;
      when I_SGEI     => aluOpcode <= geOp;
      when I_LB       => aluOpcode <= addOp;
      when	I_LH       => aluOpcode <= addOp;
      when I_LW       => aluOpcode <= addOp;
      when I_LBU      => aluOpcode <= addOp;
      when I_LHU      => aluOpcode <= addOp;
      when I_SB       => aluOpcode <= addOp;
      when I_SH       => aluOpcode <= addOp;
      when I_SW       => aluOpcode <= addOp;
      when I_SLTUI    => aluOpcode <= ltUOp;
      when I_SGTUI    => aluOpcode <= gtUOp;
      when I_SLEUI    => aluOpcode <= leUOp;
      when I_SGEUI    => aluOpcode <= geUOp;
  		  when others     => aluOpcode <= nopOp;
	 end case;
	end process;

end architecture;

