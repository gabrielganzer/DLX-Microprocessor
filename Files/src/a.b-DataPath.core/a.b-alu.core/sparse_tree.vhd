----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: SPARSETREE
-- Function: PG Network structure
-- Input: A, B (N-bit), Ci_array (1-bit)
-- Output: Co (1-bit)
-- Architecture: structural
-- Library/package: ieee.std_logic_ll64, 
--		    work.CONSTANTS
--		    work.FUNCTIONS
-- Date: 14/04/2020
----------------------------------------------------------------------------------
library IEEE; 
use IEEE.std_logic_1164.all;
use work.CONSTANTS.all;
use work.FUNCTIONS.all;

entity SPARSETREE is
  generic (NBIT: integer:= WIDTH;
           RADIX: integer := STEP);
	port(A:   in std_logic_vector(NBIT-1 downto 0);
		   B:   in std_logic_vector(NBIT-1 downto 0);
		   Ci:  in std_logic;
	     Co:  out std_logic_vector((NBIT/RADIX)-1 downto 0));		  
end entity;

architecture STRUCTURAL of SPARSETREE is
    -- Components 
    component PGNET is
        generic (NBIT: integer:= WIDTH);
        port (A:  in std_logic_vector(NBIT-1 downto 0);
              B:  in std_logic_vector(NBIT-1 downto 0);
              Ci: in std_logic;
              P:  out std_logic_vector(NBIT-1 downto 0);
              G:  out std_logic_vector(NBIT-1 downto 0));
    end component;
    component BLOCKG is 
        port (pik:    in std_logic;
            gik:    in std_logic;
            gk_1j:  in std_logic;
            gij:    out std_logic);
    end component;
    component BLOCKPG is  
    port (pik:    in std_logic;
          gik:    in std_logic;
          gk_1j:  in std_logic;
          pk_1j:  in std_logic;
          gij:    out std_logic;
          pij:    out std_logic);
    end component;
  -- Constants
  --NROW defines the number of stages in the PG network
	constant NROW : integer := log2(NBIT);
	-- Types		
	type t_array is array (NROW downto 0) of std_logic_vector(NBIT-1 downto 0);
	-- Signals 
	signal s_P, s_G: t_array := (others=>(others=>'0'));
begin
	-- Create the initial PG network
	PGNETWORK: PGNET
	   generic map (NBIT)
		 port map (A, B, Ci, s_P(0), s_G(0));
    -- Instantiation of G blocks
    G0: for l in 1 to NROW generate	
        G1: for i in 0 to NBIT-1 generate
            -- starts to generate the first part of PG and G blocks 
            G2: if (l <= log2(STEP)) generate
                -- if here is needded a PG or a G block
                G3: if ((i+1)mod(2**l) = 0) generate
                    -- if it is a G block generates it
                    G4: if (i < 2**l) generate
                        n_G1: BLOCKG	port map (s_P(l-1)(i), s_G(l-1)(i), s_G(l-1)(i - 2**(l-1)), s_G(l)(i));
                    end generate;
                    -- if it is a PG block generates it
                    G5: if (i >= 2**l) generate    
                        m_PG1: BLOCKPG port map (s_P(l-1)(i), s_G(l-1)(i), s_G(l-1)(i - (2**(l-1))), s_P(l-1)(i - (2**(l-1))), s_G(l)(i), s_P(l)(i));
                    end generate;
                end generate;
            end generate;
            -- starts to generate the second part of PG and G blocks 
            G6: if (l > log2(STEP)) generate
                G7: if((i mod (2**l))>=2**(l-1) and (i mod (2**l))<2**l) and (((i+1) mod STEP) =0) generate
                    -- if it is a G block
                    G8: if (i < 2**l) generate
                        n_G2: BLOCKG port map (s_P(l-1)(i), s_G(l-1)(i), s_G(l-1)((i/2**(l-1))*2**(l-1) - 1), s_G(l)(i));
                    end generate;
                    -- if it is a PG block
                    G9: if (i>=2**l) generate
                        m_PG2: BLOCKPG port map (s_P(l-1)(i), s_G(l-1)(i), s_G(l-1)((i/2**(l-1))*2**(l-1)-1), s_P(l-1)((i/2**(l-1))*2**(l-1)-1), s_G(l)(i), s_P(l)(i));
                    end generate;
                end generate;
                -- if the signal has to be brought to the next level, connects the current row with the previous
                G10: if((i mod (2**l))<2**(l-1) and (i mod (2**l))>=0) and (((i+1) mod STEP) =0) generate
                    s_P(l)(i) <= s_P(l-1)(i);
                    s_G(l)(i) <= s_G(l-1)(i);
                end generate;
            end generate;
            -- if it is the last row, connects the G signals to the carries output			
            G11: if (l = NROW) generate
                G12: if ((i+1) mod STEP) = 0 generate
                    Co(i/STEP) <= s_G(l)(i);
                end generate;
            end generate;
        end generate;
    end generate;               
end architecture;	
