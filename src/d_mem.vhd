library ieee;
use ieee.std_logic_1164.all;    
use ieee.numeric_std.all;  

entity data_memory is

    port(

        clk      : in std_logic;
        addr     : in std_logic_vector(13 downto 0); -- byte address
        din      : in std_logic_vector(31 downto 0); -- rs2 value
        w_enable : in std_logic;                     -- from state machine
        funct3   : in std_logic_vector(2 downto 0);
        
        dout : out std_logic_vector(31 downto 0)

    );

end entity data_memory;

architecture behavioural of data_memory is 

    type word_array is array (0 to 4095) of std_logic_vector(31 downto 0);
    signal words : word_array := (others => (others => '0'));

    signal idx      : integer range 0 to 4095;
    signal offset   : std_logic_vector(1 downto 0);
    signal offset_q : std_logic_vector(1 downto 0) := "00";
    signal word     : std_logic_vector(31 downto 0) := (others => '0');

    begin 

        idx <= to_integer(unsigned(addr(13 downto 2)));
        offset <= addr(1 downto 0);

        -- RISCV memory is byte addressed = every address points to 1 byte, a word is 4
        -- We have 4096 = 2^12 addresses => 12 bits needed 

        -- store
        process(clk) begin
            if rising_edge(clk) then
                if w_enable = '1' then

                    -- sw (32 bit) => funct3 = 010
                    -- sh (16 bit) => funct3 = 001 => offset: 00 => stored in word from 0 to 15, 10 => stored in word from 16 to 31
                    -- sb (8 bit)  => funct3 = 000 => offset: 00 => byte 0, 01 => byte 1 in word, 10 => byte 2 in word, 11 => byte 3 in word 

                    case funct3 is
                        when "000" =>
                        case offset is
                            when "00" => words(idx)(7 downto 0)   <= din(7 downto 0);
                            when "01" => words(idx)(15 downto 8)  <= din(7 downto 0);
                            when "10" => words(idx)(23 downto 16) <= din(7 downto 0);
                            when others => words(idx)(31 downto 24) <= din(7 downto 0);
                        end case; 
                        when "001" => 
                        if offset(1) = '0' then
                            words(idx)(15 downto 0)  <= din(15 downto 0);
                        else 
                            words(idx)(31 downto 16)  <= din(15 downto 0);
                        end if;
                        when "010" => words(idx) <= din;
                        when others => null;
                    end case;
                end if;
                word <= words(idx);  -- synch read
                offset_q <= offset;  -- remember which byte of the word was requested
            end if;
        end process;


        -- load
        process(all)

        variable byte : std_logic_vector(7 downto 0);
        variable half : std_logic_vector(15 downto 0);

        -- Little endian
        -- lw (32 bit)  => funct3 = 010      => alligned access = offset is always 00 (divisible by 4)
        -- lh/u (16bit) => funct3 = 001/101  => offset is always 00 or 10 (divisible by 2)
        -- lb/u (8bit)  => funct3 = 000/100  => offset can be 00, 01, 10, 11 (divisible by 1)

        begin 
            case offset_q is
                when "00" => byte := word(7 downto 0); 
                when "01" => byte := word(15 downto 8);
                when "10" => byte := word(23 downto 16); 
                when others => byte := word(31 downto 24);
            end case;

            if offset_q(1) = '0' then
                half := word(15 downto 0);
            else 
                half := word(31 downto 16);
            end if;

            case funct3 is
                when "000"  => dout <= (31 downto 8  => byte(7)) & byte;
                when "001"  => dout <= (31 downto 16 => half(15)) & half;
                when "100"  => dout <= (31 downto 8 => '0') & byte;
                when "101"  => dout <= (31 downto 16 => '0') & half;
                when others => dout <= word;
            end case;
        end process;

end architecture;