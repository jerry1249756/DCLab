module ModuloProduct (
	input          i_clk,
	input          i_rst,
	input          i_valid,
	input  [255:0] i_N,
	input  [256:0] i_a,	
	input  [255:0] i_b,
	input  [8:0]   i_k,
	output [255:0] o_moduloproduct,
	output         o_ready
);

	parameter S_IDLE = 2'd0;
	parameter S_CALC = 2'd1;
	parameter S_FINAL = 2'd2;
	logic [1:0]   state, state_nxt;
	logic [8:0]   counter, counter_nxt;
	logic [256:0] reg_t, reg_t_nxt;
	logic [256:0] reg_m, reg_m_nxt;

	assign o_moduloproduct = reg_m;
	assign o_ready = (state == S_FINAL) ? 1'd1 : 1'd0;

	always_comb begin
		case(state)
			S_IDLE: begin
				state_nxt = (i_valid) ? S_CALC : state;
				counter_nxt = 9'd0;
			end
			S_CALC: begin
				state_nxt = (counter >= i_k) ? S_FINAL : state;
				counter_nxt = counter + 9'd1;
			end
			S_FINAL: begin
				state_nxt = S_IDLE;
				counter_nxt = counter;
			end
			default: begin
				state_nxt = state;
				counter_nxt = counter;
			end
		endcase
	end

	always_comb begin
		case(state)
			S_IDLE: begin
				reg_m_nxt = 256'd0;
				reg_t_nxt = i_b;
			end
			S_CALC: begin
				if (i_a[counter]) begin
					reg_m_nxt = (reg_m + reg_t >= i_N) ? reg_m + reg_t - i_N : reg_m + reg_t;
					reg_t_nxt = (reg_t + reg_t >= i_N) ? reg_t + reg_t - i_N : reg_t + reg_t;
				end 
				else begin
					reg_m_nxt = reg_m;
					reg_t_nxt = (reg_t + reg_t >= i_N) ? reg_t + reg_t - i_N : reg_t + reg_t;
				end
			end
			S_FINAL: begin
				reg_m_nxt = reg_m;
				reg_t_nxt = reg_t;
			end
			default: begin
				reg_m_nxt = reg_m;
				reg_t_nxt = reg_t;
			end
		endcase
	end

	always_ff @(posedge i_clk or posedge i_rst) begin
		if(i_rst) begin
			state <= S_IDLE;
			counter <= 9'd0;
			reg_m <= 256'd0;
			reg_t <= i_b;
		end
		else begin
			state <= state_nxt;
			counter <= counter_nxt;
			reg_m <= reg_m_nxt;
			reg_t <= reg_t_nxt;
			$display("%d%d", reg_m, reg_t);
		end
	end

endmodule