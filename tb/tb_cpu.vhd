library ieee;
use ieee.std_logic_1164.all;    
use ieee.numeric_std.all; 
use work.rv_pkg.all;

entity tb_cpu is
end entity tb_cpu;

architecture behavioural of tb_cpu is

    signal clk       : std_logic := '0';
    signal reset     : std_logic := '1'; -- start in FETCH
    signal dbg_pc    : std_logic_vector(31 downto 0);
    signal dbg_instr : std_logic_vector(31 downto 0);
    signal dbg_state : sm_state;
    signal done      : boolean := false;

begin

    utt : entity work.cpu(behavioural) generic map (MEM_FILE => "tb/simple_sum.mem") port map (clk => clk, reset => reset, dbg_pc => dbg_pc, 
                                                 dbg_instr => dbg_instr, dbg_state => dbg_state);

    clk <= not clk after 5 ns when not done;

    process begin

        wait until falling_edge(clk);
        reset <= '0';
        wait for 2 us;  -- 37 instructions x 4 cycles x 10 ns => 2 us
        assert dbg_instr = x"0000006F" report "Did not reach the end of the cycle: PC = " & to_hstring(dbg_instr) severity error;
        report "tb_cpu: simulation finished.";
        done <= true;
        wait;
    end process;
end architecture;