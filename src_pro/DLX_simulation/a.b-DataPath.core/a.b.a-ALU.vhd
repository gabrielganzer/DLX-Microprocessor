----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: ALU
-- Function: DLX arithmetic logic unit
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

entity ALU is
    generic (
      WIDTH: integer:= word_size;
      RADIX: integer:= radix_size;
      OPCODE: integer:= op_size
    );
    port (A  :  in	std_logic_vector(WIDTH-1 downto 0);   -- Operand A
          B  :  in	std_logic_vector(WIDTH-1 downto 0);   -- Operand B
          OP :  in	aluOp;                                -- Opcode
          Y  :  out	std_logic_vector(WIDTH-1 downto 0)); -- Result
end entity;

architecture STRUCTURAL of ALU is
  
  -- Components
  -- Adder/Subtractor
  component ADDER_SUBTRACTOR
    generic (WIDTH: integer:= word_size; RADIX: integer:= radix_size);
    port (A:    in	std_logic_vector(WIDTH-1 downto 0);
          B:    in	std_logic_vector(WIDTH-1 downto 0);
          Ci:   in	std_logic;
          S:    out	std_logic_vector(WIDTH-1 downto 0);
          Co:   out std_logic);
  end component;
  -- Logic Unit
  component LOGIC
    generic (WIDTH: integer := 32);
    port (R1, R2         : in  std_logic_vector(WIDTH-1 downto 0);
          S0, S1, S2, S3 : in  std_logic;
          Y              : out std_logic_vector(WIDTH-1 downto 0));
  end component;
  -- Comparator
  component COMPARATOR
    port (Z, C                  : in  std_logic;
          LE, LT, GE, GT, EQ, NE: out std_logic);
  end component;
  -- Shifter
  component SHIFTER
    generic (WIDTH: integer := 32);
    port (R1, R2 : in  std_logic_vector(WIDTH-1 downto 0);
          SEL    : in std_logic_vector(1 downto 0);
          Y      : out std_logic_vector(WIDTH-1 downto 0));
  end component;
  -- Zero Detector
  component ZERO_DETECTOR
    generic (WIDTH : integer:= word_size);
    port (A : in  std_logic_vector(WIDTH-1 downto 0);
          Y : out std_logic);
  end component;
  -- Multiplier

component WALLACE_TREE
    generic (WIDTH: integer := word_size);
    port (A   : in std_logic_vector((WIDTH/2)-1 downto 0);
          B   : in std_logic_vector((WIDTH/2)-1 downto 0);
          S   : out std_logic_vector(WIDTH-1 downto 0);
          Co  : out std_logic_vector(WIDTH-1 downto 0)
    );
end component;
  
  -- Signals
  signal s_ADD_SUB : std_logic := '0'; 
  signal s_Z       : std_logic := '0'; 
  signal s_LE      : std_logic := '0'; 
  signal s_LT      : std_logic := '0'; 
  signal s_GE      : std_logic := '0';  
  signal s_GT      : std_logic := '0';  
  signal s_EQ      : std_logic := '0'; 
  signal s_NE      : std_logic := '0'; 
  signal s_Co      : std_logic := '0'; 
  signal s_SIGN    : std_logic := '0'; 
  signal s_C       : std_logic := '0'; 
  signal s_LOGIC   : std_logic_vector(3 downto 0) := (others => '0');
  signal s_SHIFT   : std_logic_vector(1 downto 0) := (others => '0');
  signal s_OUT     : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
  signal s_MULT    : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
  signal s_LOG     : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
  signal s_SHI     : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
  signal S_B_LHI   : std_logic_vector((WIDTH/2)-1 downto 0) := (others => '0');
  signal s_A_ADDER, S_B_ADDER : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
  signal s_A_LOGIC, S_B_LOGIC : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
  signal s_A_SHIFT, S_B_SHIFT : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
  signal s_A_MULT, S_B_MULT   : std_logic_vector((WIDTH/2)-1 downto 0) := (others => '0');
  
