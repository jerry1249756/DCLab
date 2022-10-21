// === AudPlayer ===
// receive data address from DSP and fetch data to sent to WM8731 with I2S protocal
module AudPlayer (
	input i_rst_n,
	input i_bclk,
	input i_daclrck,
	input i_en, // enable AudPlayer only when playing audio, work with AudDSP
	input [15:0] i_dac_data, //dac_data
	output o_aud_dacdat
);

parameter S_IDLE = 2'd0;
parameter S_PLAY = 2'd1;

logic [1:0] state_r, state_w; 
logic [4:0] counter_r, counter_w; 

logic [15:0] reg_dac_data_r, reg_dac_data_w;

logic aud_dacdat_r, aud_dacdat_w;

logic flag;

assign o_aud_dacdat = aud_dacdat_r;

//state
always_comb begin
	case(state_r)
		S_IDLE : begin
			if(i_daclrck == 1'b1 && i_en == 1'b1 && counter_r == 5'b0) begin
				state_w = S_PLAY;
			end
			else begin
				state_w = state_r;
			end
		end
		S_PLAY : begin
			if(i_daclrck == 1'b0 || i_en == 1'b0) begin
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

always_comb begin
	if(i_en == 1'b1) reg_dac_data_w = i_dac_data;
	else reg_dac_data_w = reg_dac_data_r;
end

always_comb begin
	case(state_r) 
		S_IDLE : begin
			counter_w = 0;
		end
		S_PLAY : begin
			counter_w = counter_r + 5'd1;
		end
		default : begin
			counter_w = counter_r;
		end
	endcase
end

always_comb begin
	case(state_r)
		S_IDLE : begin
			aud_dacdat_w = 1'b0;
		end
		S_PLAY : begin
			if(counter_r < 5'd16) aud_dacdat_w = reg_dac_data_r[5'd15 - counter_r];
			else aud_dacdat_w = 1'b0;
		end
		default : begin
			aud_dacdat_w = 1'b0;
		end
	endcase
end

always_ff @(posedge i_bclk or negedge i_rst_n) begin
	if (!i_rst_n) begin
		 state_r <= S_IDLE;
		 counter_r <= 5'd0;
		 reg_dac_data_r <= 16'b0;
	end
	else begin
		state_r <= state_w;
		counter_r <= counter_w;
		reg_dac_data_r <= reg_dac_data_w;
	end
end

always_ff @(negedge i_bclk or negedge i_rst_n) begin
	if (!i_rst_n) begin
		 aud_dacdat_r <= 1'b0;
	end
	else begin
		aud_dacdat_r <= aud_dacdat_w;
	end
end

endmodule
