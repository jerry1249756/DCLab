`timescale 1us/1us

module Prod_test;

parameter	cycle = 100.0;

logic         i_clk;
logic         i_rst;
logic         i_valid;
logic [255:0] i_N;
logic [256:0] i_a;	
logic [255:0] i_b;
logic [8:0]   i_k;
logic [255:0] o_moduloproduct;
logic         o_ready;

initial i_clk = 0;
always #(cycle/2.0) i_clk = ~i_clk;

ModuloProduct MP0(
	.i_clk(i_clk),
	.i_rst(i_rst),
	.i_valid(i_valid),
	.i_N(i_N),
	.i_a(i_a),	
	.i_b(i_b),
	.i_k(i_k),
	.o_moduloproduct(o_moduloproduct),
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
	i_N = 256'd91461769394684063230410546004684083346491234956006074818403671954991458613297;
    i_a = 257'd115792089237316195423570985008687907853269984665640564039457584007913129639936;	
	i_b = 256'd89880192937653710598380335437431847203866094229526865542213091600506423557627;
 	i_k = 9'd257;  //# of bits of a

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

	$finish;
end

endmodule
