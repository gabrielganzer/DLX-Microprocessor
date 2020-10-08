----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: DLX
-- Function: DLX processor
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

entity DLX is
    generic (WIDTH          : integer := word_size);
    port (CLK               : in std_logic;
          RST               : in std_logic; -- Active-low
          IROM_EN				       : out std_logic;
		      IROM_ADDR   	     : out std_logic_vector(iram_addr_size-1 downto 0);
		      IROM_DATA				     : in std_logic_vector(WIDTH-1 downto 0);
		      DRAM_EN		         : out std_logic;
		      DRAM_RW		         : out std_logic;
		      DRAM_ADDR         : out std_logic_vector(dram_addr_size-1 downto 0);
		      DRAM_DATA_IN      : in std_logic_vector(WIDTH-1 downto 0);
		      DRAM_DATA_OUT     : out std_logic_vector(WIDTH-1 downto 0)
		);
end entity;

architecture STRUCTURAL of DLX is
  
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
  
  -- Component Data-Path
  component DLX_DP is
    generic (WIDTH     : integer := word_size;
             LENGTH    : integer := addr_size;
             RADIX     : integer := radix_size;
             OPCODE    : integer:= op_size
    );
    port (CLK              : in  std_logic;
          RST              : in  std_logic;
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
          IROM_DATA        : in std_logic_vector(WIDTH-1 downto 0);
          DRAM_OUT         : in std_logic_vector(WIDTH-1 downto 0);
          STALL            : out std_logic;
          FLUSH            : out std_logic;
          DRAM_WE          : out std_logic;
          IR               : out std_logic_vector(WIDTH-1 downto 0);
          IROM_ADDR        : out std_logic_vector(iram_addr_size-1 downto 0);
          DRAM_ADDR        : out std_logic_vector(dram_addr_size-1 downto 0);
          DRAM_IN          : out std_logic_vector(WIDTH-1 downto 0)
    ); 
  end component;

  ----------------------------------------------------------------
  -- Signal Declaration
  ----------------------------------------------------------------
    signal w_IF_EN            : std_logic;
    signal w_ID_EN            : std_logic;
    signal w_RF_LATCH_EN      : std_logic;
    signal w_RF_RD1           : std_logic;
    signal w_RF_RD2           : std_logic;
    signal w_SIGN_EN          : std_logic;
    signal w_IMM_SEL          : std_logic;
    signal w_RegImm_LATCH_EN  : std_logic;
    signal w_RegRD1_LATCH_EN  : std_logic;
    signal w_RegPC1_LATCH_EN  : std_logic;
    signal w_EX_EN            : std_logic;
    signal w_MuxA_SEL         : std_logic;
    signal w_MuxB_SEL         : std_logic;
    signal w_ALU_OPCODE       : aluOp;
    signal w_EQ_COND          : std_logic;
    signal w_JUMP_EN          : std_logic;
    signal w_RegA1_LATCH_EN   : std_logic;
    signal w_RegME_LATCH_EN   : std_logic;
    signal w_RegRD2_LATCH_EN  : std_logic;
    signal w_RegPC2_LATCH_EN  : std_logic;
    signal w_RF_WE_EX         : std_logic;
    signal w_MEM_EN           : std_logic;
    signal w_JUMP_REG         : std_logic;
    signal w_DATA_WE          : std_logic;
    signal w_STORE_SIZE       : std_logic_vector(2 downto 0);
    signal w_SIGN_LD          : std_logic;
    signal w_LOAD_SIZE        : std_logic_vector(2 downto 0);
    signal w_RegNPC3_LATCH_EN : std_logic;
    signal w_RegALU2_LATCH_EN : std_logic;
    signal w_RegLMD_LATCH_EN  : std_logic;
    signal w_RegRD3_LATCH_EN  : std_logic;
    signal w_RF_WE_MEM        : std_logic;
    signal w_WB_EN            : std_logic;
    signal w_MuxWB_SEL        : std_logic;
    signal w_RF_WE            : std_logic;
    signal w_JUMP_LINK        : std_logic;
    signal w_STALL            : std_logic;
    signal w_FLUSH            : std_logic;
    signal w_IR               : std_logic_vector(WIDTH-1 downto 0);
    
