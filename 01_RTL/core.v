module core #(                             //Don't modify interface
	parameter ADDR_W = 32,
	parameter INST_W = 32,
	parameter DATA_W = 32
)(
	input                   i_clk,
	input                   i_rst_n,
	output [ ADDR_W-1 : 0 ] o_i_addr,
	input  [ INST_W-1 : 0 ] i_i_inst,
	output                  o_d_wen,
	output [ ADDR_W-1 : 0 ] o_d_addr,
	output [ DATA_W-1 : 0 ] o_d_wdata,
	input  [ DATA_W-1 : 0 ] i_d_rdata,
	output [        1 : 0 ] o_status,
	output                  o_status_valid,
);

// LW   000001	I
// SW   000010	I
// ADD  000011	R
// SUB  000100	R
// ADDI 000101	I
// OR   000110	R
// XOR  000111	R
// BEQ  001000	I
// BNE  001001	I
// EOF  001010	EOF

parameter INST_ADDR_W = 32;
parameter OP_W = 6;
parameter REG_ADDR_W = 5;
parameter IM_W = 16;
parameter REG_N = 32;

// ---------------------------------------------------------------------------
// Wires and Registers
// ---------------------------------------------------------------------------
// ---- Add your own wires and registers here if needed ---- //
wire	[OP_W-1			:	0]	op;
wire							i_type;
wire	[REG_ADDR_W-1	:	0]	s1, s2, s3;
wire 	[IM_W-1			:	0]	im;

reg		[INST_W-1		:	0]	pc, pc_add_four, pc_branch;
reg								stall_r, stall_w;

wire							write_reg_en;
wire	[DATA_W-1		:	0]	write_data, read_data_0, read_data_1;

wire	[DATA_W-1		:	0]	alu_result;
wire							over_flow;
wire							zero, branch;



// ---------------------------------------------------------------------------
// Continuous Assignment
// ---------------------------------------------------------------------------
// ---- Add your own wire data assignments here if needed ---- //
assign	op = i_i_inst[INST_W-1: INST_W - OP_W];
assign	i_type = op[3] | (~op[2] & (op[1] ^ op[0])) | (op[2] & ~op[1] & op[0]);

assign	s1 = i_type ? i_i_inst[INST_W - OP_W - REG_ADDR_W - 1: INST_W - OP_W - 2*REG_ADDR_W]
					: i_i_inst[INST_W - OP_W - 2*REG_ADDR_W - 1: INST_W - OP_W - 3*REG_ADDR_W];
assign	s2 = i_i_inst[INST_W - OP_W - 1: INST_W - OP_W - REG_ADDR_W];
assign	s3 = i_i_inst[INST_W - OP_W - REG_ADDR_W - 1: INST_W - OP_W - 2*REG_ADDR_W];

assign	im = i_i_inst[IM_W-1: 0];

assign	write_reg_en = op[2] | (op[1] & op[0]) | stall_r;
assign 	write_data = alu_result;


Register registers(i_clk, i_rst_n, s2, s3, s1, write_data, write_reg_en, read_data_0, read_data_1);
Alu alu(op, read_data_0, read_data_1, im, alu_result, zero, over_flow);

assign	branch = (op[3] & ~op[1]) & (zero ^ op[0]);

assign  pc_add_four = pc + {{(INST_W-3){1'b0}}, 3'd4};
assign	pc_branch	= pc_add_four + {{(INST_ADDR_W - IM_W){1'b0}}, im};

assign	o_i_addr	= branch ? pc_branch : pc_add_four;
assign	o_d_wen		= ~op[3] & ~op[2] & op[1] & op[0];
assign	o_d_addr	= alu_result;
assign	o_d_wdata	= write_data;		// !!!!!!!!!

inst_mem inst_mem(i_clk, i_rst_n, o_i_addr, i_i_inst);
data_mem data_mem(i_clk, i_rst_n, o_d_wen, o_d_addr, o_d_wdata, i_d_rdata);

// ---------------------------------------------------------------------------
// Combinational Blocks
// ---------------------------------------------------------------------------
// ---- Write your conbinational block design here ---- //



// ---------------------------------------------------------------------------
// Sequential Block
// ---------------------------------------------------------------------------
// ---- Write your sequential block design here ---- //



endmodule