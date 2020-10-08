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

entity ICACHE_CONTROLLER is
  generic (WIDTH        : integer := word_size;
           LENGTH       : integer := line_size+word_offset);
	port (CLK          : in std_logic;
	      RST          : in std_logic;                                  -- Synchronous, active-low
	      ADDR         : in std_logic_vector(WIDTH-1 downto 0);         -- PC address
	      CACHE_WE     : out std_logic;                                 -- Cache write enable, read otherwise
	      CACHE_ADDR   : out std_logic_vector(LENGTH-1 downto 0); -- LINE&WORD fields
	      STALL        : out std_logic                                  -- Pipeline stall
	);
end entity;

architecture BEHAVIORAL of ICACHE_CONTROLLER is
   type stateTYPE is (IDLE, RD_CACHE, RD0, RD1, RD2, RD3);
   type tag_array is array ((2**line_size)-1 downto 0) of std_logic_vector(tag_size downto 0);
   signal CAM       : tag_array;
   signal currST    : stateTYPE;
   signal nextST    : stateTYPE;
   signal TAG       : std_logic_vector(tag_size-1 downto 0);
   signal LINE      : std_logic_vector(line_size-1 downto 0);
   signal WORD      : std_logic_vector(word_offset-1 downto 0);
   signal BLOCK_SEL : std_logic_vector(word_offset-1 downto 0);
   signal HIT       : std_logic;
   signal LD        : std_logic;

begin
    
    TAG  <= ADDR(tag_size+line_size+word_offset-1 downto tag_size);
    LINE <= ADDR(tag_size-1 downto word_offset);
    WORD <= ADDR(word_offset-1 downto 0);
    
    HIT <= '1' when ((CAM(to_integer(unsigned(LINE)))(tag_size-1 downto 0) = TAG) and (CAM(to_integer(unsigned(LINE)))(tag_size) = '1')) else '0';
    
    CACHE_ADDR <= LINE&BLOCK_SEL when LD = '1' else LINE&WORD;
    
    
    CRTL: process (CLK, RST)
    begin
      if (RST = '0') then
        CAM     <= (others => (others => '0'));
        currST  <= IDLE;
      elsif (CLK = '1' and CLK'event) then
          if (LD = '1') then
            -- TAG field
            CAM(to_integer(unsigned(LINE)))(tag_size-1 downto 0) <= TAG;
            -- Valid bit
            CAM(to_integer(unsigned(LINE)))(tag_size) <= '1';
          end if;
	      currST  <= nextST;
      end if;
    end process;
    
    FSM: process(currST, HIT)
    begin
        case currST is
            when IDLE =>
   	          CACHE_WE    <= '0';
              STALL       <= '0';
              BLOCK_SEL   <= "00";
              LD          <= '0';              
              if (HIT = '1') then
                nextST      <= RD_CACHE;
              else
                nextST      <= RD0;
              end if;
            when RD_CACHE =>
   	          CACHE_WE    <= '0';
              STALL       <= '0';
              BLOCK_SEL   <= "00";
              LD          <= '0';
	            nextST      <= IDLE;
            when RD0 => 
              CACHE_WE    <= '1';
 	            STALL       <= '1';
	            BLOCK_SEL   <= "00";
	            LD          <= '1';
	            nextST      <= RD1;
            when RD1 =>
              CACHE_WE    <= '1';
 	            STALL       <= '1';
              BLOCK_SEL   <= "01";
              LD          <= '1';
              nextST      <= RD2;
            when RD2 =>
              CACHE_WE    <= '1';
 	            STALL       <= '1';
              BLOCK_SEL   <= "10";
              LD          <= '1';
              nextST      <= RD3;
            when RD3 =>
              CACHE_WE    <= '1';
 	            STALL       <= '1';
              BLOCK_SEL   <= "11";
              LD          <= '1';
              nextST      <= RD_CACHE;
            when others =>
              nextST      <= IDLE;
        end case;
    end process;

end architecture;