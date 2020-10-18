----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: RWMEM
-- Function: Single-port RAM memory
-- Input:
-- Output:
-- Architecture: behavioral
-- Library/package: ieee.std_logic_ll64, work.globals
-- Date: 12/08/2020
----------------------------------------------------------------------------------
library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.globals.all;

entity TB_CU is
end entity;

architecture TESTBENCH of TB_CU is
    
  --------------------------------------------------------------------
  -- Component Declaration
  --------------------------------------------------------------------
  
  -- Control Unit
  component DLX_CU is
    generic (WIDTH  : integer := word_size;
             LENGTH : integer := addr_size);
    port (
      CLK              : in  std_logic;
      RST              : in  std_logic;
      STALL            : in  std_logic;
      FLUSH            : in  std_logic;
      IR_IN            : in std_logic_vector(WIDTH-1 downto 0);
      IF_EN            : out std_logic;
      ID_EN            : out std_logic;
      RF_LATCH_EN      : out std_logic;
      RF_RD1           : out std_logic;
      RF_RD2           : out std_logic;
      SIGN_EN          : out std_logic;
      IMM_SEL          : out std_logic;
      RegImm_LATCH_EN  : out std_logic;
      RegRD1_LATCH_EN  : out std_logic;
      RegPC1_LATCH_EN  : out std_logic;
      EX_EN            : out std_logic;
      MuxA_SEL         : out std_logic;
      MuxB_SEL         : out std_logic;
      ALU_OPCODE       : out aluOp;
      EQ_COND          : out std_logic;
      JUMP_EN          : out std_logic;
      RegA1_LATCH_EN   : out std_logic;
      RegME_LATCH_EN   : out std_logic;
      RegRD2_LATCH_EN  : out std_logic;
      RegPC2_LATCH_EN  : out std_logic;
      RF_WE_EX         : out std_logic;
      MEM_EN           : out std_logic;
      JUMP_REG         : out std_logic;
      DATA_WE          : out std_logic;
      STORE_SIZE       : out std_logic_vector(2 downto 0);
      SIGN_LD          : out std_logic;
      LOAD_SIZE        : out std_logic_vector(2 downto 0);
      RegNPC3_LATCH_EN : out std_logic;
      RegALU2_LATCH_EN : out std_logic;
      RegLMD_LATCH_EN  : out std_logic;
      RegRD3_LATCH_EN  : out std_logic;
      RF_WE_MEM        : out std_logic;   
      WB_EN            : out std_logic;
      MuxWB_SEL        : out std_logic;
      RF_WE            : out std_logic;
      JUMP_LINK        : out std_logic 
    ); 
  end component;
  
  --------------------------------------------------------------------
  -- Signals Declaration
  --------------------------------------------------------------------
  
  signal CLK              : std_logic;
  signal RST              : std_logic;
  signal STALL            : std_logic;
  signal FLUSH            : std_logic;
  signal IR_IN            : std_logic_vector(word_size-1 downto 0);
  signal IF_EN            : std_logic;
  signal ID_EN            : std_logic;
  signal RF_LATCH_EN      : std_logic;
  signal RF_RD1           : std_logic;
  signal RF_RD2           : std_logic;
  signal SIGN_EN          : std_logic;
  signal IMM_SEL          : std_logic;
  signal RegImm_LATCH_EN  : std_logic;
  signal RegRD1_LATCH_EN  : std_logic;
  signal RegPC1_LATCH_EN  : std_logic;
  signal EX_EN            : std_logic;
  signal MuxA_SEL         : std_logic;
  signal MuxB_SEL         : std_logic;
  signal ALU_OPCODE       : aluOp;
  signal EQ_COND          : std_logic;
  signal JUMP_EN          : std_logic;
  signal RegA1_LATCH_EN   : std_logic;
  signal RegME_LATCH_EN   : std_logic;
  signal RegRD2_LATCH_EN  : std_logic;
  signal RegPC2_LATCH_EN  : std_logic;
  signal RF_WE_EX         : std_logic;
  signal MEM_EN           : std_logic;
  signal JUMP_REG         : std_logic;
  signal DATA_WE          : std_logic;
  signal STORE_SIZE       : std_logic_vector(2 downto 0);
  signal SIGN_LD          : std_logic;
  signal LOAD_SIZE        : std_logic_vector(2 downto 0);
  signal RegNPC3_LATCH_EN : std_logic;
  signal RegALU2_LATCH_EN : std_logic;
  signal RegLMD_LATCH_EN  : std_logic;
  signal RegRD3_LATCH_EN  : std_logic;
  signal RF_WE_MEM        : std_logic;   
  signal WB_EN            : std_logic;
  signal MuxWB_SEL        : std_logic;
  signal RF_WE            : std_logic;
  signal JUMP_LINK        : std_logic;
      
