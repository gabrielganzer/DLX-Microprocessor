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
  generic (WIDTH       : integer := word_size;
           CACHE_LENGTH: integer := index_size+word_cache_size;
           SDRAM_LENGTH: integer := tag_size+index_size+word_cache_size+block_size);
	port (CLK          : in std_logic;
	      RST          : in std_logic;                                  -- Synchronous, active-low
	      EN           : in std_logic;                                  -- Active-high
	      WE           : in std_logic;                                  -- Write enable, read otherwise
	      FWD          : in std_logic;                                  -- Forwarding signal enable
	      ADDR         : in std_logic_vector(WIDTH-1 downto 0);         -- Address from ALU
	      CACHE_WE     : out std_logic;                                 -- Cache write enable, read otherwise
	      CACHE_SRC    : out std_logic_vector(2 downto 0);              -- Cache data source select
	      CACHE_ADDR   : out std_logic_vector(CACHE_LENGTH-1 downto 0); -- INDEX & WORD fields
	      SDRAM_WE     : out std_logic;                                 -- Cache write enable, read otherwise
	      SDRAM_SRC    : out std_logic;                                 -- Data memory address source select
	      SDRAM_ADDR   : out std_logic_vector(SDRAM_LENGTH downto 0);   -- TAG & INDEX & BLOCK & 0's
	      STALL        : out std_logic                                  -- Pipeline stall
	);
end entity;

architecture BEHAVIORAL of DCACHE_CONTROLLER is
   type stateTYPE is (IDLE, WR_CACHE, RD_CACHE, WR0, WR1, WR2, WR3, RD0, RD1, RD2, RD3);
   type tag_array is array (3 downto 0) of std_logic_vector(6 downto 0);
   signal cacheTAG   : tag_array := (others => (others => '0'));
   signal currST     : stateTYPE := IDLE;
   signal nextST     : stateTYPE := IDLE;
   signal TAG        : std_logic_vector(tag_size-1 downto 0) := (others => '0');
   signal INDEX      : std_logic_vector(index_size-1 downto 0) := (others => '0');
   signal WORD       : std_logic_vector(word_cache_size-1 downto 0) := (others => '0');
   signal BLOCK_SEL  : std_logic_vector(block_size-1 downto 0) := (others => '0');
   signal HIT        : std_logic := '0';
   signal DIRTY      : std_logic := '0';
   signal CACHE_SRCi : std_logic_vector(2 downto 0) := (others => '0');
	 signal CACHE_ADDRi: std_logic_vector(index_size+word_cache_size-1 downto 0) := (others => '0');
	 signal SDRAM_SRCi  : std_logic := '0';
	 signal SDRAM_ADDRi : std_logic_vector(tag_size+index_size+word_cache_size+block_size-1 downto 0):= (others => '0');
begin
    
    TAG    <= ADDR(tag_size+index_size+word_cache_size+block_size-1 downto tag_size);
    INDEX  <= ADDR(tag_size-1 downto index_size+word_cache_size);
    WORD   <= ADDR(index_size+word_cache_size-1 downto word_cache_size);
    
    HIT    <= '1' when (cacheTAG(to_integer(unsigned(INDEX)))(tag_size-1 downto 0) = TAG) else '0';
    DIRTY  <= cacheTAG(to_integer(unsigned(INDEX)))(tag_size);
    
    CRTL: process(CLK)
    begin
      if (CLK = '1' and CLK'event) then
        if (RST = '0') then
           CACHE_SRC   <= (others => '0');
	         CACHE_ADDR  <= (others => '0');
	         SDRAM_SRC   <= '0';
	         SDRAM_ADDR  <= (others => '0');
           currST      <= IDLE;
        else
          if (EN = '1') then
            CACHE_SRC  <= CACHE_SRCi;
	          CACHE_ADDR <= CACHE_ADDRi;
	          SDRAM_SRC  <= SDRAM_SRCi;
	          SDRAM_ADDR <= SDRAM_ADDRi;
	          currST     <= nextST;
	        end if;
        end if;
      end if;
    end process;
    
    FSM: process(currST, WE, HIT, DIRTY, TAG, INDEX, WORD)
    begin
        case currST is
            when IDLE =>
   	          CACHE_WE  <= '0';
	            SDRAM_WE  <= '0';
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
   	          CACHE_WE    <= '0';
	            STALL       <= '0';
	            CACHE_ADDRi <= INDEX&WORD;
	            nextST      <= IDLE;
            when RD0 =>
   	          CACHE_WE    <= '1';
	            CACHE_SRCi  <= "001";
	            SDRAM_WE    <= '0';
	            BLOCK_SEL   <= "00";
	            STALL       <= '1';
	            CACHE_ADDRi <= INDEX&BLOCK_SEL;
              cacheTAG(to_integer(unsigned(INDEX)))(tag_size-1 downto 0) <= TAG;
              cacheTAG(to_integer(unsigned(INDEX)))(tag_size) <= '0';
	            nextST      <= RD1;
            when RD1 =>
              BLOCK_SEL  <= "01";
              nextST <= RD2;
            when RD2 =>
              BLOCK_SEL  <= "10";
              nextST <= RD3;
            when RD3 =>
              BLOCK_SEL  <= "11";
              nextST <= RD_CACHE;
            when WR_CACHE =>
   	          CACHE_WE  <= '1';
	          	 if (FWD = '1') then
                CACHE_SRCi <= "010";
              else
                CACHE_SRCi <= "100";
              end if;
	            SDRAM_WE    <= '0';
	            STALL       <= '0';
	            CACHE_ADDRi <= INDEX&WORD;
              cacheTAG(to_integer(unsigned(INDEX)))(tag_size) <= '1';
	            nextST      <= IDLE;
            when WR0 =>  
   	          CACHE_WE    <= '0';
	            SDRAM_WE    <= '1';
	            SDRAM_SRCi  <= '1';
	            BLOCK_SEL   <= "00";
	            STALL       <= '1';
	            SDRAM_ADDRi <= TAG&INDEX&WORD&BLOCK_SEL;
	            CACHE_ADDRi <= INDEX&BLOCK_SEL;
              cacheTAG(to_integer(unsigned(INDEX)))(tag_size-1 downto 0) <= TAG;
              cacheTAG(to_integer(unsigned(INDEX)))(tag_size) <= '0';
	            nextST     <= WR1;
            when WR1 =>
              BLOCK_SEL  <= "01";
              nextST     <= WR2;
            when WR2 =>
              BLOCK_SEL  <= "10";
              nextST     <= WR3;
            when WR3 =>
              BLOCK_SEL  <= "11";
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