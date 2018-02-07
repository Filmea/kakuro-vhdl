library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package kakuro_package is

	constant CELL_ADDRESS_LENGTH: positive := 8;                     -- dimensione: 8 bit
	constant CELL_DOMAIN_LENGTH: positive := 9;                      -- dimensione: 9 bit
	constant CONSTRAINT_ID_LENGTH: positive := 5;                    -- dimensione: 5 bit
	
	subtype cell_address is std_logic_vector(CELL_ADDRESS_LENGTH-1 downto 0);
	subtype cell_domain is std_logic_vector(CELL_DOMAIN_LENGTH-1 downto 0);
	subtype constraint_id is std_logic_vector(CONSTRAINT_ID_LENGTH-1 downto 0);
	
	constant MAX_CELLS: positive := 2**CELL_ADDRESS_LENGTH;               -- numero massimo di celle
	constant MAX_CONSTRAINTS: positive := 2**CONSTRAINT_ID_LENGTH;   -- numero massimo di somme indicate
	
	constant MAX_PEERS: positive := 16;                              -- numero massimo di peers per una cella

	constant INVALID_ADDRESS: cell_address := (others => '1');
	
	type cell_address_array is array (natural range <>) of cell_address;

	type sum_constraint is record
		sum: integer range 3 to 45;
		cell_count: integer range 2 to 9;
		cells: cell_address_array(0 to 8);
	end record;
	
end package;
