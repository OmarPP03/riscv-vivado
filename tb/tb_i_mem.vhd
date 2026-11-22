library ieee;
use ieee.std_logic_1164.all;    
use ieee.numeric_std.all;  
use std.textio.all;

entity tb_instruction_memory is
end entity tb_instruction_memory;

architecture behavioural of tb_instruction_memory is

    signal addr  : std_logic_vector(9 downto 0);
    signal instr : std_logic_vector(31 downto 0);

begin 

    uut : entity work.instruction_memory(behavioural) generic map (MEM_FILE => "tb/test_imem.mem") port map (addr => addr, instr => instr);

    process begin

        -- Ready every word of the file 
        addr <= std_logic_vector(to_unsigned(0, 10));
        wait for 5 ns;
        assert instr = x"002081B3" report "Test failed: address " & to_hstring(addr) & " points to " & to_hstring(instr) severity error;
        addr <= std_logic_vector(to_unsigned(1, 10));
        wait for 5 ns;
        assert instr = x"402081B3" report "Test failed: address " & to_hstring(addr) & " points to " & to_hstring(instr) severity error;
        addr <= std_logic_vector(to_unsigned(2, 10));
        wait for 5 ns;
        assert instr = x"FFF00093" report "Test failed: address " & to_hstring(addr) & " points to " & to_hstring(instr) severity error;
        addr <= std_logic_vector(to_unsigned(3, 10));
        wait for 5 ns;
        assert instr = x"4040D093" report "Test failed: address " & to_hstring(addr) & " points to " & to_hstring(instr) severity error;
        addr <= std_logic_vector(to_unsigned(4, 10));
        wait for 5 ns;
        assert instr = x"0040D093" report "Test failed: address " & to_hstring(addr) & " points to " & to_hstring(instr) severity error;
        addr <= std_logic_vector(to_unsigned(5, 10));
        wait for 5 ns;
        assert instr = x"0050A113" report "Test failed: address " & to_hstring(addr) & " points to " & to_hstring(instr) severity error;
        addr <= std_logic_vector(to_unsigned(6, 10));
        wait for 5 ns;
        assert instr = x"0FF0F113" report "Test failed: address " & to_hstring(addr) & " points to " & to_hstring(instr) severity error;
        addr <= std_logic_vector(to_unsigned(7, 10));
        wait for 5 ns;
        assert instr = x"00812083" report "Test failed: address " & to_hstring(addr) & " points to " & to_hstring(instr) severity error;
        addr <= std_logic_vector(to_unsigned(8, 10));
        wait for 5 ns;
        assert instr = x"0020A423" report "Test failed: address " & to_hstring(addr) & " points to " & to_hstring(instr) severity error;
        addr <= std_logic_vector(to_unsigned(9, 10));
        wait for 5 ns;
        assert instr = x"00000463" report "Test failed: address " & to_hstring(addr) & " points to " & to_hstring(instr) severity error;
        addr <= std_logic_vector(to_unsigned(10, 10));
        wait for 5 ns;
        assert instr = x"001000EF" report "Test failed: address " & to_hstring(addr) & " points to " & to_hstring(instr) severity error;
        addr <= std_logic_vector(to_unsigned(11, 10));
        wait for 5 ns;
        assert instr = x"00008067" report "Test failed: address " & to_hstring(addr) & " points to " & to_hstring(instr) severity error;
        addr <= std_logic_vector(to_unsigned(12, 10));
        wait for 5 ns;
        assert instr = x"123452B7" report "Test failed: address " & to_hstring(addr) & " points to " & to_hstring(instr) severity error;
        addr <= std_logic_vector(to_unsigned(13, 10));
        wait for 5 ns;
        assert instr = x"12345297" report "Test failed: address " & to_hstring(addr) & " points to " & to_hstring(instr) severity error;
        addr <= std_logic_vector(to_unsigned(14, 10));
        wait for 5 ns;
        assert instr = x"00000073" report "Test failed: address " & to_hstring(addr) & " points to " & to_hstring(instr) severity error;
        addr <= std_logic_vector(to_unsigned(15, 10));
        wait for 5 ns;
        assert instr = x"00000013" report "Test failed: empty address should be NOP, got " & to_hstring(instr) severity error;
        report "tb_i_mem: tests finished.";
        wait;
    end process;
end architecture;
