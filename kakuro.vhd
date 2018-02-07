library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.kakuro_package.all;

entity kakuro is

	port (
		CLOCK_50 : in std_logic;
		KEY : in std_logic_vector(3 downto 0);
		SW : in std_logic_vector(9 downto 0);
		UART_RXD : in std_logic;
		LEDG : out std_logic_vector(7 downto 0);
		LEDR : out std_logic_vector(9 downto 0)
	);
	
end entity;

architecture rtl of kakuro is
	
	signal data_valid : std_logic;
	signal data : std_logic_vector(7 downto 0);
	
	signal current_constraint : sum_constraint;
	
	type state_type is (INIT, RECEIVING_SUM, RECEIVING_CELL_COUNT,
		RECEIVING_CELL_ADDR, SOLVING);
	
	signal current_state : state_type;
	signal next_state : state_type;
	signal current_address_index : integer;
	signal next_address_index : integer;

begin

	data_receiver : entity work.UART_RX
	generic map (5208)
	port map (
		CLOCK_50,
		UART_RXD,
		data_valid,
		data
	);
	
	state_register : process (KEY(0), CLOCK_50) is
	begin
		if KEY(0) = '0' then
			current_state <= INIT;
			current_address_index <= 0;
		elsif rising_edge(CLOCK_50) then
			current_state <= next_state;
			current_address_index <= next_address_index;
		end if;
	end process;
	
	output_and_next_state : process (current_state, data_valid, data, current_address_index) is
	begin
		
		case current_state is
			
			when INIT =>
			
				next_state <= INIT;
				LEDR <= "0000000001";
				LEDG <= "10101010";
				
				if data_valid = '1' and data = "00000000" then
					next_state <= RECEIVING_SUM;
				end if;
			
			when RECEIVING_SUM =>
			
				next_state <= RECEIVING_SUM;
				LEDR <= "0000000010";
			
				if data_valid = '1' then	
					current_constraint.sum <= to_integer(unsigned(data));
					next_state <= RECEIVING_CELL_COUNT;
				end if;
			
			when RECEIVING_CELL_COUNT =>
			
				next_state <= RECEIVING_CELL_COUNT;
				next_address_index <= 0;
				LEDR <= "0000000100";
				
				if data_valid = '1' then
					current_constraint.cell_count <= to_integer(unsigned(data));
					next_state <= RECEIVING_CELL_ADDR;
				end if;
				
			when RECEIVING_CELL_ADDR =>
			
				next_state <= RECEIVING_CELL_ADDR;
				next_address_index <= current_address_index;
				
				LEDR <= "00" & std_logic_vector(to_unsigned(current_address_index, 8));
				
				if data_valid = '1' then
				
					current_constraint.cells(current_address_index) <= data;
					
					if current_address_index < 8 then
						next_address_index <= current_address_index + 1;
					else
						next_state <= SOLVING;
					end if;
					
				end if;

			when SOLVING =>
			
				next_state <= SOLVING;
				LEDR <= "0000100000";
			
				if SW(9) = '1' then
					LEDG <= std_logic_vector(to_unsigned(current_constraint.sum, 8));
				elsif SW(8) = '1' then
					LEDG <= std_logic_vector(to_unsigned(current_constraint.cell_count, 8));
				elsif SW(7) = '1' then
					LEDG <= current_constraint.cells(7);
				elsif SW(6) = '1' then
					LEDG <= current_constraint.cells(6);
				elsif SW(5) = '1' then
					LEDG <= current_constraint.cells(5);
				elsif SW(4) = '1' then
					LEDG <= current_constraint.cells(4);
				elsif SW(3) = '1' then
					LEDG <= current_constraint.cells(3);
				elsif SW(2) = '1' then
					LEDG <= current_constraint.cells(2);
				elsif SW(1) = '1' then
					LEDG <= current_constraint.cells(1);
				elsif SW(0) = '1' then
					LEDG <= current_constraint.cells(0);
				end if;
				
		end case;
		
	end process;

end architecture;
