----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: SPARSE_TREE
-- Function: PG Network structure
-- Input: A, B (N-bit), Ci_array (1-bit)
-- Output: Co (1-bit)
-- Architecture: structural
-- Library/package: ieee.std_logic_ll6RADIX, 
--		    work.CONSTANTS
--		    work.FUNCTIONS
-- Date: 1RADIX/0RADIX/2020
----------------------------------------------------------------------------------
library ieee;
library work; 
use ieee.std_logic_1164.all;
use work.globals.all;

entity SPARSE_TREE is
  generic (
    WIDTH: integer:= word_size;
    RADIX: integer:= radix_size
  );
	port(A:   in std_logic_vector(WIDTH-1 downto 0);
		   B:   in std_logic_vector(WIDTH-1 downto 0);
		   Ci:  in std_logic;
	     Co:  out std_logic_vector((WIDTH/RADIX) downto 0));		  
end entity;

architecture STRUCTURAL of SPARSE_TREE is
  -- Components
  -- PG Network
  component PG_NETWORK is
      generic (WIDTH: integer:= word_size);
      port (A:  in std_logic_vector(WIDTH-1 downto 0);
            B:  in std_logic_vector(WIDTH-1 downto 0);
            Ci: in std_logic;
            P:  out std_logic_vector(WIDTH-1 downto 0);
            G:  out std_logic_vector(WIDTH-1 downto 0));
  end component;
  -- G general generate block
	component BLOCKG
		port (pik   : in std_logic;
			    gik 		: in std_logic;
			    pik_1 : in std_logic;
			    gik_1 : in std_logic;
			    gij   : out std_logic);
	end component;
	-- PG general propagate block
	component BLOCKPG
		port (pik  	 : in std_logic;
			    gik  	 : in std_logic;
			    pik_1  : in std_logic;
			    gik_1  : in std_logic;
			    pij    : out std_logic;
			    gij  	 : out std_logic);
	end component;
  -- Constants
  --NROW defines the number of stages in the PG network
	constant NROW : integer := log2(WIDTH);
	-- Types		
	type t_array is array (NROW downto 0) of std_logic_vector(WIDTH-1 downto 0);
	-- Signals 
	signal s_P, s_G: t_array := (others=>(others=>'0'));
begin
	
	-- Create the initial PG network
	PGNET: PG_NETWORK
	   generic map (WIDTH)
		 port map (A, B, Ci, s_P(NROW), s_G(NROW));
	
  	-- First two rows that are always the same for every number of bits
	ROW_GEN : for row in NROW downto NROW-1 generate
		COL_GEN : for col in 0 to (2**(row-1))-1 generate			
				PGij: BLOCKPG port map(s_P(row)(col*2+1), s_G(row)(col*2+1), s_P(row)(col*2), s_G(row)(col*2), s_P(row-1)(col), s_G(row-1)(col));
		end generate COL_GEN ;
	end generate ROW_GEN;
	
	-- Other rows
	ROW_GENi : for row in NROW-2 downto 1 generate
		COL_GENi : for col in 0 to 2**(row-1)-1 generate
			
			-- Generate a connection
				CONNECT : for i in 0 to (WIDTH)/(2**(2+row))-1 generate
					s_G(row-1)(col*2**(NROW-1-row)+i) <= s_G(row)(col*2**(NROW-1-row)+i);
					s_P(row-1)(col*2**(NROW-1-row)+i) <= s_P(row)(col*2**(NROW-1-row)+i);
				end generate CONNECT;
			
			-- Generate a BLOCKPG or a g_block if it it the first column
				PG_G : for i in 0 to (WIDTH)/(2**(2+row))-1 generate
					COL0 : if col>0 generate
						PG_GEN : BLOCKPG port map(s_P(row)(col*2**(NROW-1-row)+2**(NROW-2-row)+i),
																			  s_G(row)(col*2**(NROW-1-row)+2**(NROW-2-row)+i),
																			  s_P(row)(col*2**(NROW-1-row)+2**(NROW-2-row)-1),
											 								  s_G(row)(col*2**(NROW-1-row)+2**(NROW-2-row)-1),
																			  s_P(row-1)(col*2**(NROW-1-row)+2**(NROW-2-row)+i),
																			  s_G(row-1)(col*2**(NROW-1-row)+2**(NROW-2-row)+i));
					end generate COL0;
					COLi : if col=0 generate
						G_GEN : BLOCKG port map(s_P(row)(col*2**(NROW-1-row)+2**(NROW-2-row)+i),
											  						  s_G(row)(col*2**(NROW-1-row)+2**(NROW-2-row)+i),
											  						  s_P(row)(col*2**(NROW-1-row)+2**(NROW-2-row)-1),
											  						  s_G(row)(col*2**(NROW-1-row)+2**(NROW-2-row)-1),
											  						  s_G(row-1)(col*2**(NROW-1-row)+2**(NROW-2-row)+i));
					end generate COLi;
				end generate PG_G;
			
		end generate COL_GENi;
	end generate ROW_GENi;
	
	-- Vector containing the generated carries with the Ci
	Co <= s_G(0)((WIDTH/RADIX)-1 downto 0) & Ci;

end architecture;