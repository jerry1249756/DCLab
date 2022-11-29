`timescale 1us/1us

module Delta_test;

parameter cycle = 100.0;

logic  i_clk;
logic signed[7:0]  p_x;
logic signed[7:0]  p_y;
logic [7:0] delta[15:0];
initial i_clk = 0;
always #(cycle/2.0) i_clk = ~i_clk;


Delta_generator d0(
   	.i_clk(i_clk),
    .p_x(p_x),
    .p_y(p_y),
    .delta(delta)
);

initial begin
	$fsdbDumpfile("Delta_test.fsdb");
	$fsdbDumpvars(0, Delta_test, "+all");
end

initial begin	
	i_clk = 0;
    p_x = 3; p_y = -26;
	@(negedge i_clk);
	@(negedge i_clk);
	@(negedge i_clk)  p_x = 27; p_y = 30;
    @(negedge i_clk);
	@(negedge i_clk);
	@(negedge i_clk)  p_x =-18; p_y = 45;
    @(negedge i_clk);
	@(negedge i_clk);
	@(negedge i_clk)  p_x = -100; p_y = 140;
	@(negedge i_clk);
	@(negedge i_clk);
	$finish;
end

endmodule