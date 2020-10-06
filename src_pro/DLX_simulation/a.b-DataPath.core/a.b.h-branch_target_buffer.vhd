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

entity BTB is
  generic (WIDTH: integer := word_size;
           LENGTH: integer := btb_size);
	port (CLK           : in std_logic;
	      RST           : in std_logic;   -- Synchronous, active-low
	      EN            : in std_logic;
	      OUTCOME       : in std_logic;   -- Outcome of branch prediction (0 -> NT, 1 -> T)
        PC_READ       : in std_logic_vector(WIDTH-1 downto 0);  -- PC to be compared with LUT
        PC_WRITE      : in std_logic_vector(WIDTH-1 downto 0);  -- PC to be compared with LUT
        TARG_IN       : in std_logic_vector(WIDTH-1 downto 0);  -- Target to be written into LUT
        TARG_OUT      : out std_logic_vector(WIDTH-1 downto 0); -- Target read from LUT
        FLUSH         : out std_logic;                          -- Flush pipeline
        PREDICT       : out std_logic                           -- Prediction signal (0 -> NPC, 1 -> TARGET)
  );
end entity;

architecture BEHAVIORAL of BTB is
  
  -- Counter states and signals
  constant STRONG_NT : std_logic_vector(1 downto 0) := "00"; 
  constant WEAK_NT   : std_logic_vector(1 downto 0) := "01"; 
  constant WEAK_T    : std_logic_vector(1 downto 0) := "10"; 
  constant STRONG_T  : std_logic_vector(1 downto 0) := "11";
  signal COUNTER     : std_logic_vector(1 downto 0);
  signal COUNTER1    : std_logic_vector(1 downto 0);
  signal COUNTER2    : std_logic_vector(1 downto 0);
  signal COUNTERnext : std_logic_vector(1 downto 0);
  
  type btb_array is array (0 to (2**LENGTH)-1) of std_logic_vector(btb_field-1 downto 0);
  signal LUT: btb_array;
  
  signal HIT        : std_logic;
  signal HIT1       : std_logic;
  signal HIT2       : std_logic;
  signal PREDICTION : std_logic;
  signal PC_BTB     : std_logic_vector(WIDTH-1 downto 0);
    
begin
  
  PC_BTB  <= LUT(to_integer(unsigned(PC_READ(LENGTH-1 downto 0))))(pc_up downto pc_down);
  COUNTER <= LUT(to_integer(unsigned(PC_READ(LENGTH-1 downto 0))))(counter_up downto counter_down);
  HIT     <= '1' when (PC_BTB = PC_READ) else '0';
  
  TARG_OUT <= LUT(to_integer(unsigned(PC_READ(LENGTH-1 downto 0))))(target_up downto target_down);
  
  PREDICTION <= '0' when (COUNTER = STRONG_NT) else '1';
  PREDICT    <= HIT and PREDICTION;
  
  DATAPATH: process (OUTCOME, HIT2, COUNTERnext, PC_WRITE, TARG_IN)
  begin
    
    if (OUTCOME = '0' and HIT2 = '1') then
      LUT(to_integer(unsigned(PC_WRITE(LENGTH-1 downto 0))))(pc_up downto pc_down)           <= (others => '0');
      LUT(to_integer(unsigned(PC_WRITE(LENGTH-1 downto 0))))(target_up downto target_down)   <= (others => '0');
      LUT(to_integer(unsigned(PC_WRITE(LENGTH-1 downto 0))))(counter_up downto counter_down) <= STRONG_NT;
      FLUSH <= '1';
    elsif (OUTCOME = '1' and HIT2 = '0') then
      LUT(to_integer(unsigned(PC_WRITE(LENGTH-1 downto 0))))(pc_up downto pc_down)           <= PC_WRITE;
      LUT(to_integer(unsigned(PC_WRITE(LENGTH-1 downto 0))))(target_up downto target_down)   <= TARG_IN;
      LUT(to_integer(unsigned(PC_WRITE(LENGTH-1 downto 0))))(counter_up downto counter_down) <= COUNTERnext;
      FLUSH <= '0';
    elsif (OUTCOME = '1' and HIT2 = '1') then
      LUT(to_integer(unsigned(PC_WRITE(LENGTH-1 downto 0))))(counter_up downto counter_down) <= COUNTERnext;
      FLUSH <= '0';
    else
      FLUSH <= '0';
    end if;

  end process;
  
  CTRL: process(CLK, RST)
  begin
    if (RST = '0') then
      HIT1     <= '0';
      HIT2     <= '0';
      COUNTER1 <= STRONG_NT;
      COUNTER2 <= STRONG_NT;
      LUT      <= (others => (others => '0'));
    elsif (CLK = '1' and CLK'event) then
      if (EN = '1') then
        HIT1     <= HIT;
        HIT2     <= HIT1;
        COUNTER1 <= COUNTER;
        COUNTER2 <= COUNTER1;
      end if;
    end if;
  end process;
  
  FSMD: process (COUNTER2, OUTCOME)
  begin
    case COUNTER2 is
      when STRONG_T  =>
        if (OUTCOME = '1') then
          COUNTERnext  <= STRONG_T;
        else
          COUNTERnext <= WEAK_T;
        end if;
      when WEAK_T    =>
        if (OUTCOME = '1') then
          COUNTERnext <= STRONG_T;
        else
          COUNTERnext <= STRONG_NT;
        end if;
      when STRONG_NT =>
        if (OUTCOME = '1') then
          COUNTERnext <= WEAK_NT;
        else
          COUNTERnext <= STRONG_NT;
        end if;
      when WEAK_NT   =>
        if (OUTCOME = '1') then
          COUNTERnext <= STRONG_T;
        else
          COUNTERnext <= STRONG_NT;
        end if;
      when others =>
        COUNTERnext <= STRONG_NT;
    end case;
  end process;

end architecture;

