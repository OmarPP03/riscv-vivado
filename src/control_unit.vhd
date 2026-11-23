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
		op_alu     : out alu_op;
		imm_sel    : out imm_selector;

		-- Decide PC value based on branch, jal and jalr
		branch	   : out std_logic;
		jal		   : out std_logic;
		jalr	   : out std_logic
	);
	
end entity control_unit;

-- 10 major OPCODES (SYSTEM not considered as we have not access to an os):

architecture behavioural of control_unit is
	begin
		process(all) begin
			-- Default values 
			reg_write <= '0'; op1_sel <= OP1_RS1; op2_sel <= '0'; mem_read <= '0'; mem_write <= '0'; mem_to_reg <= WB_ALU; op_alu <= ALU_ADD;
			imm_sel <= IMM_I; branch <= '0'; jal <= '0'; jalr <= '0';
			case op_code is
				when "0110111" => -- LUI
				reg_write <= '1'; imm_sel <= IMM_U; op1_sel <= OP1_ZERO; op2_sel <= '1';
				when "1101111" => -- JAL
				reg_write <= '1'; imm_sel <= IMM_J; op1_sel <= OP1_PC; op2_sel <= '1'; mem_to_reg <= WB_PC; jal <= '1';
				when "1100111" => -- JALR
				reg_write <= '1'; op2_sel <= '1'; mem_to_reg <= WB_PC; jalr <= '1';
				when "1100011" => -- BRANCH
				imm_sel <= IMM_B; op1_sel <= OP1_PC; op2_sel <= '1'; branch <= '1';  
				when "0000011" => -- LOAD
				reg_write <= '1'; op2_sel <= '1'; mem_to_reg <= WB_MEM; mem_read <= '1';
				when "0100011" => -- STORE
				imm_sel <= IMM_S; op2_sel <= '1'; mem_write <= '1';
				when "0010011" => -- I-type
				reg_write <= '1'; op2_sel <= '1';
				case funct3 is
					when "001" => op_alu <= ALU_SLL;
					when "010" => op_alu <= ALU_SLT;
					when "011" => op_alu <= ALU_SLTU;
					when "100" => op_alu <= ALU_XOR;
					when "101" => op_alu <= ALU_SRL when funct7(5) = '0' else ALU_SRA;
					when "110" => op_alu <= ALU_OR;
					when "111" => op_alu <= ALU_AND;
					when others => null;
					end case;
				when "0110011" => -- R-type
				reg_write <= '1'; 
				case funct3 is
					when "000" => op_alu <= ALU_ADD when funct7(5) = '0' else ALU_SUB;
					when "001" => op_alu <= ALU_SLL;
					when "010" => op_alu <= ALU_SLT;
					when "011" => op_alu <= ALU_SLTU;
					when "100" => op_alu <= ALU_XOR;
					when "101" => op_alu <= ALU_SRL when funct7(5) = '0' else ALU_SRA;
					when "110" => op_alu <= ALU_OR;
					when "111" => op_alu <= ALU_AND;
					when others => null;
					end case;
				when "0010111" => -- AUIPC
				reg_write <= '1'; imm_sel <= IMM_U; op1_sel <= OP1_PC; op2_sel <= '1';
				when others => null;
			end case;
		end process;
end architecture;
