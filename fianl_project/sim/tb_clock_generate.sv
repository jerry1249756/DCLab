`timescale 1us/1us
module tb_clock_generate;

parameter	cycle = 100.0;
logic i_clk;
logic i_rst;
initial i_clk = 0;
always #(cycle/2.0) i_clk = ~i_clk;

logic o_25_clk;

Clock_Generate clock25_0(
    .i_fast_50M_clk(i_clk),
    .i_rst(i_rst),
    .o_slow_25M_clk(o_25_clk)
);

initial begin
	$fsdbDumpfile("tb_clock_generate.fsdb");
	$fsdbDumpvars(0, tb_clock_generate, "+all");
end

initial begin	
	#(cycle*20000);
	$finish;
end

initial begin	
	i_clk 	= 0;
	i_rst = 0;
	

	@(negedge i_clk);
	@(negedge i_clk);
	@(negedge i_clk) i_rst = 1;
	@(negedge i_clk) i_rst = 0; 
end

endmodule