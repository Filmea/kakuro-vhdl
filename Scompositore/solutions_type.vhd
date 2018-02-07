library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

package solutions_type is
	constant SOLUTION_LENGTH : integer := 9;  --bits wide
	constant NUMBER_OF_SOLUTIONS : integer := 12; --bits wide
	
	type solutions is array(0 to NUMBER_OF_SOLUTIONS-1) of std_logic_vector(0 to SOLUTION_LENGTH-1);
	
	type scomposizione is record
		n_scomposto : integer range 1 to 44;
		first_fact : integer range 0 to 9;
		celle : integer range 1 to 9;
		solution : std_logic_vector(0 to 8);
	end record scomposizione;
	
	type stack_signal is array (0 to 1) of scomposizione;
end package solutions_type;