begin
  
  UUT: DLX_CU
    generic map (word_size, addr_size)
    port map (CLK, RST, STALL, FLUSH, IR_IN, IF_EN, ID_EN, RF_LATCH_EN, RF_RD1, RF_RD2, SIGN_EN, IMM_SEL, RegImm_LATCH_EN, RegRD1_LATCH_EN, RegPC1_LATCH_EN,
              EX_EN, MuxA_SEL, MuxB_SEL, ALU_OPCODE, EQ_COND, JUMP_EN, RegA1_LATCH_EN, RegME_LATCH_EN, RegRD2_LATCH_EN, RegPC2_LATCH_EN, RF_WE_EX,
              MEM_EN, JUMP_REG, DATA_WE, STORE_SIZE, SIGN_LD, LOAD_SIZE, RegNPC3_LATCH_EN, RegALU2_LATCH_EN, RegLMD_LATCH_EN, RegRD3_LATCH_EN, RF_WE_MEM, 
              WB_EN, MuxWB_SEL, RF_WE, JUMP_LINK);
               
  CLK_PROC: process
  begin
    CLK <= '0';
    wait for 2.5 ns;
    CLK <= '1';
    wait for 2.5 ns;
  end process;
  
  STIMULI: process
  begin
    -- Reset
    RST   <= '0';
    wait for 6 ns;
    RST   <= '1';
    STALL <= '0'; 
    FLUSH <= '0';
    IR_IN <= (others => '0');
    wait until (CLK = '1' and CLK'event);
    IR_IN <= x"028a4820";
    wait until (CLK = '1' and CLK'event);
    IR_IN <= x"2041fffb";
    wait until (CLK = '1' and CLK'event);
    IR_IN <= x"006a4824";
    wait until (CLK = '1' and CLK'event);
    IR_IN <= x"31340008";
    wait until (CLK = '1' and CLK'event);
    IR_IN <= x"8d13003f";
    wait until (CLK = '1' and CLK'event);
    STALL <= '1';
    IR_IN <= x"54000000";
    wait until (CLK = '1' and CLK'event);
    STALL <= '1'; 
    wait until (CLK = '1' and CLK'event);
    STALL <= '1'; 
    wait until (CLK = '1' and CLK'event);
    STALL <= '1';
    wait until (CLK = '1' and CLK'event);
    STALL <= '0';
    wait until (CLK = '1' and CLK'event);
    IR_IN <= x"10200002";
    wait until (CLK = '1' and CLK'event);
    IR_IN <= x"76890006";
    wait until (CLK = '1' and CLK'event);
    IR_IN <= x"0044682c";
    wait until (CLK = '1' and CLK'event);
    IR_IN <= x"7061fffc";
    wait until (CLK = '1' and CLK'event);
    FLUSH <= '1';
    IR_IN <= x"10200002";
    wait until (CLK = '1' and CLK'event);
    FLUSH <= '0';
    IR_IN <= x"76890006";
    wait until (CLK = '1' and CLK'event);
    IR_IN <= x"0044682c";
    wait until (CLK = '1' and CLK'event);
    IR_IN <= x"7061fffc";
    wait;
  end process;
  
end architecture;