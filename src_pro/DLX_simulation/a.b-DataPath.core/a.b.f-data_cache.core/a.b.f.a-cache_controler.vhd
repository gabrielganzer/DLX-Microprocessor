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
use IEEE.numeric_std.all;
use work.globals.all;

entity DCACHE_CONTROLLER is
  generic (WIDTH  : integer := word_size;
           LENGTH : integer := line_size+word_offset);
	port (CLK          : in std_logic;
	      RST          : in std_logic;                                     -- Synchronous, active-low
	      WE           : in std_logic;                                     -- Write enable, read otherwise
	      FWD          : in std_logic;                                     -- Forwarding signal enable
	      ADDR         : in std_logic_vector(WIDTH-1 downto 0);            -- Address from ALU
	      CACHE_WE     : out std_logic;                                    -- Cache write enable, read otherwise
	      CACHE_SRC    : out std_logic_vector(2 downto 0);                 -- Cache data source select
	      CACHE_ADDR   : out std_logic_vector(LENGTH-1 downto 0);          -- LINE & WORD fields
	      SDRAM_WE     : out std_logic;                                    -- Cache write enable, read otherwise
	      SDRAM_SRC    : out std_logic;                                    -- Data memory address source select
	      SDRAM_ADDR   : out std_logic_vector(tag_size+LENGTH-1 downto 0); -- TAG&LINE&WORD fields
	      STALL        : out std_logic                                     -- Pipeline stall
	);
end entity;

architecture BEHAVIORAL of DCACHE_CONTROLLER is
   type stateTYPE is (IDLE, WR_CACHE, RD_CACHE, WR0, WR1, WR2, WR3, RD0, RD1, RD2, RD3);
   type tag_array is array ((2**line_size)-1 downto 0) of std_logic_vector(tag_size+1 downto 0);
   signal CAM       : tag_array;
   signal currST    : stateTYPE;
   signal nextST    : stateTYPE;
   signal TAG       : std_logic_vector(tag_size-1 downto 0);
   signal LINE      : std_logic_vector(line_size-1 downto 0);
   signal WORD      : std_logic_vector(word_offset-1 downto 0);
   signal BLOCK_SEL : std_logic_vector(word_offset-1 downto 0);
   signal HIT       : std_logic;
   signal DIRTY     : std_logic;
   signal CTRL      : std_logic_vector(1 downto 0);

begin
    
    TAG  <= ADDR(tag_size+line_size+word_offset-1 downto tag_size);
    LINE <= ADDR(tag_size-1 downto word_offset);
    WORD <= ADDR(word_offset-1 downto 0);
    
    HIT   <= '1' when ((CAM(to_integer(unsigned(LINE)))(tag_size-1 downto 0) = TAG) and (CAM(to_integer(unsigned(LINE)))(tag_size) = '1')) else '0';
    DIRTY <= CAM(to_integer(unsigned(LINE)))(tag_size+1);
    
    CACHE_SRC  <= "001" when CTRL = "01" else
                 	"010" when (CTRL = "10" and FWD = '1') else
                  "100";
    CACHE_ADDR <= LINE&BLOCK_SEL when (CTRL = "01" or CTRL = "11") else LINE&WORD;
    
                  
    SDRAM_SRC  <= '1' when CTRL = "11" else '0';
    SDRAM_ADDR <= TAG&LINE&BLOCK_SEL;
    
    CRTL: process(CLK, RST)
    begin
      if (RST = '0') then
         CAM     <= (others => (others => '0'));
         currST      <= IDLE;
      elsif (CLK = '1' and CLK'event) then
        if (CTRL = "01" or CTRL = "11") then
          -- TAG field
          CAM(to_integer(unsigned(LINE)))(tag_size-1 downto 0) <= TAG;
          -- Valid bit
          CAM(to_integer(unsigned(LINE)))(tag_size) <= '1';
          -- Dirty bit
          CAM(to_integer(unsigned(LINE)))(tag_size+1) <= '0';
        end if;
        if (CTRL = "10") then
          -- Dirty bit
          CAM(to_integer(unsigned(LINE)))(tag_size+1) <= '1';
        end if;
        currST     <= nextST;
      end if;
    end process;
    
    FSM: process(currST, WE, HIT, DIRTY)
    begin
        case currST is
            when IDLE =>
   	          CACHE_WE  <= '0';
	            SDRAM_WE  <= '0';
	            BLOCK_SEL <= "00";
              CTRL      <= "00";   
	            STALL     <= '0';
              if (WE = '0' and HIT = '1') then
                  nextST <= RD_CACHE;
              elsif (WE = '1') then
                  nextST <= WR_CACHE;
              elsif (WE = '0' and HIT = '0' and DIRTY = '0') then
                  nextST <= RD0;
              elsif (HIT = '0' and DIRTY = '1') then
                  nextST <= WR0;
              else
                  nextST <= IDLE;
              end if;
            when RD_CACHE =>
   	          CACHE_WE  <= '0';
	            SDRAM_WE  <= '0';
	            BLOCK_SEL <= "00";
              CTRL      <= "00";   
	            STALL     <= '0';
	            nextST    <= IDLE;
            when RD0 =>
   	          CACHE_WE  <= '1';
	            SDRAM_WE  <= '0';
	            BLOCK_SEL <= "00";
	            CTRL      <= "01"; 
	            STALL     <= '1';
	            nextST    <= RD1;
            when RD1 =>
   	          CACHE_WE  <= '1';
	            SDRAM_WE  <= '0';
              BLOCK_SEL <= "01";
              CTRL      <= "01"; 
	            STALL     <= '1';
              nextST    <= RD2;
            when RD2 =>
              CACHE_WE  <= '1';
	            SDRAM_WE  <= '0';
              BLOCK_SEL <= "10";
              CTRL      <= "01"; 
	            STALL     <= '1';
              nextST    <= RD3;
            when RD3 =>
              CACHE_WE  <= '1';
	            SDRAM_WE  <= '0';
              BLOCK_SEL <= "11";
              CTRL      <= "01";
	            STALL     <= '1';
              nextST    <= RD_CACHE;
            when WR_CACHE =>
   	          CACHE_WE  <= '1';
	            SDRAM_WE  <= '0';
	            BLOCK_SEL <= "00";
              CTRL      <= "10";
	            STALL     <= '0';
	            nextST    <= IDLE;
            when WR0 =>  
   	          CACHE_WE  <= '0';
	            SDRAM_WE  <= '1';
	            BLOCK_SEL <= "00";
              CTRL      <= "11";
	            STALL     <= '1';
	            nextST    <= WR1;
            when WR1 =>
   	          CACHE_WE  <= '0';
	            SDRAM_WE  <= '1';
              BLOCK_SEL <= "01";
              CTRL      <= "11";
              STALL     <= '1';
              nextST    <= WR2;
            when WR2 =>
              CACHE_WE  <= '0';
	            SDRAM_WE  <= '1';
              BLOCK_SEL <= "10";
              CTRL      <= "11";
              STALL     <= '1';
              nextST    <= WR3;
            when WR3 =>
              CACHE_WE  <= '0';
	            SDRAM_WE  <= '1';
              BLOCK_SEL <= "11";
              CTRL      <= "11";
              STALL     <= '1';
              if (WE = '1') then
                  nextST <= WR_CACHE;
              else
                  nextST <= RD0;  
              end if;  
            when others =>
              nextST <= IDLE;
        end case;
    end process;

end architecture;