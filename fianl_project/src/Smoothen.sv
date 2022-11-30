module Smoothen(
	input                i_50M_clk                ,
	input                i_rst_n                  ,
	input                i_valid                  ,
	input  signed [15:0] i_square_add_data_seq    ,
	input         [19:0] i_SRAM_address           ,
	output               o_ready                  ,
	output        [19:0] o_SRAM_address           ,
	output        [15:0] o_SRAM_data              
);   

parameter S_IDLE = 2'd0;
parameter S_ACCUMULATE = 2'd1;
parameter S_OUT = 2'd2;

logic [1:0] state_r, state_w;
logic [4:0] counter_r, counter_w;
logic [21:0] accumulate_data_r, accumulate_data_w;

assign o_ready = (state_r == S_OUT);
assign o_SRAM_data = (state_r == S_OUT)? accumulate_data_r : 16'bz;
assign o_SRAM_address = (state_r == S_OUT)? i_SRAM_address : 20'bz;

//state
always_comb begin
	state_w = state_r;
	case(state_r)
		S_IDLE : begin
			if(i_valid) begin
				state_w = S_ACCUMULATE;
			end
			else begin
				state_w = S_IDLE;
			end
		end
		S_ACCUMULATE : begin
			if(counter_r == 5'd29) begin
				state_w = S_OUT;
			end
			else begin
				state_w = S_ACCUMULATE;
			end
		end
		S_OUT : begin
			state_w = S_IDLE;
		end
	endcase
end

always_comb begin
	counter_w = counter_r;
	accumulate_data_w = accumulate_data_r;
	case(state_r)
		S_IDLE : begin
			counter_w = 0;
			accumulate_data_w = 0;
		end
		S_ACCUMULATE : begin
			counter_w = counter_r + 1;
			accumulate_data_w = accumulate_data_r + i_square_add_data_seq;
		end
		S_OUT : begin
			counter_w = 0;
			accumulate_data_w = 0;
		end
	endcase
end


always_ff @(posedge i_50M_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
		state_r <= S_IDLE;
		counter_r <= 0;
		accumulate_data_r <= 0;
	end
	else begin
		state_r <= state_w;
		counter_r <= counter_w;
		accumulate_data_r <= accumulate_data_w;
	end
end

endmodule

