library ieee;
use ieee.std_logic_1164.all;    -- std_logic, std_logic_vector
use ieee.numeric_std.all;       -- signed, unsigned
use work.rv_pkg.all;

entity alu is

    port(
        -- ALU needs r1 and r2 both in signed and unsigned form, so just declare as logic vector and keep conversion inside ALU.
        a  : in std_logic_vector(31 downto 0);
        b  : in std_logic_vector(31 downto 0);
        op_alu  : in alu_op;
        res : out std_logic_vector(31 downto 0)
    );

end entity alu;

architecture behavioural of alu is
    begin
        process(a, b, op_alu)
        variable shamt : natural range 0 to 31;
        begin
            shamt := to_integer(unsigned(b(4 downto 0))); -- RV32I uses the least 5 significant bits of the second shift operand.
            case op_alu is
                when ALU_ADD => res <= std_logic_vector(unsigned(a) + unsigned(b));
                when ALU_SUB => res <= std_logic_vector(unsigned(a) - unsigned(b));
                when ALU_SLT =>
                    if signed(a) < signed(b) then
                        res <= x"00000001";
                    else
                        res <= (others => '0');
                    end if;
                when ALU_SLTU =>
                    if unsigned(a) < unsigned(b) then
                        res  <= x"00000001";
                    else
                        res <= (others => '0');
                    end if;
                when ALU_SLL => res <= std_logic_vector(shift_left(unsigned(a), shamt));
                when ALU_SRL => res <= std_logic_vector(shift_right(unsigned(a), shamt));
                when ALU_SRA => res <= std_logic_vector(shift_right(signed(a), shamt));
                when ALU_AND => res <= a and b;
                when ALU_XOR => res <= a xor b;
                when ALU_OR  => res <= a or b;
            end case;
        end process;
end architecture;