
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
end package rv_pkg;