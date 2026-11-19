library ieee;
use ieee.std_logic_1164.all;    
use ieee.numeric_std.all;       

entity register_file is

	port(
		data_wr                : in std_logic_vector(31 downto 0);  -- Data to write in rd
		rd_addr                : in std_logic_vector(4 downto 0);   -- Register to write 
		rs1_addr, rs2_addr     : in std_logic_vector(4 downto 0);   -- Registers to output on data1/data2 respectively
		clk, w_enable          : in std_logic; 					    -- No reset, vivado uses LUTRAM for registers. w_enable is asynchrounous
		data1, data2           : out std_logic_vector(31 downto 0)  -- The contents of the registers selected by rs1/rs2_addr
	);

end entity register_file;

architecture behavioural of register_file is
	-- Create array to store registers
	type reg_array is array(0 to 31) of std_logic_vector(31 downto 0);
	-- Create signal for the registers. Every element of the array is 0 for now
	signal regs : reg_array := (others => (others => '0'));
	begin
		-- Only sensible value 
		process(clk)
		begin
			if rising_edge(clk) then
				if w_enable = '1' then
					regs(to_integer(unsigned(rd_addr))) <= data_wr; -- Writing is always synchronous
				end if;
			end if;
		end process;
		-- Reading is combinational, no need to wait for the clock
		data1 <= (others => '0') when rs1_addr = "00000" else regs(to_integer(unsigned(rs1_addr)));
		data2 <= (others => '0') when rs2_addr = "00000" else regs(to_integer(unsigned(rs2_addr)));
end architecture;