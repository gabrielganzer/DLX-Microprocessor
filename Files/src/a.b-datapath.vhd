----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: DATAPATH
-- Function: DLX data-path
-- Input: A, B (32-bit)
--        OP (6-bit)
-- Output: Y (32-bit)
--         Co (1-bit)
-- Architecture: structural
-- Library/package: ieee.std_logic_ll64, work.globals
-- Date: 12/08/2020
----------------------------------------------------------------------------------
library IEEE;
library work;
use IEEE.std_logic_1164.all;
use work.globals.all;

entity DATAPATH is
    generic (
      FUNC_SIZE          :     integer := 11;  -- Func Field Size for R-Type Ops
      OP_CODE_SIZE       :     integer := 6;   -- Op Code Size
      IR_SIZE            :     integer := 32;  -- Instruction Register Size    
      CW_SIZE            :     integer := 15);  -- Control Word Size
      WIDTH: integer:= word_size;
      RADIX: integer:= radix_size;
      OPCODE: integer:= op_size
    );
    port (
      CLK             : in  std_logic;
      RST             : in  std_logic;  -- Synchronous, active-high
      -- Stage 1: instruction fetch
      IR_LATCH_EN     : in std_logic;  -- Instruction Register Latch Enable
      NPC_LATCH_EN    : in std_logic;
      -- Stage 2: instruction decode/register fetch
      RegA_LATCH_EN   : in std_logic;  -- Register A Latch Enable
      RegB_LATCH_EN   : in std_logic;  -- Register B Latch Enable
      RegIMM_LATCH_EN : in std_logic;  -- Immediate Register Latch Enable
      -- Stage 3: execute/address calculation
      MUXA_SEL        : in std_logic;  -- MUX-A Sel
      MUXB_SEL        : in std_logic;  -- MUX-B Sel
      ALU_OUTREG_EN   : in std_logic;  -- ALU Output Register Enable
      EQ_COND         : in std_logic;  -- Branch if (not) Equal to Zero
      ALU_OPCODE      : in aluOp;      -- choose between implicit or exlicit coding, like std_logic_vector(ALU_OPC_SIZE -1 downto 0);
      -- Stage 4: memory access
      DRAM_WE         : in std_logic;  -- Data RAM Write Enable
      LMD_LATCH_EN    : in std_logic;  -- LMD Register Latch Enable
      JUMP_EN         : in std_logic;  -- JUMP Enable Signal for PC input MUX
      PC_LATCH_EN     : in std_logic;  -- Program Counte Latch Enable
      -- Stage 5: write-back
      WB_MUX_SEL      : in std_logic;  -- Write Back MUX Sel
      RF_WE           : in std_logic);  -- Register File Write Enable
end entity;

architecture STRUCTURAL of DATAPATH is
  
  -- Components
  -- Multiplexer 2x1
  component MUX21_GENERIC
    generic(NBIT: integer);
    port (S1  :	in 	std_logic_vector(NBIT-1 downto 0);
	        S0  :	in	std_logic_vector(NBIT-1 downto 0);
	        SEL :	in	std_logic;
	        Y   :	out	std_logic_vector(NBIT-1 downto 0));
  end component;
  -- Register
  component REGISTER_GENERIC
    generic (WIDTH: integer := 32);
    port (CLK  : in std_logic;
          RST  : in std_logic;
          EN   : in std_logic;
          DIN  : in std_logic_vector(WIDTH-1 downto 0);    
          DOUT : out std_logic_vector(WIDTH-1 downto 0));
  end component;
  -- PC increment
  component PC_INCREMENT
    port (PC  : in std_logic_vector(31 downto 0);    
          NPC : out std_logic_vector(31 downto 0));
  end component;
  -- Register file
  component REGISTER_FILE
    generic (WIDTH: integer:= 32;
             DEPTH: integer:= 32;
             LENGTH: integer:= log2(32));
    port (CLK     :IN std_logic;
          RST     :IN std_logic;
          EN      :IN std_logic;
          RD1     :IN std_logic;
          RD2     :IN std_logic;
          WR      :IN std_logic;
          DATAIN  :IN std_logic_vector(WIDTH-1 downto 0);
          OUT1    :OUT std_logic_vector(WIDTH-1 downto 0);
          OUT2    :OUT std_logic_vector(WIDTH-1 downto 0);
          ADD_WR  :IN std_logic_vector(LENGTH-1 downto 0);
          ADD_RD1 :IN std_logic_vector(LENGTH-1 downto 0);
          ADD_RD2 :IN std_logic_vector(LENGTH-1 downto 0));
  end component;
  -- Sign extend
  component SIGN_EXTEND
    port (IMMU : in std_logic_vector(15 downto 0);    
          IMMS : out std_logic_vector(31 downto 0));
  end component;
  -- Instruction memory
  component ROMEM
    generic (
      file_path : string; -- string(1 to 37) := "C://DLX//dlx-master//rocache//hex.txt";
      ENTRIES   : integer := 128;
      WORD_SIZE : integer := 32;
      data_delay  : natural := 0);
    port (
      CLK         : in std_logic;
      RST         : in std_logic;
      ADDRESS     : in std_logic_vector(WORD_SIZE - 1 downto 0);
      ENABLE      : in std_logic;
      DATA_READY  : out std_logic;
      DATA        : out std_logic_vector(WORD_SIZE - 1 downto 0));
  end component;
  -- Data memory
  component RWMEM
    generic(
      file_path: string;
      file_path_init: string;
      Data_size : natural := 32;
      Instr_size: natural := 32;
      RAM_DEPTH:  natural := 128);
    port (
      CLK             : in std_logic;
      RST             : in std_logic;
      ADDR            : in std_logic_vector(Instr_size - 1 downto 0);
      ENABLE          : in std_logic;
      READNOTWRITE    : in std_logic;
      DATA_IN         : in std_logic_vector(Data_size-1 downto 0);
      DATA_READY      : out std_logic;
      DATA_OUT        : out std_logic_vector(Data_size-1 downto 0));
  end component;
  -- Arithmetic Logic Unit
  component ALU
    generic (WIDTH: integer:= word_size;
             RADIX: integer:= radix_size;
             OPCODE: integer:= op_size);
    port (A  :  in	std_logic_vector(WIDTH-1 downto 0);
          B  :  in	std_logic_vector(WIDTH-1 downto 0);
          OP :  in	aluOp;                             
          Y  :  out	std_logic_vector(WIDTH-1 downto 0));
  end component;
  
  -- Signals
  
begin
end architecture;
