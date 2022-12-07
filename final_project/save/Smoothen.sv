module Smoothen(
	input                i_50M_clk                ,
	input                i_rst_n                  ,
	input                i_valid                  ,
	input          [9:0] i_x                      ,
	input          [9:0] i_y                      ,
	input  signed [51:0] i_new_data               ,
	input  signed [51:0] i_old_data               ,
	input         [15:0] i_SRAM_read_data         ,

	output        [19:0] o_SRAM_address           ,
	output        [16:0] o_SRAM_write_data        ,
	output               o_SRAM_write_en          ,
	output               o_SRAM_read_en           ,
	output               o_finish           
);   

parameter S_IDLE = 2'd0;
parameter S_READ_SRAM = 2'd2;
parameter S_WRITE_SRAM = 2'd3;


logic [1:0] state_r, state_w;
logic [9:0] x_r, x_w, y_r, y_w;
logic [51:0] new_data_r, new_data_w;
logic [51:0] old_data_r, old_data_w;
logic [15:0] SRAM_read_data_r, SRAM_read_data_w;
logic [19:0] SRAM_address_r, SRAM_address_w;
logic [15:0] SRAM_write_data_r, SRAM_write_data_w;


assign o_finish = (state == S_WRITE_SRAM);
assign o_SRAM_write_en = (state == S_WRITE_SRAM);
assign o_SRAM_read_en = (state == S_READ_SRAM) && i_valid;
//state
always_comb begin
	state_w = state_r;
	case(state_r)
		S_IDLE : begin
			if(i_valid) begin
				state_w = S_READ_SRAM;
			end
			else begin
				state_w = S_IDLE;
			end
		end
		S_READ_SRAM : begin
			state_w = S_WRITE_SRAM;
		end
		S_WRITE_SRAM : begin
			state_w = S_IDLE;
		end
	endcase
end

always_comb begin
	x_w = x_r;
	y_w = y_r;
	new_data_w = new_data_r;
	old_data_w = old_data_r;
	SRAM_read_data_w = SRAM_read_data_r;
	SRAM_address_w = SRAM_address_r;
	SRAM_write_data_w = SRAM_write_data_r;
	case(state_r)
		S_IDLE : begin
			if(i_valid) begin
				x_w = i_x;
				y_w = i_y;
				new_data_w = i_new_data;
				old_data_w = i_old_data;
				SRAM_address_w = i_x * 10'd480 + i_y;
				SRAM_read_data_w = i_SRAM_read_data;
			end
			else begin
				x_w = 0;
				y_w = 0;
				new_data_w = 0;
				old_data_w = 0;
				SRAM_address_w = 20'bz;
			end
		end
		S_READ_SRAM : begin
			SRAM_write_data_w = SRAM_read_data_r + new_data_r - old_data_r;
		end
		S_WRITE_SRAM : begin
			x_w = 0;
			y_w = 0;
			new_data_w = 0;
			old_data_w = 0;
			SRAM_address_w = 20'bz;
			SRAM_write_data_w = 0
			SRAM_read_data_w = 0;
		end
	endcase
end


always_ff @(posedge i_50M_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
		state_r <= S_IDLE;
		x_r <= 0;
		y_r <= 0;
 		new_data_r <= 0;
 		old_data_r <= 0;
 		SRAM_read_data_r <= 0;
 		SRAM_address_r <= 20'bz;
 		SRAM_write_data_r <= 0;
	end
	else begin
		state_r <= state_w;
		x_r <= x_w;
		y_r <= y_w;
 		new_data_r <= new_data_w;
 		old_data_r <= old_data_w;
 		SRAM_read_data_r <= SRAM_read_data_w;
 		SRAM_address_r <= SRAM_address_w;
 		SRAM_write_data_r <= SRAM_write_data_w;
	end
end

endmodule
/*module Smoothen(
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

*/