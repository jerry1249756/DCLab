`timescale 1us/1us
`define NUM_PARALLEL  6

module paraSRAM_test;

logic i_clk;

logic [12:0]  i_write_address [`NUM_PARALLEL-1:0];
logic [23:0]  i_write_data    [`NUM_PARALLEL-1:0];
logic [12:0]  i_read_address  [`NUM_PARALLEL-1:0];
logic [23:0] o_read_data     [`NUM_PARALLEL-1:0];

parameter cycle = 100.0;

paraSRAM ram(
    .i_clk(i_clk),
    .i_write_address(i_write_address),
	.i_write_data(i_write_data),
	.i_read_address(i_read_address),
	.o_read_data(o_read_data)
);


always #(cycle/2.0) i_clk = ~i_clk;

initial begin
	$fsdbDumpfile("final_parallel_SRAM_test.fsdb");
	$fsdbDumpvars(0, paraSRAM_test, "+all");
end

initial begin	
    i_clk = 0;
    i_write_address[0]=13'd41;
    i_write_data[0]=24'd50;
    i_write_address[1]=13'd56;
    i_write_data[1]=24'd100;
    i_write_address[2]=13'd0;
    i_write_data[2]=24'd0;
    i_write_address[3]=13'd10;
    i_write_data[3]=24'd1000;
    i_read_address[0]=13'd1;
    i_read_address[1]=13'd2;
    i_read_address[2]=13'd3;
    i_read_address[3]=13'd5;
    @(negedge i_clk);
    i_read_address[0]=13'd1;
    i_read_address[1]=13'd41;
    i_read_address[2]=13'd10;
    i_read_address[3]=13'd5;
     i_write_data[0]=24'd40;
	@(negedge i_clk);
	@(negedge i_clk);
	@(negedge i_clk); 
	$finish;
end

endmodule
