
library IEEE;
use IEEE.std_logic_1164.all; --  libreria IEEE con definizione tipi standard logic


entity odd_parity_checker is
port( 	A:	in std_logic;
	clock: 	in std_logic;
	reset:	in std_logic;
	O:	out std_logic
);
end	odd_parity_checker;

---------------------------------------------

architecture FSM_OPC of odd_parity_checker is

	type TYPE_STATE is (S0, S1);
	signal CURRENT_STATE : TYPE_STATE;
	signal NEXT_STATE : TYPE_STATE;

begin
 	P_OPC : process(CLOCK, RESET)		
	begin
		
		if reset='1' then
	        	CURRENT_STATE <= S0;
		elsif (CLOCK ='1' and CLOCK'EVENT) then 
			CURRENT_STATE <= NEXT_STATE;
		end if;
	end process P_OPC;

	P_NEXT_STATE : process(CURRENT_STATE,A)
	begin
		NEXT_STATE <= CURRENT_STATE;
		case CURRENT_STATE is
			when S0 => if A ='0' then
					NEXT_STATE <= S0;
				   elsif A ='1' then
					NEXT_STATE <= S1;	
				   end if;
			when S1 => if A ='0' then
					NEXT_STATE <= S1;
			     	   elsif A ='1' then
                                        NEXT_STATE <= S0;
				   end if;
		end case;	
	end process P_NEXT_STATE;

	
	P_OUTPUTS: process(CURRENT_STATE)
	begin
		--O <= '0';
		case CURRENT_STATE is
				
			when S0 => O <= '0';
			when S1 => O <= '1';
		end case; 	
	end process P_OUTPUTS;
end FSM_OPC;
 

configuration CFG_FSM_OPC of odd_parity_checker is
	for  FSM_OPC
	end for;
end CFG_FSM_OPC;
