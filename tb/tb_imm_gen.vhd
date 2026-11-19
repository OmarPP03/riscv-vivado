library ieee;
use ieee.std_logic_1164.all;    
use ieee.numeric_std.all;       
use work.rv_pkg.all;

entity tb_immediate_generator is 
end entity tb_immediate_generator;

architecture behavioural of tb_immediate_generator is

	signal instr     : std_logic_vector(31 downto 0);   
	signal immediate : std_logic_vector(31 downto 0);  
	signal imm_sel   : imm_selector;						
	
begin 
	
	uut : entity work.immediate_generator(behavioural) port map (instr => instr, immediate => immediate, imm_sel => imm_sel);
	
	process begin
		-- addi r1, r0, -1
		instr <= x"FFF00093"; imm_sel <= IMM_I;
		wait for 5 ns;
		assert immediate = x"FFFFFFFF" report "First test (IMM_I) failed: immediate is " & to_hstring(immediate) severity error;
		-- addi r1, r0, 1094
		instr <= x"44600093"; imm_sel <= IMM_I;
		wait for 5 ns;
		assert immediate = x"00000446" report "Second test (IMM_I) failed: immediate is " & to_hstring(immediate) severity error;
		-- sw r2, 8(r1)
		instr <= x"0020A423"; imm_sel <= IMM_S;
		wait for 5 ns;
		assert immediate = x"00000008" report "Third test (IMM_S) failed: immediate is " & to_hstring(immediate) severity error;
		-- sw r2, -4(r1)
		instr <= x"FE20AE23"; imm_sel <= IMM_S;
		wait for 5 ns;
		assert immediate = x"FFFFFFFC" report "Fourth test (IMM_S) failed: immediate is " & to_hstring(immediate) severity error;
		-- beq r0, r0, 8
		instr <= x"00000463"; imm_sel <= IMM_B;
		wait for 5 ns;
		assert immediate = x"00000008" report "Fifth test (IMM_B) failed: immediate is " & to_hstring(immediate) severity error;
		-- beq r0, r0, -4
		instr <= x"FE000EE3"; imm_sel <= IMM_B;
		wait for 5 ns;
		assert immediate = x"FFFFFFFC" report "Sixth test (IMM_B) failed: immediate is " & to_hstring(immediate) severity error;
		-- lui r5, 0x12345
		instr <= x"123452B7"; imm_sel <= IMM_U;
		wait for 5 ns;
		assert immediate = x"12345000" report "Seventh test (IMM_U) failed: immediate is " & to_hstring(immediate) severity error;
		-- jal r1, 2048
		instr <= x"001000EF"; imm_sel <= IMM_J;
		wait for 5 ns;
		assert immediate = x"00000800" report "Eight test (IMM_J) failed: immediate is " & to_hstring(immediate) severity error;
		-- jal r0, -8
		instr <= x"FF9FF06F"; imm_sel <= IMM_J;
		wait for 5 ns;
		assert immediate = x"FFFFFFF8" report "Eight test (IMM_J) failed: immediate is " & to_hstring(immediate) severity error;
		report "tb_imm_gen: tests finished.";
		wait;
	end process;

end architecture;
	