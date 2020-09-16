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
  component MULTIPLIER is
    generic (WIDTH: integer := word_size/2);
    port (A:   in std_logic_vector(WIDTH-1 downto 0);
          B:   in std_logic_vector(WIDTH-1 downto 0);
          P:   out std_logic_vector((2*WIDTH)-1 downto 0));
  end component;
  
  -- Signals
  signal s_ADD_SUB : std_logic;
  signal s_Z       : std_logic;
  signal s_LE      : std_logic; 
  signal s_LT      : std_logic; 
  signal s_GE      : std_logic; 
  signal s_GT      : std_logic; 
  signal s_EQ      : std_logic;
  signal s_NE      : std_logic;
  signal s_Co      : std_logic;
  signal s_SIGN    : std_logic;
  signal s_C       : std_logic; 
  signal s_LOGIC   : std_logic_vector(3 downto 0);
  signal s_SHIFT   : std_logic_vector(1 downto 0);
  signal s_OUT     : std_logic_vector(WIDTH-1 downto 0);
  signal s_MULT    : std_logic_vector(WIDTH-1 downto 0);
  signal s_LOG     : std_logic_vector(WIDTH-1 downto 0);
  signal s_SHI     : std_logic_vector(WIDTH-1 downto 0);
  
begin
  
  -- Sign/Unsign handling
  s_C <= s_Co xor s_SIGN;
  
  -- Select which component will execute according to the opcode signal
  SEL_PROC: process (OP, A, B)
  begin
    case OP is
      -- Adder/Subtractor
      when addOp  => s_ADD_SUB <= '0'; s_LOGIC <= "1111"; s_SHIFT <= "11"; s_SIGN <= '0';
      when subOp  => s_ADD_SUB <= '1'; s_LOGIC <= "1111"; s_SHIFT <= "11"; s_SIGN <= '0';
      -- Logic Unit
      when andOp  => s_ADD_SUB <= '0'; s_LOGIC <= "1000"; s_SHIFT <= "11"; s_SIGN <= '0';
      when orOp   => s_ADD_SUB <= '0'; s_LOGIC <= "1110"; s_SHIFT <= "11"; s_SIGN <= '0';
      when xorOp  => s_ADD_SUB <= '0'; s_LOGIC <= "0110"; s_SHIFT <= "11"; s_SIGN <= '0';
      -- Shifter
      when sllOp  => s_ADD_SUB <= '0'; s_LOGIC <= "1111"; s_SHIFT <= "00"; s_SIGN <= '0';
      when srlOp  => s_ADD_SUB <= '0'; s_LOGIC <= "1111"; s_SHIFT <= "01"; s_SIGN <= '0';
      when sraOp  => s_ADD_SUB <= '0'; s_LOGIC <= "1111"; s_SHIFT <= "10"; s_SIGN <= '0';
      -- Comparator
      when gtOp   => s_ADD_SUB <= '1'; s_LOGIC <= "1111"; s_SHIFT <= "11"; s_SIGN <= A(WIDTH-1) xor B(WIDTH-1);
      when geOp   => s_ADD_SUB <= '1'; s_LOGIC <= "1111"; s_SHIFT <= "11"; s_SIGN <= A(WIDTH-1) xor B(WIDTH-1);
      when ltOp   => s_ADD_SUB <= '1'; s_LOGIC <= "1111"; s_SHIFT <= "11"; s_SIGN <= A(WIDTH-1) xor B(WIDTH-1);
      when leOp   => s_ADD_SUB <= '1'; s_LOGIC <= "1111"; s_SHIFT <= "11"; s_SIGN <= A(WIDTH-1) xor B(WIDTH-1);
      when gtUOp  => s_ADD_SUB <= '1'; s_LOGIC <= "1111"; s_SHIFT <= "11"; s_SIGN <= '0';
      when geUOp  => s_ADD_SUB <= '1'; s_LOGIC <= "1111"; s_SHIFT <= "11"; s_SIGN <= '0';
      when ltUOp  => s_ADD_SUB <= '1'; s_LOGIC <= "1111"; s_SHIFT <= "11"; s_SIGN <= '0';
      when leUOp  => s_ADD_SUB <= '1'; s_LOGIC <= "1111"; s_SHIFT <= "11"; s_SIGN <= '0';
      when eqOp   => s_ADD_SUB <= '1'; s_LOGIC <= "1111"; s_SHIFT <= "11"; s_SIGN <= '0';
      when neOp   => s_ADD_SUB <= '1'; s_LOGIC <= "1111"; s_SHIFT <= "11"; s_SIGN <= '0';
      when multOp => s_ADD_SUB <= '0'; s_LOGIC <= "1111"; s_SHIFT <= "11"; s_SIGN <= '0';
      when others => null;
    end case;
  end process;
  
  -- Select the correct output according to the opcode signal
  OUT_PROC: process (OP, s_OUT, s_LOG, s_SHI, s_GT, s_GE, s_LT, s_LE, s_EQ, s_NE, s_MULT)
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
      when lhiOp  => Y <= B(15 downto 0) & x"0000"; 
      when multOp => Y <= s_MULT;
      when others => Y <= (others => '0');
    end case;
  end process;
  
  -- Component assignment
  ADD_SUB: ADDER_SUBTRACTOR
    generic map (WIDTH, RADIX)
    port map (A, B, s_ADD_SUB, s_OUT, s_Co);
  
  BIG_XNOR: ZERO_DETECTOR
    generic map (WIDTH)
    port map (s_OUT, s_Z);
    
  LOGICALS: LOGIC
    generic map (WIDTH)
    port map (A, B, s_LOGIC(0), s_LOGIC(1), s_LOGIC(2), s_LOGIC(3), s_LOG);
    
  COMP: COMPARATOR
    port map (s_Z, s_C, s_LE, s_LT, s_GE, s_GT, s_EQ, s_NE);
  
  SHIFT: SHIFTER
    generic map (WIDTH)
    port map (A, B, s_SHIFT, s_SHI);
      
  MULT: MULTIPLIER
    generic map(WIDTH/2)
    port map (A(15 downto 0), B(15 downto 0), s_MULT);
  
end architecture;
