`define L  32
`define DELTA_START  147
`define DELTA_LAST  179
`define BUFFER_LENGTH  65//`L + `DELTA_LAST - `DELTA_START + 1
`define PIXEL_ROW  480
`define PIXEL_COLUMN  640
`define PIXEL_LENGTH  307200//`PIXEL_ROW * `PIXEL_COLUMN
`define MIC_NUMBER 16
`define READBIT 16

`define H_SYNC  96
`define H_BACK  40
`define H_LEFT  8
`define H_ACT  640//`PIXEL_COLUMN
`define H_RIGHT  8
`define H_FRONT  8
`define H_VALID_LB   144//`H_SYNC + `H_BACK + `H_LEFT 
`define H_VALID_UB   784//`H_SYNC + `H_BACK + `H_LEFT + `H_ACT
`define H_TOTAL  800//`H_VALID_LB + `H_ACT + `H_RIGHT + `H_FRONT //800

`define V_SYNC  2
`define V_BACK  25
`define V_TOP  8
`define V_ACT  480//`PIXEL_ROW
`define V_BOTTOM  8
`define V_FRONT  2
`define V_VALID_LB    35//`V_SYNC + `V_BACK + `V_TOP
`define V_VALID_UB    515//`V_SYNC + `V_BACK + `V_TOP + `V_ACT
`define V_TOTAL  525//`V_VALID_LB + `V_ACT + + `V_BOTTOM + `V_FRONT // 525



module Top(
    input i_50M_clk, //50M
    input i_BCLK, 
    input i_LRCK,
    input i_rst, //key[3]
    input i_start, //key[0]
    input i_mic_data [`MIC_NUMBER-1:0],
    //SRAM
	output [19:0] o_SRAM_ADDR, //read/write address
	inout  [15:0] io_SRAM_DQ,  //read/write 16bit data
	output        o_SRAM_WE_N, //sram write enable
	output        o_SRAM_CE_N, //sram output enable
	output        o_SRAM_OE_N, //sram Upper-byte control(IO15-IO8)
	output        o_SRAM_LB_N, //sram Lower-byte control(IO7-IO0)
	output        o_SRAM_UB_N, //sram Chip enable

    // VGA
    output [7:0] VGA_R,
    output [7:0] VGA_G,
    output [7:0] VGA_B,
    output VGA_BLANK_N,
    output VGA_CLK,
    output VGA_HS,
    output VGA_SYNC_N,
    output VGA_VS
);

localparam S_IDLE = 0;
localparam S_INITIAL = 1; // fill in the buffer
localparam S_CALCULATE = 2;

logic [2:0] state_r, state_w;
logic [$clog2(`H_TOTAL)-1:0] column_counter_r, column_counter_w;
logic [$clog2(`V_TOTAL)-1:0] row_counter_r, row_counter_w;
logic [$clog2(`BUFFER_LENGTH)-1:0] frame_counter_r, frame_counter_w;

logic signed [$clog2(`PIXEL_COLUMN)-1:0] pos_coordinate_x;
logic signed [$clog2(`PIXEL_ROW)-1:0] pos_coordinate_y;
logic signed [$clog2(`PIXEL_COLUMN)-1:0] sign_coordinate_x;
logic signed [$clog2(`PIXEL_ROW)-1:0] sign_coordinate_y;

