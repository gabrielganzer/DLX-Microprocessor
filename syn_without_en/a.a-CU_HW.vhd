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
    -- Stage 1: Instruction Fetch (IF)
    IF_EN            : out std_logic;
    -- Stage 2: Instruction Decode (ID)
    ID_EN            : out std_logic;
    RF_RD1           : out std_logic;  -- (1 -> Operand A     0 -> otherwise)
    RF_RD2           : out std_logic;  -- (1 -> Operand B     0 -> otherwise)
    SIGN_EN          : out std_logic;  -- (1 -> Signed IMM16  0 -> Unsigned IMM16)          
    IMM_SEL          : out std_logic;  -- (1 -> IMM26         0 -> IMM16)
    -- Stage 3: Execution (EX)
    EX_EN            : out std_logic;
    MuxA_SEL         : out std_logic;  -- (1 -> Operand A     0 -> NPC)
    MuxB_SEL         : out std_logic;  -- (1 -> Immediate     0 -> Operand B)
    ALU_OPCODE       : out aluOp;
    JUMP_EN          : out std_logic;  -- (1 -> J             0 -> otherwise)
    JUMP_EQ          : out std_logic;  -- (1 -> BEQZ          0 -> otherwise)
    JUMP_REG         : out std_logic;  -- (1 -> JR, JALR      0 -> otherwise)
    JUMP_LINK        : out std_logic;  -- (1 -> JAL, JALR     0 -> otherwise)
    RF_WE_EX         : out std_logic;
    -- Stage 4: Memory Access (MEM)
    MEM_EN           : out std_logic;
    DATA_WE          : out std_logic;  -- (1 -> Memory write  0 -> Memory read)
    STORE_SIZE       : out std_logic_vector(2 downto 0);  -- (0 -> SW 1 -> SH     2 -> SB)
    SIGN_LD          : out std_logic;  -- (1 -> Signed load   0 -> Unsigned load)
    LOAD_SIZE        : out std_logic_vector(2 downto 0);  -- (0 -> LW 1 -> LH/LHU 2 -> LB/LBU)
    RF_WE_MEM        : out std_logic;
    -- Stage 5: Write-Back (WB)
    WB_EN            : out std_logic;
    MuxWB_SEL        : out std_logic;  -- (1 -> Load          0 -> otherwise)
    RF_WE            : out std_logic;
    FLUSH            : out std_logic
  ); 
end entity;

architecture HARDWIRED of DLX_CU is

  -- Instruction Register Fields
  signal IR_opcode : std_logic_vector(op_size-1 downto 0);              -- OpCode part of IR
  signal IR_func   : std_logic_vector(function_size -1 downto 0);       -- Func part of IR when Rtype
  -- Shifted Control Word
  signal cw : std_logic_vector(control_word_size-1 downto 0);    -- Full Control Word
  signal cw1 : std_logic_vector(control_word_size-6 downto 0);    -- 1st stage
  signal cw2 : std_logic_vector(control_word_size-9 downto 0);    -- 2nd stage
  signal cw3 : std_logic_vector(control_word_size-22 downto 0);   -- 3rd stage
  -- Shifted ALU Opcode
  signal aluOpcode  : aluOp := nopOp; -- ALUOP defined in package
  signal aluOpcode1 : aluOp := nopOp; -- 1st stage
  -- Flush logic
  signal JUMP    : std_logic;
  signal JUMP1   : std_logic;
  signal JUMP2   : std_logic;
  signal JUMP3   : std_logic;
  
