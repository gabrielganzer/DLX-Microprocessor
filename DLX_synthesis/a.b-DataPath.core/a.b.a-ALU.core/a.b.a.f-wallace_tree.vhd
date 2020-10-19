----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: WALLACE_TREE
-- Function: Wallace Tree based multiplier
-- Input: A (N/2-bit), B (N/2-bit)
-- Output: S (N-bit), Co (N-bit)
-- Architecture: structural
-- Library/package: ieee.std_logic_ll64, ieee.numeric_std, work.globals
-- Date: 14/04/2020
----------------------------------------------------------------------------------
library IEEE;
library work;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.globals.all;

entity WALLACE_TREE is
    generic (WIDTH: integer := word_size);
    port (A   : in std_logic_vector((WIDTH/2)-1 downto 0);  -- Operand A
          B   : in std_logic_vector((WIDTH/2)-1 downto 0);  -- Operand B
          S   : out std_logic_vector(WIDTH-1 downto 0);     -- Partial multiplication (Operand A to Adder/Subtractor)
          Co  : out std_logic_vector(WIDTH-1 downto 0)      -- Partial multiplication (Operand B to Adder/Subtractor)
    );
end entity;

architecture STRUCTURAL of WALLACE_TREE is

  -- Components
  component CSA
      generic (WIDTH: integer := radix_size);
      port (A	 :	in	std_logic_vector(WIDTH-1 downto 0);
            B	 :	in	std_logic_vector(WIDTH-1 downto 0);
            Ci	:	in	std_logic_vector(WIDTH-1 downto 0);
            S	 :	out	std_logic_vector(WIDTH-1 downto 0);
            Co	:	out	std_logic_vector(WIDTH-1 downto 0));
  end component;
  
  component SHIFTER_MULT
  	generic(WIDTH: integer:= 4; SHIFT : integer := 1);
  	port (A    :	in std_logic_vector(WIDTH-1 downto 0);
  	      S1   :	out	std_logic_vector(2*WIDTH-1 downto 0);
  	      S2   :	out std_logic_vector(2*WIDTH-1 downto 0);
  	      S3   :	out	std_logic_vector(2*WIDTH-1 downto 0);
  	      S4   :	out	std_logic_vector(2*WIDTH-1 downto 0)
  	);
  end component;
  
  component MUX58_MULT 
  	generic(WIDTH: integer:= 4);
  	port (S0   :	in std_logic_vector(WIDTH-1 downto 0);
  	      S1   :	in	std_logic_vector(WIDTH-1 downto 0);
  	      S2   :	in std_logic_vector(WIDTH-1 downto 0);
  	      S3   :	in	std_logic_vector(WIDTH-1 downto 0);
  	      S4   :	in	std_logic_vector(WIDTH-1 downto 0);
  	      SEL  :	in	std_logic_vector(2 downto 0);
  	      Y    :	out	std_logic_vector(WIDTH-1 downto 0));
  end component; 
  
  -- Types
  type booth_array is array ((WIDTH/2)-1 downto 0) of std_logic_vector(WIDTH-1 downto 0);
  type csa_array is array (4 downto 0) of std_logic_vector(WIDTH-1 downto 0);
  
  -- Signals
  signal partial  : booth_array;
  signal S1       :	booth_array;
  signal S2       :	booth_array;
  signal S3       :	booth_array;
  signal S4       :	booth_array;
  signal sum      : csa_array;
  signal carry    : csa_array;
  signal bv       : std_logic_vector(WIDTH/2 downto 0);
  
begin
  
  -- B-1 extension, '0' by convention
  bv <= B&'0';
  
  -- Shifters instantiation
	SHIFTER: for i in 0 to (WIDTH/4)-1 generate
	  SHIFTERi: SHIFTER_MULT
	    generic map (WIDTH/2, 2*i) 
	    port map (A, S1(i), S2(i), S3(i), S4(i));
	end generate;
  
  -- Booth Multiplexers instantiation
	MUX: for i in 0 to (WIDTH/4)-1 generate
	  MUXi: MUX58_MULT 
	    generic map (WIDTH) 
	    port map((others=> '0'), S1(i), S2(i), S3(i), S4(i), bv(2*i+2 downto 2*i), partial(i));
	end generate;
  
  -- Wallace tree network (CSA instantiation)
	CSA0: CSA 
	  generic map (WIDTH) 
    port map (partial(0), partial(1), partial(2), sum(0), carry(0));
	CSA1: CSA 
	  generic map (WIDTH) 
	  port map (partial(3), partial(4), partial(5), sum(1), carry(1));

	CSA2: CSA 
	  generic map (WIDTH) 
	  port map (sum(0), carry(0), sum(1), sum(2), carry(2));
	CSA3: CSA 
	  generic map (WIDTH) 
	  port map (carry(1), partial(6), partial(7), sum(3), carry(3));

	CSA4: CSA 
	  generic map (WIDTH) 
	  port map (sum(2), carry(2), sum(3), sum(4), carry(4));

	CSA5: CSA 
	  generic map (32) 
	  port map (sum(4), carry(4), carry(3), S, Co);


end architecture;
