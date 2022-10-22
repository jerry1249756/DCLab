// === AudDSP ===
// responsible for DSP operations including fast play and slow play at different speed
// in other words, determine which data addr to be fetch for player 
/*
AudDSP dsp0(
	.i_rst_n(i_rst_n),
	.i_clk(),
	.i_start(),
	.i_pause(),
	.i_stop(),
	.i_speed(),
	.i_fast(),
	.i_slow_0(), // constant interpolation
	.i_slow_1(), // linear interpolation
	.i_daclrck(i_AUD_DACLRCK),
	.i_sram_data(data_play),
	.o_dac_data(dac_data),
	.o_sram_addr(addr_play)
);
*/
module AudDSP (
	input 		  i_rst_n,
	input 		  i_clk,
	input 		  i_start,
	input 	 	  i_pause,
	input 		  i_stop,
	input  [3:0]  i_speed, // 1 mean 1x playing , 8 mean 8x playing
	input 		  i_fast,
	input 		  i_slow_0,
	input 		  i_slow_1,
	input 		  i_daclrck, // real clk
	input  [15:0] i_sram_data,
	output [15:0] o_dac_data,
	output [19:0] o_sram_addr,
	output 		  o_DSP_finished
);

// state parameter
localparam S_IDLE = 0;
localparam S_CAL_FAST = 1;
localparam S_CAL_SLOW0 = 2;
localparam S_CAL_SLOW1 = 3;
localparam S_PAUSE = 4;

