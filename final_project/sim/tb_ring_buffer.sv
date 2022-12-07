`timescale 1us/1us

module tb_ring_buffer;

parameter	cycle = 10.0;
parameter   bclk_cycle = 100.0;
parameter	lr_cycle = 5800.0;
logic 		i_clk, i_bclk, i_lrck;
logic       i_rst;
logic       i_initial_start, i_iterate_start;
logic       i_change_pointer;
logic       i_data;
logic [7:0]      i_delta;

logic [23:0] o_data;
logic [23:0] L_o_data;

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
    .i_initial_start(i_initial_start),
    .i_iterate_start(i_iterate_start),
    .i_change_pointer(i_change_pointer),
    .i_data(i_data),
    .i_delta(i_delta),
    .o_buffer_data(o_data),
	.o_L_buffer_data(L_o_data)
);

initial begin
	$fsdbDumpfile("tb_ring_buffer.fsdb");
	$fsdbDumpvars(0, tb_ring_buffer, "+all");
end

initial begin	
	#(cycle*2000000);
	$finish;
end

initial begin	
	i_clk 	= 0;
    i_bclk  = 0;
	i_lrck 	= 0;
	i_rst = 0;
    i_initial_start = 0;
    i_iterate_start = 0;

	@(negedge i_clk);
	@(negedge i_clk);
	@(negedge i_clk) i_rst = 1;
	@(negedge i_clk) i_rst = 0; 

	@(negedge i_clk);
	@(negedge i_clk);
	@(negedge i_clk);
	#(cycle*15);
	@(negedge i_clk) i_initial_start = 1;
	@(negedge i_clk) i_initial_start = 0;
	#(cycle*150000);
    @(negedge i_clk) i_iterate_start = 1;
	@(negedge i_clk) i_iterate_start = 0;
end

initial begin
    i_change_pointer = 0;
    forever begin
        #(cycle*15000)
        // #(cycle*0.1)
        // i_change_pointer = 1;
        // #(cycle*0.8)
        // i_change_pointer = 0;
        @(negedge i_clk) i_change_pointer = 1;
        @(negedge i_clk) i_change_pointer = 0;
    end
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