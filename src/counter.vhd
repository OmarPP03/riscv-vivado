library ieee;
use ieee.std_logic_1164.all;    -- std_logic, std_logic_vector
use ieee.numeric_std.ALL;       -- signed, unsigned

-- <nome> : in/out std_logic_vector(<n_bits> downto 0) := <initial value>
-- Vector used to contain multiple logic signals togheter, representing
-- multi-bit data busses. Each bit can hold all 9 standard logic states, and
-- logical bitwise logical operators are built in.

-- signal <nome> : signed/unsigned(<n_bits> downto 0) := <inital value>
-- Bit vectors used for performing mathematical operations. Can also hold
-- characters instead of integers.

entity counter is 

    generic (size : integer := 3);
    port(
        res, clk, c_init, c_en : in std_logic;
        count : out std_logic_vector(2 downto 0);
        tc : out std_logic
    );

end entity counter;

architecture behavioral of counter is

    signal conteggio : unsigned(2 downto 0) := (others => '0');

begin

    -- Execute process when given signals (clk, res) change.
    process (clk, res) begin
        if res = '0' then
            conteggio <= (others => '0');
        elsif rising_edge(clk) then
            if c_init = '1' then
                conteggio <= (others => '0');
            elsif c_en = '1' then
                conteggio <= conteggio + 1;
            end if;
        end if;
    end process;

    tc <= '1' when conteggio = 7 else '0';
    count <= std_logic_vector(conteggio);

end architecture;