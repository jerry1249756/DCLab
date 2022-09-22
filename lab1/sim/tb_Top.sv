`timescale 1us/1us

module Top_test;

parameter	cycle = 100.0;

logic 		i_clk;
logic 		i_rst_n, i_start, i_stop, i_save;
logic [3:0] o_random_out, o_saved;
logic [2:0] o_state;

initial i_clk = 0;
always #(cycle/2.0) i_clk = ~i_clk;

Top top0(
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.i_start(i_start),
	.i_stop(i_stop),
	.i_save(i_save),
	.o_random_out(o_random_out),
	.o_saved(o_saved),
	.o_state(o_state)
);


initial begin
	$fsdbDumpfile("Lab1_test.fsdb");
	$fsdbDumpvars(0, Top_test, "+all");
end

initial begin	
	i_clk 	= 0;
	i_rst_n = 1;
	i_start	= 0;
	i_stop = 0;

	@(negedge i_clk);
	@(negedge i_clk);
	@(negedge i_clk) i_rst_n = 0;
	@(negedge i_clk) i_rst_n = 1; 


	@(negedge i_clk);
	@(negedge i_clk);
	@(negedge i_clk);
	@(negedge i_clk) i_start = 1;
	@(negedge i_clk);
	@(negedge i_clk) i_start = 0;
	#(cycle*100);
	@(negedge i_clk) i_stop = 1;
	@(negedge i_clk) i_stop = 0;
	#(cycle*30);
	@(negedge i_clk) i_save = 1;
	@(negedge i_clk) i_save = 0;
	#(cycle*30);
	@(negedge i_clk) i_stop = 1;
	@(negedge i_clk) i_stop = 0;
	#(cycle*1450);
	@(negedge i_clk);
	@(negedge i_clk) i_start = 1;
	@(negedge i_clk) i_start = 0;
	@(negedge i_clk);
	#(cycle*20);
	@(negedge i_clk) i_save = 1;
	@(negedge i_clk) i_save = 0;
	@(negedge i_clk);
	@(negedge i_clk);
	@(negedge i_clk);
	@(negedge i_clk);
	@(negedge i_clk);
	@(negedge i_clk) i_start = 1;
	@(negedge i_clk);
	@(negedge i_clk) i_start = 0;
	#(cycle*300);
	@(negedge i_clk) i_stop = 1;
	@(negedge i_clk) i_stop = 0;
	#(cycle*30);
	@(negedge i_clk) i_save = 1;
	@(negedge i_clk) i_save = 0;
	#(cycle*30);
	@(negedge i_clk) i_stop = 1;
	@(negedge i_clk) i_stop = 0;
	#(cycle*650);
	@(negedge i_clk) i_save = 1;
	@(negedge i_clk) i_save = 0;
	#(cycle*600);
	@(negedge i_clk);
	@(negedge i_clk) i_start = 1;
	@(negedge i_clk) i_start = 0;
	@(negedge i_clk);
	#(cycle*20);
	@(negedge i_clk) i_save = 1;
	@(negedge i_clk) i_save = 0;
	@(negedge i_clk);
	@(negedge i_clk);
	$finish;
end

endmodule
