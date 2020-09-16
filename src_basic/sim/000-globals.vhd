----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Descriptions: set of constants, subtypes, and functions
-- Date: 28/07/2020
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;

package GLOBALS is
  
  -- Functions
 	-- Division between the two parameters, the result is an integer rounded by excess	
	function divide (n:integer; m:integer) return integer;
	-- Log base 2 of the number n, the result is an integer rounded by excess
	function log2 (n:integer) return integer;

  -- Datapath constants
  constant instruction_size  : integer := 32;
  constant word_size         : integer := 32;
  constant addr_size         : integer := 5;
  constant radix_size        : integer := 4;

  constant opcode_up         : integer :=  31;
  constant opcode_down       : integer :=  26;
  constant r1_up             : integer :=  25;
  constant r1_down           : integer :=  21;
  constant r2_up             : integer :=  20;
  constant r2_down           : integer :=  16;
  constant r3_up             : integer :=  15;
  constant r3_down           : integer :=  11;
  constant inp2_up           : integer :=  15;
  constant inp2_down         : integer :=  0;
  constant func_up           : integer :=  10;
  constant func_down         : integer :=  0;

  constant dram_addr_size    : integer := 6;
  constant iram_addr_size    : integer := 6;

  constant op_size           : integer := 6;
  constant function_size     : integer := 11;
  constant control_word_size : integer := 15;
  constant microcode_mem_size: integer := 256;
  constant reloc_mem_size    : integer := 64;   
  constant instructions_execution_cycles : integer := 5;
  

  -- CU constants
  -- NOP instruction -> OPCODE field
  constant	NOP	    : std_logic_vector(op_size - 1 downto 0) :=  "010101";		-- (0x15)
  -- J-Type instruction -> OPCODE field
  constant	J	      : std_logic_vector(op_size - 1 downto 0) :=  "000010";		-- (0x02)
  constant	J_JAL	  : std_logic_vector(op_size - 1 downto 0) :=  "000011";		-- (0x03)
  constant	J_BEQZ	 : std_logic_vector(op_size - 1 downto 0) :=  "000100";		-- (0x04)
  constant	J_BNEZ	 : std_logic_vector(op_size - 1 downto 0) :=  "000101";		-- (0x05)
  -- R-Type instruction -> OPCODE field
  constant RTYPE   : std_logic_vector(op_size - 1 downto 0) :=  "000000";  -- Register-to-register operation
  -- I-Type instruction -> OPCODE field
  constant	I_ADDI		: std_logic_vector(op_size - 1 downto 0) :=  "001000";		-- (0x08)
  constant	I_SUBI		: std_logic_vector(op_size - 1 downto 0) :=  "001010";		-- (0x0A)
  constant	I_ANDI		: std_logic_vector(op_size - 1 downto 0) :=  "001100";		-- (0x0C)
  constant	I_ORI		 : std_logic_vector(op_size - 1 downto 0) :=  "001101";		-- (0x0D)
  constant	I_XORI		: std_logic_vector(op_size - 1 downto 0) :=  "001110";		-- (0x0E)
  constant	I_SLLI		: std_logic_vector(op_size - 1 downto 0) :=  "010100";		-- (0x14)
  constant	I_SRLI		: std_logic_vector(op_size - 1 downto 0) :=  "010110";		-- (0x16)
  constant	I_SRAI		: std_logic_vector(op_size - 1 downto 0) :=  "010111";		-- (0x17)
  constant	I_SNEI		: std_logic_vector(op_size - 1 downto 0) :=  "011001";		-- (0x19)
  constant	I_SLEI		: std_logic_vector(op_size - 1 downto 0) :=  "011100";		-- (0x1C)
  constant	I_SGEI		: std_logic_vector(op_size - 1 downto 0) :=  "011101";		-- (0x1D)
  constant	I_LW    : std_logic_vector(op_size - 1 downto 0) :=  "100011";		-- (0x23)
  constant	I_SW    : std_logic_vector(op_size - 1 downto 0) :=  "101011";		-- (0x2B)

  -- R-Type instruction -> FUNC field
  constant	R_SLL   : std_logic_vector(function_size - 1 downto 0) :=  "00000000100";	-- (0x04) 
  constant	R_SRL   : std_logic_vector(function_size - 1 downto 0) :=  "00000000110";	-- (0x06) 
  constant	R_SRA   : std_logic_vector(function_size - 1 downto 0) :=  "00000000111";	-- (0x07) 
  constant	R_ADD   : std_logic_vector(function_size - 1 downto 0) :=  "00000100000";	-- (0x20) 
  constant	R_SUB   : std_logic_vector(function_size - 1 downto 0) :=  "00000100010";	-- (0x22) 
  constant	R_AND   : std_logic_vector(function_size - 1 downto 0) :=  "00000100100";	-- (0x24)
  constant	R_OR    : std_logic_vector(function_size - 1 downto 0) :=  "00000100101";	-- (0x25)
  constant	R_XOR   : std_logic_vector(function_size - 1 downto 0) :=  "00000100110";	-- (0x26)
  constant	R_SNE   : std_logic_vector(function_size - 1 downto 0) :=  "00000101001";	-- (0x29)
  constant	R_SLE   : std_logic_vector(function_size - 1 downto 0) :=  "00000101100";	-- (0x2C)
  constant	R_SGE   : std_logic_vector(function_size - 1 downto 0) :=  "00000101101";	-- (0x2D)

  -- Types
  type aluOp is (nopOp, addOp, subOp, andOp, orOp, xorOp, sllOp, srlOp, sraOp,  geOp,  leOp,  eqOp, neOp);
  
end package;

package body GLOBALS is
	function divide (n:integer; m:integer) return integer is
	begin
		if (n mod m) = 0 then
			return n/m;
		else
			return (n/m) + 1;
		end if;
	end divide;
	function log2 (n:integer) return integer is
	begin
		if n <=2 then
			return 1;
		else
			return 1 + log2(divide(n,2));
		end if;
	end log2;	
end package body;
