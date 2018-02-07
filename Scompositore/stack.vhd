--Empty descending stack implementation in VHDL.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.solutions_type.all;

entity stack is
	port(	Clk : in std_logic;  --Clock for the stack.
			Reset : in std_logic; --active high reset.    
			Enable : in std_logic;  --Enable the stack. Otherwise neither push nor pop will happen.
			Data_In : in scomposizione;  --Data to be pushed to stack
			Data_Out : out scomposizione;  --Data popped from the stack.
			PUSH_barPOP : in std_logic;  --active low for POP and active high for PUSH.
			Stack_Full : out std_logic;  --Goes high when the stack is full.
			Stack_Empty : out std_logic  --Goes high when the stack is empty.
		  );
end stack;

architecture Behavioral of stack is

type mem_type is array (0 to 255) of scomposizione;
signal stack_mem : mem_type;
signal full : std_logic;
signal empty : std_logic;
signal SP : integer := 0;  --for simulation and debugging. 

begin

	Stack_Full <= full; 
	Stack_Empty <= empty;

	--PUSH and POP process for the stack.
	PUSH : process(Clk,reset)
		variable stack_ptr : integer := 256;
	begin
		if(reset = '1') then
			stack_ptr := 256;  --stack grows downwards.
			full <= '0';
			empty <= '1';
			Data_out.solution <= (others => '0');
		elsif(rising_edge(Clk)) then
			--POP section.
			if (Enable = '1' and PUSH_barPOP = '0' and empty = '0') then
				--setting empty flag.           
				if(stack_ptr /= 256) then
					full <= '0';
					empty <= '0';
				end if;
			
				Data_Out <= stack_mem(stack_ptr);
				
				if(stack_ptr /= 256) then   
					stack_ptr := stack_ptr + 1;
				end if;
			
				if(stack_ptr = 256) then   
					empty <= '1';
				end if;
			end if;
			
			--PUSH section.
			if (Enable = '1' and PUSH_barPOP = '1' and full = '0') then
				--setting full flag.
				if(stack_ptr /= 0) then
					full <= '0';
					empty <= '0';
				end if;
					 
				if(stack_ptr /= 0) then
					stack_ptr := stack_ptr - 1;
				end if;
				
				stack_mem(stack_ptr) <= Data_In;      	         
			
			end if;
			SP <= stack_ptr;  --for debugging/simulation.
			  
		end if; 
	end process;
end Behavioral;