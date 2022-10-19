`timescale 1us/1us

module tb_AudRecorder;

parameter	cycle = 100.0;
parameter	lr_cycle = 3800.0;

logic 		i_clk, i_lrc;
logic 		i_rst_n, i_start, i_stop, i_pause, i_data;

logic [19:0] o_address;
logic [15:0] o_data;
logic o_REC_finish;

initial i_clk = 0;
always #(cycle/2.0) i_clk = ~i_clk;

initial i_lrc = 0;
always #(lr_cycle/2.0) i_lrc = ~i_lrc;


AudRecorder recorder0(
	.i_rst_n(i_rst_n), 
	.i_clk(i_clk),
	.i_lrc(i_lrc),
	.i_start(i_start),
	.i_pause(i_pause),
	.i_stop(i_stop),
	.i_data(i_data),
	.o_address(o_address),
	.o_data(o_data),
	.o_REC_finish(o_REC_finish)
);  


initial begin
	$fsdbDumpfile("tb_AudRecorder.fsdb");
	$fsdbDumpvars(0, tb_AudRecorder, "+all");
end

initial begin	
	#(cycle*2000);
	$finish;
end

initial begin	
	i_clk 	= 0;
	i_lrc 	= 0;
	i_rst_n = 1;
	i_start	= 0;

	@(negedge i_clk);
	@(negedge i_clk);
	@(negedge i_clk) i_rst_n = 0;
	@(negedge i_clk) i_rst_n = 1; 

	@(negedge i_clk);
	@(negedge i_clk);
	@(negedge i_clk);
	#(cycle*15);
	@(negedge i_clk) i_start = 1;
	@(negedge i_clk);
	@(negedge i_clk) i_start = 0;

end

initial begin
	i_data = 0;
	forever begin
		@(negedge i_clk) i_data = 1'b1;
		@(negedge i_clk) i_data = 1'b1;
		@(negedge i_clk) i_data = 1'b0;
		@(negedge i_clk) i_data = 1'b1;
		@(negedge i_clk) i_data = 1'b0;
		@(negedge i_clk) i_data = 1'b0;
		@(negedge i_clk) i_data = 1'b1;
		@(negedge i_clk) i_data = 1'b0;
		@(negedge i_clk) i_data = 1'b1;
		@(negedge i_clk) i_data = 1'b1;
		@(negedge i_clk) i_data = 1'b1;
		@(negedge i_clk) i_data = 1'b0;
	end
end

initial begin	
	i_stop = 0;
	i_pause = 0;
	#(cycle*58);
	

	@(negedge i_clk) i_pause = 1'b1;
	@(negedge i_clk) i_pause = 1'b0;
	#(cycle*50);
	@(negedge i_clk) i_pause = 1'b1;
	@(negedge i_clk) i_pause = 1'b0;

	#(cycle*1000);
	
	@(negedge i_clk) i_stop = 1;
	@(negedge i_clk) i_stop = 0;
end

endmodule
