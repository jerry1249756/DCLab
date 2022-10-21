// === AudRecorder ===
// receive data from WM8731 with I2S protocal and save to SRAM
module AudRecorder(
	input i_rst_n,
	input i_clk,
	input i_lrc,
	input i_start,
	input i_pause,
	input i_stop,
	input i_data,
	output [19:0] o_address,
	output [15:0] o_data,
	output o_REC_finish
);   

parameter S_IDLE = 3'd0;
parameter S_REC = 3'd1;
parameter S_PAUSE = 3'd2;

logic [19:0] address_r, address_w;
logic [15:0] data_r, data_w;
logic REC_finish;

logic [2:0] state_r, state_w; 
logic [4:0] counter_r, counter_w; 

logic [15:0] save_bits_r, save_bits_w;

assign o_address = address_r;
assign o_data = data_r;
assign o_REC_finish = REC_finish;

always_comb begin
	if(i_stop == 1'b1)begin
		REC_finish = 1'b1;
	end
	else if(address_r == {20{1'b1}})begin
		REC_finish = 1'b1;
	end
	else begin
		REC_finish = 1'b0;
	end
end


//state
always_comb begin
	case(state_r)
		S_IDLE : begin
			if(i_start == 1'b1)begin
				state_w = S_REC;
			end
			else begin
				state_w = state_r;
			end
		end
		S_REC : begin
			if(i_pause == 1'b1)begin
				state_w = S_PAUSE;
			end
			else if(REC_finish == 1'b1)begin
				state_w = S_IDLE;
			end
			else begin
				state_w = state_r;
			end
		end
		S_PAUSE : begin
			if(i_pause == 1'b1)begin
				state_w = S_REC;
			end
			else if(REC_finish == 1'b1)begin
				state_w = S_IDLE;
			end
			else begin
				state_w = state_r;
			end
		end
		default : begin
			state_w = state_r;
		end
	endcase
end

//counter
always_comb begin
	case(state_r)
		S_IDLE : begin
			counter_w = 5'd0;
		end
		S_REC : begin
			if(i_lrc == 1)begin
				counter_w = counter_r + 1;
			end 
			else begin
				counter_w = 0;
			end
		end
		S_PAUSE : begin
			counter_w = counter_r;
		end
		default : begin
			counter_w = counter_r;
		end
	endcase
end
//save_bits
always_comb begin
	case(state_r)
		S_IDLE : begin
			save_bits_w = 16'd0;
		end
		S_REC : begin
			if(counter_r > 5'd0 && counter_r < 5'd17) begin
				save_bits_w = (save_bits_r << 1) + i_data;
			end 
			else begin
				save_bits_w = 16'd0;
			end
		end
		S_PAUSE : begin
			save_bits_w = save_bits_r;
		end
		default : begin
			save_bits_w = save_bits_r;
		end
	endcase
end
//data address
always_comb begin
	case(state_r)
		S_IDLE : begin
			address_w = address_r;
			data_w = data_r;
		end
		S_REC : begin
			if(counter_r == 17) begin
				address_w = address_r + 20'd1;
				data_w = save_bits_r;
			end 
			else begin
				address_w = address_r;
				data_w = data_r;
			end
		end
		S_PAUSE : begin
			address_w = address_r;
			data_w = data_r;
		end
		default : begin
			address_w = address_r;
			data_w = data_r;
		end
	endcase
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
		 state_r <= S_IDLE;
		 counter_r <= 5'd0;
		 save_bits_r <= 16'd0;
		 address_r <= 20'd0;
		 data_r <= 16'd0;
	end
	else begin
		state_r <= state_w;
		counter_r <= counter_w;
		save_bits_r <= save_bits_w;
		address_r <= address_w;
		data_r <= data_w;
	end
end

endmodule
