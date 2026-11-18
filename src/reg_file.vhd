library ieee;
use ieee.std_logic_1164.all;    
use ieee.numeric_std.all;       
use work.rv_pkg.all;

entity register_file is

	port(
		data_wr                : in std_logic_vector(31 downto 0);
		rd_addr                : in std_logic_vector(4 downto 0);
		rs1_addr, rs2_addr     : in std_logic_vector(4 downto 0);
		clk, w_enable          : in std_logic; -- No reset input, vivado already has LUTRAM
		data1, data2           : out std_logic_vector(31 downto 0);
	);
	
end entity register_file;

architecture behavioural of register_file is

		