library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.solutions_type.all;

entity test_get_white_cell_domain is
end entity;

architecture test of test_get_white_cell_domain is

	component get_white_cell_domain
		port( first_number : in integer range 1 to 45;
				first_cells : in integer range 2 to 9;
				second_number : in integer range 1 to 45;
				second_cells : in integer range 2 to 9;
				clock : in std_logic;
				reset : in std_logic;
				domain : out std_logic_vector(0 to 8);
				domain_done : out std_logic);
	end component;

	signal first_number : integer := 39;
	signal first_cells : integer := 8;
	signal second_number : integer := 6;
	signal second_cells : integer := 3;
	signal clock : std_logic := '0';
	signal domain_done : std_logic := '0';
	signal domain : std_logic_vector(0 to 8);
	signal reset : std_logic := '1';
   constant clk_period : time := 1 ps;
	
	begin
	dominio : get_white_cell_domain
	port map(first_number => first_number,
				first_cells => first_cells,
				second_number => second_number,
				second_cells => second_cells,
            clock => clock,
				reset => reset,
            domain => domain,
				domain_done => domain_done
            );
	
	clk_process : process
   begin
		if(reset = '1') then
			reset <= '0';
		end if;
      clock <= not clock;
      wait for 1 ps; 
	end process;
	
end test;