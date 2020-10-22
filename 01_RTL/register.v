module Register #(
    parameter   DATA_W = 32,
    parameter   REG_N = 32,
)(
    input                       i_clk,
    input                       i_rst_n,
    input   [REG_N-1    : 0]    read_reg_0,
    input   [REG_N-1    : 0]    read_reg_1,
    input   [REG_N-1    : 0]    write_reg,
    input   [DATA_W-1   : 0]    write_data,
    input                       write_en,
    output  [DATA_W-1   : 0]    read_data_0,
    output  [DATA_W-1   : 0]    read_data_1,
);

reg [REG_N-1    : 0]    reg_file_r, reg_file_w;

assign read_data_0 = reg_file_r[read_reg_0];
assign read_data_1 = reg_file_r[read_reg_1];

integer k;

always@(*) begin
    for(k=0; k<REG_N; k=k+1)
        reg_file_w[k] = reg_file_r[k];

    if (write_en)
        reg_file_w[write_reg] = write_data;
end

always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        for(k=0; k<REG_N; k=k+1)
            reg_file_r[k] <= {(DATA_W){1'b0}};
        read_data_0 <= {(DATA_W){1'b0}};
        read_data_2 <= {(DATA_W){1'b0}};
    end
    else begin
        for(k=0; k<REG_N; k=k+1)
            reg_file_r[k] <= reg_file_w;
    end
end


endmodule