begin
  
  -- OpCode and Func extraction
  IR_opcode <= IR_IN(opcode_up downto opcode_down);
  IR_func   <= IR_IN(func_up downto func_down);
  -- FLush Logic
  FLUSH     <= JUMP1 or JUMP2 or JUMP3;
  -- Stage 1: Instruction Fetch (IF)
  IF_EN     <= RST when (CLK = '1' and CLK'event);
  -- Stage 2: Instruction Decode (ID)
  ID_EN            <= cw(control_word_size-1);
  RF_RD1           <= cw(control_word_size-2);
  RF_RD2           <= cw(control_word_size-3);
  SIGN_EN          <= cw(control_word_size-4);
  IMM_SEL          <= cw(control_word_size-5);
  -- Stage 3: Execution (EX)
  EX_EN            <= cw1(control_word_size-6);
  MuxA_SEL         <= cw1(control_word_size-7);
  MuxB_SEL         <= cw1(control_word_size-8);
  ALU_OPCODE       <= aluOpcode1;
  JUMP_EN          <= cw1(control_word_size-9);
  JUMP_EQ          <= cw1(control_word_size-10);
  JUMP_REG         <= cw1(control_word_size-11);
  JUMP_LINK        <= cw1(control_word_size-12);
  RF_WE_EX         <= cw1(control_word_size-24);
  -- Stage 4: Memory Access (MEM)
  MEM_EN           <= cw2(control_word_size-13);
  DATA_WE          <= cw2(control_word_size-14);
  STORE_SIZE       <= cw2(control_word_size-15 downto control_word_size-17);
  SIGN_LD          <= cw2(control_word_size-18);
  LOAD_SIZE        <= cw2(control_word_size-19 downto control_word_size-21);
  RF_WE_MEM        <= cw2(control_word_size-24);
  -- Stage 5: Write-Back (WB)
  WB_EN            <= cw3(control_word_size-22);
  MuxWB_SEL        <= cw3(control_word_size-23);
  RF_WE            <= cw3(control_word_size-24);

  -- Pipeline control words
  PIPE: process (CLK)
  begin
    if (CLK = '1' and CLK'event) then
      if (RST = '0') then
        cw1 <= (others => '0');
        cw2 <= (others => '0');
        cw3 <= (others => '0');
        JUMP1   <= '0';
        JUMP2   <= '0';
        JUMP3   <= '0';
        aluOpcode1 <= nopOp; 
      else
        cw1 <= cw(control_word_size-6 downto 0);
        cw2 <= cw1(control_word_size-9 downto 0);
        cw3 <= cw2(control_word_size-22 downto 0);
        JUMP1   <= JUMP;
        JUMP2   <= JUMP1;
        JUMP3   <= JUMP2;
        aluOpcode1 <= aluOpcode;
      end if;
    end if;
  end process;

  CW_LUT: process(IR_opcode, IR_FUNC)
  begin
 	  case IR_opcode is
 	    when RTYPE      => 
 	      case IR_FUNC is
 	        when "00000000000" => cw <= "00000"&"0000000"&"000000000"&"000";
 	        when others => cw <= "11100"&"1100000"&"100000000"&"101";
 	      end case;
  		  when NOP        => cw <= "00000"&"0000000"&"100000000"&"000";
      when J          => cw <= "10001"&"1011000"&"100000000"&"000";
      when J_JAL      => cw <= "10001"&"1010001"&"100000000"&"101";
      when J_BEQZ     => cw <= "11000"&"1010100"&"100000000"&"000";
      when J_BNEZ     => cw <= "11000"&"1010000"&"100000000"&"000";
      when J_JR       => cw <= "11000"&"1000010"&"100000000"&"000";
      when J_JALR     => cw <= "11000"&"1000011"&"100000000"&"101";
      when I_ADDI     => cw <= "11010"&"1110000"&"100000000"&"101";
      when I_ADDUI    => cw <= "11000"&"1110000"&"100000000"&"101";
      when I_SUBI     => cw <= "11010"&"1110000"&"100000000"&"101";
      when I_SUBUI    => cw <= "11000"&"1110000"&"100000000"&"101";
      when I_ANDI     => cw <= "11000"&"1110000"&"100000000"&"101";
      when I_ORI      => cw <= "11000"&"1110000"&"100000000"&"101";
      when I_XORI     => cw <= "11000"&"1110000"&"100000000"&"101";
      when I_LHI      => cw <= "10010"&"1010000"&"100000000"&"101";  
      when I_SLLI     => cw <= "11000"&"1110000"&"100000000"&"101";
      when I_SRLI     => cw <= "11000"&"1110000"&"100000000"&"101";
      when I_SRAI     => cw <= "11000"&"1110000"&"100000000"&"101";
      when I_SEQI     => cw <= "11010"&"1110000"&"100000000"&"101";
      when I_SNEI     => cw <= "11010"&"1110000"&"100000000"&"101";
      when I_SLTI     => cw <= "11010"&"1110000"&"100000000"&"101";
      when I_SGTI     => cw <= "11010"&"1110000"&"100000000"&"101";
      when I_SLEI     => cw <= "11010"&"1110000"&"100000000"&"101";
      when I_SGEI     => cw <= "11010"&"1110000"&"100000000"&"101";
      when I_LB       => cw <= "11010"&"1110000"&"100001100"&"111";
      when I_LH       => cw <= "11010"&"1110000"&"100001010"&"111";
      when I_LW       => cw <= "11010"&"1110000"&"100000001"&"111";
      when I_SB       => cw <= "11110"&"1110000"&"111000000"&"000";
      when I_SH       => cw <= "11110"&"1110000"&"110100000"&"000";
      when I_SW       => cw <= "11110"&"1110000"&"110010000"&"000";
      when I_LBU      => cw <= "11010"&"1110000"&"100000100"&"111";
      when I_LHU      => cw <= "11010"&"1110000"&"100000010"&"111";
      when I_SLTUI    => cw <= "11000"&"1110000"&"100000000"&"101";
      when I_SGTUI    => cw <= "11000"&"1110000"&"100000000"&"101";
      when I_SLEUI    => cw <= "11000"&"1110000"&"100000000"&"101";
      when I_SGEUI    => cw <= "11000"&"1110000"&"100000000"&"101";
  		  when others     => cw <= "00000"&"0000000"&"000000000"&"000";
	 end case;
  end process;

  OPCODE_LUT: process (IR_opcode, IR_func)
  begin
	  case IR_opcode is
  		  when RTYPE =>
  		    case IR_func is
          when R_SLL  => aluOpcode <= sllOp;  JUMP <= '0';
          when R_SRL  => aluOpcode <= srlOp;  JUMP <= '0';
          when R_SRA  => aluOpcode <= sraOp;  JUMP <= '0';
          when R_MULT => aluOpcode <= multOp; JUMP <= '0';
          when R_ADD  => aluOpcode <= addOp;  JUMP <= '0';
          when R_ADDU => aluOpcode <= addOp;  JUMP <= '0';
          when R_SUB  => aluOpcode <= subOp;  JUMP <= '0';
          when R_SUBU => aluOpcode <= subOp;  JUMP <= '0';
          when R_AND  => aluOpcode <= andOp;  JUMP <= '0';
          when R_OR   => aluOpcode <= orOp;   JUMP <= '0';
          when R_XOR  => aluOpcode <= xorOp;  JUMP <= '0';
          when R_SEQ  => aluOpcode <= eqOp;   JUMP <= '0';
          when R_SNE  => aluOpcode <= neOp;   JUMP <= '0';
          when R_SLT  => aluOpcode <= ltOp;   JUMP <= '0';
          when R_SGT  => aluOpcode <= gtOp;   JUMP <= '0';
          when R_SLE  => aluOpcode <= leOp;   JUMP <= '0';
          when R_SGE  => aluOpcode <= geOp;   JUMP <= '0';
          when R_SLTU => aluOpcode <= ltUOp;  JUMP <= '0';
          when R_SGTU => aluOpcode <= gtUOp;  JUMP <= '0';
          when R_SLEU => aluOpcode <= leUOp;  JUMP <= '0';
          when R_SGEU => aluOpcode <= geUOp;  JUMP <= '0';
          when others => aluOpcode <= nopOp;  JUMP <= '0';
        end case;
  		  when NOP        => aluOpcode <= nopOp;  JUMP <= '0';
      when J          => aluOpcode <= addOp;  JUMP <= '1';
      when J_JAL      => aluOpcode <= addOp;  JUMP <= '1';
      when J_BEQZ     => aluOpcode <= addOp;  JUMP <= '1';
      when J_BNEZ     => aluOpcode <= addOp;  JUMP <= '1';
      when J_JR       => aluOpcode <= addOp;  JUMP <= '1';
      when J_JALR     => aluOpcode <= addOp;  JUMP <= '1';
      when I_ADDI     => aluOpcode <= addOp;  JUMP <= '0';
      when I_ADDUI    => aluOpcode <= addOp;  JUMP <= '0';
      when I_SUBI     => aluOpcode <= subOp;  JUMP <= '0';
      when I_SUBUI    => aluOpcode <= subOp;  JUMP <= '0';
      when I_ANDI     => aluOpcode <= andOp;  JUMP <= '0';
      when I_ORI      => aluOpcode <= orOp;   JUMP <= '0';
      when I_XORI     => aluOpcode <= xorOp;  JUMP <= '0';
      when I_LHI      => aluOpcode <= lhiOp;  JUMP <= '0';    
      when I_SLLI     => aluOpcode <= sllOp;  JUMP <= '0';
      when I_SRLI     => aluOpcode <= srlOp;  JUMP <= '0';
      when I_SRAI     => aluOpcode <= sraOp;  JUMP <= '0';
      when I_SEQI     => aluOpcode <= eqOp;   JUMP <= '0';
      when I_SNEI     => aluOpcode <= neOp;   JUMP <= '0';
      when I_SLTI     => aluOpcode <= ltOp;   JUMP <= '0';
      when I_SGTI     => aluOpcode <= gtOp;   JUMP <= '0';
      when I_SLEI     => aluOpcode <= leOp;   JUMP <= '0';
      when I_SGEI     => aluOpcode <= geOp;   JUMP <= '0';
      when I_LB       => aluOpcode <= addOp;  JUMP <= '0';
      when	I_LH       => aluOpcode <= addOp;  JUMP <= '0';
      when I_LW       => aluOpcode <= addOp;  JUMP <= '0';
      when I_LBU      => aluOpcode <= addOp;  JUMP <= '0';
      when I_LHU      => aluOpcode <= addOp;  JUMP <= '0';
      when I_SB       => aluOpcode <= addOp;  JUMP <= '0';
      when I_SH       => aluOpcode <= addOp;  JUMP <= '0';
      when I_SW       => aluOpcode <= addOp;  JUMP <= '0';
      when I_SLTUI    => aluOpcode <= ltUOp;  JUMP <= '0';
      when I_SGTUI    => aluOpcode <= gtUOp;  JUMP <= '0';
      when I_SLEUI    => aluOpcode <= leUOp;  JUMP <= '0';
      when I_SGEUI    => aluOpcode <= geUOp;  JUMP <= '0';
  		  when others     => aluOpcode <= nopOp;  JUMP <= '0';
	 end case;
	end process;

end architecture;

