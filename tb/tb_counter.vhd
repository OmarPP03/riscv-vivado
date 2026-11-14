library ieee;
use ieee.std_logic_1164.all;    
use ieee.numeric_std.ALL;   

entity tb_counter is
    -- empty
end entity;

architecture behavioral of tb_counter is

    component counter is
        
        generic (size : integer := 3);
        port(
        res, clk, c_init, c_en : in std_logic;
        count : out std_logic_vector(2 downto 0);
        tc : out std_logic
    );

    end component;
    signal res, clk, c_init, c_en : std_logic;
    signal count : std_logic_vector(2 downto 0);
    signal tc : std_logic;

begin
    -- Instantiate the counter
    dut : counter port map (
        clk => clk, res => res,
        c_init => c_init, c_en => c_en, 
        count => count,
        tc => tc
    );

    process begin
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
    end process;

    process begin
        res <= '0';
        wait for 100 ns;
        res <= '1';
        wait;
    end process;

    process begin
        c_init <= '0';
        c_en <= '0';
        wait for 100 ns;
        wait for 30 ns;
        c_en <= '1';
        wait for 120 ns;
        c_en <= '0';
        wait for 20 ns;
        c_init <= '1';
        wait for 30 ns;
        c_init <= '0';
        c_en <= '1';
        wait for 50 ns;
        c_init <= '1';
        wait for 50 ns;
        c_init <= '0';
        wait for 100 ns;
        wait;
    end process;
end architecture;