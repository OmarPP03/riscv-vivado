library ieee;
use ieee.std_logic_1164.all;    
use ieee.numeric_std.all;  
use work.rv_pkg.all;

-- Without BRAM, async read only for now (until single cycle implemetation is finished)

entity instruction_memory is

    port(
        addr  : in std_logic_vector(9 downto 0);
        instr : out std_logic_vector(31 downto 0);
    );

end entity instruction_memory;

architecture behavioural of instruction_memory is

    type i_array is array(0 to 31) of std_logic_vector(31 downto 0);

    begin
        process(addr) begin

            -- Insert addresses from a file? Then read async
    
        end process;
end architecture;

