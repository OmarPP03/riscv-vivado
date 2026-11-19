library ieee;
use ieee.std_logic_1164.all;    
use ieee.numeric_std.all;  
use work.rv_pkg.all;

entity immediate_generator is
	
	port(
		instr     : in std_logic_vector(31 downto 0);   -- instruction message
		immediate : out std_logic_vector(31 downto 0);  -- immediate out 
		imm_sel   : in imm_selector						-- what is the type of immediate operation?
	);

end entity immediate_generator;

architecture behavioural of immediate_generator is

	-- Sign extender: takes the sign bit of the instruction and extends it to 32 bit
	signal sext : std_logic_vector(31 downto 0);
	
	begin
		sext <= (others => instr(31));
		process(all)
		begin
		case imm_sel is
			-- Follow RV32I operation decoding
			when IMM_I => immediate <= sext(31 downto 11) & instr(30 downto 20);
			when IMM_S => immediate <= sext(31 downto 11) & instr(30 downto 25) & instr(11 downto 7);
			when IMM_B => immediate <= sext(31 downto 12) & instr(7) & instr(30 downto 25) & instr(11 downto 8) & '0';
			when IMM_U => immediate <= instr(31 downto 12) & x"000";
			when IMM_J => immediate <= sext(31 downto 20) & instr(19 downto 12) & instr(20) & instr(30 downto 21) & '0';
		end case;
		end process;
end architecture;