localparam addr_max = (21'd1 << 20) - 21'd1;

logic signed [16:0] i_sram_signed_data;
assign i_sram_signed_data[15:0] = i_sram_data;
assign i_sram_signed_data[16] = 0;

logic signed [16:0] o_dac_data_r, o_dac_data_w; // 17 bits for not overflow 
logic [20:0] o_sram_addr_r, o_sram_addr_w; // 21 bits for need to plus 
logic [2:0] state_r, state_w;
logic [2:0] slow_counter_r, slow_counter_w; // count the cycle for waiting in the slow mode
logic wait_output_r, wait_output_w; // whether change back to IDLE state
logic [2:0] save_state_r, save_state_w; // save state for pause
logic signed [16:0] o_dac_data_save_r, o_dac_data_save_w; // save last data for calculating slow1
logic signed [4:0] i_speed_signed ;
//assign output
assign o_dac_data = o_dac_data_r[15:0];
assign o_sram_addr = o_sram_addr_r[19:0];
assign o_DSP_finished = wait_output_r;
assign i_speed_signed[3:0] = i_speed; 
assign i_speed_signed[4] = 0;

logic start_flag_r, start_flag_w;
logic pause1_flag_r, pause1_flag_w;
logic pause2_flag_r, pause2_flag_w;
logic stop_flag_r, stop_flag_w;

always_comb begin
	start_flag_w = start_flag_r;
	pause1_flag_w = pause1_flag_r;
	pause2_flag_w = pause2_flag_r;
	stop_flag_w = stop_flag_r;
	case(state_r)
		S_IDLE: begin
			pause1_flag_w = 0;
			pause2_flag_w = 0;
			stop_flag_w = 0;
			if(i_start) start_flag_w = 1;
		end
		S_CAL_FAST, S_CAL_SLOW0, S_CAL_SLOW1: begin
			pause2_flag_w = 0;
			start_flag_w = 0;
			if(i_stop) stop_flag_w = 1;
			if(i_pause) pause1_flag_w = 1;
		end
		S_PAUSE: begin
			start_flag_w = 0;
			pause1_flag_w = 0;
			if(i_stop) stop_flag_w = 1;
			if(i_pause) pause2_flag_w = 1;
		end
		default begin
			start_flag_w = start_flag_r;
			pause1_flag_w = pause1_flag_r;
			pause2_flag_w = pause2_flag_r;
			stop_flag_w = stop_flag_r;
		end
	endcase
end

//state
always_comb begin
	state_w = state_r;
	save_state_w = save_state_r;
	case(state_r)
		S_IDLE: begin
			if(start_flag_r) begin
				if(i_fast == 1 && i_slow_0 == 0 && i_slow_1 == 0) state_w = S_CAL_FAST;
				if(i_fast == 0 && i_slow_0 == 1 && i_slow_1 == 0) state_w = S_CAL_SLOW0;
				if(i_fast == 0 && i_slow_0 == 0 && i_slow_1 == 1) state_w = S_CAL_SLOW1;
			end
		end
		S_CAL_FAST: begin
			if(stop_flag_r || wait_output_r) state_w = S_IDLE;
			else begin
				if(pause1_flag_r) begin
					save_state_w = S_CAL_FAST;
					state_w = S_PAUSE;
				end
			end
		end
		S_CAL_SLOW0: begin
			if(stop_flag_r || wait_output_r) state_w = S_IDLE;
			else begin
				if(pause1_flag_r) begin
					save_state_w = S_CAL_SLOW0;
					state_w = S_PAUSE;
				end
			end
		end
		S_CAL_SLOW1: begin
			if(stop_flag_r || wait_output_r) state_w = S_IDLE;
			else begin
				if(pause1_flag_r) begin
					save_state_w = S_CAL_SLOW1;
					state_w = S_PAUSE;
				end
			end
		end
		S_PAUSE: begin
			if(stop_flag_r) state_w = S_IDLE;
			else begin
				if(pause2_flag_r) begin
					state_w = save_state_r;
				end
			end
		end
		default begin
			state_w = state_r;
			save_state_w = save_state_r;
		end
	endcase
end

// o_sram_addr (the address of data which is needed)
always_comb begin
	o_sram_addr_w = o_sram_addr_r;
	case(state_r)
		S_IDLE: o_sram_addr_w = 0;
		S_CAL_FAST: begin
			o_sram_addr_w = o_sram_addr_r + i_speed;
		end
		S_CAL_SLOW0: begin
			if(slow_counter_r == i_speed - 1) o_sram_addr_w = o_sram_addr_r + 1;
		end
		S_CAL_SLOW1: begin
			if(slow_counter_r == i_speed - 1) o_sram_addr_w = o_sram_addr_r + 1;
		end
		default o_sram_addr_w = o_sram_addr_r;
	endcase
	if(stop_flag_r || wait_output_r) o_sram_addr_w = 0;
end

// slow_counter and wait_output
always_comb begin
	slow_counter_w = 0;
	if(o_sram_addr_r > addr_max) wait_output_w = !wait_output_r;
	else wait_output_w = 0;
	case(state_r)
		S_IDLE: begin
			slow_counter_w = 0;
			wait_output_w = 0;
		end
		S_CAL_FAST: begin
			if(o_sram_addr_r > addr_max) wait_output_w = !wait_output_r;
			else wait_output_w = 0;
		end
		S_CAL_SLOW0: begin
			if(slow_counter_r != i_speed - 1) slow_counter_w = slow_counter_r + 1;
		end
		S_CAL_SLOW1: begin
			if(slow_counter_r != i_speed - 1) slow_counter_w = slow_counter_r + 1;
		end
		default begin
			slow_counter_w = slow_counter_r;
			wait_output_w = wait_output_r;
		end
	endcase
end 


//output data after DSP
always_comb begin
	o_dac_data_w = o_dac_data_r;
	o_dac_data_save_w = o_dac_data_save_r;
	case(state_r)
		S_IDLE: begin
			o_dac_data_w = 0;
			o_dac_data_save_w = 0;
		end
		S_CAL_FAST: begin
			if(o_sram_addr_r >= 1) o_dac_data_w = i_sram_data;
		end
		S_CAL_SLOW0: begin
			if(o_sram_addr_r >= 1) begin
				if(slow_counter_r == i_speed - 1) o_dac_data_w = i_sram_data;
				else o_dac_data_w = o_dac_data_r;
			end
		end
		S_CAL_SLOW1: begin
			if(o_sram_addr_r >= 1) begin
				if(slow_counter_r == i_speed - 1) begin
					o_dac_data_w = i_sram_data;
					o_dac_data_save_w = i_sram_data;
				end
				else o_dac_data_w = $signed(o_dac_data_r) + $signed(i_sram_signed_data - o_dac_data_save_r) / $signed(i_speed_signed);
				//else o_dac_data_w = o_dac_data_r + ((i_sram_data - o_dac_data_save_r) / i_speed);
			end
		end
		default begin
			o_dac_data_w = o_dac_data_r;
			o_dac_data_save_w = o_dac_data_save_r;
		end
	endcase
	if(stop_flag_r || wait_output_r) o_dac_data_w = 0;
end

always_ff @(posedge i_daclrck or negedge i_rst_n) begin
	if (!i_rst_n) begin
		state_r <= 0;
		o_sram_addr_r <= 0;
		o_dac_data_r <= 0;
		slow_counter_r <= 0;
		wait_output_r <= 0;
		o_dac_data_save_r <= 0;
	end
	else begin
		state_r <= state_w;
		o_sram_addr_r <= o_sram_addr_w;
		o_dac_data_r <= o_dac_data_w;
		slow_counter_r <= slow_counter_w;
		wait_output_r <= wait_output_w;
		o_dac_data_save_r <= o_dac_data_save_w;
	end
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
	if(!i_rst_n)begin
		start_flag_r <= 0;
		pause1_flag_r <= 0;
		pause2_flag_r <= 0;
		stop_flag_r <= 0;
		save_state_r <= 0;
	end
	else begin
		start_flag_r <= start_flag_w;
		pause1_flag_r <= pause1_flag_w;
		pause2_flag_r <= pause2_flag_w;
		stop_flag_r <= stop_flag_w;
		save_state_r <= save_state_w;
	end
end

endmodule
