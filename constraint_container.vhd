library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.kakuro_package.all;

entity constraint_dictionary is

	port (
		CLOCK: in std_logic;
		WE: in std_logic;
		ID: in constraint_id;
		DATA_IN: in sum_constraint;
		DATA_OUT: out sum_constraint
	);

end entity;

architecture rtl of constraint_dictionary is

	type memory_array is array (natural range <>) of sum_constraint;
	signal memory: memory_array(0 to MAX_CONSTRAINTS-1);

begin

	p0: process (CLOCK) is
	begin
		if rising_edge(CLOCK) then
			if WE = '1' then
				memory(to_integer(unsigned(ID))) <= DATA_IN;
			end if;
		end if;
	end process;
	
	DATA_OUT <= memory(to_integer(unsigned(ID)));
	
end architecture;
