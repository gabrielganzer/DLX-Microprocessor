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
          IRAM_EN				       : out std_logic;
		      IRAM_ADDR   	     : out std_logic_vector(iram_addr_size-1 downto 0);
		      IRAM_DATA				     : in std_logic_vector(WIDTH-1 downto 0);
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
  
  -- Generic Register
  component REGISTER_GENERIC
    generic (WIDTH: integer := 32);
    port (CLK  : in std_logic;
          RST  : in std_logic;  -- Synchronous reset, active-low
          EN   : in std_logic;  -- Active-high enable
          DIN  : in std_logic_vector(WIDTH-1 downto 0);
          DOUT : out std_logic_vector(WIDTH-1 downto 0)
    );
  end component;
  
  -- Control Unit
  component DLX_CU
  generic (WIDTH  : integer := word_size;
           LENGTH : integer := addr_size);
  port (
    CLK             : in  std_logic;
    RST             : in  std_logic;
    IR_IN           : in std_logic_vector(WIDTH-1 downto 0);
    EN1             : out std_logic;
    EN2             : out std_logic;
    RF_RD1          : out std_logic;
    RF_RD2          : out std_logic;
    MuxIMM_SEL      : out std_logic;
    EN3             : out std_logic;
    MuxA_SEL        : out std_logic;
    MuxB_SEL        : out std_logic;
    EQ_COND         : out std_logic;
    JUMP_EN         : out std_logic;
    ALU_OPCODE      : out aluOp;
    EN4             : out std_logic;
    DRAM_WE         : out std_logic; 
    MuxWB_SEL       : out std_logic;
    RF_WE           : out std_logic;
    JUMP_LINK       : out std_logic
    ); 
  end component;
  
  -- Component Data-Path
  component DLX_DP
    generic (
      WIDTH     : integer := word_size;
      LENGTH    : integer := addr_size;
      RADIX     : integer := radix_size;
      OPCODE    : integer:= op_size
    );
    port (
      CLK             : in std_logic;
      RST             : in std_logic;
      EN1             : in std_logic;
      PC_IN           : in std_logic_vector(WIDTH-1 downto 0);
      EN2             : in std_logic;
      RF_RD1          : in std_logic;
      RF_RD2          : in std_logic;
      MuxIMM_SEL      : in std_logic;          
      RD              : in std_logic_vector(LENGTH-1 downto 0);
      RS1             : in std_logic_vector(LENGTH-1 downto 0);
      RS2             : in std_logic_vector(LENGTH-1 downto 0);
      IMM16           : in std_logic_vector((WIDTH/2)-1 downto 0);
      IMM26           : in std_logic_vector(WIDTH-OPCODE-1 downto 0);
      EN3             : in std_logic;
      MuxA_SEL        : in std_logic;
      MuxB_SEL        : in std_logic;
      EQ_COND         : in std_logic;
      JUMP_EN         : in std_logic;
      ALU_OPCODE      : in aluOp;
      EN4             : in std_logic;
      NPC_OUT         : out std_logic_vector(WIDTH-1 downto 0);
      DRAM_ADDR       : out std_logic_vector(dram_addr_size-1 downto 0);
      DRAM_IN         : in std_logic_vector(WIDTH-1 downto 0);
      DRAM_OUT        : out std_logic_vector(WIDTH-1 downto 0);
      MuxWB_SEL       : in std_logic;
      RF_WE           : in std_logic;
      JUMP_LINK       : in std_logic
    ); 
  end component;

  ----------------------------------------------------------------
  -- Signal Declaration
  ----------------------------------------------------------------
  signal w_PC_IN      : std_logic_vector(WIDTH-1 downto 0);
  signal w_PC_OUT     : std_logic_vector(WIDTH-1 downto 0);
  signal w_IR_OUT     : std_logic_vector(WIDTH-1 downto 0);
  signal w_EN1        : std_logic;
  signal w_EN2        : std_logic;
  signal w_RF_RD1     : std_logic;
  signal w_RF_RD2     : std_logic;
  signal w_MuxIMM_SEL : std_logic;
  signal w_SIGN_EN    : std_logic;
  signal w_EN3        : std_logic;
  signal w_MuxA_SEL   : std_logic;
  signal w_MuxB_SEL   : std_logic;
  signal w_EQ_COND    : std_logic;
  signal w_JUMP_EN    : std_logic;
  signal w_ALU_OPCODE : aluOp;
  signal w_EN4        : std_logic;
  signal w_MuxWB_SEL  : std_logic;
  signal w_RF_WE      : std_logic;
  signal w_JUMP_LINK  : std_logic;
  signal w_RD         : std_logic_vector(addr_size-1 downto 0);
  signal w_RS1        : std_logic_vector(addr_size-1 downto 0);
  signal w_RS2        : std_logic_vector(addr_size-1 downto 0);
  signal w_IMM16      : std_logic_vector(15 downto 0);
  signal w_IMM26      : std_logic_vector(25 downto 0);
    
