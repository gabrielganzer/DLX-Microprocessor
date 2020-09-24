----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: ADDER_SUBTRACTOR
-- Function: P4 adder circuit
-- Input: A, B (N-bit), Ci_array (1-bit)
-- Output: Co (1-bit)
-- Architecture: structural
-- Library/package: ieee.std_logic_ll64, work.CONSTANTS
-- Date: 14/04/2020
----------------------------------------------------------------------------------
library IEEE;
library work;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.globals.all;

entity TB_MULT is
end entity;

architecture TB_WALLACE_TREE of TB_MULT is
  -- Components
  component WALLACE_TREE
    generic (WIDTH: integer := word_size);
    port (A   : in std_logic_vector((WIDTH/2)-1 downto 0);
          B   : in std_logic_vector((WIDTH/2)-1 downto 0);
          S   : out std_logic_vector(WIDTH-1 downto 0);
          Co  : out std_logic_vector(WIDTH-1 downto 0)
    );
  end component;
  component ADDER_SUBTRACTOR
      generic (
        WIDTH: integer:= word_size;
        RADIX: integer:= radix_size
      );
      port (A:    in	std_logic_vector(WIDTH-1 downto 0);
            B:    in	std_logic_vector(WIDTH-1 downto 0);
            Ci:   in	std_logic;
            S:    out	std_logic_vector(WIDTH-1 downto 0);
            Co:   out std_logic);
  end component;
  -- Signals
  signal wA, wB       : std_logic_vector((word_size/2)-1 downto 0) := (others => '0');
  signal wSUM, wCARRY : std_logic_vector(word_size-1 downto 0);
  signal wPRODUCT     : std_logic_vector(word_size-1 downto 0);
begin
  
  
  STIMULI: process
  begin
    wait for 1 ns;
    -- Unsigned
    uROW: for i in 0 to (word_size/2)-1 loop
      wA <= std_logic_vector(to_unsigned(i+1, wA'length));
      uCOL: for j in 0 to (word_size/2)-1 loop
        wB <= std_logic_vector(to_unsigned(j+1, wB'length));
        wait for 1 ns;
      end loop;
    end loop;
    -- Signed
    sROW: for i in 1 to (word_size/2)-1 loop
      wA <= std_logic_vector(to_signed(-i, wA'length));
      sCOL: for j in 0 to (word_size/2)-1 loop
        wB <= std_logic_vector(to_signed(j+1, wB'length));
        wait for 1 ns;
      end loop;
    end loop;
    -- Overflow
    wA <= (others => '1');
    wB <= (others => '1');
    wait;
  end process;
  
  UUT: WALLACE_TREE
      generic map (word_size)
      port map (wA, wB, wSUM, wCARRY);

  CLA: ADDER_SUBTRACTOR
      generic map (word_size, radix_size)
      port map(wSUM, wCARRY, '0', wPRODUCT, open);
   
end architecture;

architecture TB_BOOTH_MULT of TB_MULT is
  -- Components
  component BOOTH_MULTIPLIER
    generic (WIDTH: integer := word_size);
    port (A   : in std_logic_vector((WIDTH/2)-1 downto 0);
          B   : in std_logic_vector((WIDTH/2)-1 downto 0);
          P   : out std_logic_vector(WIDTH-1 downto 0)
    );
  end component;
  -- Signals
  signal wA, wB       : std_logic_vector((word_size/2)-1 downto 0) := (others => '0');
  signal wPRODUCT     : std_logic_vector(word_size-1 downto 0);
begin
  
  
  STIMULI: process
  begin
    wait for 1 ns;
    -- Unsigned
    uROW: for i in 0 to (word_size/2)-1 loop
      wA <= std_logic_vector(to_unsigned(i+1, wA'length));
      uCOL: for j in 0 to (word_size/2)-1 loop
        wB <= std_logic_vector(to_unsigned(j+1, wB'length));
        wait for 1 ns;
      end loop;
    end loop;
    -- Signed
    sROW: for i in 1 to (word_size/2)-1 loop
      wA <= std_logic_vector(to_signed(-i, wA'length));
      sCOL: for j in 0 to (word_size/2)-1 loop
        wB <= std_logic_vector(to_signed(j+1, wB'length));
        wait for 1 ns;
      end loop;
    end loop;
    -- Overflow
    wA <= (others => '1');
    wB <= (others => '1');
    wait;
  end process;
  
  UUT: BOOTH_MULTIPLIER
      generic map (word_size)
      port map (wA, wB, wPRODUCT);
   
end architecture;