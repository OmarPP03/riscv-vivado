library ieee;
use ieee.std_logic_1164.all;    
use ieee.numeric_std.all;       
use work.rv_pkg.all;

entity tb_state_machine is
end entity tb_state_machine;

architecture behavioural of tb_state_machine is
	
	signal clk       	 : std_logic := '0';
	signal reset     	 : std_logic := '0';
	signal reg_write 	 : std_logic := '0'; 
	signal mem_write 	 : std_logic := '0';
	
	signal pc_load       : std_logic;  
	signal rd_w_enable   : std_logic;  
	signal mem_w_enable  : std_logic;  
	
	signal p_state    	 : sm_state;
	signal done          : boolean := false;

begin

	uut : entity work.state_machine(behavioural) port map ( clk => clk, reset => reset, reg_write => reg_write, mem_write => mem_write,
															pc_load => pc_load, rd_w_enable => rd_w_enable, mem_w_enable => mem_w_enable, p_state => p_state );
															
	clk <= not clk after 5 ns when not done;
															
	process begin
	
		-- Check that state is at fetch after reset
		reset <= '1'; reg_write <= '1'; mem_write <= '0';
		wait until falling_edge(clk);
		assert p_state = S_FETCH report "First cycle (FETCH): Stage after reset not S_FETCH, instead: " & sm_state'image(p_state) severity error;
		reset <= '0';
		
		-- one cycle with reg_write <= 1
		wait until rising_edge(clk);
		wait for 1 ns;
		assert p_state = S_DECODE 										  report "First cycle (DECODE): Should be S_DECODE stage, instead got " & sm_state'image(p_state) severity error;
		assert pc_load = '0' and rd_w_enable = '0' and mem_w_enable = '0' report "First cycle (DECODE): No enable should be active at S_DECODE stage." severity error;
		
		wait until rising_edge(clk);
		wait for 1 ns;
		assert p_state = S_EXECUTE report "First cycle (EXECUTE): Should be S_EXECUTE stage, instead got " & sm_state'image(p_state) severity error;
		assert mem_w_enable = '0'  report "First cycle (EXECUTE): mem_w_enable active with mem_write unactive" severity error;
		assert rd_w_enable = '0'   report "First cycle (EXECUTE): rd_w_enable active during S_EXECUTE stage" severity error;
		
		wait until rising_edge(clk);
		wait for 1 ns;
		assert p_state = S_MEMW  report "First cycle (MEMW): Should be S_MEMW stage, instead got " & sm_state'image(p_state) severity error;
		assert pc_load = '1' 	 report "First cycle (MEMW): pc_load unactive." severity error;
		assert rd_w_enable = '1' report "First cycle (MEMW): rd_w_enable unactive with reg_write active." severity error;
		
		wait until rising_edge(clk);
		wait for 1 ns;
		assert p_state = S_FETCH report "Second cycle (FETCH): Should be S_FETCH after S_MEMW, instead got " & sm_state'image(p_state) severity error;
		assert pc_load = '0' and rd_w_enable = '0' and mem_w_enable = '0' report "Second cycle (FETCH): No enable should be active at S_FETCH stage." severity error;
		
		-- one cycle with mem_write <= 1
		wait until falling_edge(clk);
		reg_write <= '0'; mem_write <= '1';
		
		wait until rising_edge(clk);
		wait for 1 ns;
		assert p_state = S_DECODE 										  report "Second cycle (DECODE): Should be S_DECODE stage, instead got " & sm_state'image(p_state) severity error;
		assert pc_load = '0' and rd_w_enable = '0' and mem_w_enable = '0' report "Second cycle (DECODE): No enable should be active at S_DECODE stage." severity error;
		
		wait until rising_edge(clk);
		wait for 1 ns;
		assert p_state = S_EXECUTE report "Second cycle (EXECUTE): Should be S_EXECUTE stage, instead got " & sm_state'image(p_state) severity error;
		assert mem_w_enable = '1'  report "Second cycle (EXECUTE): mem_w_enable unactive with mem_write active" severity error;
		
		wait until rising_edge(clk);
		wait for 1 ns;
		assert p_state = S_MEMW   report "Second cycle (MEMW): Should be S_MEMW stage, instead got " & sm_state'image(p_state) severity error;
		assert mem_w_enable = '0' report "Second cycle (MEMW): mem_w_enable active during S_MEMW stage." severity error;
		assert pc_load = '1' 	  report "Second cycle (MEMW): pc_load unactive." severity error;
		assert rd_w_enable = '0'  report "Second cycle (MEMW): rd_w_enable active with reg_write unactive." severity error;

		wait until rising_edge(clk);
		wait for 1 ns;
		assert p_state = S_FETCH report "Third cycle (FETCH): Should be S_FETCH after S_MEMW, instead got " & sm_state'image(p_state) severity error;
		
		-- reset in the middle 
		reg_write <= '1'; mem_write <= '1';
		wait until rising_edge(clk); wait for 1 ns;  -- S_DECODE
		wait until rising_edge(clk); wait for 1 ns;  -- S_EXEUTE
		reset <= '1';
		wait until rising_edge(clk); wait for 1 ns;
		assert p_state = S_FETCH  report "Third cycle (MEMW): reset active but didnt switch to FETCH, instead got " & sm_state'image(p_state) severity error;
		reset <= '0';
		
		report "tb_state_machine: all tests finished.";
		done <= true;
		wait;
	end process;	
		
end architecture;