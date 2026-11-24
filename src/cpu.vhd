library ieee;
use ieee.std_logic_1164.all;    
use ieee.numeric_std.all; 
use work.rv_pkg.all;

entity cpu is
	
	generic (MEM_FILE : string := "program.mem");
	
	port(
	
		clk   : in std_logic;
		reset : in std_logic;
		
		dbg_pc : out std_logic_vector(31 downto 0);
		dbg_instr : out std_logic_vector(31 downto 0);
		dbg_state : out sm_state
	
	);

end entity cpu;


architecture behavioural of cpu is

	-- FETCH STATE wires
	-- Keep PC lenght 32 bits to avoid zero extension when its used as ALU operand (auipc, jal)
	
	signal pc      : std_logic_vector(31 downto 0) := (others => '0');  -- PC register, current PC 
	signal next_pc : std_logic_vector(31 downto 0);						-- PC + 4
	signal pc_out  : std_logic_vector(31 downto 0);						-- PC + 4 or jump target, calculated by jump detection unit
	signal instr   : std_logic_vector(31 downto 0);                     -- Instruction memory output
	
	
	-- DECODE STATE wires
	
	-- RV32I instruction fields
	signal funct3 : std_logic_vector(2 downto 0);
	signal funct7 : std_logic_vector(6 downto 0);
	signal opcode : std_logic_vector(6 downto 0);
	signal rs1    : std_logic_vector(4 downto 0);
	signal rs2    : std_logic_vector(4 downto 0);
	signal rd     : std_logic_vector(4 downto 0);
	
	-- Control unit outputs
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
	
	-- imm_gen and reg_file outputs
	signal immediate : std_logic_vector(31 downto 0);
	signal rs1_value : std_logic_vector(31 downto 0);
	signal rs2_value : std_logic_vector(31 downto 0);
	
	-- Registers at the end of the DECODE STATE
	signal imm_q : std_logic_vector(31 downto 0) := (others => '0');
	signal rs1_q : std_logic_vector(31 downto 0) := (others => '0');
	signal rs2_q : std_logic_vector(31 downto 0) := (others => '0');
	
	
	-- EXECUTE STATE wires
	
	-- Output of mux for operand selection before ALU
	signal alu_a : std_logic_vector(31 downto 0);
	signal alu_b : std_logic_vector(31 downto 0);
	
	-- ALU outputs and comparator output for branch condition
	signal alu_preresult : std_logic_vector(31 downto 0);
	signal branch_cond   : std_logic;
	
	-- Registers at the end of the EXECUTE STATE
	signal alu_res_q     : std_logic_vector(31 downto 0) := (others => '0');
	signal branch_cond_q : std_logic := '0';
	
	
	-- MEM/WRITE STATE wires
	
	-- d_mem output and rd_value to write in reg_file
	signal mem_out  : std_logic_vector(31 downto 0);
	signal rd_value : std_logic_vector(31 downto 0);
	
	
	-- STATE MACHINE wires
	
	signal state        : sm_state;
	signal pc_load      : std_logic;
	signal rd_w_enable  : std_logic;
	signal mem_w_enable : std_logic;
	

begin 

	-- Connect wires to port
	dbg_pc    <= pc;
	dbg_instr <= instr;
	dbg_state <= state;
	
	-- Initiate instances of every component
	
	ime : entity work.instruction_memory(behavioural) generic map (MEM_FILE => MEM_FILE)
		port map (
			addr  => pc(11 downto 2),
			instr => instr,
			clk   => clk
		);
		
	rg_file : entity work.register_file(behavioural)
		port map(
			data_wr  => rd_value,               
			rd_addr  => rd,           
			rs1_addr => rs1, 
			rs2_addr => rs2,  
			clk 	 => clk, 
			w_enable => rd_w_enable,         
			data1    => rs1_value, 
			data2	 => rs2_value	
		);
		
	ctr_unit : entity work.control_unit(behavioural)
		port map(
			op_code    => opcode,
			funct3     => funct3,
			funct7     => funct7,
			reg_write  => reg_write,
			op1_sel    => op1_sel,
			op2_sel    => op2_sel,
			mem_read   => mem_read,
			mem_write  => mem_write,
			mem_to_reg => mem_to_reg,
			op_alu     => op_alu,
			imm_sel    => imm_sel,
			branch	   => branch,
			jal		   => jal,
			jalr	   => jalr
		);
		
	im_gen : entity work.immediate_generator(behavioural)
		port map(
			instr     => instr,
			immediate => immediate,
			imm_sel   => imm_sel
		);
		
	comprtr : entity work.comparator(behavioural)
		port map(
			rs1         => rs1_q,
			rs2         => rs2_q,
			funct3      => funct3,
			branch_cond => branch_cond
		);
		
	alu_comp : entity work.alu(behavioural)
		port map(
			a  	   => alu_a,
			b      => alu_b,
			op_alu => op_alu,
			res    => alu_preresult
		);
		
	dme : entity work.data_memory(behavioural)
		port map(
			clk      => clk,
			addr     => alu_preresult(13 downto 0),
			din      => rs2_q,
			w_enable => mem_w_enable,
			funct3   => funct3,
			dout     => mem_out
		);
		
	st_machine : entity work.state_machine(behavioural)
		port map(
			clk      	 => clk,
			reset        => reset,
			reg_write    => reg_write,
			mem_write	 => mem_write,
			pc_load      => pc_load, 
			rd_w_enable  => rd_w_enable,
			mem_w_enable => mem_w_enable,
			p_state		 => state
		);
	
end architecture;