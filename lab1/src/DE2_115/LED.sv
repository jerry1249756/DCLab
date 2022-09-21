module LED (
	input  i_clk,
	input  [2:0] i_state,
   input  [3:0] i_random_out,
	input  i_rst_n,
	output [8:0] o_LEDG,
	output [17:0] o_LEDR
);

parameter S_IDLE = 3'd0;
parameter S_FAST = 3'd1;
parameter S_MEDIUM = 3'd2;
parameter S_SLOW = 3'd3;
parameter S_STOP = 3'd4;
parameter S_FINAL = 3'd5;

logic [8:0] LEDG, LEDG_nxt;
logic [17:0] LEDR, LEDR_nxt;

logic [31:0] clock_number, clock_number_nxt;
logic [24:0] clock_number_mod;

logic [31:0] IDLE_counter, IDLE_counter_nxt;

assign o_LEDG = LEDG;
assign o_LEDR = LEDR;


always_comb begin
	clock_number_nxt = clock_number + 32'd1;
end
always_comb begin
	if(i_state == S_IDLE) IDLE_counter_nxt = IDLE_counter + 32'd1;
	else IDLE_counter_nxt = 0;
end

assign clock_number_mod = clock_number[24:0];

always_comb begin
	case(i_state)
		S_IDLE: begin
			if(clock_number_mod == 0) begin
				if(IDLE_counter == 0) LEDR_nxt = 32'd3;
				else begin
					if(LEDR == 18'b11_0000_0000_0000_0000) LEDR_nxt = 32'd3;
					else LEDR_nxt = LEDR << 2;
				end
			end
			else begin
				LEDR_nxt = LEDR;
			end
			LEDG_nxt = 9'b0000_0001_1;
		end
		S_FAST:begin
			LEDR_nxt = {i_random_out[1:0],i_random_out , i_random_out, i_random_out, i_random_out};
			LEDG_nxt = 9'b011_0_0000_0;
		end
		S_MEDIUM:begin
			LEDR_nxt = {i_random_out[1:0],i_random_out , i_random_out, i_random_out, i_random_out};
			LEDG_nxt = 9'b0001_1000_0;
		end
		S_SLOW:begin
			LEDR_nxt = {i_random_out[1:0],i_random_out , i_random_out, i_random_out, i_random_out};
			LEDG_nxt = 9'b0000_0110_0;
		end
		S_FINAL:begin
			LEDR_nxt = {i_random_out[1:0],i_random_out , i_random_out, i_random_out, i_random_out};
			LEDG_nxt = 9'b0000_0001_1;
		end
		default: begin
			LEDR_nxt = {i_random_out[1:0],i_random_out , i_random_out, i_random_out, i_random_out};
			LEDG_nxt = clock_number[16:9];
		end
	endcase
end


always_ff @(posedge i_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
			clock_number = 0;
			LEDG = 0;
			LEDR = 0;
			IDLE_counter = 0;
		end
		else begin
			clock_number = clock_number_nxt;
			LEDG = LEDG_nxt;
			LEDR = LEDR_nxt;
			IDLE_counter = IDLE_counter_nxt;
		end
	end
endmodule
