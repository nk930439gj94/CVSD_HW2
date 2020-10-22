module pc #(
    parameter ADDR_W = 32,
    parameter INST_W = 32,
)(
    input                       i_clk,
    input                       i_rst_n,
    input   [ADDR_W-1   : 0]    i_pc,
    input   [ADDR_W-1   : 0]    i_addr,
    input                       i_branch,
    input                       i_stall,
    output   [ADDR_W-1   : 0]    o_next_pc,
)

wire pc_add_four;


assign  pc_add_four = i_pc + {{(ADDR_W-3){1'b0}}, 3'd4};


endmodule