`timescale 1ns/1ns

module tb_ring_buffer;

parameter	cycle = 20.0;
parameter   bclk_cycle = 312.5;
parameter	lr_cycle = 20000.0;
logic 		i_clk, i_bclk, i_lrck;
logic       i_rst;
logic       i_data;
logic [39:0]      i_delta;

logic finish, start;
logic [119:0] temp_data;
logic [23:0] o_data [4:0];
assign o_data[4] = temp_data[23:0];
assign o_data[3] = temp_data[47:24];
assign o_data[2] = temp_data[71:48];
assign o_data[1] = temp_data[95:72];
assign o_data[0] = temp_data[119:96];

initial i_clk = 0;
always #(cycle/2.0) i_clk = ~i_clk;

initial i_bclk = 0;
always #(bclk_cycle/2.0) i_bclk = ~i_bclk;

initial i_lrck = 0;
always #(lr_cycle/2.0) i_lrck = ~i_lrck;



ring_buffer r0(
    .i_50M_clk(i_clk),
    .i_BCLK(i_bclk),
    .i_LRCK(i_lrck), 
    .i_rst(i_rst),
    .i_start(start),
    .i_data(i_data),
    .i_delta_concate(i_delta),
    .o_buffer_data(temp_data),
    // output [24*`PARALLEL-1:0] o_L_buffer_data,
    .o_initial_finish(finish)
);

initial begin
	$fsdbDumpfile("tb_ring_buffer.fsdb");
	$fsdbDumpvars(0, tb_ring_buffer, "+all");
end

initial begin	
	#(lr_cycle*1000);
	$finish;
end

initial begin	
	i_rst = 0;
    start = 0;
	@(negedge i_clk);
	@(negedge i_clk);
	@(negedge i_clk) i_rst = 1;
	@(negedge i_clk) i_rst = 0; 
	#(cycle*1500);
	@(negedge i_clk) start = 1;
	@(negedge i_clk) start = 0;
end

// initial begin
//     i_change_pointer = 0;
//     forever begin
//         #(cycle*15000)
//         // #(cycle*0.1)
//         // i_change_pointer = 1;
//         // #(cycle*0.8)
//         // i_change_pointer = 0;
//         @(negedge i_clk) i_change_pointer = 1;
//         @(negedge i_clk) i_change_pointer = 0;
//     end
// end

initial begin
	i_data = 0;
	forever begin
		@(negedge i_bclk) i_data = $urandom() & 1;
	end
end

initial begin	
	i_delta = 0;
    forever begin
		@(negedge i_clk) begin
			i_delta[7:0] = ({$random} % 33) + 147;
			i_delta[15:8] = ({$random} % 33) + 147;
			i_delta[23:16] = ({$random} % 33) + 147;
			i_delta[31:24] = ({$random} % 33) + 147;
			i_delta[39:32] = ({$random} % 33) + 147;
		end
	end
end

endmodule