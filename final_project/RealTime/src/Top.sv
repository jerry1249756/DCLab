`define L  32
`define DELTA_START  74
`define DELTA_LAST  127
`define BUFFER_LENGTH  85//`L + `DELTA_LAST - `DELTA_START 
`define PIXEL_ROW  60
`define PIXEL_COLUMN  80
`define PIXEL_LENGTH  307200//`PIXEL_ROW * `PIXEL_COLUMN
`define MIC_NUMBER 16
`define READBIT 24

`define display_data_bit 24
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
    input i_25M_clk,
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
localparam S_RECORD = 1;
localparam S_CALCULATE = 2;
localparam S_VGA = 3;

logic [1:0] state_r, state_w;
logic [$clog2(`PIXEL_COLUMN*`PIXEL_ROW*`L):0] counter_50M_clk_r, counter_50M_clk_w;
logic [$clog2(`PIXEL_ROW)-1:0] row_counter_r, row_counter_w;
logic [$clog2(`PIXEL_COLUMN)-1:0] column_counter_r, column_counter_w;

logic [$clog2(`PIXEL_ROW)-1:0] row_counter_d_r, row_counter_d_w;
logic [$clog2(`PIXEL_COLUMN)-1:0] column_counter_d_r, column_counter_d_w;

logic [$clog2(`L):0] L_counter_r, L_counter_w;
logic read_writeb_r, read_writeb_w;
logic change_pointer;

