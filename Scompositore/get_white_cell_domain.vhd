library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
use work.solutions_type.all;

entity get_white_cell_domain is
	port( first_number : in integer range 1 to 45;
			first_cells : in integer range 2 to 9;
			second_number : in integer range 1 to 45;
			second_cells : in integer range 2 to 9;
			clock : in std_logic;
			reset : in std_logic;
			domain : out std_logic_vector(0 to 8);
			domain_done : out std_logic);
end get_white_cell_domain;

architecture get_domain of get_white_cell_domain is
	
	signal first_factors : std_logic_vector(0 to 8);
	signal second_factors : std_logic_vector(0 to 8);
	signal done : std_logic;
	signal done_2 : std_logic;
	type state_type is (INIT, COMPUTATION);
	signal current_state : state_type;
	signal next_state : state_type;
	
	begin
	first_get_factor : entity work.get_factor port map(first_number, first_cells, clock, reset, first_factors, done);
	second_get_factor : entity work.get_factor port map(second_number, second_cells, clock, reset, second_factors, done_2);
		
		state_register : process (reset, clock) is
		begin
			if reset = '1' then
				current_state <= INIT;
			elsif rising_edge(clock) then
				current_state <= next_state;
			end if;
		end process;
		
		output_and_next_state : process (current_state, done, done_2, first_factors, second_factors) is
		begin
		
			case current_state is
			
			when INIT =>
			
				next_state <= INIT;
				
				if(done = '1' and done_2 = '1') then
					next_state <= COMPUTATION;
				end if;
				
			when COMPUTATION =>
				
				next_state <= COMPUTATION;
				
				domain <= first_factors and second_factors;
				domain_done <= '1';
				
			end case;
		end process;
end get_domain;