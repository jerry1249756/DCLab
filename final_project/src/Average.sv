module Average(
    input                              i_50M_clk        ,
	//input                              i_25M_clk        , //0: read, 1: write
	input                              i_rst            ,
	input                              i_init_valid     ,
	input                              i_calc_valid     ,
	input                              i_stop           ,
    input  [$clog2(`PIXEL_COLUMN)-1:0] i_px             ,
    input  [$clog2(`PIXEL_ROW)-1:0]    i_py             ,
	input  [34:0]                      i_new_data       , // input: square a 16-bit data sum and divided by L. At most 35-bit
	input  [34:0]                      i_old_data       , // input: square a 9-bit data sum and divided by L. At most 35-bit  
	input  [15:0]                      i_sram_data_read , // input: truncated SRAM data, only stores 16-bit, with lowest 10-bit as 0. 
	output [15:0]                      o_sram_data_write, // input: truncated SRAM data, only stores 16-bit, with lowest 10-bit as 0.
	output [19:0]                      o_SRAM_addr            // output: SRAM addr = 640x + y         
);

parameter S_IDLE = 2'd0;
parameter S_READ_SRAM = 2'd1;
parameter S_WRITE_SRAM_INIT = 2'd2;
parameter S_WRITE_SRAM_CALC = 2'd3;

logic calc_with_SRAM, calc_with_SRAM_nxt;
logic i_stop_dly;
logic [1:0] state, state_nxt;
logic [39:0] temp_data, temp_data_nxt, total_data; 
logic signed [39:0] calc_data;

assign calc_data = (state == S_WRITE_SRAM_CALC || state == S_WRITE_SRAM_INIT) ? i_new_data - i_old_data : 40'b0;
assign total_data = (calc_with_SRAM) ? temp_data + calc_data : calc_data;
assign o_sram_data_write = total_data[39:24]; 

assign o_SRAM_addr = 640*i_px + i_py;

always_comb begin
	case(state)
		S_IDLE: begin
			if(i_init_valid || (i_stop_dly && !i_stop)) state_nxt = S_READ_SRAM; //detecting the posedge of i_init_valid or the negedge of i_stop
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
	case(state)
		S_READ_SRAM: begin 
			temp_data_nxt[39:24] = i_sram_data_read;
			temp_data_nxt[23:0] = 24'b0;
		end
	endcase
end

always_comb begin
	if(i_calc_valid) calc_with_SRAM_nxt = 1'b1;
	else calc_with_SRAM_nxt = calc_with_SRAM;
end

always_ff @(posedge i_50M_clk or posedge i_rst) begin
	i_stop_dly <= i_stop;
    if (i_rst) begin
		state <= S_IDLE;
		temp_data <= 40'b0;
		calc_with_SRAM <= 1'b0;
    end
    else begin
		state <= state_nxt;
		temp_data <= temp_data_nxt;
		calc_with_SRAM <= calc_with_SRAM_nxt;
    end
end

endmodule