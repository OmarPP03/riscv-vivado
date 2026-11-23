library ieee;
use ieee.std_logic_1164.all;    
use ieee.numeric_std.all;  
use std.textio.all;

-- Without BRAM, async read only for now (until single cycle implemetation is finished)

entity instruction_memory is

    generic (MEM_FILE : string := "program.mem");
    port(
        addr  : in std_logic_vector(9 downto 0);
        instr : out std_logic_vector(31 downto 0);
        clk   : in std_logic
    );

end entity instruction_memory;

architecture behavioural of instruction_memory is

    type i_array is array(0 to 1023) of std_logic_vector(31 downto 0);

     impure function load_mem(file_name : string) return i_array is
        file f       : text open read_mode is file_name;
        variable l   : line;
        variable m   : i_array := (others => x"00000013");   -- nop (addi x0, x0, 0)
        variable i   : natural := 0;
    begin
        while not endfile(f) and i < 1024 loop
            readline(f, l);
            hread(l, m(i));      -- Reads one hex word from the line
            i := i + 1;
        end loop;
        return m;
    end function;

    constant mem : i_array := load_mem(MEM_FILE); -- ROM

    begin
        -- Concurrent assignment implementation: 
        -- instr <= mem(to_integer(unsigned(addr)));

        -- BRAM implementation: synchrounous read

        process(clk) begin
            if rising_edge(clk) then
                instr <= mem(to_integer(unsigned(addr)));
            end if;
        end process;

end architecture;

