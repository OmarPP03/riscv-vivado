library ieee;
use ieee.std_logic_1164.all;    
use ieee.numeric_std.all;  
use work.rv_pkg.all;


entity control_unit is
	
	port(
		op_code : in std_logic_vector(6 downto 0);  -- instr[6:0]
		funct3  : in std_logic_vector(2 downto 0);  -- instr[14:12]
		funct7  : in std_logic_vector(6 downto 0);  -- instr[31:25]
		
		-- Patterson and Hennessy standard
		reg_write  : out std_logic;  -- 0 = null, 1 = write data in reg_file
		op1_sel    : out op1_selector;
		op2_sel    : out std_logic;  -- 0 = second alu operand is from reg_file, 1 = second alu operand is from imm_gen
		mem_read   : out std_logic;  -- 0 = null, 1 = data pointed by the register is read
		mem_write  : out std_logic;  -- 0 = null, 1 = data pointed by the register is overwritten
		mem_to_reg : out wb_sel;

		-- ALU control
		alu_op     : out alu_op:
		imm_sel    : out imm_selector;

		-- Decide PC value based on branch, jal and jalr
		branch	   : out std_logic;
		jal		   : out std_logic;
		jalr	   : out std_logic;
	);
	
end entity control_unit;

-- 10 major OPCODES:
-- LUI   : 0110111
-- JAL   : 1101111
-- JALR  : 1100111
-- BRANCH: 1100011
-- LOAD  : 0000011
-- STORE : 0100011
-- OP_IMM: 0010011
-- OP	 : 0110011
-- AUIPC : 0010111
-- SYSTEM not considered as we have not access to an os

architecture behavioural of control_unit is
	begin
		process(all) begin
			case op_code is
				when "0110111" =>
				reg_write <= 1; imm_sel <= IMM_U; op1_sel <= OP1_ZERO; op2_sel <= 1; mem_write <= 0; mem_to_reg <= WB_ALU;
				-- and so on

