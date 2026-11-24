library ieee;
use ieee.std_logic_1164.all;    
use ieee.numeric_std.all;       
use work.rv_pkg.all;

entity state_machine is
	
	port(
	
		clk       : in std_logic;
		reset     : in std_logic;
		reg_write : in std_logic;  -- Both signal from control unit
		mem_write : in std_logic;
		
		pc_load      : out std_logic;  -- Active when in mem/write state
		rd_w_enable  : out std_logic;  -- Active when in mem/write state and reg_write = '1'
		mem_w_enable : out std_logic;  -- Active when in execute stage and mem_write = '1'
		
		p_state : out sm_state  -- Output state for debugging
		
	);
end entity state_machine;

	
architecture behavioural of state_machine is
	
	signal state : sm_state := S_FETCH;
	
begin 

	process(clk) begin
		if rising_edge(clk) then
			if reset = '1' then
				state <= S_FETCH;
			else
				case state is
					when S_FETCH   => state <= S_DECODE;
					when S_DECODE  => state <= S_EXECUTE;
					when S_EXECUTE => state <= S_MEMW;
					when S_MEMW    => state <= S_FETCH;
					when others => null;
				end case;
			end if;
		end if;
	end process;
	
	pc_load      <= '1' when state = S_MEMW else '0';
	rd_w_enable  <= '1' when state = S_MEMW and reg_write = '1' else '0';
	mem_w_enable <= '1' when state = S_EXECUTE and mem_write = '1' else '0';
	p_state 	 <= state;
	
	
end architecture;
	