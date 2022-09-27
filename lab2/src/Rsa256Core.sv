//ModuloProduct
module ModuloProduct (
	input          i_clk,
	input          i_rst,
	input          i_valid,
   input  [255:0] i_N,
   input  [255:0] i_a,	
   input  [255:0] i_b,
   input  [255:0] i_k,
	output [255:0] o_moduloproduct,
	output         o_ready

);

endmodule

//MontgomeryAlgorithm
module MontgomeryAlgorithm (
	input          i_clk,
	input          i_rst,
	input          i_valid,
   input  [255:0] i_N,
   input  [255:0] i_m,	
   input  [255:0] i_t,
	output [255:0] o_montgomeryalgorithm,
	output         o_ready

); 

endmodule

//Main
module Rsa256Core (
	input          i_clk,
	input          i_rst,
	input          i_start,
	input  [255:0] i_a, // cipher text y
	input  [255:0] i_d, // private key
	input  [255:0] i_n,
	output [255:0] o_a_pow_d, // plain text x
	output         o_finished
);


parameter S_IDLE = 3'd0;
parameter S_PREP = 3'd1;
parameter S_MONT = 3'd2;
parameter S_CALC = 3'd3;

logic [2:0] state, state_nxt;

logic [8:0] counter, counter_nxt;

logic [255:0]  Rsa256Core_result;
logic 			Rsa256Core_ready;

logic	[255:0] t, t_nxt;
logic	[255:0] m, m_nxt;


assign o_a_pow_d = Rsa256Core_result;
assign o_finished = Rsa256Core_ready;

//FSM
always_comb begin
	case(state)
		S_IDLE : begin
			if(i_start == 1) begin
				state_nxt = S_PREP;
			end
			else begin
				state_nxt = S_IDLE;
			end
		end
		S_PREP : begin
			if(moduloproduct_ready == 1) begin
				state_nxt = S_MONT;
			end
			else begin
				state_nxt = S_PREP;
			end
		end
		S_MONT : begin
			if(montgomeryalgorithm_ready == 1) begin
				state_nxt = S_CALC;
			end
			else begin
				state_nxt = S_MONT;
			end
		end
		S_CALC : begin
			if(counter == 256) begin
				state_nxt = S_IDLE;
			end
			else begin
				state_nxt = S_MONT;
			end
		end
		default : begin
			state_nxt = state;
		end
end

//counter 
always_comb begin
	case(state)
		S_IDLE : begin
			counter_nxt = 0;
		end
		S_CALC : begin
			counter_nxt = counter + 9'd1;
		end
		default : begin
			counter_nxt = counter;
		end
end


always_ff @(posedge i_clk or negedge i_rst_n) begin
		// reset
	if (!i_rst_n) begin
		state <= S_IDLE;
		t <= 0;
		m <= 0;
		counter <= 0;
	end
	else begin
		state <= state_nxt;
		t <= t_nxt;
		m <= m_nxt;
		counter <= counter_nxt;
	end
end

endmodule
