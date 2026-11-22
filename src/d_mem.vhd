library ieee;
use ieee.std_logic_1164.all;    
use ieee.numeric_std.all;  

entity data_memory is

    port(

        clk      : in std_logic;
        addr     : in std_logic_vector(11 downto 0); -- byte address
        din      : in std_logic_vector(31 downto 0); -- rs2 value
        w_enable : in std_logic; -- from control unit
        funct3   : in std_logic_vector(2 downto 0);
        
        dout : out std_logic_vector(31 downto 0)

    );

end entity data_memory;

architecture behavioural of data_memory is 

    type word_array is array (0 to 1023) of std_logic_vector(31 downto 0);
    signal words : word_array := (others => (others => '0'));
    signal idx   : integer range 0 to 1023;

    begin 

        idx <= to_integer(unsigned(addr(11 downto 2)));
        process(clk)
        begin
            if rising_edge(clk) then
                if w_enable = '1' then
                    words(idx) <= din;
                end if;
            end if;
        end process;

        dout <= words(idx);

end architecture;