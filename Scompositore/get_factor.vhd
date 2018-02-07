library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.solutions_type.all;

entity get_factor is
	port( 
			numero_da_scomporre : in integer range 1 to 45;
			celle : in integer range 2 to 9;
			clock : in std_logic;
			reset : in std_logic;
			factor : out std_logic_vector(0 to 8);
			get_factor_done : out std_logic
		 );
end get_factor;

architecture factoring of get_factor is

	signal combinations : solutions;
	signal done : std_logic;
	signal index : integer range 0 to 12;
	signal temp_factor : std_logic_vector(0 to 8) := (others => '0');
	type state_type is (INIT, COMPUTATION, OUTPUT);
	signal current_state : state_type;
	signal next_state : state_type;

	begin
	first_splitter : entity work.scompositore port map(numero_da_scomporre, celle, clock, combinations, done);
		
		state_register : process (reset, clock) is
		begin
			if reset = '1' then
				current_state <= INIT;
			elsif rising_edge(clock) then
				current_state <= next_state;
			end if;
		end process;
		
		output_and_next_state : process (current_state, done, index, combinations, temp_factor) is
		begin
		
			case current_state is
			
			when INIT =>
			
				next_state <= INIT;
				
				if(done = '1') then
					next_state <= COMPUTATION;
					index <= 0;
				end if;
		
			when COMPUTATION =>
					
				next_state <= COMPUTATION;	 
				
				if(index < 12) then	
					temp_factor <= temp_factor or combinations(index);
					index <= index + 1;		
				else
					next_state <= OUTPUT;
				end if;
					
			when OUTPUT =>
				
				next_state <= OUTPUT;
				
				factor <= temp_factor;
				get_factor_done <= '1';
				
			end case;	
		end process;
end factoring;