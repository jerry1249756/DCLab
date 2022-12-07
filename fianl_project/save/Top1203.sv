`define L = 32
`define DELTA_START = 147
`define DELTA_LAST = 169
`define BUFFER_LENGTH = L + DELTA_LAST - DELTA_START + 1
`define PIXEL_ROW = 480
`define PIXEL_COLUMN = 640
`define PIXEL_LENGTH = PIXEL_ROW * PIXEL_COLUMN
`define MIC_NUMBER = 16

// i_25M_clk = 1 , write 
// i_25M_clk = 1 , read


module Top(
    input i_50M_clk, //50M
    input i_BCLK, 
    input i_LRCK,
    input i_rst, //key[3]
    input i_start, //key[0]
    
    // AudDSP and SRAM
	output [19:0] o_SRAM_ADDR, //read/write address
	inout  [15:0] io_SRAM_DQ,  //read/write 16bit data
	output        o_SRAM_WE_N, //sram write enable
	output        o_SRAM_CE_N, //sram output enable
	output        o_SRAM_OE_N, //sram Upper-byte control(IO15-IO8)
	output        o_SRAM_LB_N, //sram Lower-byte control(IO7-IO0)
	output        o_SRAM_UB_N, //sram Chip enable

    input [23:0] i_mic_data[MIC_NUMBER-1:0],

);

localparam S_IDLE = 0;
localparam S_INITIAL = 1; // fill in the buffer
localparam S_CALCULATE = 2;
localparam S_DISPLAY = 3;


logic [2:0] state_r, state_w;
logic [$clog2(PIXEL_COLUMN)-1:0] column_counter_r, column_counter_w;
logic [$clog2(PIXEL_ROW)-1:0] row_counter_r, row_counter_w;
logic [$clog2(BUFFER_LENGTH)-1:0] frame_counter_r, frame_counter_w;
logic signed [$clog2(PIXEL_COLUMN)-1:0] sign_coordinate_x;
logic signed [$clog2(PIXEL_ROW)-1:0] sign_coordinate_y;
logic [MIC_NUMBER-1 : 0][$clog2(DELTA_LAST)-1 : 0] delta_array;
logic [MIC_NUMBER-1 : 0][23:0] L_buffer_data, buffer_data,
logic calculate_start_r, calculate_start_w; 

//for add&square
logic [15:0] add_square_data, L_add_square_data;
//for SRAM
logic [15:0] sram_data_read, sram_data_write;
 

assign io_SRAM_DQ  = (i_25M_clk) ? sram_data_write : 16'dz; // sram_dq as output
assign sram_data_read = (!i_25M_clk) ? io_SRAM_DQ : 16'd0; // sram_dq as input

assign o_SRAM_WE_N = (i_25M_clk) ? 1'b0 : 1'b1;
assign o_SRAM_CE_N = 1'b0;
assign o_SRAM_OE_N = 1'b0;
assign o_SRAM_LB_N = 1'b0;
assign o_SRAM_UB_N = 1'b0;

assign sign_coordinate_x = column_counter_r - (PIXEL_COLUMN >> 1);
assign sign_coordinate_y = row_counter_r - (PIXEL_ROW >> 1);

Clock_Generate clock25_generate(
    .i_fast_50M_clk(i_50M_clk),
    .i_rst(i_rst),
    .o_slow_25M_clk(i_25M_clk)
);

Delta_generator delta_generator0 (
    .p_x(sign_coordinate_x),
    .p_y(sign_coordinate_y),
    .delta(delta_array)
);



genvar idx;
generate
    for(idx=0; idx<MIC_NUMBER, idx = idx+1) begin
        RingBuffer ring_buffer_generate(
            .i_clk(i_50M_clk),
            .i_BCLK(i_BCLK),
            .i_LRCK(i_LRCK),
            .i_rst(i_rst),
            .i_start(i_start),
            .i_data(i_mic_data[idx]),
            .i_delta(delta_array[idx]),
            .o_L_buffer_data(L_buffer_data[idx]),
            .o_buffer_data(buffer_data[idx])
        );
    end
endgenerate

Add_Square add_square0(
	.i_data(buffer_data),
    .o_add_square_data(add_square_data)                  
); 

Add_Square add_square1(
	.i_data(L_buffer_data),
    .o_add_square_data(L_add_square_data)                  
); 

Average average0(
    .i_50M_clk(i_50M_clk),
	.i_rst(i_rst),
	.i_valid(calculate_start_r), // high when S_CALCULATE start
    .i_read_write(i_25M_clk), // read:0 , write:1
    .i_px(sign_coordinate_x),
    .i_py(sign_coordinate_y),
	.i_new_data(L_add_square_data), // this data has been divided by L
	.i_old_data(add_square_data), // this data has been divided by L
    .i_sram_data_read(sram_data_read), // use when i_read_write = 0
	.o_sram_data_write(sram_data_write), // use when i_read_write = 1
	.o_SRAM_addr(o_SRAM_ADDR), //addr = 640x +y       
);

always_comb begin
    state_w = state_r;
    calculate_start_w = calculate_start_r;
    case(state_r)
        S_IDLE: if(i_start) state_w = S_INITIAL;
        S_INITIAL: begin
            if(frame_counter_r == BUFFER_LENGTH - 1 && !i_25M_clk) begin
                state_w = S_CALCULATE;
                calculate_start_w = 1;
            end
        end
        S_CALCULATE: begin
            calculate_start_w = 0;
        end
    endcase
end

// row column frame counter
always_comb begin
    column_counter_w = column_counter_r;
    row_counter_w = row_counter_r;
    frame_counter_w = frame_counter_r;
    if(!i_25M_clk) begin
        if(column_counter_r == PIXEL_COLUMN - 1) begin
            column_counter_w = 0;
            if(row_counter_r == PIXEL_ROW - 1) begin
                row_counter_w = 0;
                frame_counter_w = frame_counter_r + 1;
            end
            else row_counter_w = row_counter_r + 1;
        end
        else column_counter_w = column_counter_r + 1;
    end
end

always_ff @(posedge i_50M_clk or posedge i_rst) begin
	if(i_rst)begin
        column_counter_r <= 0;
        row_counter_r <= 0;
        frame_counter_r <= 0;
        calculate_start_r <= 0;
	end
	else begin
        column_counter_r <= column_counter_w ;
        row_counter_r <= row_counter_w;
        frame_counter_r <= frame_counter_w;
        calculate_start_r <= calculate_start_w;
	end
end


endmodule