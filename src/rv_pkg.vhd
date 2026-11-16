
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
end package rv_pkg;