begin

  --------------------------------------------------------------------
  -- Program Counter
  --------------------------------------------------------------------
  PC: REGISTER_GENERIC
    generic map(WIDTH)
    port map(
      CLK  => CLK,
      RST  => RST,
      EN   => w_EN1,
      DIN  => w_PC_IN,
      DOUT => w_PC_OUT
    );
  
  --------------------------------------------------------------------
  -- IRAM
  --------------------------------------------------------------------
  
  IRAM_EN				  <= w_EN1;
  IRAM_ADDR   	<= w_PC_OUT(iram_addr_size-1 downto 0);
  
  --------------------------------------------------------------------
  -- Instruction Register
  --------------------------------------------------------------------
  IR: REGISTER_GENERIC
    generic map(WIDTH)
    port map(
      CLK  => CLK,
      RST  => RST,
      EN   => w_EN1,
      DIN  => IRAM_DATA,
      DOUT => w_IR_OUT
  );
  
  --------------------------------------------------------------------
  -- Control Unit
  --------------------------------------------------------------------
  CU: DLX_CU
    generic map (word_size, addr_size)
    port map (
      CLK         => CLK,
      RST         => RST,
      IR_IN       => w_IR_OUT,
      EN1         => w_EN1,
      EN2         => w_EN2,
      RF_RD1      => w_RF_RD1,
      RF_RD2      => w_RF_RD2,
      MuxIMM_SEL  => w_MuxIMM_SEL,
      EN3         => w_EN3,
      MuxA_SEL    => w_MuxA_SEL,
      MuxB_SEL    => w_MuxB_SEL,
      EQ_COND     => w_EQ_COND,
      JUMP_EN     => w_JUMP_EN,
      ALU_OPCODE  => w_ALU_OPCODE,
      EN4         => w_EN4,
      DRAM_WE     => DRAM_RW, 
      MuxWB_SEL   => w_MuxWB_SEL,
      RF_WE       => w_RF_WE,
      JUMP_LINK   => w_JUMP_LINK
    ); 

  --------------------------------------------------------------------
  -- Datapath
  --------------------------------------------------------------------
  DP: DLX_DP
    generic map (word_size, addr_size, radix_size, op_size)
    port map(
      CLK         => CLK,
      RST         => RST,
      EN1         => w_EN1,
      PC_IN       => w_PC_OUT,
      EN2         => w_EN2,
      RF_RD1      => w_RF_RD1,
      RF_RD2      => w_RF_RD2,
      MuxIMM_SEL  => w_MuxIMM_SEL,
      RD          => w_RD,
      RS1         => w_RS1,
      RS2         => w_RS2,
      IMM16       => w_IMM16,
      IMM26       => w_IMM26,
      EN3         => w_EN3,
      MuxA_SEL    => w_MuxA_SEL,
      MuxB_SEL    => w_MuxB_SEL,
      EQ_COND     => w_EQ_COND,
      JUMP_EN     => w_JUMP_EN,
      ALU_OPCODE  => w_ALU_OPCODE,
      EN4         => w_EN4,
      NPC_OUT     => w_PC_IN,
      DRAM_ADDR   => DRAM_ADDR,
      DRAM_IN     => DRAM_DATA_IN,
      DRAM_OUT    => DRAM_DATA_OUT,
      MuxWB_SEL   => w_MuxWB_SEL,
      RF_WE       => w_RF_WE,
      JUMP_LINK   => w_JUMP_LINK
    );
    
  --------------------------------------------------------------------
  -- DRAM
  --------------------------------------------------------------------
  DRAM_EN		 <= w_EN4;
  
  --------------------------------------------------------------------
  -- ADDRESSES & IMMEDIATE
  --------------------------------------------------------------------
  w_RD      <= w_IR_OUT(r3_up downto r3_down) when (w_IR_OUT(opcode_up downto opcode_down) = RTYPE)   else
               (others => '1')                when (w_IR_OUT(opcode_up downto opcode_down) = J_JAL)   else
               w_IR_OUT(r2_up downto r2_down);            
  w_RS1     <= w_IR_OUT(r1_up downto r1_down); 
  w_RS2     <= w_IR_OUT(r2_up downto r2_down) when (w_IR_OUT(opcode_up downto opcode_down) = RTYPE)   else
               w_IR_OUT(r2_up downto r2_down) when (w_IR_OUT(opcode_up downto opcode_down) = I_SW)    else
               (others => '0');
  w_IMM16   <= (others => '0')                when (w_IR_OUT(opcode_up downto opcode_down) = J_JAL)   else
               w_IR_OUT(inp2_up downto inp2_down);
  w_IMM26   <= w_IR_OUT(opcode_down-1 downto 0);
  
end architecture;
