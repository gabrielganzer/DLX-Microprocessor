library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.globals.all;

entity TB_ALU is
end TB_ALU;

architecture TESTBENCH of TB_ALU is
  --------------------------------------------------------------------
  -- Components Declaration
  --------------------------------------------------------------------
  component ALU
    generic (WIDTH: integer:= word_size;
             RADIX: integer:= radix_size;
             OPCODE: integer:= op_size);
    port (A  :  in	std_logic_vector(WIDTH-1 downto 0);   -- Operand A
          B  :  in	std_logic_vector(WIDTH-1 downto 0);   -- Operand B
          OP :  in	aluOp;                                -- Opcode
          Y  :  out	std_logic_vector(WIDTH-1 downto 0)); -- Result
  end component;
  
  ----------------------------------------------------------------
  -- Signal Declaration
  ----------------------------------------------------------------
  
	signal s_A	  : std_logic_vector(word_size-1 downto 0);
	signal s_B   : std_logic_vector(word_size-1 downto 0);
	signal s_OP  : aluOp;
	signal s_Y   : std_logic_vector(word_size-1 downto 0);

begin
  
  ----------------------------------------------------------------
  -- Unit Under Test (UUT)
  ----------------------------------------------------------------
  UUT: ALU
    generic map (word_size, radix_size, op_size)
    port map (s_A, s_B, s_OP, s_Y);
	
  -- Stimuli process
  STIMULI: process
  begin
    s_A  <= (others => '0');
    s_B  <= (others => '0');
    s_OP <= nopOp;
    wait for 1 ns;
    s_A  <= std_logic_vector(to_signed(2, s_A'length));
    s_B  <= std_logic_vector(to_signed(1, s_A'length));
    s_OP <= nopOp;
    wait for 1 ns;
    s_A  <= std_logic_vector(to_signed(2, s_A'length));
    s_B  <= std_logic_vector(to_signed(1, s_A'length));
    s_OP <= addOp;
    wait for 1 ns;
    s_A  <= std_logic_vector(to_signed(1, s_A'length));
    s_B  <= std_logic_vector(to_signed(2, s_A'length));
    s_OP <= subOp;
    wait for 1 ns;
    s_A  <= std_logic_vector(to_signed(2, s_A'length));
    s_B  <= std_logic_vector(to_signed(1, s_A'length));
    s_OP <= subOp;
    wait for 1 ns;
    s_A  <= std_logic_vector(to_signed(3, s_A'length));
    s_B  <= std_logic_vector(to_signed(3, s_A'length));
    s_OP <= subOp;
    wait for 1 ns;
    s_A  <= std_logic_vector(to_signed(-2, s_A'length));
    s_B  <= std_logic_vector(to_signed(2, s_A'length));
    s_OP <= subOp;
    wait for 1 ns;
    s_A  <= std_logic_vector(to_signed(-3, s_A'length));
    s_B  <= std_logic_vector(to_signed(-4, s_A'length));
    s_OP <= subOp;
    wait for 1 ns;
    s_A  <= std_logic_vector(to_signed(2, s_A'length));
    s_B  <= std_logic_vector(to_signed(-3, s_A'length));
    s_OP <= subOp;
    wait for 1 ns;
    s_A  <= std_logic_vector(to_signed(1, s_A'length));
    s_B  <= std_logic_vector(to_signed(5, s_A'length));
    s_OP <= andOp;
    wait for 1 ns;
    s_A  <= std_logic_vector(to_signed(1, s_A'length));
    s_B  <= std_logic_vector(to_signed(5, s_A'length));
    s_OP <= orOp;
    wait for 1 ns;
    s_A  <= std_logic_vector(to_signed(4, s_A'length));
    s_B  <= std_logic_vector(to_signed(4, s_A'length));
    s_OP <= xorOp;
    wait for 1 ns;
    s_A  <= std_logic_vector(to_signed(1, s_A'length));
    s_B  <= std_logic_vector(to_signed(4, s_A'length));
    s_OP <= xorOp;
    wait for 1 ns;
    s_A  <= std_logic_vector(to_signed(8, s_A'length));
    s_B  <= std_logic_vector(to_signed(2, s_A'length));
    s_OP <= sllOp;
    wait for 1 ns;
    s_A  <= std_logic_vector(to_signed(4, s_A'length));
    s_B  <= std_logic_vector(to_signed(1, s_A'length));
    s_OP <= srlOp;
    wait for 1 ns;
    s_A  <= std_logic_vector(to_signed(8, s_A'length));
    s_B  <= std_logic_vector(to_signed(2, s_A'length));
    s_OP <= sraOp;
    wait for 1 ns;
    s_A  <= std_logic_vector(to_signed(4, s_A'length));
    s_B  <= std_logic_vector(to_signed(1, s_A'length));
    s_OP <= gtOp;
    wait for 1 ns;
    s_A  <= std_logic_vector(to_signed(2, s_A'length));
    s_B  <= std_logic_vector(to_signed(2, s_A'length));
    s_OP <= gtOp;
    wait for 1 ns;
    s_A  <= std_logic_vector(to_signed(1, s_A'length));
    s_B  <= std_logic_vector(to_signed(4, s_A'length));
    s_OP <= gtOp;
    wait for 1 ns;
    s_A  <= std_logic_vector(to_signed(4, s_A'length));
    s_B  <= std_logic_vector(to_signed(1, s_A'length));
    s_OP <= geOp;
    wait for 1 ns;
    s_A  <= std_logic_vector(to_signed(2, s_A'length));
    s_B  <= std_logic_vector(to_signed(2, s_A'length));
    s_OP <= geOp;
    wait for 1 ns;
    s_A  <= std_logic_vector(to_signed(1, s_A'length));
    s_B  <= std_logic_vector(to_signed(5, s_A'length));
    s_OP <= geOp;
    wait for 1 ns;
    s_A  <= std_logic_vector(to_signed(2, s_A'length));
    s_B  <= std_logic_vector(to_signed(6, s_A'length));
    s_OP <= ltOp;
    wait for 1 ns;
    s_A  <= std_logic_vector(to_signed(3, s_A'length));
    s_B  <= std_logic_vector(to_signed(3, s_A'length));
    s_OP <= ltOp;
    wait for 1 ns;
    s_A  <= std_logic_vector(to_signed(6, s_A'length));
    s_B  <= std_logic_vector(to_signed(2, s_A'length));
    s_OP <= ltOp;
    wait for 1 ns;
    s_A  <= std_logic_vector(to_signed(3, s_A'length));
    s_B  <= std_logic_vector(to_signed(3, s_A'length));
    s_OP <= leOp;
    wait for 1 ns;
    s_A  <= std_logic_vector(to_signed(4, s_A'length));
    s_B  <= std_logic_vector(to_signed(2, s_A'length));
    s_OP <= leOp;
    wait for 1 ns;
    s_A  <= std_logic_vector(to_signed(2, s_A'length));
    s_B  <= std_logic_vector(to_signed(4, s_A'length));
    s_OP <= leOp;
    wait for 1 ns;
    s_A  <= std_logic_vector(to_signed(8, s_A'length));
    s_B  <= std_logic_vector(to_signed(8, s_A'length));
    s_OP <= eqOp;
    wait for 1 ns;
    s_A  <= std_logic_vector(to_signed(2, s_A'length));
    s_B  <= std_logic_vector(to_signed(3, s_A'length));
    s_OP <= eqOp;
    wait for 1 ns;
    s_A  <= std_logic_vector(to_signed(8, s_A'length));
    s_B  <= std_logic_vector(to_signed(8, s_A'length));
    s_OP <= neOp;
    wait for 1 ns;
    s_A  <= std_logic_vector(to_signed(2, s_A'length));
    s_B  <= std_logic_vector(to_signed(3, s_A'length));
    s_OP <= neOp;
    wait for 1 ns;
    s_A  <= std_logic_vector(to_signed(2, s_A'length));
    s_B  <= std_logic_vector(to_signed(2, s_A'length));
    s_OP <= multOp;
    wait for 1 ns;
    s_A  <= std_logic_vector(to_signed(-2, s_A'length));
    s_B  <= std_logic_vector(to_signed(2, s_A'length));
    s_OP <= multOp;
    wait for 1 ns;
    s_A  <= std_logic_vector(to_signed(-3, s_A'length));
    s_B  <= std_logic_vector(to_signed(-4, s_A'length));
    s_OP <= multOp;
    wait for 1 ns;
    s_A  <= std_logic_vector(to_signed(0, s_A'length));
    s_B  <= std_logic_vector(to_signed(1, s_A'length));
    s_OP <= lhiOp;
    wait for 1 ns;
    s_A  <= std_logic_vector(to_unsigned(4, s_A'length));
    s_B  <= std_logic_vector(to_unsigned(1, s_A'length));
    s_OP <= gtUOp;
    wait for 1 ns;
    s_A  <= std_logic_vector(to_unsigned(2, s_A'length));
    s_B  <= std_logic_vector(to_unsigned(2, s_A'length));
    s_OP <= gtUOp;
    wait for 1 ns;
    s_A  <= std_logic_vector(to_unsigned(1, s_A'length));
    s_B  <= std_logic_vector(to_unsigned(4, s_A'length));
    s_OP <= gtUOp;
    wait for 1 ns;
    s_A  <= std_logic_vector(to_unsigned(4, s_A'length));
    s_B  <= std_logic_vector(to_unsigned(1, s_A'length));
    s_OP <= geUOp;
    wait for 1 ns;
    s_A  <= std_logic_vector(to_unsigned(2, s_A'length));
    s_B  <= std_logic_vector(to_unsigned(2, s_A'length));
    s_OP <= geUOp;
    wait for 1 ns;
    s_A  <= std_logic_vector(to_unsigned(1, s_A'length));
    s_B  <= std_logic_vector(to_unsigned(5, s_A'length));
    s_OP <= geUOp;
    wait for 1 ns;
    s_A  <= std_logic_vector(to_unsigned(2, s_A'length));
    s_B  <= std_logic_vector(to_unsigned(6, s_A'length));
    s_OP <= ltUOp;
    wait for 1 ns;
    s_A  <= std_logic_vector(to_unsigned(3, s_A'length));
    s_B  <= std_logic_vector(to_unsigned(3, s_A'length));
    s_OP <= ltUOp;
    wait for 1 ns;
    s_A  <= std_logic_vector(to_unsigned(6, s_A'length));
    s_B  <= std_logic_vector(to_unsigned(2, s_A'length));
    s_OP <= ltUOp;
    wait for 1 ns;
    s_A  <= std_logic_vector(to_unsigned(3, s_A'length));
    s_B  <= std_logic_vector(to_unsigned(3, s_A'length));
    s_OP <= leUOp;
    wait for 1 ns;
    s_A  <= std_logic_vector(to_unsigned(4, s_A'length));
    s_B  <= std_logic_vector(to_unsigned(2, s_A'length));
    s_OP <= leUOp;
    wait for 1 ns;
    s_A  <= std_logic_vector(to_unsigned(2, s_A'length));
    s_B  <= std_logic_vector(to_unsigned(4, s_A'length));
    s_OP <= leUOp;
    wait for 1 ns;
    wait;
  end process;

end architecture;
