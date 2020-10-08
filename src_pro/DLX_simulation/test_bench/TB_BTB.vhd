----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Design units: RWMEM
-- Function: Single-port RAM memory
-- Input:
-- Output:
-- Architecture: behavioral
-- Library/package: ieee.std_logic_ll64, work.globals
-- Date: 12/08/2020
----------------------------------------------------------------------------------
library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.globals.all;

entity TB_BTB is
end entity;

architecture TESTBENCH of TB_BTB is
  
  -- Components
  component BTB
    generic (WIDTH: integer := word_size;
             LENGTH: integer := btb_size);
  	port (CLK           : in std_logic;
  	      RST           : in std_logic;   -- Synchronous, active-low
  	      EN            : in std_logic;
  	      OUTCOME       : in std_logic;   -- Outcome of branch prediction (0 -> NT, 1 -> T)
         PC_READ       : in std_logic_vector(WIDTH-1 downto 0);  -- PC to be compared with CAM
         PC_WRITE      : in std_logic_vector(WIDTH-1 downto 0);  -- PC to be compared with CAM
         TARG_IN       : in std_logic_vector(WIDTH-1 downto 0);  -- Target to be written into CAM
         TARG_OUT      : out std_logic_vector(WIDTH-1 downto 0); -- Target read from CAM
         FLUSH         : out std_logic;                          -- Flush pipeline
         PREDICT       : out std_logic                           -- Prediction signal (0 -> NPC, 1 -> TARGET)
    );
  end component;
  
  -- Signals
  signal CLK           : std_logic;
  signal RST           : std_logic;
  signal EN            : std_logic;
  signal OUTCOME       : std_logic;
  signal PC_READ       : std_logic_vector(word_size-1 downto 0);
  signal PC_WRITE      : std_logic_vector(word_size-1 downto 0);
  signal TARG_IN       : std_logic_vector(word_size-1 downto 0);
  signal TARG_OUT      : std_logic_vector(word_size-1 downto 0);
  signal FLUSH         : std_logic;
  signal PREDICT       : std_logic
  
begin
  
  UUT: BTB
    generic map(word_size, btb_size)
  	 port map(CLK, RST, EN, OUTCOME, PC_READ, PC_WRITE, TARG_IN, TARG_OUT, FLUSH, PREDICT);
     
  CLK_PROC: process
  begin
    CLK <= '0';
    wait for 5 ns;
    CLK <= '1';
    wait for 5 ns;
  end process;
  
  STIMULI: process
  begin
    -- Reset
    RST  <= '0';
    EN   <= '0'; 
    wait for 4 ns;
    RST  <= '1';
    EN   <= '1'; 
    PC_READ <= (others => '0');
    wait until (CLK = '1' and CLK'event);
    ADDR <=  std_logic_vector(to_unsigned(1, ADDR'length));
    wait until (CLK = '1' and CLK'event);
    ADDR <=  std_logic_vector(to_unsigned(2, ADDR'length));
    wait until (CLK = '1' and CLK'event);
    ADDR <=  std_logic_vector(to_unsigned(3, ADDR'length));
    wait until (CLK = '1' and CLK'event);
    ADDR <=  std_logic_vector(to_unsigned(4, ADDR'length));
    wait until (CLK = '1' and CLK'event);
    ADDR <=  std_logic_vector(to_unsigned(5, ADDR'length));
    wait until (CLK = '1' and CLK'event);
    ADDR <=  std_logic_vector(to_unsigned(6, ADDR'length));
    wait until (CLK = '1' and CLK'event);
    ADDR <=  std_logic_vector(to_unsigned(7, ADDR'length));
    wait;
  end process;
  
end architecture;