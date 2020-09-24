----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: BOOTH_ENCODER
-- Function: Shift B, Encode + MUX circuit
-- Input: A (N-bit), b (3-bit)
-- Output: vp (N-bit)
-- Architecture: behavioral
-- Library/package: ieee.std_logic_ll64
-- Date: 14/04/2020
----------------------------------------------------------------------------------
library IEEE;
library work;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.globals.all;

entity BOOTH_MULTIPLIER is
    generic (WIDTH: integer := word_size);
    port (A   : in std_logic_vector((WIDTH/2)-1 downto 0);
          B   : in std_logic_vector((WIDTH/2)-1 downto 0);
          P   : out std_logic_vector(WIDTH-1 downto 0)
    );
end entity;

architecture STRUCTURAL of BOOTH_MULTIPLIER is

  component RCA
      generic (WIDTH: integer := radix_size);
      port (A	:	in	std_logic_vector(WIDTH-1 downto 0);
            B	:	in	std_logic_vector(WIDTH-1 downto 0);
            Ci	:	in	std_logic;
            S	:	out	std_logic_vector(WIDTH-1 downto 0);
            Co	:	out	std_logic);
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
  
  type booth_array is array ((WIDTH/2)-1 downto 0) of std_logic_vector(WIDTH-1 downto 0);
  type rca_array is array (6 downto 0) of std_logic_vector(WIDTH-1 downto 0);
  signal partial  : booth_array;
  signal S1       :	booth_array;
  signal S2       :	booth_array;
  signal S3       :	booth_array;
  signal S4       :	booth_array;
  signal sum      : rca_array;
  signal bv       : std_logic_vector(WIDTH/2 downto 0);
  
begin
  
  bv <= B&'0';

	SHIFTER: for i in 0 to (WIDTH/4)-1 generate
	  SHIFTERi: SHIFTER_MULT
	    generic map (WIDTH/2, 2*i) 
	    port map (A, S1(i), S2(i), S3(i), S4(i));
	end generate;
  
	MUX: for i in 0 to (WIDTH/4)-1 generate
	  MUXi: MUX58_MULT 
	    generic map (WIDTH) 
	    port map((others=> '0'), S1(i), S2(i), S3(i), S4(i), bv(2*i+2 downto 2*i), partial(i));
	end generate;

	RCA0: RCA 
	  generic map (WIDTH) 
    port map (partial(0), partial(1), '0', sum(0), open);      
  
  RCA_GEN: for i in 1 to (WIDTH/4)-2 generate
	  RCAi: RCA 
	    generic map (WIDTH) 
      port map (partial(i+1), sum(i-1), '0', sum(i), open);
  end generate;
  
 	RCA7: RCA 
	  generic map (WIDTH) 
    port map (partial(7), sum(6), '0', P, open);

end architecture;
