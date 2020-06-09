library IEEE;

use IEEE.std_logic_1164.all;
		


entity TBFSM is
end TBFSM;

architecture TEST of TBFSM is

	signal T_IN: std_logic;
	signal T_CLOCK: std_logic;
	signal T_RESET: std_logic;
	signal T_OUT: std_logic;

	component odd_parity_checker
	port (  A:     in std_logic;
	        clock:  in std_logic;
        	reset:  in std_logic;
        	O:    out std_logic);
	end component;

begin

	U_fsm_opc: odd_parity_checker
	Port Map (T_IN, T_CLOCK, T_RESET, T_OUT);
	
	process
	begin
		T_CLOCK <= '1';			-- clock cycle 6 ns
		wait for 3 ns;
		T_CLOCK <= '0';
		wait for 3 ns;
	end process;
	
		T_RESET <= '1' after 2 ns, '0' after 10 ns;
		T_IN <= '1' after 3 ns, '0' after 11 ns, '1' after 19 ns, '0' after 25 ns, '1' after 34 ns, '0' after 49 ns, '1' after 65 ns;

end TEST;

-------------------------------

configuration CFG_TB of TBFSM is
	for TEST
	end for;
end CFG_TB;

