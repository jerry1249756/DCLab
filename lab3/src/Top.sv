module Top (
	input i_rst_n, //key[3]
	input i_clk,   //12M
	input i_key_0, //key[0] record
	input i_key_1, //key[1] play
	input i_key_2, //key[2] stop
	input [4:0] i_speed, 
	/*
	i_speed[4]: linear=1, const=0;
	i_speed[3]: fast=1, slow=0; 
	i_speed[2:0]: speed 1-8
	*/
	
	// AudDSP and SRAM
	output [19:0] o_SRAM_ADDR, //read/write address
	inout  [15:0] io_SRAM_DQ,  //read/write 16bit data
	output        o_SRAM_WE_N, //sram write enable
	output        o_SRAM_CE_N, //sram output enable
	output        o_SRAM_OE_N, //sram Upper-byte control(IO15-IO8)
	output        o_SRAM_LB_N, //sram Lower-byte control(IO7-IO0)
	output        o_SRAM_UB_N, //sram Chip enable

	// I2C
	input  i_clk_100k,
	output o_I2C_SCLK,
	inout  io_I2C_SDAT, //bidirectional port reading I2C protocal for reset
	
	// AudPlayer
	input  i_AUD_ADCDAT,
	inout  i_AUD_ADCLRCK,
	inout  i_AUD_BCLK,
	inout  i_AUD_DACLRCK,
	output o_AUD_DACDAT

	// SEVENDECODER (optional display)
	// output [5:0] o_record_time,
	// output [5:0] o_play_time,

	// LCD (optional display)
	// input        i_clk_800k,
	// inout  [7:0] o_LCD_DATA,
	// output       o_LCD_EN,
	// output       o_LCD_RS,
	// output       o_LCD_RW,
	// output       o_LCD_ON,
	// output       o_LCD_BLON,

	// LED
	// output  [8:0] o_ledg,
	// output [17:0] o_ledr
);

// design the FSM and states as you like
localparam S_IDLE       = 0; //after entering IDLE state, do one I2C protocal
localparam S_I2C        = 1;  
localparam S_AWAIT      = 2;
localparam S_RECD       = 3;
localparam S_RECD_PAUSE = 4;
localparam S_PLAY       = 5;
localparam S_PLAY_PAUSE = 6;

logic [3:0] state, state_nxt;

logic [1:0] counter, counter_nxt;
logic i2c_start, i2c_finish, i2c_oen, i2c_sdat;

logic i_key_0_dly, i_key_1_dly, i_key_2_dly;
logic key_0_posedge, key_1_posedge, key_2_posedge;

assign key_0_posedge = i_key_0 & ~i_key_0_dly;
assign key_1_posedge = i_key_1 & ~i_key_1_dly;
assign key_2_posedge = i_key_2 & ~i_key_2_dly;

logic rec_start, rec_pause, rec_stop, rec_finish;
// logic rec_start_nxt, rec_pause_nxt, rec_stop_nxt, rec_finish_nxt;
logic play_start, play_pause, play_stop, play_finish;
// logic play_start_nxt, play_pause_nxt, play_stop_nxt, play_finish_nxt, play_enable_nxt;

logic play_enable, play_fast, slow_const, slow_linear;
logic [3:0] play_speed;

logic [19:0] addr_record, addr_play;
logic [15:0] data_record, data_play, dac_data;