begin
  
  --------------------------------------------------------------------
  -- IROM
  --------------------------------------------------------------------
  IROM_EN	<= w_IF_EN;
  
  --------------------------------------------------------------------
  -- DRAM
  --------------------------------------------------------------------
	DRAM_EN <= w_MEM_EN;
  
  --------------------------------------------------------------------
  -- Control Unit
  --------------------------------------------------------------------
  CU: DLX_CU
    generic map(word_size, addr_size)
    port map(
      CLK              => CLK,
      RST              => RST,
      STALL            => w_STALL,
      FLUSH            => w_FLUSH,
      IR_IN            => w_IR,
      IF_EN            => w_IF_EN,
      ID_EN            => w_ID_EN,
      RF_LATCH_EN      => w_RF_LATCH_EN,
      RF_RD1           => w_RF_RD1,
      RF_RD2           => w_RF_RD2,
      SIGN_EN          => w_SIGN_EN,
      IMM_SEL          => w_IMM_SEL,
      RegImm_LATCH_EN  => w_RegImm_LATCH_EN,
      RegRD1_LATCH_EN  => w_RegRD1_LATCH_EN,
      RegPC1_LATCH_EN  => w_RegPC1_LATCH_EN,
      EX_EN            => w_EX_EN,
      MuxA_SEL         => w_MuxA_SEL,
      MuxB_SEL         => w_MuxB_SEL,
      ALU_OPCODE       => w_ALU_OPCODE,
      EQ_COND          => w_EQ_COND,
      JUMP_EN          => w_JUMP_EN,
      RegA1_LATCH_EN   => w_RegA1_LATCH_EN,
      RegME_LATCH_EN   => w_RegME_LATCH_EN,
      RegRD2_LATCH_EN  => w_RegRD2_LATCH_EN,
      RegPC2_LATCH_EN  => w_RegPC2_LATCH_EN,
      RF_WE_EX         => w_RF_WE_EX,
      MEM_EN           => w_MEM_EN,
      JUMP_REG         => w_JUMP_REG,
      DATA_WE          => w_DATA_WE,
      STORE_SIZE       => w_STORE_SIZE,
      SIGN_LD          => w_SIGN_LD,
      LOAD_SIZE        => w_LOAD_SIZE,
      RegNPC3_LATCH_EN => w_RegNPC3_LATCH_EN,
      RegALU2_LATCH_EN => w_RegALU2_LATCH_EN,
      RegLMD_LATCH_EN  => w_RegLMD_LATCH_EN,
      RegRD3_LATCH_EN  => w_RegRD3_LATCH_EN,
      RF_WE_MEM        => w_RF_WE_MEM,
      WB_EN            => w_WB_EN,
      MuxWB_SEL        => w_MuxWB_SEL,
      RF_WE            => w_RF_WE,
      JUMP_LINK        => w_JUMP_LINK
    ); 

  --------------------------------------------------------------------
  -- Datapath
  --------------------------------------------------------------------
  DP: DLX_DP
    generic map(word_size, addr_size, radix_size, op_size)
    port map(
      CLK              => CLK,
      RST              => RST,
      IF_EN            => w_IF_EN,
      ID_EN            => w_ID_EN,
      RF_LATCH_EN      => w_RF_LATCH_EN,
      RF_RD1           => w_RF_RD1,
      RF_RD2           => w_RF_RD2,
      SIGN_EN          => w_SIGN_EN,
      IMM_SEL          => w_IMM_SEL,
      RegImm_LATCH_EN  => w_RegImm_LATCH_EN,
      RegRD1_LATCH_EN  => w_RegRD1_LATCH_EN,
      RegPC1_LATCH_EN  => w_RegPC1_LATCH_EN,
      EX_EN            => w_EX_EN,
      MuxA_SEL         => w_MuxA_SEL,
      MuxB_SEL         => w_MuxB_SEL,
      ALU_OPCODE       => w_ALU_OPCODE,
      EQ_COND          => w_EQ_COND,
      JUMP_EN          => w_JUMP_EN,
      RegA1_LATCH_EN   => w_RegA1_LATCH_EN,
      RegME_LATCH_EN   => w_RegME_LATCH_EN,
      RegRD2_LATCH_EN  => w_RegRD2_LATCH_EN,
      RegPC2_LATCH_EN  => w_RegPC2_LATCH_EN,
      RF_WE_EX         => w_RF_WE_EX,
      MEM_EN           => w_MEM_EN,
      JUMP_REG         => w_JUMP_REG,
      DATA_WE          => w_DATA_WE,
      STORE_SIZE       => w_STORE_SIZE,
      SIGN_LD          => w_SIGN_LD,
      LOAD_SIZE        => w_LOAD_SIZE,
      RegNPC3_LATCH_EN => w_RegNPC3_LATCH_EN,
      RegALU2_LATCH_EN => w_RegALU2_LATCH_EN,
      RegLMD_LATCH_EN  => w_RegLMD_LATCH_EN,
      RegRD3_LATCH_EN  => w_RegRD3_LATCH_EN,
      RF_WE_MEM        => w_RF_WE_MEM,
      WB_EN            => w_WB_EN,
      MuxWB_SEL        => w_MuxWB_SEL,
      RF_WE            => w_RF_WE,
      JUMP_LINK        => w_JUMP_LINK,
      IROM_DATA        => IROM_DATA,
      DRAM_OUT         => DRAM_DATA_IN,
      STALL            => w_STALL,
      FLUSH            => w_FLUSH,
      DRAM_WE          => DRAM_RW,
      IR               => w_IR,
      IROM_ADDR        => IROM_ADDR,
      DRAM_ADDR        => DRAM_ADDR,
      DRAM_IN          => DRAM_DATA_OUT
    ); 
    
end architecture;
