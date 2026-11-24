library ieee;
use ieee.std_logic_1164.all;    
use ieee.numeric_std.all;  

entity tb_comparator is
end entity tb_comparator;

architecture behavioural of tb_comparator is

	signal rs1         : std_logic_vector(31 downto 0);
	signal rs2         : std_logic_vector(31 downto 0);
	signal funct3      : std_logic_vector(2 downto 0);
	signal branch_cond : std_logic;
	
begin

	uut : entity work.comparator(behavioural) port map (rs1 => rs1, rs2 => rs2, 
														funct3 => funct3, branch_cond => branch_cond);
	
	process begin
	
		rs1 <= x"00000005"; rs2 <= x"00000005"; funct3 <= "000";
		wait for 1 ns;
		assert branch_cond = '1' report "test failed: funct3 " & to_string(funct3) & " gives " & std_logic'image(branch_cond) severity error;
		rs1 <= x"00000005"; rs2 <= x"00000006"; funct3 <= "000";
		wait for 1 ns;
		assert branch_cond = '0' report "test failed: funct3 " & to_string(funct3) & " gives " & std_logic'image(branch_cond) severity error;
		rs1 <= x"00000005"; rs2 <= x"00000006"; funct3 <= "001";
		wait for 1 ns;
		assert branch_cond = '1' report "test failed: funct3 " & to_string(funct3) & " gives " & std_logic'image(branch_cond) severity error;
		rs1 <= x"00000005"; rs2 <= x"00000005"; funct3 <= "001";
		wait for 1 ns;
		assert branch_cond = '0' report "test failed: funct3 " & to_string(funct3) & " gives " & std_logic'image(branch_cond) severity error;
		rs1 <= x"FFFFFFFF"; rs2 <= x"00000001"; funct3 <= "100";
		wait for 1 ns;
		assert branch_cond = '1' report "test failed: funct3 " & to_string(funct3) & " gives " & std_logic'image(branch_cond) severity error;
		rs1 <= x"FFFFFFFF"; rs2 <= x"00000001"; funct3 <= "110";
		wait for 1 ns;
		assert branch_cond = '0' report "test failed: funct3 " & to_string(funct3) & " gives " & std_logic'image(branch_cond) severity error;
		rs1 <= x"FFFFFFFF"; rs2 <= x"00000001"; funct3 <= "101";
		wait for 1 ns;
		assert branch_cond = '0' report "test failed: funct3 " & to_string(funct3) & " gives " & std_logic'image(branch_cond) severity error;
		rs1 <= x"FFFFFFFF"; rs2 <= x"00000001"; funct3 <= "111";
		wait for 1 ns;
		assert branch_cond = '1' report "test failed: funct3 " & to_string(funct3) & " gives " & std_logic'image(branch_cond) severity error;
		rs1 <= x"00000005"; rs2 <= x"00000005"; funct3 <= "101";
		wait for 1 ns;
		assert branch_cond = '1' report "test failed: funct3 " & to_string(funct3) & " gives " & std_logic'image(branch_cond) severity error;
		rs1 <= x"00000005"; rs2 <= x"00000005"; funct3 <= "111";
		wait for 1 ns;
		assert branch_cond = '1' report "test failed: funct3 " & to_string(funct3) & " gives " & std_logic'image(branch_cond) severity error;
		rs1 <= x"00000005"; rs2 <= x"00000005"; funct3 <= "010";
		wait for 1 ns;
		assert branch_cond = '0' report "unknown funct3 " & to_string(funct3) severity error;
		report "tb_control_unit: tests finished.";
		wait;
	end process;
end architecture;