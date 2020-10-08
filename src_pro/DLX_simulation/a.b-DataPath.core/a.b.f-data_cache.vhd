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

entity DATA_CACHE is
  generic (WIDTH  : integer := word_size;
           LENGTH : integer := dram_addr_size);
	port (CLK          : in std_logic;
 	      RST          : in std_logic;                                  -- Synchronous, active-low
 	      EN           : in std_logic;                                  -- Active-high
 	      WE           : in std_logic;                                  -- Write enable, read otherwise
 	      FWD          : in std_logic;                                  -- Forwarding signal enable
 	      ADDR         : in std_logic_vector(WIDTH-1 downto 0);         -- Address from ALU
 	      SDRAM_WE     : out std_logic;                                 -- Cache write enable, read otherwise
 	      SDRAM_SRC    : out std_logic;                                 -- Data memory address source select
 	      SDRAM_ADDR   : out std_logic_vector(LENGTH-1 downto 0);       -- TAG & INDEX & 0's
 	      CACHE_DIN    : in std_logic_vector(WIDTH-1 downto 0);
 	      CACHE_DOUT   : out std_logic_vector(WIDTH-1 downto 0);
 	      CACHE_SRC    : out std_logic_vector(2 downto 0);              -- Cache data source select
 	      STALL        : out std_logic                                  -- Pipeline stall 	        
	);
end entity;

architecture STRUCTURAL of DATA_CACHE is
  
  -- Components
  component DCACHE_CONTROLLER
    generic(WIDTH  : integer := word_size;
            LENGTH : integer := line_size+word_offset);
    port(CLK          : in std_logic;
  	      RST          : in std_logic;                                                                   
  	      WE           : in std_logic;                                  
  	      FWD          : in std_logic;                                                                      
  	      ADDR         : in std_logic_vector(WIDTH-1 downto 0);         
  	      CACHE_WE     : out std_logic;                                 
  	      CACHE_SRC    : out std_logic_vector(2 downto 0);              
  	      CACHE_ADDR   : out std_logic_vector(LENGTH-1 downto 0); 
  	      SDRAM_WE     : out std_logic;                                 
  	      SDRAM_SRC    : out std_logic;                                 
  	      SDRAM_ADDR   : out std_logic_vector(tag_size+LENGTH-1 downto 0);                                  
  	      STALL        : out std_logic);
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

  DCACHE_CTRL: DCACHE_CONTROLLER
    generic map (word_size, line_size+word_offset)
  	 port map(CLK, RST, WE, FWD, ADDR, CACHE_WE, CACHE_SRC, CACHE_ADDR, 
	           SDRAM_WE, SDRAM_SRC, SDRAM_ADDR, STALL);
	           
	DCACHE_MEM: CACHE_MEMORY
     generic map (word_size, line_size+word_offset)
    	port map (CLK, RST, EN, CACHE_WE, CACHE_ADDR, CACHE_DIN, CACHE_DOUT);

end architecture;