//delta generator
logic signed [$clog2(`PIXEL_COLUMN)-1:0] sign_coordinate_x;
logic signed [$clog2(`PIXEL_ROW)-1:0] sign_coordinate_y;
logic [$clog2(`DELTA_LAST)-1 : 0] delta_array [`MIC_NUMBER-1 : 0];

//ring buffer
logic rb_black_finish, rb_color_finish;
logic ringbuffer_initial_finish [`MIC_NUMBER-1:0];
logic signed [`READBIT-1:0] buffer_data [`MIC_NUMBER-1:0];

//add square
logic [15:0] add_square_data; 
logic [15:0] add_square_sram_read;
//SRAM 
logic [15:0] sram_data_read, sram_data_write;
logic [19:0] cal_read_addr, cal_write_addr;

//VGA
logic VGA_black_finish;
logic VGA_color_finish;
logic [19:0] VGA_ADDR;
logic VGA_color_blackb_r, VGA_color_blackb_w;

assign io_SRAM_DQ  = (!read_writeb_r && state_r == S_CALCULATE && L_counter_r < `L) ? sram_data_write : 16'dz; // sram_dq as output
assign sram_data_read = (read_writeb_r && (state_r == S_CALCULATE || state_r == S_VGA)) ? io_SRAM_DQ : 16'd0; // sram_dq as input

assign o_SRAM_WE_N = (!read_writeb_r && state_r == S_CALCULATE && L_counter_r < `L) ? 1'b0 : 1'b1;
assign o_SRAM_CE_N = 1'b0;
assign o_SRAM_OE_N = 1'b0;
assign o_SRAM_LB_N = 1'b0;
assign o_SRAM_UB_N = 1'b0;

//delta generate coordinate
assign sign_coordinate_x = column_counter_r - (`PIXEL_COLUMN >> 1);
assign sign_coordinate_y = row_counter_r - (`PIXEL_ROW >> 1);

assign rb_black_finish = VGA_black_finish && read_writeb_r;
assign rb_color_finish = VGA_color_finish && read_writeb_r;

//ADD square 
assign sram_data_write = (state_r == S_CALCULATE && !read_writeb_r) ? add_square_data : 16'dz;

assign cal_read_addr = column_counter_r + row_counter_r*`PIXEL_COLUMN ;
assign cal_write_addr = column_counter_d_r + row_counter_d_r*`PIXEL_COLUMN ; 
assign o_SRAM_ADDR = (state_r == S_CALCULATE) ? ((read_writeb_r) ? cal_read_addr : cal_write_addr) : (state_r == S_VGA) ? VGA_ADDR : 0;

assign add_square_sram_read = (L_counter_r == 0) ? 16'b0 : sram_data_read;

Delta_generator delta_generator0(
    .p_x(sign_coordinate_x),
    .p_y(sign_coordinate_y),
    .delta(delta_array)
);

genvar idx;
generate
    for(idx=0;idx<`MIC_NUMBER;idx = idx+1) begin : RINGBUFFERs
        ring_buffer ring_buffer0(
         .i_50M_clk(i_50M_clk),
         .i_BCLK(i_BCLK),
         .i_LRCK(i_LRCK),
         .i_rst(i_rst),
         .i_start(i_start),
         .i_data(i_mic_data[idx]),
         .i_delta(delta_array[idx]),
         .i_change_pointer(change_pointer),
         .i_black_finish(rb_black_finish),
         .i_color_finish(rb_color_finish),
         .o_buffer_data(buffer_data[idx]),
         .o_initial_finish(ringbuffer_initial_finish[idx])
        );
    end
endgenerate


Add_Square Add_Square1(
    .i_clk(i_50M_clk),
    .i_rst(i_rst),
	.i_data(buffer_data),
    .i_addsquare_sramread(add_square_sram_read),
	.o_add_square_data(add_square_data)                
); 

VGA VGA0(
    .i_rst(i_rst),
    .i_clk_25M(i_25M_clk),
    .i_start_display(i_start),
    .i_display_data(sram_data_read),
    .i_color_blackb(VGA_color_blackb_r),
    .o_VGA_B(VGA_B),
	.o_VGA_BLANK_N(VGA_BLANK_N),
	.o_VGA_CLK(VGA_CLK),
	.o_VGA_G(VGA_G),
	.o_VGA_HS(VGA_HS),
	.o_VGA_R(VGA_R),
	.o_VGA_SYNC_N(VGA_SYNC_N),
	.o_VGA_VS(VGA_VS),
    .o_access_address(VGA_ADDR),
    .o_black_finish(VGA_black_finish),
    .o_color_finish(VGA_color_finish)
);

always_comb begin
    read_writeb_w = ~read_writeb_r;
    column_counter_d_w = column_counter_r;
    row_counter_d_w = row_counter_r;
    case(state_r)
        S_VGA: read_writeb_w = 1;
    endcase
end

always_comb begin
    state_w = state_r;
    case(state_r) 
        S_IDLE: if(i_start) state_w = S_RECORD;
        S_RECORD: begin
            if(ringbuffer_initial_finish[0] && read_writeb_r) state_w = S_CALCULATE;
        end
        S_CALCULATE: begin
            if(rb_black_finish) state_w = S_VGA;
        end
        S_VGA: begin
            if(rb_color_finish) state_w = S_RECORD;
        end
    endcase
end

always_comb begin
    column_counter_w = column_counter_r;
    row_counter_w = row_counter_r;
    counter_50M_clk_w = counter_50M_clk_r;
    L_counter_w = L_counter_r;
    case(state_r) 
        S_IDLE, S_RECORD: begin
            column_counter_w = 0;
            row_counter_w = 0;
            counter_50M_clk_w = 0;
            L_counter_w = 0;
        end
        S_CALCULATE: begin
            if(read_writeb_r)begin
                counter_50M_clk_w = counter_50M_clk_r + 1;
                if(column_counter_r == `PIXEL_COLUMN - 1)begin
                    column_counter_w = 0;
                    row_counter_w = row_counter_r + 1;
                end
                else begin
                    column_counter_w = column_counter_r + 1;
                end
                if(row_counter_r == `PIXEL_ROW - 1 && column_counter_r == `PIXEL_COLUMN - 1 )begin
                    row_counter_w = 0;
                    if(L_counter_r != `L) L_counter_w = L_counter_r + 1;
                end
            end
        end
        S_VGA: begin
            column_counter_w = 0;
            row_counter_w = 0;
            counter_50M_clk_w = 0;
            L_counter_w = 0;
        end
    endcase
end

always_comb begin
    change_pointer = 0;
    if(state_r == S_CALCULATE && read_writeb_r) begin
        if(row_counter_r == `PIXEL_ROW - 1 && column_counter_r == `PIXEL_COLUMN - 1)begin
            change_pointer = 1;
        end
    end
end

always_comb begin
    VGA_color_blackb_w = VGA_color_blackb_r;
    case(state_r) 
        S_RECORD : VGA_color_blackb_w = 0;
        S_CALCULATE: VGA_color_blackb_w = 0;
        S_VGA: VGA_color_blackb_w = 1;
    endcase
end

// always_comb begin
//     L_counter_w = L_counter_r;
//     if(state_r == S_CALCULATE) L_counter_w = L_counter_r + 1;
//     else L_counter_w = 0;
// end





always_ff @ (posedge i_50M_clk or posedge i_rst) begin
    if(i_rst) begin
        read_writeb_r <= 0;
        state_r <= 0;
        column_counter_r <= 0;
        row_counter_r <= 0;
        counter_50M_clk_r <= 0;
        column_counter_d_r <= 0;
        row_counter_d_r <= 0;
        L_counter_r <= 0;
        VGA_color_blackb_r <= 0;
    end
    else begin
        read_writeb_r <= read_writeb_w;
        state_r <= state_w;
        column_counter_r <= column_counter_w;
        row_counter_r <= row_counter_w;
        counter_50M_clk_r <= counter_50M_clk_w;
        column_counter_d_r <= column_counter_d_w;
        row_counter_d_r <= row_counter_d_w;
        L_counter_r <= L_counter_w;
        VGA_color_blackb_r <= VGA_color_blackb_w;
    end
end
// always_ff @ (posedge i_LRCK or posedge i_rst) begin
//     if(i_rst) begin
//         L_counter_r <= 0;
//     end
//     else begin
//         L_counter_r <= L_counter_w;
//     end
// end

endmodule