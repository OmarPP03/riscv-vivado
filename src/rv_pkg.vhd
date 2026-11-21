
library ieee;
use ieee.std_logic_1164.all;

package rv_pkg is
    type alu_op is(
        ALU_ADD, ALU_SUB,
        ALU_SLT,  -- Set Less Than 
        ALU_SLTU, -- Set Less Than Unsigned
        ALU_SLL,  -- Shift Left Logical
        ALU_SRL,  -- Shift Right Logical
        ALU_SRA,  -- Shift Right Arithemetic (keeps sign bit)
        ALU_AND, ALU_XOR, ALU_OR
    );
	
	type imm_selector is(
		IMM_I,  -- One source, one immediate
		IMM_S,  -- Store operations
		IMM_B,  -- Branch operations
		IMM_U,  -- LUI instructions: lui, auipc
		IMM_J   -- Jump operations: jal
	);

    type wb_sel is(
        WB_ALU, -- data sent to reg_file comes from ALU output
        WB_PC,  -- data sent to reg_file comes from rd (pc + 4)
        WB_MEM -- data sent to reg_file comes from memory
    );

    type op1_selector is(
        OP1_ZERO,  -- used by lui rd, imm (0 + imm)
        OP1_PC,    -- used by auipc rd, imm (PC + imm)
        OP1_RS1   -- every other operand
    );
end package rv_pkg;