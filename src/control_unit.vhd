library ieee;
use ieee.std_logic_1164.all;    
use ieee.numeric_std.all;  


entity control_unit is
	
	port(
		op_code : in std_logic_vector(6 downto 0);  -- instr[6:0]
		funct3  : in std_logic_vector(2 downto 0);  -- instr[15:12]
		funct7  : in std_logic_vector(6 downto 0);  -- instr[31:25]
		
		
	);
	
end entity control_unit;