begin
  
  -- Sign/Unsign handling
  s_C <= s_Co xor s_SIGN;
  
  -- Select which component will execute according to the opcode signal
  SEL_PROC: process (OP, A, B)
  begin
    case OP is
      -- Adder/Subtractor
      when addOp  => s_A_ADDER <= A; s_B_ADDER <= B; s_ADD_SUB <= '0';
      when subOp  => s_A_ADDER <= A; s_B_ADDER <= B; s_ADD_SUB <= '1';
      -- Logic Unit
      when andOp  => s_A_LOGIC <= A; S_B_LOGIC <= B; s_LOGIC <= "1000";
      when orOp   => s_A_LOGIC <= A; S_B_LOGIC <= B; s_LOGIC <= "1110";
      when xorOp  => s_A_LOGIC <= A; S_B_LOGIC <= B; s_LOGIC <= "0110";
      -- Shifter
      when sllOp  => s_A_SHIFT <= A; S_B_SHIFT <= B; s_SHIFT <= "00";
      when srlOp  => s_A_SHIFT <= A; S_B_SHIFT <= B; s_SHIFT <= "01";
      when sraOp  => s_A_SHIFT <= A; S_B_SHIFT <= B; s_SHIFT <= "10";
      -- Comparator
      when gtOp   => s_A_ADDER <= A; s_B_ADDER <= B; s_ADD_SUB <= '1'; s_SIGN <= A(WIDTH-1) xor B(WIDTH-1);
      when geOp   => s_A_ADDER <= A; s_B_ADDER <= B; s_ADD_SUB <= '1'; s_SIGN <= A(WIDTH-1) xor B(WIDTH-1);
      when ltOp   => s_A_ADDER <= A; s_B_ADDER <= B; s_ADD_SUB <= '1'; s_SIGN <= A(WIDTH-1) xor B(WIDTH-1);
      when leOp   => s_A_ADDER <= A; s_B_ADDER <= B; s_ADD_SUB <= '1'; s_SIGN <= A(WIDTH-1) xor B(WIDTH-1);
      when gtUOp  => s_A_ADDER <= A; s_B_ADDER <= B; s_ADD_SUB <= '1'; s_SIGN <= '0';
      when geUOp  => s_A_ADDER <= A; s_B_ADDER <= B; s_ADD_SUB <= '1'; s_SIGN <= '0';
      when ltUOp  => s_A_ADDER <= A; s_B_ADDER <= B; s_ADD_SUB <= '1'; s_SIGN <= '0';
      when leUOp  => s_A_ADDER <= A; s_B_ADDER <= B; s_ADD_SUB <= '1'; s_SIGN <= '0';
      when eqOp   => s_A_ADDER <= A; s_B_ADDER <= B; s_ADD_SUB <= '1'; s_SIGN <= '0';
      when neOp   => s_A_ADDER <= A; s_B_ADDER <= B; s_ADD_SUB <= '1'; s_SIGN <= '0';
      when multOp => s_A_MULT  <= A((WIDTH/2)-1 downto 0); s_B_MULT  <= B((WIDTH/2)-1 downto 0); s_ADD_SUB <= '0';
      when lhiOp  => s_B_LHI   <= B((WIDTH/2)-1 downto 0);
      when others => null;
    end case;
  end process;
  
  -- Select the correct output according to the opcode signal
  OUT_PROC: process (OP, s_OUT, s_LOG, s_SHI, s_GT, s_GE, s_LT, s_LE, s_EQ, s_NE, s_B_LHI, s_MULT)
  begin
    case OP is
      when addOp  => Y <= s_OUT;
      when subOp  => Y <= s_OUT;
      when andOp  => Y <= s_LOG;
      when orOp   => Y <= s_LOG;
      when xorOp  => Y <= s_LOG;
      when sllOp  => Y <= s_SHI;
      when srlOp  => Y <= s_SHI;
      when sraOp  => Y <= s_SHI;
      when gtOp   => Y <= (WIDTH-1 downto 1 => '0') & s_GT;
      when gtUOp  => Y <= (WIDTH-1 downto 1 => '0') & s_GT;  
      when geOp   => Y <= (WIDTH-1 downto 1 => '0') & s_GE;
      when geUOp  => Y <= (WIDTH-1 downto 1 => '0') & s_GE;
      when ltOp   => Y <= (WIDTH-1 downto 1 => '0') & s_LT;
      when ltUOp  => Y <= (WIDTH-1 downto 1 => '0') & s_LT;
      when leOp   => Y <= (WIDTH-1 downto 1 => '0') & s_LE;
      when leUOp  => Y <= (WIDTH-1 downto 1 => '0') & s_LE;
      when eqOp   => Y <= (WIDTH-1 downto 1 => '0') & s_EQ;
      when neOp   => Y <= (WIDTH-1 downto 1 => '0') & s_NE;
      when lhiOp  => Y <= s_B_LHI & x"0000"; 
      when multOp => Y <= s_MULT;
      when others => Y <= (others => '0');
    end case;
  end process;
  
  -- Component assignment
  ADD_SUB: ADDER_SUBTRACTOR
    generic map (WIDTH, RADIX)
    port map (s_A_ADDER, s_B_ADDER, s_ADD_SUB, s_OUT, s_Co);
  
  BIG_XNOR: ZERO_DETECTOR
    generic map (WIDTH)
    port map (s_OUT, s_Z);
    
  LOGICALS: LOGIC
    generic map (WIDTH)
    port map (s_A_LOGIC, s_B_LOGIC, s_LOGIC(0), s_LOGIC(1), s_LOGIC(2), s_LOGIC(3), s_LOG);
    
  COMP: COMPARATOR
    port map (s_Z, s_C, s_LE, s_LT, s_GE, s_GT, s_EQ, s_NE);
  
  SHIFT: SHIFTER
    generic map (WIDTH)
    port map (s_A_SHIFT, s_B_SHIFT, s_SHIFT, s_SHI);
      
	MULT: WALLACE_TREE
    		generic map (WIDTH)
    		port map (s_A_MULT, s_B_MULT, s_A_ADDER, s_B_ADDER);
  
end architecture;
