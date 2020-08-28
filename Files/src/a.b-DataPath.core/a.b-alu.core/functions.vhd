----------------------------------------------------------------------------------
-- Engineer: GANZER Gabriel
-- Company: Politecnico di Torino
-- Descriptions: functions used throughout project (divide, log2)
-- Date: 14/04/2020
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;

package FUNCTIONS is
	--Calculates the division between the two parameters, the result is an integer which is rounded by excess	
	function divide (n:integer; m:integer) return integer;
	-- Calculates the log in base 2 of the number n, the result is an integer which is rounded by excess
	function log2 (n:integer) return integer;
end package;

package body FUNCTIONS is
	function divide (n:integer; m:integer) return integer is
	begin
		if (n mod m) = 0 then
			return n/m;
		else
			return (n/m) + 1;
		end if;
	end divide;
	function log2 (n:integer) return integer is
	begin
		if n <=2 then
			return 1;
		else
			return 1 + log2(divide(n,2));
		end if;
	end log2;	
end package body;