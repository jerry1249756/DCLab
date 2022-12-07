module Average(
    input          i_50M_clk            ,
	input          i_rst                ,
	input          i_init_valid         ,
	input          i_calc_valid         ,
	input          i_stop               ,
    input   [8:0]  i_px                 ,
    input   [8:0]  i_py                 ,
	input   [50:0] i_new_data           ,
	input   [50:0] i_old_data           ,   
	input   [15:0] i_sram_data_read     , 
	output  [15:0] o_sram_data_write    , 
	output  [19:0] o_SRAM_addr           //addr = 640x + y         
);

parameter S_IDLE = 2'd0;
parameter S_READ_SRAM = 2'd1;
parameter S_WRITE_SRAM_INIT = 2'd2;
parameter S_WRITE_SRAM_CALC = 2'd3;

logic calc_with_SRAM, calc_with_SRAM_nxt;
logic i_init_valid_dly;
logic [1:0] state, state_nxt;
logic [15:0] temp_data, temp_data_nxt, calc_data;

assign calc_data = (state == S_WRITE_SRAM_CALC || state == S_WRITE_SRAM_INIT) ? i_new_data - i_old_data : 16'b0;
assign o_sram_data_write = (calc_with_SRAM) ? temp_data + calc_data : calc_data;

assign o_SRAM_addr = 640*i_px + i_py;

always_comb begin
	case(state)
		S_IDLE: begin
			if(i_init_valid_dly) state_nxt = S_READ_SRAM; //detecting the posedge of i_Valid
			else state_nxt = S_IDLE;
		end
		S_READ_SRAM: begin
			if(i_stop) state_nxt = S_IDLE;
			else if (calc_with_SRAM) state_nxt = S_WRITE_SRAM_CALC;
			else state_nxt = S_WRITE_SRAM_INIT;
		end
		S_WRITE_SRAM_INIT: begin
			if(i_stop) state_nxt = S_IDLE;
			else state_nxt = S_READ_SRAM;
		end
		S_WRITE_SRAM_CALC: begin
			if(i_stop) state_nxt = S_IDLE;
			else state_nxt = S_READ_SRAM;
		end
	endcase
end

always_comb begin
	temp_data_nxt = temp_data;
	if(i_calc_valid) calc_with_SRAM_nxt = 1'b1;
	else calc_with_SRAM_nxt = calc_with_SRAM;
	case(state)
		S_READ_SRAM: temp_data_nxt = i_sram_data_read;
	endcase
end

always_ff @(posedge i_50M_clk or posedge i_rst) begin
    if (i_rst) begin
		state <= S_IDLE;
		temp_data <= 16'b0;
		i_init_valid_dly <= i_init_valid;
		calc_with_SRAM <= 1'b0;
    end
    else begin
		state <= state_nxt;
		temp_data <= temp_data_nxt;
		i_init_valid_dly <= i_init_valid;
		calc_with_SRAM <= calc_with_SRAM_nxt;
    end
end

endmodule