`timescale 1us/1us

module SRAM_test;

logic i_clk;
logic write; //0: read, 1: write
logic [19:0] address;
wire [15:0] data;
logic [15:0] data_r;
logic [15:0] data_get;

parameter cycle = 100.0;

SRAM ram(
    .i_clk(i_clk),
    .i_write(write), //0: read, 1: write
    .i_address(address),
	.io_data(data)
);



assign data = (write == 1'b1) ? data_r : 16'dz;
assign data_get = (write == 1'b0) ? data : 16'd0;

always #(cycle/2.0) i_clk = ~i_clk;

initial begin
	$fsdbDumpfile("Lab3_SRAM_test.fsdb");
	$fsdbDumpvars(0, SRAM_test, "+all");
end

initial begin	
    i_clk = 0;
    write = 0;
    address = 20'd1; 
    data_r = 16'd4;
    @(negedge i_clk);
    write = 1;
    while (data_r <= 20'h15) begin
        @(negedge i_clk);
        data_r = data_r + 16'd1;
        address = address + 20'd10;
    end
    write = 0;
    address = 20'd21;
	@(negedge i_clk);
    address = 20'd101;
    @(negedge i_clk);
    address = 20'd81;
    @(negedge i_clk);
	$finish;
end

endmodule
