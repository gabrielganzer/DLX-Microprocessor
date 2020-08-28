----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Description: functions used throughout the project (round division, log2)
-- Date: 05/05/2020
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

package FUNCTIONS is
  -- Functions
    -- Division where result is an integer rounded by excess	
    function divide( N: integer; M: integer) return integer;
    -- Log base 2 where result is an integer rounded by excess
    function log2 (N: integer) return integer;
end package;

package body FUNCTIONS is
  -- Subprograms
    -- Divide
    function divide( N: integer; M: integer) return integer is
    begin
		  if (n mod m) = 0 then
		    return n/m;
		  else
			  return (n/m) + 1;
		  end if;
	  end function;	
	  -- Log2
	  function log2 (N: integer) return integer is
	  begin
	    if n <=2 then
			  return 1;
		  else
			  return 1 + log2(divide(n,2));
		  end if;
	  end function;
end package body;