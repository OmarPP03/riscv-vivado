library ieee;
use ieee.std_logic_1164.all;    
use ieee.numeric_std.all;       
use work.rv_pkg.all;

entity tb_alu is
end entity;

architecture behavioural of tb_alu is

    signal a       : std_logic_vector(31 downto 0);
    signal b       : std_logic_vector(31 downto 0);
    signal op_alu  : alu_op;
    signal res     : std_logic_vector(31 downto 0);

begin

    uut : entity work.alu(behavioural) port map (a => a, b => b, op_alu => op_alu, res => res);

    process begin
        a <= x"00000000"; b <= x"00000001"; op_alu <= ALU_ADD;
        wait for 5 ns;
        assert res = x"00000001" report "ALU_ADD fail (1 + 0 != 1)" severity error;
        a <= x"7FFFFFFF"; b <= x"00000001"; op_alu <= ALU_ADD;
        wait for 5 ns;
        assert res = x"80000000" report "ALU_ADD fail (overflow)" severity error;
        a <= x"00000001"; b <= x"00000001"; op_alu <= ALU_SUB;
        wait for 5 ns;
        assert res = x"00000000" report "ALU_SUB fail (1 - 1 != 0)" severity error;
        a <= x"00000005"; b <= x"00000007"; op_alu <= ALU_SUB;
        wait for 5 ns;
        assert res = x"FFFFFFFE" report "ALU_SUB fail (5 - 7 != -2)" severity error;
        a <= x"FFFFFFFF"; b <= x"00000001"; op_alu <= ALU_SLT;
        wait for 5 ns;
        assert res = x"00000001" report "ALU_SLT fail (-1 > 1)" severity error;
        a <= x"00000001"; b <= x"FFFFFFFF"; op_alu <= ALU_SLT;
        wait for 5 ns;
        assert res = x"00000000" report "ALU_SLT fail (1 < xFFFFFFFF)" severity error;
        a <= x"FFFFFFFF"; b <= x"00000000"; op_alu <= ALU_SLTU;
        wait for 5 ns;
        assert res = x"00000000" report "ALU_SLTU fail (xFFFFFFFF > 0)" severity error;
        a <= x"00000001"; b <= x"FFFFFFFF"; op_alu <= ALU_SLTU;
        wait for 5 ns;
        assert res = x"00000001" report "ALU_SLTU fail (1 > xFFFFFFFF)" severity error;
        a <= x"0FFFFFFF"; b <= x"00000004"; op_alu <= ALU_SLL;
        wait for 5 ns;
        assert res = x"FFFFFFF0" report "ALU_SLL fail (x0FFFFFFF sll 4 != xFFFFFFF0)" severity error;
        a <= x"00000001"; b <= x"0000001F"; op_alu <= ALU_SLL;
        wait for 5 ns;
        assert res = x"80000000" report "ALU_SLL fail (x00000001 sll x0000001F != x80000000)" severity error;
        a <= x"00000001"; b <= x"00000010"; op_alu <= ALU_SLL;
        wait for 5 ns;
        assert res = x"00010000" report "ALU_SLL fail (only the lowest 5 bits count)" severity error;
        a <= x"FFFFFFF0"; b <= x"00000004"; op_alu <= ALU_SRL;
        wait for 5 ns;
        assert res = x"0FFFFFFF" report "ALU_SRL fail (xFFFFFFF0 srl 4 != x0FFFFFFF)" severity error;
        a <= x"FFFFFFF0"; b <= x"00000004"; op_alu <= ALU_SRA;
        wait for 5 ns;
        assert res = x"FFFFFFFF" report "ALU_SRA fail (xFFFFFFF0 sra 4 != xFFFFFFFF)" severity error;
        a <= x"FFFFFFFF"; b <= x"FFFFFFFF"; op_alu <= ALU_AND;
        wait for 5 ns;
        assert res = x"FFFFFFFF" report "ALU_AND fail (xFFFFFFFF and xFFFFFFFF != xFFFFFFFF)" severity error;
        a <= x"FFFFFFFF"; b <= x"00000000"; op_alu <= ALU_AND;
        wait for 5 ns;
        assert res = x"00000000" report "ALU_AND fail (xFFFFFFFF and x00000000 != x00000000)" severity error;
        a <= x"01010101"; b <= x"01010101"; op_alu <= ALU_OR;
        wait for 5 ns;
        assert res = x"01010101" report "ALU_OR fail (x01010101 or x01010101 != x01010101)" severity error;
        a <= x"FFFFFFFF"; b <= x"00000000"; op_alu <= ALU_OR;
        wait for 5 ns;
        assert res = x"FFFFFFFF" report "ALU_OR fail (xFFFFFFFF or x00000000 != x00000000)" severity error;
        a <= x"F0F0F0F0"; b <= x"0F0F0F0F"; op_alu <= ALU_XOR;
        wait for 5 ns;
        assert res = x"FFFFFFFF" report "ALU_XOR fail (xF0F0F0F0 xor x0F0F0F0F != xFFFFFFFF)" severity error;
        a <= x"FF0F0F0F"; b <= x"0FF0F0F0"; op_alu <= ALU_XOR;
        wait for 5 ns;
        assert res = x"F0FFFFFF" report "ALU_XOR fail (xFF0F0F0F xor x0FF0F0F0 != xF0FFFFFF)" severity error;
        report "tb_alu: tests finished.";
        wait;
    end process;
end architecture;

