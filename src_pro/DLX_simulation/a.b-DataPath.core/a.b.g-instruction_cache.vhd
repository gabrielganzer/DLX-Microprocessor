----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: MUX21_GENERIC
-- Function: multiplexer 2x1 
-- Input: A, B (N-bit), SEL (1-bit)
-- Output: Y (N-bit)
-- Architecture: behavioral
-- Library/package: ieee.std_logic_ll64
-- Date: 14/04/2020
----------------------------------------------------------------------------------
library IEEE;
library work;
use IEEE.std_logic_1164.all;
use work.globals.all;

entity INSTRUCTION_CACHE is
  generic (WIDTH        : integer := word_size);
	port (CLK          : in std_logic;
	      RST          : in std_logic;                                  -- Synchronous, active-low
	      EN           : in std_logic;                                  -- Active-high
	      ADDR         : in std_logic_vector(WIDTH-1 downto 0);         -- PC address
        DIN          : in std_logic_vector(WIDTH-1 downto 0);         -- Instruction from ROM
        WORD         : out std_logic_vector(1 downto 0);              -- Word select
        DOUT         : out std_logic_vector(WIDTH-1 downto 0);        -- Instruction to IR
	      STALL        : out std_logic                                  -- Pipeline stall
	);
end entity;

architecture STRUCTURAL of INSTRUCTION_CACHE is
  
  component ICACHE_CONTROLLER is
    generic (WIDTH        : integer := word_size;
             LENGTH       : integer := line_size+word_offset);
	  port (CLK          : in std_logic;
   	      RST          : in std_logic;                                  -- Synchronous, active-low
   	      ADDR         : in std_logic_vector(WIDTH-1 downto 0);         -- PC address
   	      CACHE_WE     : out std_logic;                                 -- Cache write enable, read otherwise
   	      CACHE_ADDR   : out std_logic_vector(LENGTH-1 downto 0); -- LINE&WORD fields
   	      STALL        : out std_logic                                  -- Pipeline stall
	   );
  end component;
  
  component CACHE_MEMORY is
     generic (WIDTH  : integer := word_size;
              LENGTH : integer := line_size+word_offset);
    	port (CLK      : in std_logic;
    	      RST      : in std_logic;
    	      EN       : in std_logic;
    	      WE       : in std_logic;
    	      ADDR     : in std_logic_vector(LENGTH-1 downto 0);
    	      DIN      : in std_logic_vector(WIDTH-1 downto 0);
    	      DOUT     : out std_logic_vector(WIDTH-1 downto 0)
    	);
  end component;

   -- Signals
   signal CACHE_WE   : std_logic; 
   signal CACHE_ADDR : std_logic_vector(line_size+word_offset-1 downto 0);
   
begin
  
  WORD  <= CACHE_ADDR(word_offset-1 downto 0);
  
  ICACHE_CTRL: ICACHE_CONTROLLER
    generic map (word_size, line_size+word_offset)
  	 port map (CLK, RST, ADDR, CACHE_WE, CACHE_ADDR, STALL);
	           
	ICACHE_MEM: CACHE_MEMORY
     generic map (word_size, line_size+word_offset)
    	port map (CLK, RST, EN, CACHE_WE, CACHE_ADDR, DIN, DOUT);

end architecture;