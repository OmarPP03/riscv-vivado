library ieee;
use ieee.std_logic_1164.all;    
use ieee.numeric_std.all;       

entity tb_reg_file is
end entity;

architecture behavioural of tb_reg_file is

    signal data_wr, data1, data2       : std_logic_vector(31 downto 0) := (others => '0');
	signal rd_addr, rs1_addr, rs2_addr : std_logic_vector(4 downto 0) := (others => '0');
	signal clk                         : std_logic := '0';
    signal w_enable                    : std_logic := '0';
    signal done                        : boolean := false; 

begin 

    utt : entity work.register_file(behavioural) port map (data_wr => data_wr, rd_addr => rd_addr, rs1_addr => rs1_addr, rs2_addr => rs2_addr,
                                                        clk => clk, w_enable => w_enable, data1 => data1, data2 => data2);

    process 
    begin
        clk <= not clk after 5 ns when not done;
        for i in 0 to 31 loop
            wait until falling_edge(clk);
            w_enable <= '1';
            rd_addr  <= std_logic_vector(to_unsigned(i, 5));
            data_wr  <= std_logic_vector(to_unsigned(i + 100, 32));
        end loop;
        wait until falling_edge(clk);
        

        report "tb_reg_file: tests finished";
        done <= true;
        wait;
    end process;
end architecture;
