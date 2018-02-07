library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.kakuro_package.all;

entity cell_domain_dictionary is
	
	port (
		CLOCK: in std_logic;
		WE: in std_logic;
		ADDRESS: in cell_address;
		DATA_IN: in cell_domain;
		DATA_OUT: out cell_domain
	);
	
end entity;

architecture rtl of cell_domain_dictionary is

	type memory_array is array (natural range <>) of cell_domain;
	signal memory: memory_array(0 to MAX_CELLS-1) := (others => (others => '1'));

begin
	
	p0: process (CLOCK) is
	begin
		if rising_edge(CLOCK) then
			if (WE = '1') then
				memory(to_integer(unsigned(ADDRESS))) <= DATA_IN;
			end if;
		end if;
	end process;
	
	DATA_OUT <= memory(to_integer(unsigned(ADDRESS)));
	
end architecture;
