/*
this module works as an moving average filter that does NOT read in 1 state and write in 
next state, but rather, continuously giving out the moving average of the input data flow by
y[n] = y[n-1] + x[n] - x[n-N]

need to define proper N inside the module. 
*/

`define N  30

module MovAvg(
    input            i_50M_clk        ,
	input            i_rst            ,
    input            i_start          ,
	input  [23:0]    i_new_data       , // input: 
	input  [23:0]    i_old_data       , // input: when less then N, this will be ignored  
	output [23:0]    o_avg_data
); 

parameter S_IDLE = 1'd0;
parameter S_WORK = 1'd1;

logic state, state_nxt;
logic [$clog2(`N)-1:0] counter, counter_nxt;
logic [$clog2(`N)+23:0] sum, sum_nxt;

assign o_avg_data = sum[$clog2(`N)+23:$clog2(`N)];

always_comb begin
    state_nxt = state;
	if(i_start && state == S_IDLE) state_nxt = S_WORK;
end

always_comb begin
    counter_nxt = counter;
    if(state == S_WORK) begin
        if(counter <= `N) counter_nxt = counter + 1;
        else counter_nxt = counter;
    end
end

always_comb begin
    sum_nxt = sum;
    if(state == S_WORK) begin
        if(counter <= `N) sum_nxt = sum + i_new_data;
        else sum_nxt = sum + i_new_data - i_old_data;
    end
end

always_ff @(posedge i_50M_clk or posedge i_rst) begin
    if (i_rst) begin
		state <= S_IDLE;
        counter <= 0;
		sum <= 0;
    end
    else begin
		state <= state_nxt;
		counter <= counter_nxt;
        sum <= sum_nxt;
    end
end

endmodule