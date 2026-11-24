library ieee;
use ieee.std_logic_1164.all;    
use ieee.numeric_std.all;       

entity comparator is

    port(

        rs1         : in std_logic_vector(31 downto 0);
        rs2         : in std_logic_vector(31 downto 0);
        funct3      : in std_logic_vector(2 downto 0);

        branch_cond : out std_logic -- take the branch or not

    );

end entity comparator;

architecture behavioural of comparator is
begin 

    process(all) begin

        branch_cond <= '0';
        case funct3 is
            when "000" => branch_cond <= '1' when rs1 = rs2 else '0';
            when "001" => branch_cond <= '1' when rs1 /= rs2 else '0';
            when "100" => branch_cond <= '1' when signed(rs1) < signed(rs2) else '0';
            when "101" => branch_cond <= '1' when signed(rs1) > signed(rs2) else '0';
            when "110" => branch_cond <= '1' when unsigned(rs1) < unsigned(rs2) else '0';
            when "111" => branch_cond <= '1' when unsigned(rs1) > unsigned(rs2) else '0';
            when others => null;
        end case;

    end process;
end architecture;
            