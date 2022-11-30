`timescale 1us/1us

module tb_ring_buffer;

parameter	cycle = 10.0;
parameter   bclk_cycle = 1000.0;
parameter	lr_cycle = 58000.0;

logic 		i_clk, i_bclk, i_lrck;
logic 		i_rst, i_start;
logic       i_data;
logic [7:0]      i_delta;

logic [23:0] o_data;

initial i_clk = 0;
always #(cycle/2.0) i_clk = ~i_clk;

initial i_bclk = 0;
always #(bclk_cycle/2.0) i_bclk = ~i_bclk;

initial i_lrck = 0;
always #(lr_cycle/2.0) i_lrck = ~i_lrck;

RingBuffer buffer0(
    .i_clk(i_clk),
    .i_BCLK(i_bclk),
    .i_LRCK(i_lrck),
    .i_rst(i_rst),
    .i_start(i_start),
    .i_data(i_data),
    .i_delta(i_delta),
    .buffer_data(o_data)
);

initial begin
	$fsdbDumpfile("tb_ring_buffer.fsdb");
	$fsdbDumpvars(0, tb_ring_buffer, "+all");
end

initial begin	
	#(cycle*200000);
	$finish;
end

initial begin	
	i_clk 	= 0;
    i_bclk  = 0;
	i_lrck 	= 0;
	i_rst = 0;
	i_start	= 0;

	@(negedge i_clk);
	@(negedge i_clk);
	@(negedge i_clk) i_rst = 1;
	@(negedge i_clk) i_rst = 0; 

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
		@(negedge i_bclk) i_data = 1'b1;
		@(negedge i_bclk) i_data = 1'b1;
		@(negedge i_bclk) i_data = 1'b0;
		@(negedge i_bclk) i_data = 1'b1;
		@(negedge i_bclk) i_data = 1'b0;
		@(negedge i_bclk) i_data = 1'b0;
		@(negedge i_bclk) i_data = 1'b1;
		@(negedge i_bclk) i_data = 1'b0;
		@(negedge i_bclk) i_data = 1'b1;
		@(negedge i_bclk) i_data = 1'b1;
		@(negedge i_bclk) i_data = 1'b1;
		@(negedge i_bclk) i_data = 1'b0;
        @(negedge i_bclk) i_data = 1'b1;
        @(negedge i_bclk) i_data = 1'b1;
        @(negedge i_bclk) i_data = 1'b0;
        @(negedge i_bclk) i_data = 1'b0;
        @(negedge i_bclk) i_data = 1'b1;
        @(negedge i_bclk) i_data = 1'b0;
        @(negedge i_bclk) i_data = 1'b0;
        @(negedge i_bclk) i_data = 1'b0;
        @(negedge i_bclk) i_data = 1'b1;
        @(negedge i_bclk) i_data = 1'b0;
        @(negedge i_bclk) i_data = 1'b1;
        @(negedge i_bclk) i_data = 1'b1;
	end
end

initial begin	
	i_delta = 0;
    forever begin
		@(negedge i_clk) i_delta = 8'd148;
		@(negedge i_clk) i_delta = 8'd147;
		@(negedge i_clk) i_delta = 8'd148;
		@(negedge i_clk) i_delta = 8'd149;
		@(negedge i_clk) i_delta = 8'd150;
		@(negedge i_clk) i_delta = 8'd152;
		@(negedge i_clk) i_delta = 8'd163;
		@(negedge i_clk) i_delta = 8'd154;
		@(negedge i_clk) i_delta = 8'd168;
		@(negedge i_clk) i_delta = 8'd169;
		@(negedge i_clk) i_delta = 8'd167;
		@(negedge i_clk) i_delta = 8'd168;
	end
end

endmodule
