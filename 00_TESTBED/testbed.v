`timescale 1ns/100ps

module testbed;

	wire clk, rst_n;
	wire [ 31 : 0 ] imem_addr;
	wire [ 31 : 0 ] imem_inst;
	wire            dmem_wen;
	wire [ 31 : 0 ] dmem_addr;
	wire [ 31 : 0 ] dmem_wdata;
	wire [ 31 : 0 ] dmem_rdata;
	wire [  1 : 0 ] mips_status;
	wire            mips_status_valid;

	initial $readmemb (`Inst, u_inst_mem.mem_r); // Don't modify
	
	initial begin
		$fsdbDumpfile("cpu.fsdb");
	    $fsdbDumpvars(0, "+mda");
	end

	core u_core (
		.i_clk(clk),
		.i_rst_n(rst_n),
		.o_i_addr(imem_addr),
		.i_i_inst(imem_inst),
		.o_d_wen(dmem_wen),
		.o_d_addr(dmem_addr),
		.o_d_wdata(dmem_wdata),
		.i_d_rdata(dmem_rdata),
		.o_status(mips_status),
		.o_status_valid(mips_status_valid)
	);

	inst_mem  u_inst_mem (
		.i_clk(clk),
		.i_rst_n(rst_n),
		.i_addr(imem_addr),
		.o_inst(imem_inst)
	);

	data_mem  u_data_mem (
		.i_clk(clk),
		.i_rst_n(rst_n),
		.i_wen(dmem_wen),
		.i_addr(dmem_addr),
		.i_wdata(dmem_wdata),
		.o_rdata(dmem_rdata)
	);


	localparam
		Test_Idle	= 0,
		Test_Read	= 1,
		Test_Write	= 2,
		Test_Done	= 3;
	
	reg		[1	: 0]	golden_status[0:15];
	reg		[1	: 0]	test_cs, test_ns;
	reg 	[5	: 0]	test_idx_r;
	wire	[5	: 0]	test_idx_w;

	reg					all_correct;
	
	initial	$readmemb (`Status, golden_status);

	assign	test_idx_w	= (mips_status_valid & (test_idx_r != 16)) ? test_idx_r+1 : test_idx_r;
	
	always@(*) begin
		test_ns = test_cs;
		case(test_cs)
			Test_Idle	: test_ns = Test_Read;
			Test_Read	: test_ns = Test_Write;
			Test_Write	: begin
				if(mips_status_valid)
					test_ns = (test_idx_r == 15) ? Test_Done : Test_Read;
			end
			Test_Done	: begin
				if(all_correct)
					$display("PASS");
				$finish;
			end
		endcase
	end
	
	// checking
	always@(negedge clk) begin
		if((test_cs == Test_Write) & mips_status_valid) begin
			if(mips_status == golden_status[test_idx_r])
				$display("Test[%d]: Correct!", test_idx_r);
			else begin
				$display("Test[%d]: Error! | golden: %b, yours: %b", test_idx_r, golden_status[test_idx_r], mips_status);
				all_correct <= 1'b0;				
			end
		end
	end

	always@(negedge clk or negedge rst_n) begin
		if(~rst_n) begin
			test_cs <= Test_Idle;
			test_idx_r <= 0;
			all_correct <= 1'b1;
		end
		else begin
			test_cs <= test_ns;
			test_idx_r <= test_idx_w;
		end
	end

	Clkgen u_clkgen(
		.clk(clk),
		.rst_n(rst_n)
	);


endmodule


module Clkgen (
    output reg clk,
    output reg rst_n
);
    always # (`HCYCLE) clk = ~clk;

    initial begin
        clk = 1'b1;
        rst_n = 1; # (0.25 * `CYCLE);
        rst_n = 0; # (1 * `CYCLE);
        rst_n = 1; # (`MAX_CYCLE * `CYCLE);
		$display("-------------------------------------------");
        $display("Latency of your design is over 300 cycles!!");
        $display("-------------------------------------------");
        $finish;
    end
endmodule

