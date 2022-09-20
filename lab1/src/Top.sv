module LCG(input  [3:0] i_lcg,
		   output [3:0] o_lcg);

	parameter A = 5'd11;
	parameter B = 5'd29;

	logic [3:0] o_lcg_bf;

	assign o_lcg = o_lcg_bf;

	always_comb begin
		o_lcg_bf = ( A*i_lcg + B ) % 5'd16;
	end

endmodule


module Top (input        i_clk,
			input        i_rst_n,
			input        i_start,
			input 		 i_stop,
			output [3:0] o_random_out,
			output [2:0] o_state);
			

	parameter S_IDLE = 3'd0;
	parameter S_FAST = 3'd1;
	parameter S_MEDIUM = 3'd2;
	parameter S_SLOW = 3'd3;
	parameter S_STOP = 3'd4;
	parameter threshold1 = 30'd100000000;
	parameter threshold2 = 30'd100000000;
	parameter threshold3 = 30'd100000000;

	
	// ===== Registers & Wires =====
	logic [2:0] state, state_nxt;
	logic [2:0] state_last, state_last_nxt;
	logic [3:0] IDLE_counter , IDLE_counter_nxt;
	logic [29:0] FAST_counter , FAST_counter_nxt;
	logic [29:0] MEDIUM_counter , MEDIUM_counter_nxt;
	logic [29:0] SLOW_counter , SLOW_counter_nxt;

	//LCG register wire
	logic [3:0] input_lcg , input_lcg_nxt, output_lcg;

	assign o_random_out = output_lcg;
	
	assign o_state = state;
	
	LCG LCG0( 
		.i_lcg(input_lcg),
		.o_lcg(output_lcg)
	);


	always_comb begin
		// FSM
		case(state)
			S_IDLE: begin
				state_last_nxt = state_last;
				if (i_start) begin
					state_nxt = S_FAST;
				end
				else state_nxt = state;
			end
			S_FAST: begin
				if(i_stop) begin
					state_nxt = S_STOP;
					state_last_nxt = state;
				end
				else begin
					state_last_nxt = state_last;
					if(FAST_counter >= threshold1) begin
						state_nxt = S_MEDIUM;
					end
					else state_nxt = state;
				end
				
			end
			S_MEDIUM: begin
				if(i_stop) begin
					state_nxt = S_STOP;
					state_last_nxt = state;
				end
				else begin
					state_last_nxt = state_last;
					if(MEDIUM_counter >= threshold2) begin
						state_nxt = S_SLOW;
					end
					else state_nxt = state;
				end
				
			end
			S_SLOW: begin
				//
				if(i_stop) begin
					state_nxt = S_STOP;
					state_last_nxt = state;
				end
				else begin
					state_last_nxt = state_last;
					if(SLOW_counter >= threshold3) begin
						state_nxt = S_IDLE;
					end
					else state_nxt = state;
				end
			end
			S_STOP: begin
				state_last_nxt = state_last;
				if (i_stop) begin
					state_nxt = state_last;
				end
				else state_nxt = state;
			end
			default: begin
				state_nxt = state;
				state_last_nxt = state_last;
			end
		endcase
	end

	always_comb begin
		//counter
		case(state)
			S_IDLE: begin
				IDLE_counter_nxt = IDLE_counter + 1'd1;
				FAST_counter_nxt = 0;
				MEDIUM_counter_nxt = 0;
				SLOW_counter_nxt = 0;
			end
			S_FAST: begin
				IDLE_counter_nxt = IDLE_counter;
				FAST_counter_nxt = FAST_counter + 1'd1;
				MEDIUM_counter_nxt = 0;
				SLOW_counter_nxt = 0;
			end
			S_MEDIUM: begin
				IDLE_counter_nxt = IDLE_counter;
				FAST_counter_nxt = 0;
				MEDIUM_counter_nxt = MEDIUM_counter + 1'd1;
				SLOW_counter_nxt = 0;
			end
			S_SLOW: begin
				IDLE_counter_nxt = IDLE_counter;
				FAST_counter_nxt = 0;
				MEDIUM_counter_nxt = 0;
				SLOW_counter_nxt = SLOW_counter + 1'd1;
			end
			S_STOP: begin
				IDLE_counter_nxt = IDLE_counter;
				FAST_counter_nxt = FAST_counter;
				MEDIUM_counter_nxt = MEDIUM_counter;
				SLOW_counter_nxt = SLOW_counter;
			end
			default: begin
				IDLE_counter_nxt = IDLE_counter;
				FAST_counter_nxt = 0;
				MEDIUM_counter_nxt = 0;
				SLOW_counter_nxt = 0;
			end
		endcase
	end

	always_comb begin
		//lcg_input
		case(state)
			S_IDLE: begin
				input_lcg_nxt = input_lcg;
			end
			S_FAST: begin
				if(FAST_counter == 0) input_lcg_nxt = IDLE_counter;
				else begin
					if((FAST_counter % 600000) == 0) input_lcg_nxt = o_random_out;
					else input_lcg_nxt = input_lcg;
				end
			end
			S_MEDIUM: begin
				if((MEDIUM_counter % 2000000) == 0) input_lcg_nxt = o_random_out;
				else input_lcg_nxt = input_lcg;
			end
			S_SLOW: begin
				if((SLOW_counter % 8000000) == 0) input_lcg_nxt = o_random_out;
				else input_lcg_nxt = input_lcg;
			end
			S_STOP: begin
				input_lcg_nxt = input_lcg;
			end
			default: begin
				input_lcg_nxt = input_lcg;
			end
		endcase
	end

	// ===== Sequential Circuits =====
	always_ff @(posedge i_clk or negedge i_rst_n) begin
		// reset
		if (!i_rst_n) begin
			state <= S_IDLE;
			state_last <= S_STOP;
			IDLE_counter <= 1'd0;
			FAST_counter <= 1'd0;
			MEDIUM_counter <= 1'd0;
			SLOW_counter <= 1'd0;
			input_lcg <= 4'd9;
		end
		else begin
			state <= state_nxt;
			state_last <= state_last_nxt;
			IDLE_counter <= IDLE_counter_nxt;
			FAST_counter <= FAST_counter_nxt;
			MEDIUM_counter <= MEDIUM_counter_nxt;
			SLOW_counter <= SLOW_counter_nxt;
			input_lcg <= input_lcg_nxt;
		end
	end

endmodule
