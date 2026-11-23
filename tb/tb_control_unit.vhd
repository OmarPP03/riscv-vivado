library ieee;
use ieee.std_logic_1164.all;    
use ieee.numeric_std.all;       
use work.rv_pkg.all;

entity tb_control_unit is
end entity tb_control_unit;

architecture behavioural of tb_control_unit is
    signal op_code : std_logic_vector(6 downto 0);  -- instr[6:0]
    signal funct3  : std_logic_vector(2 downto 0);  -- instr[14:12]
    signal funct7  : std_logic_vector(6 downto 0);  -- instr[31:25]
    
    signal reg_write  : std_logic;  
    signal op1_sel    : op1_selector;
    signal op2_sel    : std_logic;  
    signal mem_read   : std_logic;  
    signal mem_write  : std_logic;  
    signal mem_to_reg : wb_sel;
    signal op_alu     : alu_op;
    signal imm_sel    : imm_selector;
    signal branch	  : std_logic;
    signal jal		  : std_logic;
    signal jalr	      : std_logic;

    signal instr : std_logic_vector(31 downto 0); -- Instruction is the tb input

begin
    
    uut : entity work.control_unit(behavioural) port map (op_code => op_code, funct3 => funct3, funct7 => funct7, 
                                                          reg_write => reg_write, op1_sel => op1_sel, op2_sel => op2_sel,
                                                          mem_read => mem_read, mem_write => mem_write, mem_to_reg => mem_to_reg,
                                                          op_alu => op_alu, imm_sel => imm_sel, branch => branch, jal => jal, jalr => jalr);

    op_code <= instr(6 downto 0);
    funct3 <= instr(14 downto 12);
    funct7 <= instr(31 downto 25);

    process begin

        instr <= x"002081B3";    -- add x3, x1, x2
        wait for 5 ns;
        assert reg_write = '1'     report "add: reg_write = "  & std_logic'image(reg_write)    severity error;
        assert op1_sel = OP1_RS1   report "add: op1_sel = "    & op1_selector'image(op1_sel)   severity error;
        assert op2_sel = '0'       report "add: op2_sel = "    & std_logic'image(op2_sel)      severity error;
        assert op_alu = ALU_ADD    report "add: op_alu = "     & alu_op'image(op_alu)          severity error;
        assert mem_to_reg = WB_ALU report "add: mem_to_reg = " & wb_sel'image(mem_to_reg)      severity error;
        assert mem_write = '0'     report "add: mem_write = "  & std_logic'image(mem_write)    severity error;

        instr <= x"402081B3";    -- sub x3, x1, x2
        wait for 5 ns;
        assert op_alu = ALU_SUB    report "sub: op_alu = "     & alu_op'image(op_alu)          severity error;

        instr <= x"FFF00093";    -- addi x1, x0, -1  (bit 30 = 1, but it must be ADD)
        wait for 5 ns;
        assert reg_write = '1'     report "addi: reg_write = " & std_logic'image(reg_write)    severity error;
        assert op2_sel = '1'       report "addi: op2_sel = "   & std_logic'image(op2_sel)      severity error;
        assert imm_sel = IMM_I     report "addi: imm_sel = "   & imm_selector'image(imm_sel)   severity error;
        assert op_alu = ALU_ADD    report "addi: op_alu = "    & alu_op'image(op_alu)          severity error;

        instr <= x"4040D093";    -- srai x1, x1, 4
        wait for 5 ns;
        assert op_alu = ALU_SRA    report "srai: op_alu = "    & alu_op'image(op_alu)          severity error;

        instr <= x"0040D093";    -- srli x1, x1, 4
        wait for 5 ns;
        assert op_alu = ALU_SRL    report "srli: op_alu = "    & alu_op'image(op_alu)          severity error;

        instr <= x"0050A113";    -- slti x2, x1, 5
        wait for 5 ns;
        assert op_alu = ALU_SLT    report "slti: op_alu = "    & alu_op'image(op_alu)          severity error;

        instr <= x"0FF0F113";    -- andi x2, x1, 0xFF
        wait for 5 ns;
        assert op_alu = ALU_AND    report "andi: op_alu = "    & alu_op'image(op_alu)          severity error;

        instr <= x"00812083";    -- lw x1, 8(x2)
        wait for 5 ns;
        assert reg_write = '1'     report "lw: reg_write = "   & std_logic'image(reg_write)    severity error;
        assert mem_read = '1'      report "lw: mem_read = "    & std_logic'image(mem_read)     severity error;
        assert mem_to_reg = WB_MEM report "lw: mem_to_reg = "  & wb_sel'image(mem_to_reg)      severity error;
        assert op2_sel = '1'       report "lw: op2_sel = "     & std_logic'image(op2_sel)      severity error;
        assert imm_sel = IMM_I     report "lw: imm_sel = "     & imm_selector'image(imm_sel)   severity error;
        assert op_alu = ALU_ADD    report "lw: op_alu = "      & alu_op'image(op_alu)          severity error;

        instr <= x"0020A423";    -- sw x2, 8(x1)
        wait for 5 ns;
        assert reg_write = '0'     report "sw: reg_write = "   & std_logic'image(reg_write)    severity error;
        assert mem_write = '1'     report "sw: mem_write = "   & std_logic'image(mem_write)    severity error;
        assert op2_sel = '1'       report "sw: op2_sel = "     & std_logic'image(op2_sel)      severity error;
        assert imm_sel = IMM_S     report "sw: imm_sel = "     & imm_selector'image(imm_sel)   severity error;
        assert op_alu = ALU_ADD    report "sw: op_alu = "      & alu_op'image(op_alu)          severity error;

        instr <= x"00000463";    -- beq x0, x0, 8
        wait for 5 ns;
        assert reg_write = '0'     report "beq: reg_write = "  & std_logic'image(reg_write)    severity error;
        assert branch = '1'        report "beq: branch = "     & std_logic'image(branch)       severity error;
        assert imm_sel = IMM_B     report "beq: imm_sel = "    & imm_selector'image(imm_sel)   severity error;
        assert mem_write = '0'     report "beq: mem_write = "  & std_logic'image(mem_write)    severity error;
        assert op1_sel = OP1_PC report "beq: op1_sel = " & op1_selector'image(op1_sel) severity error;
        assert op2_sel = '1'    report "beq: op2_sel = " & std_logic'image(op2_sel)    severity error;

        instr <= x"001000EF";    -- jal x1, 2048
        wait for 5 ns;
        assert reg_write = '1'     report "jal: reg_write = "  & std_logic'image(reg_write)    severity error;
        assert jal = '1'           report "jal: jal = "        & std_logic'image(jal)          severity error;
        assert branch = '0'        report "jal: branch = "     & std_logic'image(branch)       severity error;
        assert imm_sel = IMM_J     report "jal: imm_sel = "    & imm_selector'image(imm_sel)   severity error;
        assert mem_to_reg = WB_PC  report "jal: mem_to_reg = " & wb_sel'image(mem_to_reg)      severity error;
        assert op1_sel = OP1_PC report "beq: op1_sel = " & op1_selector'image(op1_sel) severity error;
        assert op2_sel = '1'    report "beq: op2_sel = " & std_logic'image(op2_sel)    severity error;

        instr <= x"00008067";    -- jalr x0, 0(x1)
        wait for 5 ns;
        assert jalr = '1'          report "jalr: jalr = "      & std_logic'image(jalr)         severity error;
        assert jal = '0'           report "jalr: jal = "       & std_logic'image(jal)          severity error;
        assert op1_sel = OP1_RS1   report "jalr: op1_sel = "   & op1_selector'image(op1_sel)   severity error;
        assert op2_sel = '1'       report "jalr: op2_sel = "   & std_logic'image(op2_sel)      severity error;
        assert imm_sel = IMM_I     report "jalr: imm_sel = "   & imm_selector'image(imm_sel)   severity error;
        assert mem_to_reg = WB_PC  report "jalr: mem_to_reg = "& wb_sel'image(mem_to_reg)      severity error;

        instr <= x"123452B7";    -- lui x5, 0x12345
        wait for 5 ns;
        assert reg_write = '1'     report "lui: reg_write = "  & std_logic'image(reg_write)    severity error;
        assert op1_sel = OP1_ZERO  report "lui: op1_sel = "    & op1_selector'image(op1_sel)   severity error;
        assert op2_sel = '1'       report "lui: op2_sel = "    & std_logic'image(op2_sel)      severity error;
        assert imm_sel = IMM_U     report "lui: imm_sel = "    & imm_selector'image(imm_sel)   severity error;
        assert op_alu = ALU_ADD    report "lui: op_alu = "     & alu_op'image(op_alu)          severity error;

        instr <= x"12345297";    -- auipc x5, 0x12345
        wait for 5 ns;
        assert op1_sel = OP1_PC    report "auipc: op1_sel = "  & op1_selector'image(op1_sel)   severity error;
        assert imm_sel = IMM_U     report "auipc: imm_sel = "  & imm_selector'image(imm_sel)   severity error;
        
        instr <= x"00000073";    -- ecall
        wait for 5 ns;
        assert reg_write = '0'     report "ecall: reg_write = "& std_logic'image(reg_write)    severity error;
        assert mem_write = '0'     report "ecall: mem_write = "& std_logic'image(mem_write)    severity error;
        assert branch = '0' and jal = '0' and jalr = '0' report "ecall: a jump signal is active" severity error;
                                                       
        report "tb_control_unit: tests finished.";
        wait;
    end process;
end architecture;