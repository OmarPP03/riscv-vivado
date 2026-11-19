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

	-- Assert clock
	clk <= not clk after 5 ns when not done; 
	
    process 
    begin
		
		-- Write during falling_edge to get stable values during rising_edge and not intefere with the register file
        for i in 0 to 31 loop
            wait until falling_edge(clk);
			-- regs[rd_addr] <= data_wr
            w_enable <= '1';
            rd_addr  <= std_logic_vector(to_unsigned(i, 5));
            data_wr  <= std_logic_vector(to_unsigned(i + 100, 32));
        end loop;
		
		-- Check for stored values: we should have regs[00001] = x00000065 (101), regs[00002] = x00000066 (102), ...
        wait until falling_edge(clk);
		w_enable <= '0';
		for i in 1 to 31 loop  -- Start from r1, r0 is always zero
			rs1_addr <= std_logic_vector(to_unsigned(i, 5));
			rs2_addr <= std_logic_vector(to_unsigned(32 - i, 5)); -- check if data2 listens to rs1_addr
			wait for 1 ns;
			assert data1 = std_logic_vector(to_unsigned(i + 100, 32)) report "data1, register " & integer'image(i) & " is " & to_hstring(data1) severity error;
			assert data2 = std_logic_vector(to_unsigned(i + 100, 32)) report "data2, register " & integer'image(i) & " is " & to_hstring(data2) severity error;
		end loop;
		
		-- Zero check
		rs1_addr <= "00000";
		rs2_addr <= "00000";
		wait for 1 ns;
		assert data1 = x"00000000" report "x0 is " & to_hstring(data1) severity error;
		assert data2 = x"00000000" report "x0 is " & to_hstring(data2) severity error;
		
		-- Write check
		wait until falling_edge(clk);
		w_enable <= '0';
		rd_addr <= "00101";  -- r5/t0
		data_wr <= x"FFFFFFFF";
		wait until rising_edge(clk);
		wait for 1 ns;
		rs1_addr <= "00101";
		wait for 1 ns;
		assert data1 = std_logic_vector(to_unsigned(105, 32)) report "write with w_enable=0. r5 is " & to_hstring(data1) severity error;
	
        report "tb_reg_file: tests finished";
        done <= true;
        wait;
    end process;
end architecture;