logic [$clog2(`DELTA_LAST)-1 : 0] delta_array [`MIC_NUMBER-1 : 0];
logic signed [`READBIT-1:0] L_buffer_data[`MIC_NUMBER-1 : 0];
logic signed [`READBIT-1:0] buffer_data [`MIC_NUMBER-1 : 0];

logic read_sram;
logic stop;
logic change_pointer_r, change_pointer_w;
logic initial_start, calculate_start;
logic initial_start_25, calculate_start_25;

//for add&square
logic [34:0] add_square_data, L_add_square_data;
//for SRAM
logic [15:0] sram_data_read, sram_data_write;


 
Clock_Generate clock25_generate(
    .i_fast_50M_clk(i_50M_clk),
    .i_rst(i_rst),
    .o_slow_25M_clk(i_25M_clk)
);

assign io_SRAM_DQ  = (!read_sram) ? sram_data_write : 16'dz; // sram_dq as output
assign sram_data_read = (read_sram) ? io_SRAM_DQ : 16'd0; // sram_dq as input

assign o_SRAM_WE_N = (!read_sram) ? 1'b0 : 1'b1;
assign o_SRAM_CE_N = 1'b0;
assign o_SRAM_OE_N = 1'b0;
assign o_SRAM_LB_N = 1'b0;
assign o_SRAM_UB_N = 1'b0;

assign pos_coordinate_x = (column_counter_r >= `H_VALID_LB && column_counter_r < `H_VALID_UB) ? (column_counter_r - `H_VALID_LB) : 10'dx;
assign pos_coordinate_y = (row_counter_r >= `V_VALID_LB && row_counter_r < `V_VALID_UB) ? (row_counter_r - `V_VALID_LB) : 10'dx;
assign sign_coordinate_x = pos_coordinate_x - (`PIXEL_COLUMN >> 1);
assign sign_coordinate_y = pos_coordinate_y - (`PIXEL_ROW >> 1);


Delta_generator delta_generator0(
    .p_x(sign_coordinate_x),
    .p_y(sign_coordinate_y),
    .delta(delta_array)
);

genvar idx;
generate
    for(idx=0;idx<`MIC_NUMBER;idx = idx+1) begin : PEs
        RingBuffer ring_buffer_generate(
            .i_clk(i_25M_clk),
            .i_fast_clk(i_50M_clk),
            .i_BCLK(i_BCLK),
            .i_LRCK(i_LRCK),
            .i_rst(i_rst),
            .i_initial_start(initial_start),
            .i_iterate_start(calculate_start),
            .i_change_pointer(change_pointer_r),
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
	.i_init_valid(initial_start),
    .i_calc_valid(calculate_start),
    .i_stop(stop),
    .i_px(pos_coordinate_x), //positive coordinate
    .i_py(pos_coordinate_y), //positive coordinate
	.i_new_data(add_square_data), // this data has been divided by L
	.i_old_data(L_add_square_data), // this data has been divided by L
    .i_sram_data_read(sram_data_read), // use when i_read_write = 0
	.o_sram_data_write(sram_data_write), // use when i_read_write = 1
	.o_SRAM_addr(o_SRAM_ADDR), //addr = 640x +y       
	.o_read_sram(read_sram)
);

VGA vga0(
    //de2-115
    .i_clk_25M(i_25M_clk),
    .i_rst(i_rst),
    .i_display_data(sram_data_read),
    .o_VGA_B(VGA_B),
	.o_VGA_BLANK_N(VGA_BLANK_N),
	.o_VGA_CLK(VGA_CLK),
	.o_VGA_G(VGA_G),
	.o_VGA_HS(VGA_HS),
	.o_VGA_R(VGA_R),
	.o_VGA_SYNC_N(VGA_SYNC_N),
	.o_VGA_VS(VGA_VS)
);

always_comb begin
    state_w = state_r;
    case(state_r)
        S_IDLE: begin
            if(i_start && !i_25M_clk) state_w = S_INITIAL;
            initial_start = 0;
            calculate_start = 0;
        end

        S_INITIAL: begin
            if(row_counter_r == 0 && column_counter_r == 0 && frame_counter_r == 0 && i_25M_clk) initial_start = 1;
            else initial_start = 0;

            if(frame_counter_r == `BUFFER_LENGTH - 1 && i_25M_clk) begin
                calculate_start = 1;
                state_w = S_CALCULATE;
            end
            else calculate_start = 0;
        end

        S_CALCULATE: begin
            initial_start = 0;
            calculate_start = 0;
        end
    endcase
end


always_comb begin
    column_counter_w = column_counter_r;
    row_counter_w = row_counter_r;
    change_pointer_w = change_pointer_r;
    case(state_r)
        S_IDLE: begin
            column_counter_w = 0;
            row_counter_w = 0;
            change_pointer_w = 0;
        end
        S_INITIAL, S_CALCULATE: begin
            if(!i_25M_clk) begin
                change_pointer_w = 0;
                if(row_counter_r < `V_VALID_LB || column_counter_r == `H_TOTAL || row_counter_r >= `V_VALID_UB-1) begin
                    column_counter_w = 0;
                    row_counter_w = row_counter_w + 1;
                end
                else begin
                    column_counter_w = column_counter_r + 1;
                    row_counter_w = row_counter_r;
                end
                if(row_counter_r == `V_TOTAL) begin
                    row_counter_w = 0;
                    change_pointer_w = 1;
                end
            end
        end
    endcase
end

always_comb begin
    frame_counter_w = frame_counter_r;
    if(state_r == S_INITIAL && !i_25M_clk && row_counter_r == `V_TOTAL) frame_counter_w = frame_counter_r + 1;
    if(state_r != S_INITIAL) frame_counter_w = 0;
end

always_comb begin
    stop = 0;
    if(state_r != S_IDLE)begin
			if(row_counter_r < `V_VALID_LB || row_counter_r >= `V_VALID_UB-1 || column_counter_r < `H_VALID_LB || column_counter_r >= `H_VALID_UB-1) stop = 1;
	 end
	 
end


always_ff @(posedge i_50M_clk or posedge i_rst) begin
	if(i_rst)begin
        state_r <= 0;
        column_counter_r <= 0;
        row_counter_r <= 0;
        frame_counter_r <= 0;
        change_pointer_r <= 0;
	end
	else begin
        state_r <= state_w;
        column_counter_r <= column_counter_w ;
        row_counter_r <= row_counter_w;
        frame_counter_r <= frame_counter_w;
        change_pointer_r <= change_pointer_w;
	end
end
endmodule

