`timescale 1us/1us

module Prod_test;

parameter	cycle = 3000.0;

logic         i_clk;
logic         i_rst;
logic         i_valid;
logic [255:0] i_N;
logic [255:0] i_m;	
logic [255:0] i_t;
logic [255:0] o_montgomeryalgorithm;
logic         o_ready;

initial i_clk = 0;
always #(cycle/2.0) i_clk = ~i_clk;

MontgomeryAlgorithm MA0(
	.i_clk(i_clk),
	.i_rst(i_rst),
	.i_valid(i_valid),
	.i_N(i_N),
	.i_m(i_m),	
	.i_t(i_t),
	.o_montgomeryalgorithm(o_montgomeryalgorithm),
	.o_ready(o_ready)
);

initial begin
	$fsdbDumpfile("Lab1_test.fsdb");
	$fsdbDumpvars(0, Prod_test, "+all");
end

initial begin	
	i_clk 	= 0;
	i_rst   = 0;
	i_valid	= 0;
	i_N = 256'd57896044618658097711785492504343953926634992332820282019728792003956564819949;
    i_m = 256'd9876645678941236164564897456 << 128;	
	i_t = 256'd6353702135648456789456312456 << 128;
 	

	@(negedge i_clk);
	@(negedge i_clk);
	@(negedge i_clk) i_rst = 1;
	@(negedge i_clk) i_rst = 0; 


	@(negedge i_clk);
	@(negedge i_clk);
	@(negedge i_clk);
	@(negedge i_clk) i_valid = 1;
	@(negedge i_clk) i_valid = 0;
	#(cycle*300);
	@(negedge i_clk) i_valid = 1;
	@(negedge i_clk) i_valid = 0;
	#(cycle*300);
	
	$finish;
end

endmodule
