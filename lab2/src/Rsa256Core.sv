//`include "ModuleProduct.sv"
//`include "MontgomeryAlgorithm.sv"
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
			//$display("%d%d", reg_m, reg_t);
		end
	end

endmodule
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


    parameter S_IDLE = 2'd0;
    parameter S_CAL = 2'd1;
    parameter S_OUT = 2'd2;

    logic [257:0] m, m_nxt;
    logic ready, ready_nxt;
    logic [1:0] state, state_nxt;
    logic [8:0] counter, counter_nxt;

    assign o_montgomeryalgorithm = m[255:0];
    assign o_ready = ready;

    always_comb begin
        case(state)
            S_IDLE: begin
                if(i_valid) state_nxt = S_CAL;
                else state_nxt = state;
            end
            S_CAL: begin
                if(counter >= 9'd255) state_nxt = S_OUT;
                else state_nxt = state;
            end
            S_OUT: begin
                if(counter >= 9'd258) state_nxt = S_IDLE;
                else state_nxt = state;
            end
            default: state_nxt = state;
        endcase
    end

    always_comb begin
        case(state)
            S_IDLE: begin
                counter_nxt = 9'd0;
            end
            S_CAL: begin
                counter_nxt = counter + 9'd1;
            end
            S_OUT: begin
                counter_nxt = counter + 9'd1; 
            end
            default: counter_nxt = counter;
        endcase
    end

    always_comb begin 
        case(state)
            S_IDLE: begin
                m_nxt = 257'd0;
                ready_nxt = 1'd0;
            end

            S_CAL: begin
                if(i_m[counter] == 1) begin
                    if(((m + i_t) % 2) == 1) m_nxt = (m + i_t + i_N) >> 1;
                    else m_nxt = (m + i_t) >> 1;
                end
                else begin
                    if(m[0] == 1) m_nxt = (m + i_N) >> 1;
                    else m_nxt = m >> 1;
                end
                ready_nxt = ready;
            end

            S_OUT: begin
                case(counter)
                    9'd256: begin
                        if(m >= i_N) m_nxt = m - i_N;
                        else m_nxt = m;
                        ready_nxt = ready;
                    end
                    9'd257: begin
                        m_nxt = m;
                        ready_nxt = 1'd1;
                    end
                    9'd258: begin
                        m_nxt = m;
                        ready_nxt = 1'd0;
                    end
                    default: begin
                        m_nxt = m;
                        ready_nxt = ready;
                    end
                endcase 
            end

            default: begin
                m_nxt = m;
                ready_nxt = ready;
            end
        endcase
    end

    always_ff @(posedge i_clk or posedge i_rst) begin
        if(i_rst)begin
            state <= S_IDLE;
            counter <= 9'd0;
            m <= 257'd0;
            ready <= 1'd0;
        end
        else begin
            state <= state_nxt;
            counter <= counter_nxt;
            m <= m_nxt;
            ready <= ready_nxt;
            //$display("%d", m);
        end

    end

endmodule

//Main
module Rsa256Core (
	input          i_clk,
	input          i_rst,
	input          i_start,
	input  [255:0] i_a, // cipher text y ****y
	input  [255:0] i_d, // private key ****d
	input  [255:0] i_n, // ****N
	output [255:0] o_a_pow_d, // plain text x
	output         o_finished
);


parameter S_IDLE = 3'd0;
parameter S_PREP = 3'd1;
parameter S_MONT = 3'd2;
parameter S_CALC = 3'd3;

logic [255:0] i_a_reg, i_a_reg_nxt;

//FSN
logic [2:0] state, state_nxt;

//counter
logic [8:0] PREP_counter, PREP_counter_nxt;
logic [8:0] MONT_counter, MONT_counter_nxt;
logic [8:0] CALC_counter, CALC_counter_nxt;

//ModuloProduct
logic moduloproduct_valid;
logic [255:0] moduloproduct_N;
logic [256:0] moduloproduct_a;
logic [255:0] moduloproduct_b;
logic [8:0] moduloproduct_k;
logic [255:0] moduloproduct_output;
logic moduloproduct_ready;

//MontgomeryAlgorithm
logic montgomeryalgorithm_valid0;
logic [255:0] montgomeryalgorithm_N0;
logic [255:0] montgomeryalgorithm_m0;
logic [255:0] montgomeryalgorithm_t0;
logic [255:0] montgomeryalgorithm_output0;
logic montgomeryalgorithm_ready0;

logic montgomeryalgorithm_valid1;
logic [255:0] montgomeryalgorithm_N1;
logic [255:0] montgomeryalgorithm_m1;
logic [255:0] montgomeryalgorithm_t1;
logic [255:0] montgomeryalgorithm_output1;
logic montgomeryalgorithm_ready1;

//output
logic [255:0]   Rsa256Core_result;
logic 			Rsa256Core_ready;

logic	[255:0] t, t_nxt;
logic	[255:0] m, m_nxt;


assign o_a_pow_d = Rsa256Core_result;
assign o_finished = Rsa256Core_ready;

ModuloProduct ModuloProduct0(
	.i_clk(i_clk),
	.i_rst(i_rst),
	.i_valid(moduloproduct_valid),
	.i_N(moduloproduct_N),
	.i_a(moduloproduct_a),
	.i_b(moduloproduct_b),
	.i_k(moduloproduct_k),
	.o_moduloproduct(moduloproduct_output),
	.o_ready(moduloproduct_ready)
);

MontgomeryAlgorithm MontgomeryAlgorithm0(
	.i_clk(i_clk),
	.i_rst(i_rst),
	.i_valid(montgomeryalgorithm_valid0),
	.i_N(montgomeryalgorithm_N0),
	.i_m(montgomeryalgorithm_m0),
	.i_t(montgomeryalgorithm_t0),
	.o_montgomeryalgorithm(montgomeryalgorithm_output0),
	.o_ready(montgomeryalgorithm_ready0)
);

MontgomeryAlgorithm MontgomeryAlgorithm1(
	.i_clk(i_clk),
	.i_rst(i_rst),
	.i_valid(montgomeryalgorithm_valid1),
	.i_N(montgomeryalgorithm_N1),
	.i_m(montgomeryalgorithm_m1),
	.i_t(montgomeryalgorithm_t1),
	.o_montgomeryalgorithm(montgomeryalgorithm_output1),
	.o_ready(montgomeryalgorithm_ready1)
);
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
			if(montgomeryalgorithm_ready1 == 1) begin
				state_nxt = S_CALC;
			end
			else begin
				state_nxt = S_MONT;
			end
		end
		S_CALC : begin
			if(CALC_counter == 255) begin
				state_nxt = S_IDLE;
			end
			else begin
				state_nxt = S_MONT;
			end
		end
		default : begin
			state_nxt = state;
		end
	endcase
end

//counter 
always_comb begin
	case(state)
		S_IDLE : begin
			PREP_counter_nxt = 0;
			MONT_counter_nxt = 0;
			CALC_counter_nxt = 0;
		end
		S_PREP : begin
			PREP_counter_nxt = PREP_counter + 9'd1;
			MONT_counter_nxt = 0;
			CALC_counter_nxt = 0;
		end
		S_MONT : begin
			PREP_counter_nxt = 0;
			MONT_counter_nxt = MONT_counter + 9'd1;
			CALC_counter_nxt = CALC_counter;
		end
		S_CALC : begin
			PREP_counter_nxt = 0;
			MONT_counter_nxt = 0;
			CALC_counter_nxt = CALC_counter + 9'd1;
		end
		default : begin
			PREP_counter_nxt = 0;
			MONT_counter_nxt = 0;
			CALC_counter_nxt = 0;
		end
	endcase
end

always_comb begin
	i_a_reg_nxt = i_a_reg;
	if(state == S_IDLE && i_start == 1'b1) i_a_reg_nxt = i_a;
	else i_a_reg_nxt = i_a_reg;
end

always_comb begin
	case(state)
		S_IDLE : begin
			//ModuloProduct
			moduloproduct_valid = 0;
			moduloproduct_N = 0;
			moduloproduct_a = 0;
			moduloproduct_b = 0;
			moduloproduct_k = 0;
			//MontgomeryAlgorithm
			montgomeryalgorithm_valid0 = 0;
			montgomeryalgorithm_N0 = 0;
			montgomeryalgorithm_m0 = 0;
			montgomeryalgorithm_t0 = 0;

			montgomeryalgorithm_valid1 = 0;
			montgomeryalgorithm_N1 = 0;
			montgomeryalgorithm_m1 = 0;
			montgomeryalgorithm_t1 = 0;
		end
		S_PREP : begin
			//ModuloProduct
			if(PREP_counter == 0) begin
				moduloproduct_valid = 1'd1;
				$display("%d", t);
			end
			else begin
				moduloproduct_valid = 1'd0;
			end
			moduloproduct_N = i_n;
			moduloproduct_a =  257'b1 << 256 ;
			moduloproduct_b = i_a_reg;
			moduloproduct_k = 9'd257;
			//MontgomeryAlgorithm
			montgomeryalgorithm_valid0 = 0;
			montgomeryalgorithm_N0 = 0;
			montgomeryalgorithm_m0 = 0;
			montgomeryalgorithm_t0 = 0;

			montgomeryalgorithm_valid1 = 0;
			montgomeryalgorithm_N1 = 0;
			montgomeryalgorithm_m1 = 0;
			montgomeryalgorithm_t1 = 0;
		end
		S_MONT : begin
			//ModuloProduct
			moduloproduct_valid = 1'd0;
			moduloproduct_N = 0;
			moduloproduct_a = 0;
			moduloproduct_b = 0;
			moduloproduct_k = 0;
			//MontgomeryAlgorithm
			if(i_d[CALC_counter] == 1) begin
				if(MONT_counter == 0) begin
					montgomeryalgorithm_valid0 = 1'd1;
					montgomeryalgorithm_valid1 = 1'd1;
				end
				else begin
					montgomeryalgorithm_valid0 = 1'd0;
					montgomeryalgorithm_valid1 = 1'd0;
				end
			end
			else begin
				if(MONT_counter == 0) begin
					montgomeryalgorithm_valid0 = 1'd0;
					montgomeryalgorithm_valid1 = 1'd1;
				end
				else begin
					montgomeryalgorithm_valid0 = 1'd0;
					montgomeryalgorithm_valid1 = 1'd0;
				end
			end
			montgomeryalgorithm_N0 = i_n;
			montgomeryalgorithm_m0 = m;
			montgomeryalgorithm_t0 = t;

			montgomeryalgorithm_N1 = i_n;
			montgomeryalgorithm_m1 = t;
			montgomeryalgorithm_t1 = t;
		end
		S_CALC : begin
			//ModuloProduct
			moduloproduct_valid = 1'd0;
			moduloproduct_N = 0;
			moduloproduct_a = 0;
			moduloproduct_b = 0;
			moduloproduct_k = 0;
			//MontgomeryAlgorithm
			montgomeryalgorithm_valid0 = 0;
			montgomeryalgorithm_N0 = 0;
			montgomeryalgorithm_m0 = 0;
			montgomeryalgorithm_t0 = 0;

			montgomeryalgorithm_valid1 = 0;
			montgomeryalgorithm_N1 = 0;
			montgomeryalgorithm_m1 = 0;
			montgomeryalgorithm_t1 = 0;
		end
		default : begin
			//ModuloProduct
			moduloproduct_valid = 1'd0;
			moduloproduct_N = 0;
			moduloproduct_a = 0;
			moduloproduct_b = 0;
			moduloproduct_k = 0;
			//MontgomeryAlgorithm
			montgomeryalgorithm_valid0 = 0;
			montgomeryalgorithm_N0 = 0;
			montgomeryalgorithm_m0 = 0;
			montgomeryalgorithm_t0 = 0;

			montgomeryalgorithm_valid1 = 0;
			montgomeryalgorithm_N1 = 0;
			montgomeryalgorithm_m1 = 0;
			montgomeryalgorithm_t1 = 0;
		end
	endcase
end

always_comb begin
	case(state)
		S_IDLE : begin
			t_nxt = 0;
			m_nxt = 1;
		end
		S_PREP : begin
			if(moduloproduct_ready == 1) begin
				t_nxt = moduloproduct_output;
			end
			else begin
				t_nxt = t;
			end
			m_nxt = 1;
		end
		S_MONT : begin
			if(montgomeryalgorithm_ready0 == 1) begin
				m_nxt = montgomeryalgorithm_output0;
			end
			else begin
				m_nxt = m;
			end
			if(montgomeryalgorithm_ready1 == 1) begin
				t_nxt = montgomeryalgorithm_output1;
			end
			else begin
				t_nxt = t;
			end
		end
		S_CALC : begin
			t_nxt = t;
			m_nxt = m;
		end
		default : begin
			t_nxt = t;
			m_nxt = m;
		end
	endcase
end

always_comb begin
	case(state)
		S_IDLE : begin
			Rsa256Core_ready = 1'b0;
			Rsa256Core_result = 0;
		end
		S_PREP : begin
			Rsa256Core_ready = 1'b0;
			Rsa256Core_result = 0;
		end
		S_MONT : begin
			Rsa256Core_ready = 1'b0;
			Rsa256Core_result = 0;
		end
		S_CALC : begin
			if(CALC_counter == 255) begin
				Rsa256Core_ready = 1'b1;
				Rsa256Core_result = m;
			end
			else begin
				Rsa256Core_ready = 1'b0;
				Rsa256Core_result = 0;
			end
		end
		default : begin
			Rsa256Core_ready = 1'b0;
			Rsa256Core_result = 0;
		end
	endcase
end

always_ff @(posedge i_clk or posedge i_rst) begin
		// reset
	if (i_rst) begin
		state <= S_IDLE;
		t <= 0;
		m <= 1;
		PREP_counter <= 0;
		MONT_counter <= 0;
		CALC_counter <= 0;
		i_a_reg <= 0;
	end
	else begin
		state <= state_nxt;
		t <= t_nxt;
		m <= m_nxt;
		PREP_counter <= PREP_counter_nxt;
		MONT_counter <= MONT_counter_nxt;
		CALC_counter <= CALC_counter_nxt;
		i_a_reg <= i_a_reg_nxt;
	end
end

endmodule