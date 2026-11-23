library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_data_memory is
end entity tb_data_memory;

architecture behavioural of tb_data_memory is

    signal clk      : std_logic := '0';
    signal addr     : std_logic_vector(13 downto 0) := (others => '0');
    signal din      : std_logic_vector(31 downto 0) := (others => '0');
    signal funct3   : std_logic_vector(2 downto 0) := "010";
    signal dout     : std_logic_vector(31 downto 0);
    signal done     : boolean := false;

begin

    uut : entity work.data_memory(behavioural)
        port map (clk => clk, addr => addr, din => din, w_enable => w_enable,
                  funct3 => funct3, dout => dout);

    clk <= not clk after 5 ns when not done;

    process
    begin

        ------------------------------------------------------------------
        -- 1) Write words 0..1023: words[0] = 100 (x64), words[4] = 101 (x65), ...
        ------------------------------------------------------------------
        funct3 <= "010";                                   -- sw
        for i in 0 to 1023 loop
            wait until falling_edge(clk);
            w_enable <= '1';
            addr     <= std_logic_vector(to_unsigned(i * 4, 14));
            din      <= std_logic_vector(to_unsigned(i + 100, 32));
        end loop;
        wait until falling_edge(clk);                      -- last write happens before this edge
        w_enable <= '0';

        ------------------------------------------------------------------
        -- 2) Read them back (lw)
        ------------------------------------------------------------------
        for i in 0 to 1023 loop
            addr <= std_logic_vector(to_unsigned(i * 4, 14));
            wait until rising_edge(clk);                   -- synchronous read
            wait for 1 ns;
            assert dout = std_logic_vector(to_unsigned(i + 100, 32))
                report "lw address " & integer'image(i * 4) & " is " & to_hstring(dout) severity error;
        end loop;

        ------------------------------------------------------------------
        -- 3) lw ignores the 2 lowest address bits
        ------------------------------------------------------------------
        for off in 1 to 3 loop
            addr <= std_logic_vector(to_unsigned(off, 14));
            wait until rising_edge(clk);
            wait for 1 ns;
            assert dout = std_logic_vector(to_unsigned(100, 32))
                report "lw address " & integer'image(off) & " should read word 0, got " & to_hstring(dout) severity error;
        end loop;

        ------------------------------------------------------------------
        -- 4) No write when w_enable = '0'
        ------------------------------------------------------------------
        wait until falling_edge(clk);
        w_enable <= '0';
        addr     <= std_logic_vector(to_unsigned(8, 14));  -- word 2
        din      <= x"FFFFFFFF";
        wait until rising_edge(clk);
        wait for 1 ns;
        assert dout = std_logic_vector(to_unsigned(102, 32))
            report "write with w_enable=0: word at 8 is " & to_hstring(dout) severity error;

        ------------------------------------------------------------------
        -- 5) sw x"AABBCCDD" at address 0
        ------------------------------------------------------------------
        wait until falling_edge(clk);
        w_enable <= '1';
        funct3   <= "010";                                 -- sw
        addr     <= std_logic_vector(to_unsigned(0, 14));
        din      <= x"AABBCCDD";
        wait until falling_edge(clk);                      -- written at the rising edge in between
        w_enable <= '0';

        ------------------------------------------------------------------
        -- 6) lbu (funct3 = 100): zero extension
        ------------------------------------------------------------------
        funct3 <= "100";
        addr   <= std_logic_vector(to_unsigned(0, 14));
        wait until rising_edge(clk);
        wait for 1 ns;
        assert dout = x"000000DD" report "lbu 0: got " & to_hstring(dout) severity error;

        addr <= std_logic_vector(to_unsigned(1, 14));
        wait until rising_edge(clk);
        wait for 1 ns;
        assert dout = x"000000CC" report "lbu 1: got " & to_hstring(dout) severity error;

        addr <= std_logic_vector(to_unsigned(2, 14));
        wait until rising_edge(clk);
        wait for 1 ns;
        assert dout = x"000000BB" report "lbu 2: got " & to_hstring(dout) severity error;

        addr <= std_logic_vector(to_unsigned(3, 14));
        wait until rising_edge(clk);
        wait for 1 ns;
        assert dout = x"000000AA" report "lbu 3: got " & to_hstring(dout) severity error;

        ------------------------------------------------------------------
        -- 7) lb (funct3 = 000): sign extension (DD and AA are negative)
        ------------------------------------------------------------------
        funct3 <= "000";
        addr   <= std_logic_vector(to_unsigned(0, 14));
        wait until rising_edge(clk);
        wait for 1 ns;
        assert dout = x"FFFFFFDD" report "lb 0: got " & to_hstring(dout) severity error;

        addr <= std_logic_vector(to_unsigned(3, 14));
        wait until rising_edge(clk);
        wait for 1 ns;
        assert dout = x"FFFFFFAA" report "lb 3: got " & to_hstring(dout) severity error;

        ------------------------------------------------------------------
        -- 8) lhu (funct3 = 101) and lh (funct3 = 001)
        ------------------------------------------------------------------
        funct3 <= "101";
        addr   <= std_logic_vector(to_unsigned(0, 14));
        wait until rising_edge(clk);
        wait for 1 ns;
        assert dout = x"0000CCDD" report "lhu 0: got " & to_hstring(dout) severity error;

        addr <= std_logic_vector(to_unsigned(2, 14));
        wait until rising_edge(clk);
        wait for 1 ns;
        assert dout = x"0000AABB" report "lhu 2: got " & to_hstring(dout) severity error;

        funct3 <= "001";
        addr   <= std_logic_vector(to_unsigned(2, 14));
        wait until rising_edge(clk);
        wait for 1 ns;
        assert dout = x"FFFFAABB" report "lh 2: got " & to_hstring(dout) severity error;

        ------------------------------------------------------------------
        -- 9) sb x"11" at address 1 -> word becomes AABB11DD
        ------------------------------------------------------------------
        wait until falling_edge(clk);
        w_enable <= '1';
        funct3   <= "000";                                 -- sb
        addr     <= std_logic_vector(to_unsigned(1, 14));
        din      <= x"00000011";
        wait until falling_edge(clk);
        w_enable <= '0';

        funct3 <= "010";                                   -- lw
        addr   <= std_logic_vector(to_unsigned(0, 14));
        wait until rising_edge(clk);
        wait for 1 ns;
        assert dout = x"AABB11DD" report "after sb at 1: got " & to_hstring(dout) severity error;

        ------------------------------------------------------------------
        -- 10) sh x"2233" at address 2 -> word becomes 223311DD
        ------------------------------------------------------------------
        wait until falling_edge(clk);
        w_enable <= '1';
        funct3   <= "001";                                 -- sh
        addr     <= std_logic_vector(to_unsigned(2, 14));
        din      <= x"00002233";
        wait until falling_edge(clk);
        w_enable <= '0';

        funct3 <= "010";                                   -- lw
        addr   <= std_logic_vector(to_unsigned(0, 14));
        wait until rising_edge(clk);
        wait for 1 ns;
        assert dout = x"223311DD" report "after sh at 2: got " & to_hstring(dout) severity error;

        ------------------------------------------------------------------
        -- 11) sb with din = FFFFFF7F: only the low byte (7F) must be written
        ------------------------------------------------------------------
        wait until falling_edge(clk);
        w_enable <= '1';
        funct3   <= "000";                                 -- sb
        addr     <= std_logic_vector(to_unsigned(0, 14));
        din      <= x"FFFFFF7F";
        wait until falling_edge(clk);
        w_enable <= '0';

        funct3 <= "010";                                   -- lw
        addr   <= std_logic_vector(to_unsigned(0, 14));
        wait until rising_edge(clk);
        wait for 1 ns;
        assert dout = x"2233117F" report "after sb at 0: got " & to_hstring(dout) severity error;

        funct3 <= "000";                                   -- lb: 7F has top bit 0 -> positive
        wait until rising_edge(clk);
        wait for 1 ns;
        assert dout = x"0000007F" report "lb 0 positive: got " & to_hstring(dout) severity error;

        report "tb_d_mem: tests finished.";
        done <= true;
        wait;
    end process;

end architecture;