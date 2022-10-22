// === I2cInitializer ===
// sequentially sent out settings to initialize WM8731 with I2C protocal
module I2cInitializer(
	input  i_rst_n,
	input  i_clk,
	input  i_start,
	output o_finished,
	output o_sclk,
	output o_sdat,
	output o_oen //output enable (you are not outputing only when you are "ack"ing.)
);

	parameter S_IDLE = 2'd0;
	parameter S_SEND = 2'd1;
	parameter S_BREAK = 2'd2;
	parameter S_FINAL = 2'd3;

	//MSB 1st bit prepareation, actually 0011_0100_000_1111_0_0000_0000
	parameter init_0 = 24'b001101000001111000000000;
	parameter init_1 = 24'b001101000000100000010101;
	parameter init_2 = 24'b001101000000101000000000;
	parameter init_3 = 24'b001101000000110000000000;
	parameter init_4 = 24'b001101000000111001000010;
	parameter init_5 = 24'b001101000001000000011001;
	parameter init_6 = 24'b001101000001001000000001;
	
	logic i_start_dly, o_oen_early, o_oen_dly;
	logic SDA, SCL, SDA_nxt, SCL_nxt;
	logic [1:0] state, state_nxt;
	logic [2:0] phase_count, phase_count_nxt;
	logic [3:0] send_count, send_count_nxt;
	logic [2:0] break_count, break_count_nxt;
	logic [4:0] data_count, data_count_nxt; 

	assign o_sclk = SCL;
	assign o_sdat = SDA;
	assign o_oen = o_oen_dly;
	assign o_oen_early = (send_count == 4'd8) ? 1'd0 : 1'd1;
	assign o_finished = (state == S_FINAL) ? 1'd1 : 1'd0;
	
	logic [23:0] param_init;
	assign param_init = f(phase_count);
	
	function [23:0] f (input [2:0] idx);
		case(idx)
			3'd0: f=init_0;
			3'd1: f=init_1;
			3'd2: f=init_2;
			3'd3: f=init_3;
			3'd4: f=init_4;
			3'd5: f=init_5;
			3'd6: f=init_6;
		endcase
	endfunction

	always_comb begin
		case(state)
			S_IDLE: begin
				state_nxt = (i_start_dly == 1'd1) ? S_SEND : S_IDLE;
			end
			S_SEND: begin
				state_nxt = ( data_count == 5'd0 && send_count == 4'd8) ? S_BREAK : S_SEND;
			end
			S_BREAK: begin
				state_nxt = (phase_count == 3'd7) ? S_FINAL :((break_count == 3'd4) ? S_SEND : S_BREAK);
			end
			S_FINAL: begin 
				state_nxt = S_IDLE;
			end
			default: begin
				state_nxt = state;
			end
		endcase
	end	

	always_comb begin
		case(state)
			S_IDLE: begin
				SDA_nxt = (i_start == 1'd1) ? 1'b0 : SDA;
				SCL_nxt = (i_start_dly == 1'd1) ? 1'b0 : SCL;
			end
			S_SEND: begin
				SDA_nxt = (SCL == 1'b0 && data_count >=24) ? 1'b0 : (SCL == 1'b0 && data_count <24) ? param_init[data_count] : SDA;
				SCL_nxt = ~SCL;
			end
			S_BREAK: begin
				case(break_count)
					3'd0, 3'd1: begin
						SCL_nxt = 1'b1;
						SDA_nxt = 1'b0;
					end
					3'd3:begin
						SCL_nxt = 1'b1;
						SDA_nxt = 1'b0;
					end
					3'd4:begin
						SCL_nxt = 1'b0;
						SDA_nxt = 1'b0;
					end
					default: begin
						SCL_nxt = 1'b1;
						SDA_nxt = 1'b1;
					end
				endcase
			end
			default: begin
				SDA_nxt = 1'b1;
				SCL_nxt = 1'b1;
			end
		endcase
	end	

	always_comb begin
		case(state)
			S_IDLE: begin
				data_count_nxt = 5'd23;
				send_count_nxt = 4'd0;
				phase_count_nxt = 3'd0;
				break_count_nxt = 3'd0;
			end
			S_SEND: begin
				if(SCL==1'd1) begin
					data_count_nxt = (data_count == 5'd0 || send_count == 4'd8) ?  data_count : data_count - 5'd1;
					send_count_nxt = (send_count == 4'd8) ? 4'd0 : send_count + 4'd1;
				end
				else begin
					data_count_nxt = data_count;
					send_count_nxt = send_count;
				end
				phase_count_nxt = phase_count;
				break_count_nxt = 3'd0;
			end
			S_BREAK: begin
				data_count_nxt = 5'd23;
				send_count_nxt = 4'd0;
				break_count_nxt = break_count + 3'd1;
				case(break_count)
					3'd1: phase_count_nxt = phase_count + 3'd1;
					default: phase_count_nxt = phase_count;
				endcase
			end
			default: begin
				data_count_nxt = 5'd23;
				send_count_nxt = 4'd0;
				phase_count_nxt = 3'd0;
				break_count_nxt = 3'd0;
			end
		endcase
	end	

	// ===== Sequential Circuits =====
	always_ff @(posedge i_clk or negedge i_rst_n) begin
		i_start_dly <= i_start;
		o_oen_dly <= o_oen_early;
		if (!i_rst_n) begin
			state <= S_IDLE;
			SDA <= 1'd1;
			SCL <= 1'd1;
			data_count <= 5'd23;
			send_count <= 4'd0;
			phase_count <= 3'd0;
			break_count <= 3'd0;
		end
		else begin
			state <= state_nxt;
			SDA <= SDA_nxt;
			SCL <= SCL_nxt;
			data_count <= data_count_nxt ;
			send_count <= send_count_nxt;
			phase_count <= phase_count_nxt ;
			break_count <= break_count_nxt ;
		end
	end

endmodule

