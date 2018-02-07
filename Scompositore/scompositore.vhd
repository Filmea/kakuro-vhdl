library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.solutions_type.all;

entity scompositore is
	port( numero_da_scomporre : in integer range 1 to 45;
			celle : in integer range 2 to 9;
			clock : in std_logic;
		   fattori : out solutions;
			done : out std_logic
        );
end scompositore;

architecture scompositore_in_fattori of scompositore is

	signal fattore_1 : integer range 0 to 10; -- deve poter arrivare fino a 10 per inserire correttamente 1 se index = 9
	signal fattore_2 : integer range 0 to 9;
	signal temp_fact : integer range 0 to 9;
	signal temp_fattori : solutions := (others => (others => '0'));

	signal index : integer := 0; -- scorre la posizione dei bit nella solution
	signal solution : integer := 0; -- tiene il conto delle solution
	signal init : integer := 0; -- usato come indice di scelta fra gli stati
	signal substate_init_1 : integer := 0; -- divide in sottostati lo stato 1
	signal substate_init_3 : std_logic := '0'; -- divide in sottostati lo stato 3
	signal substate_init_4 : integer := 0; -- divide in sottostati lo stato 4
	signal invalid_solution : std_logic := '0'; -- segnala una soluzione invalida nel caso con celle = 2
	signal last_state : std_logic := '0'; -- segnala che siamo entrati nell'ultimo stato
	signal jump_solution : std_logic := '0'; -- segnala che numero da scomporre temp > 17, quindi salto la scomposizione
	
	signal Reset : std_logic_vector(0 to 1) := (others => '1'); --active high reset.    
	signal Enable : std_logic_vector(0 to 1) := (others => '0');  --Enable the stack. Otherwise neither push nor pop will happen.
   signal PUSH_barPOP : std_logic_vector(0 to 1) := ("10");  --active low for POP and active high for PUSH.
   signal Stack_Full : std_logic_vector(0 to 1);  --Goes high when the stack is full.
   signal Stack_Empty : std_logic_vector(0 to 1);  --Goes high when the stack is empty.
	signal Data_In : stack_signal;  --Data to be pushed to stack
   signal Data_Out : stack_signal;  --Data popped from the stack.
	
	signal fattori_temp : std_logic_vector(0 to 8) := (others => '0');
	signal solution_temp : std_logic_vector(0 to 8) := (others => '0'); -- è la solution che prendo in pop dallo stack
	signal celle_temp : integer range 1 to 9;
	
	signal stack_in_push : integer range 0 to 1 := 0;
	signal stack_in_pop : integer range 0 to 1 := 1;
	signal numero_da_scomporre_temp : integer range 0 to 44;
	
	begin
	stack0 : entity work.stack port map (clock, Reset(0), Enable(0), Data_In(0), Data_Out(0), PusH_barPOP(0), Stack_Full(0), Stack_Empty(0));
	stack1 : entity work.stack port map (clock, Reset(1), Enable(1), Data_In(1), Data_Out(1), PusH_barPOP(1), Stack_Full(1), Stack_Empty(1));
		scomposizione: process(clock)
		begin
			if rising_edge(clock) then
				enable <= (others => '0');
				
				-- STATO DI INIZIALIZZAZIONE
				if(init = 0) then 
					reset <= (others => '0'); -- inizializzo entrambi gli stack subito
					numero_da_scomporre_temp <= numero_da_scomporre;
					celle_temp <= celle;
					done <= '0';
					init <= 1;
				end if;
				
				-- STATO DI COMPUTAZIONE, devo distinguere la prima computazione dalle successive
				if(init = 1) then
					if (celle_temp = 9) then
						fattori(solution) <= (others => '1');
					elsif (celle_temp > 2) then
						if(substate_init_1 = 0) then -- uso un ciclo per inizializzare i segnali
							temp_fact <= numero_da_scomporre_temp / celle_temp;
							fattore_1 <= 1;
							substate_init_1 <= 1; -- al clock dopo fa l'else che segue
						else -- SUBSTATE_INIT_1 = 1
							if(fattore_1 < temp_fact and index + 1 = fattore_1) then
								if(fattori_temp(index) = '0') then
									fattori_temp(index) <= fattori_temp(index) or '1';
								else
									fattori_temp <= (others => '0'); -- se l'uno è già presente invalido la soluzione
								end if;
								index <= 0;
								fattore_1 <= fattore_1 + 1;
								init <= 2;
							elsif (fattore_1 = temp_fact) then	-- fattore 1 è diventato come temp_fact, cambio stack SE LO STACK DA CUI FACCIO LA POP E' VUOTO
								init <= 3;
								substate_init_3 <= '0';
							else
								index <= index + 1;
							end if;
						end if;	
					else -- CASO CELLE = 2
						if (substate_init_1 = 0) then -- substate_init_1 = 0 imposta il fattore 1 per la scomposizione a due fattori
							if (numero_da_scomporre_temp < 18) then
								fattore_1 <= ((numero_da_scomporre_temp / 2) + 1);
								fattori_temp <= solution_temp; -- se non lo metto anche qui salta alcuni casi con 2 celle
								substate_init_1 <= 1;
							else
								fattori_temp <= (others => '0');
								jump_solution <= '1';
								substate_init_1 <= 2;
							end if;								
						elsif (substate_init_1 = 1) then -- substate_init_1 = 1 imposta il fattore 2 per la scomposizione a due fattori
							fattore_2 <= numero_da_scomporre_temp - fattore_1;
							substate_init_1 <= 2; 
						else -- SUBSTATE_INIT_1 = 2
							if (fattore_1 < numero_da_scomporre_temp and fattore_1 <= 9 and fattore_2 /= 0 and jump_solution = '0') then
								if ((index + 1 = fattore_1) or (index + 1= fattore_2)) and invalid_solution = '0' then
									if(fattori_temp(index) = '0') then -- CONTROLLO UNI GIA' PRESENTI
										fattori_temp(index) <= fattori_temp(index) or '1';
									else -- devo invalidare la solution
										fattori_temp <= (others => '0');
										invalid_solution <= '1';
									end if;
								end if;
								if (index = 8 or invalid_solution = '1') then
									index <= 0;
									fattore_1 <= fattore_1 + 1;
									fattore_2 <= fattore_2 - 1;
									invalid_solution <= '0';
									init <= 2;
								else
									index <= index + 1;
								end if;
							else	-- CONTROLLO SE LO STACK DA CUI STO FACENDO LA POP E' VUOTO SE NON LO E' CONTINUO CON LE POP
								if(stack_empty(stack_in_pop) = '0') then
									init <= 4;
								else -- SE LO STACK E' VUOTO VADO ALLO STATO POP, POI AL CONTROLLO FINALE
									substate_init_3 <= '1';
									init <= 3;
								end if;
								jump_solution <= '0';
							end if;
						end if;
					end if;
				end if;
				
				-- STATO DI PUSH
				if(init = 2) then
					if(fattori_temp /= "000000000") then --se la soluzione contiene almeno un uno la pusho
						enable(stack_in_push) <= '1';
						data_in(stack_in_push).n_scomposto <= numero_da_scomporre_temp;
						data_in(stack_in_push).first_fact <= fattore_1 - 1;
						data_in(stack_in_push).celle <= celle_temp - 1;
						data_in(stack_in_push).solution <= fattori_temp;
					end if;
					fattori_temp <= solution_temp;
					init <= 1;
				end if;
				
				-- CAMBIO STACK
				if(init = 3) then
					if(stack_empty(stack_in_pop) = '1') then
						if(stack_in_push = 0) then
							stack_in_push <= 1;
							stack_in_pop <= 0;
							PUSH_barPOP <= "01";
						else
							stack_in_push <= 0;
							stack_in_pop <= 1;
							PUSH_barPOP <= "10";
						end if;
					end if;
					if(substate_init_3 = '0') then -- arrivo in 3 da stato 1 e continuo l'iterazione
						substate_init_3 <= '0';
						init <= 4;
					else -- arrivo in 3 da stato 1 e devo andare nello stato finale passando per pop
						last_state <= '1';
						init <= 4;
					end if;
				end if;
				
				-- STATO DI POP, PROBABILMENTE PUO' ESSERE MIGLIORATO
				if(init = 4) then
					if(substate_init_4 = 0) then				
						enable(stack_in_pop) <= '1';
						if(last_state = '0') then
							substate_init_4 <= 1;
						else
							substate_init_4 <= 2;
						end if;
					elsif (substate_init_4 = 1) then
						substate_init_4 <= 0;
						init <= 5; -- va allo stato di aggiornamento
					else -- substate_init = 2
						substate_init_4 <= 0;
						init <= 6; -- va all'ultimo stato
					end if;
				end if;

				-- STATO DI AGGIORNAMENTO NUMERO E CELLE
				if(init = 5) then
					numero_da_scomporre_temp <= data_out(stack_in_pop).n_scomposto - data_out(stack_in_pop).first_fact; 
					celle_temp <= data_out(stack_in_pop).celle;
					solution_temp <= data_out(stack_in_pop).solution;
					fattori_temp <= data_out(stack_in_pop).solution;
					substate_init_1 <= 0;
					init <= 1;
				end if;
				
				-- STATO DI CONTROLLO DELLE SOLUZIONI DOPPIE, si può migliorare invalid_solution
				if(init = 6) then
					if(invalid_solution = '0') then
						if(index < 12) then
							if(temp_fattori(index) = data_out(stack_in_pop).solution) then
								invalid_solution <= '1';
							end if;
							index <= index + 1;
						else
							temp_fattori(solution) <= data_out(stack_in_pop).solution;
							index <= 0;
							solution <= solution + 1;
							if(stack_empty(stack_in_pop) = '0') then
								init <= 4;
							else
								init <= 7; -- STATO FINALE
							end if;
						end if;
					else -- invalid solution è 1
						invalid_solution <= '0';
						index <= 0;
						if(stack_empty(stack_in_pop) = '0') then
							init <= 4;
						else
							init <= 7; -- STATO FINALE
						end if;
					end if;
				end if;
				
				-- STATO FINALE
				if(init = 7) then
					fattori <= temp_fattori;
					done <= '1';
					init <= 8;
				end if;
				
			end if;
		end process scomposizione;		
end scompositore_in_fattori;