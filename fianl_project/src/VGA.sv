module VGA(
    //de2-115
   input  i_rst_n,
   input  i_clk_25M,
   output [7:0] o_VGA_B,
	output o_VGA_BLANK_N,
	output o_VGA_CLK,
	output [7:0] o_VGA_G,
	output o_VGA_HS,
	output [7:0] o_VGA_R,
	output o_VGA_SYNC_N,
	output o_VGA_VS,
	input [15:0] i_display_data
);

parameter C_H_SYNC_PULSE = 96,
		  C_H_BACK_PORCH = 48,
		  C_H_ACTIVE_TIME = 640,
		  C_H_FRONT_PORCH = 16,
		  C_H_LINE_PERIOD = 800;

parameter C_V_SYNC_PULSE = 2,
		  C_V_BACK_PORCH = 33,
		  C_V_ACTIVE_TIME = 480,
		  C_V_FRONT_PORCH = 10,
		  C_V_FRAME_PERIOD = 525;

parameter S_IDLE = 2'd0,
		  S_RENEW = 2'd1;


reg [11:0] h_counter_r, h_counter_w;
reg [11:0] v_counter_r, v_counter_w;


logic [1:0] state_r, state_w;
logic frame_finish;

logic [15:0] SRAM_data;
logic [19:0] SRAM_address_r, SRAM_address_w;

assign o_hs = (h_counter_r < C_H_SYNC_PULSE) ? 1'b0 : 1'b1 ;
assign o_vs = (v_counter_r < C_V_SYNC_PULSE) ? 1'b0 : 1'b1 ;
assign o_SRAM_address = (state == S_RENEW)? SRAM_address : 20'bz;
assign SRAM_data = i_SRAM_data;
assign o_red = SRAM_data[4:0];
assign o_green = SRAM_data[5:0];
assign o_blue = SRAM_data[5:0];

//state
always_comb begin
	state_w = state_r;
	case(state_r)
		S_IDLE : begin
			if(i_en == 1) begin
				state_w = S_RENEW;
			end
			else begin
				state_w =  S_IDLE;
			end
		end
		S_RENEW : begin
			if(frame_finish) begin
				state_w =  S_IDLE;
			end
			else begin
				state_w = S_RENEW;
			end
		end
	endcase
end

always_comb begin
	h_counter_w = h_counter_r;
	v_counter_w = v_counter_r;
	SRAM_address_w = SRAM_address_r;
	case(state)
		S_IDLE : begin
			h_counter_w = 0;
			v_counter_w = 0;
			SRAM_address_w = 0;
		end
		S_RENEW : begin
			//h_counter
			if(h_counter_r == C_H_LINE_PERIOD - 1'b1) begin
				h_counter_w = 0;
			end
			else begin
				h_counter_w = h_counter_r + 12'd1;
			end
			
			//v_counter
			if(R_v_cnt == C_V_FRAME_PERIOD - 1'b1) begin
				v_counter_w <= 12'd0 ;
			end
			else if(R_h_cnt == C_H_LINE_PERIOD - 1'b1) begin
				v_counter_w <= v_counter_r + 12'd1 ;
			end
			else begin
				v_counter_w <= v_counter_r;
			end

			//SRAM_address_w
			SRAM_address_w = SRAM_address_r + 20'd1;
		end
	endcase
end


always_ff @(posedge i_25M_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
		state_r <= S_IDLE;
		h_counter_r <= 0;
		v_counter_r <= 0;
		SRAM_address_r <= 0;
	end
	else begin
		state_r <= state_w;
		h_counter_r <= h_counter_w;
		v_counter_r <= v_counter_w;
		SRAM_address_r <= SRAM_address_w;
	end
end



endmodule

