`timescale 1us/1us

module I2C_test;

parameter	cycle = 100.0;

logic  i_rst_n;
logic  i_clk;
logic  i_start;
logic o_finished;
logic o_sclk;
logic o_sdat;
logic o_oen; 

initial i_clk = 0;
always #(cycle/2.0) i_clk = ~i_clk;

I2cInitializer init0(
	.i_rst_n(i_rst_n),
	.i_clk(i_clk),
	.i_start(i_start),
	.o_finished(o_finished),
	.o_sclk(o_sclk),
	.o_sdat(o_sdat),
	.o_oen(o_oen) // you are outputing (you are not outputing only when you are "ack"ing.)
);

initial begin
	$fsdbDumpfile("Lab3_I2C_test.fsdb");
	$fsdbDumpvars(0, I2C_test, "+all");
end

initial begin	
	i_clk 	= 0;
	i_rst_n = 1;
	i_start	= 0;

	@(negedge i_clk);
	@(negedge i_clk);
	@(negedge i_clk) i_rst_n = 0;
	@(negedge i_clk) i_rst_n = 1; 
	@(negedge i_clk);
	@(negedge i_clk);
	@(negedge i_clk);
	@(negedge i_clk) i_start = 1;
	@(negedge i_clk) i_start = 0;
	#(cycle*60);
    @(negedge i_clk);
	@(negedge i_clk);
	@(negedge i_clk) i_rst_n = 0;
	@(negedge i_clk) i_rst_n = 1; 
	@(negedge i_clk);
	@(negedge i_clk);
	@(negedge i_clk);
	@(negedge i_clk) i_start = 1;
	@(negedge i_clk) i_start = 0;
	#(cycle*60);

	$finish;
end

endmodule