assign i2c_start = (counter == 2'd3) ? 1'b1 : 1'b0;
assign io_I2C_SDAT = (i2c_oen) ? i2c_sdat : 1'bz;

assign rec_start  = ( state == S_AWAIT && key_0_posedge == 1'b1 ) ? 1'b1 : 1'b0;
assign rec_pause  = ( (state == S_RECD || state == S_RECD_PAUSE) && key_0_posedge == 1'b1 ) ? 1'b1 : 1'b0;
assign rec_stop   = ( (state == S_RECD || state == S_RECD_PAUSE) && key_2_posedge == 1'b1 ) ? 1'b1 : 1'b0;

assign play_enable = ( state == S_PLAY ) ? 1'b1 : 1'b0;
assign play_start = ( state == S_AWAIT && key_1_posedge == 1'b1 ) ? 1'b1 : 1'b0;
assign play_pause = ( (state == S_PLAY || state == S_PLAY_PAUSE) && key_1_posedge == 1'b1 ) ? 1'b1 : 1'b0;
assign play_stop  = ( (state == S_PLAY || state == S_PLAY_PAUSE) && key_2_posedge == 1'b1 ) ? 1'b1 : 1'b0;


assign play_fast   = (i_speed[3] == 1'b1) ? 1'b1 : 1'b0;
assign slow_const  = (i_speed[3] == 1'b0 && i_speed[4] == 1'b0) ? 1'b1 : 1'b0;
assign slow_linear = (i_speed[3] == 1'b0 && i_speed[4] == 1'b1) ? 1'b1 : 1'b0;
assign play_speed  = i_speed[2:0] + 1'b1;

assign o_SRAM_ADDR = (state == S_RECD) ? addr_record : addr_play[19:0];
assign io_SRAM_DQ  = (state == S_RECD) ? data_record : 16'dz; // sram_dq as output
assign data_play   = (state != S_RECD) ? io_SRAM_DQ : 16'd0; // sram_dq as input

assign o_SRAM_WE_N = (state == S_RECD) ? 1'b0 : 1'b1;
assign o_SRAM_CE_N = 1'b0;
assign o_SRAM_OE_N = 1'b0;
assign o_SRAM_LB_N = 1'b0;
assign o_SRAM_UB_N = 1'b0;

// below is a simple example for module division
// you can design these as you like

// === I2cInitializer ===
// sequentially sent out settings to initialize WM8731 with I2C protocal
I2cInitializer init0(
	.i_rst_n(i_rst_n),
	.i_clk(i_clk_100k),
	.i_start(i2c_start),
	.o_finished(i2c_finish),
	.o_sclk(o_I2C_SCLK),
	.o_sdat(i2c_sdat),
	.o_oen(i2c_oen) // you are outputing (you are not outputing only when you are "ack"ing.)
);

// === AudDSP ===
// responsible for DSP operations including fast play and slow play at different speed
// in other words, determine which data addr to be fetch for player 
AudDSP dsp0(
	.i_rst_n(i_rst_n),
	.i_clk(i_AUD_BCLK),
	.i_start(play_start),
	.i_pause(play_pause),
	.i_stop(play_stop),
	.i_speed(play_speed), //[3:0] 1-8
	.i_fast(play_fast),
	.i_slow_0(slow_const), // constant interpolation
	.i_slow_1(slow_linear), // linear interpolation
	.i_daclrck(i_AUD_DACLRCK), //calculate when 0->1
	.i_sram_data(data_play),
	.o_dac_data(dac_data),
	.o_sram_addr(addr_play),
	.o_DSP_finished(play_finish)
);

// === AudPlayer ===
// receive data address from DSP and fetch data to sent to WM8731 with I2S protocal
AudPlayer player0(
	.i_rst_n(i_rst_n),
	.i_bclk(i_AUD_BCLK),
	.i_daclrck(i_AUD_DACLRCK), //calculate when 0->1
	.i_en(play_enable), // enable AudPlayer only when playing audio, work with AudDSP
	.i_dac_data(dac_data), //dac_data
	.o_aud_dacdat(o_AUD_DACDAT)
);

// === AudRecorder ===
// receive data from WM8731 with I2S protocal and save to SRAM
AudRecorder recorder0(
	.i_rst_n(i_rst_n), 
	.i_clk(i_AUD_BCLK),
	.i_lrc(i_AUD_ADCLRCK),
	.i_start(rec_start),
	.i_pause(rec_pause),
	.i_stop(rec_stop),
	.i_data(i_AUD_ADCDAT),
	.o_REC_finish(rec_finish),
	.o_address(addr_record),
	.o_data(data_record)
);   

always_comb begin
	// FSM
	case(state)
		S_IDLE: state_nxt = (counter == 2'd3) ? S_I2C : S_IDLE;
		S_I2C: state_nxt = (i2c_finish == 1'b1) ? S_AWAIT : S_I2C;
		S_AWAIT: begin
			if (key_0_posedge == 1'b1) state_nxt = S_RECD;
			else if (key_1_posedge == 1'b1) state_nxt = S_PLAY;
			else state_nxt = S_AWAIT;
		end
		S_RECD: begin
			if (key_0_posedge == 1'b1) state_nxt = S_RECD_PAUSE;
			else if (rec_finish == 1'b1) state_nxt = S_AWAIT;
			else state_nxt = S_RECD;
		end
		S_RECD_PAUSE: begin 
			if(key_0_posedge == 1'b1) state_nxt = S_RECD;
			else if (rec_finish == 1'b1) state_nxt = S_AWAIT;
			else state_nxt = S_RECD_PAUSE;
		end
		S_PLAY: begin
			if(key_1_posedge == 1'b1) state_nxt = S_PLAY_PAUSE;
			else if (play_finish == 1'b1) state_nxt = S_AWAIT;
			else state_nxt = S_PLAY;
		end
		S_PLAY_PAUSE: begin
			if(key_1_posedge == 1'b1) state_nxt = S_PLAY;
			else if (play_finish == 1'b1) state_nxt = S_AWAIT;
			else state_nxt = S_PLAY;
		end
	endcase
end

// always_comb begin
// 	rec_start_nxt = 1'b0;
// 	rec_pause_nxt = 1'b0;
// 	rec_stop_nxt  = 1'b0;
// 	play_enable_nxt = 1'b0;
// 	play_start_nxt = 1'b0;
// 	play_pause_nxt = 1'b0;
// 	play_stop_nxt  = 1'b0;
// 	case(state)
// 		S_AWAIT: begin
// 			if(i_key_0 == 1'b1) rec_start_nxt = 1'b1;
// 			if(i_key_1 == 1'b1) play_start_nxt = 1'b1;
// 		end
// 		S_RECD, S_RECD_PAUSE: begin
// 			if(i_key_0 == 1'b1) rec_pause_nxt = 1'b1;
// 			if(i_key_2 == 1'b1) rec_stop_nxt  = 1'b1;
// 		end
// 		S_PLAY: begin
// 			play_enable_nxt = 1'b1; 
// 			if(i_key_1 == 1'b1) play_pause_nxt = 1'b1;
// 			if(i_key_2 == 1'b1) play_stop_nxt  = 1'b1;
// 		end
// 		S_PLAY_PAUSE: begin
// 			if(i_key_1 == 1'b1) play_pause_nxt = 1'b1;
// 			if(i_key_2 == 1'b1) play_stop_nxt  = 1'b1;
// 		end

// 		default: begin
// 			rec_start_nxt = 1'b0;
// 			rec_pause_nxt = 1'b0;
// 			rec_stop_nxt  = 1'b0;
// 			play_enable_nxt = 1'b0;
// 			play_start_nxt = 1'b0;
// 			play_pause_nxt = 1'b0;
// 			play_stop_nxt  = 1'b0;
// 		end
// 	endcase
// end


always_comb begin
	// counter
	case(state)
		S_IDLE: counter_nxt = counter + 2'd1;
		default: counter_nxt = 2'd0;
	endcase
end
always_ff @(posedge i_AUD_BCLK or posedge i_rst_n) begin
	i_key_0_dly <= i_key_0;
	i_key_1_dly <= i_key_1;
	i_key_2_dly <= i_key_2;
	if (!i_rst_n) begin
		state <= S_IDLE;
		counter <= 2'd0;
	end
	else begin
		state <= state_nxt;
		counter <= counter_nxt;
	end
end

endmodule