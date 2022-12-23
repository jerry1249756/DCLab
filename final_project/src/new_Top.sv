`define SRAM_PARALLEL  6
`define PARALLEL 5
`define NUM_50M 999


`define L  32
`define DELTA_START  147
`define DELTA_LAST  179
`define BUFFER_LENGTH  64//`L + `DELTA_LAST - `DELTA_START + 1
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
localparam S_INITIAL = 1;
localparam S_ITERATE = 2;
localparam S_VGA = 3;

//Top
logic [1:0] state_r, state_w;
logic [10:0] counter_50M_clk_r, counter_50M_clk_w; // how many 50M cycle in a LRcycle
logic [5:0] L_counter_r, L_counter_w; // total L=32 for average
logic [5:0] row_r, row_w;
logic [6:0] column_r, column_w;

//delta
logic signed [$clog2(`PIXEL_COLUMN)-1:0] sign_coordinate_x[`PARALLEL-1:0];
logic signed [$clog2(`PIXEL_ROW)-1:0] sign_coordinate_y[`PARALLEL-1:0];
logic [$clog2(`DELTA_LAST)-1 : 0] delta_array1 [`MIC_NUMBER-1 : 0];
logic [$clog2(`DELTA_LAST)-1 : 0] delta_array2 [`MIC_NUMBER-1 : 0];
logic [$clog2(`DELTA_LAST)-1 : 0] delta_array3 [`MIC_NUMBER-1 : 0];
logic [$clog2(`DELTA_LAST)-1 : 0] delta_array4 [`MIC_NUMBER-1 : 0];
logic [$clog2(`DELTA_LAST)-1 : 0] delta_array5 [`MIC_NUMBER-1 : 0];

//ring buffer
logic ringbuffer_initial_finish [`MIC_NUMBER-1:0];
logic [8*`PARALLEL-1:0] delta_concate [`MIC_NUMBER-1:0];
logic [24*`PARALLEL-1:0] buffer_data_concate [`MIC_NUMBER-1 : 0];

//Add square
logic signed [`READBIT-1:0] buffer_data1 [`MIC_NUMBER-1 : 0];
logic signed [`READBIT-1:0] buffer_data2 [`MIC_NUMBER-1 : 0];
logic signed [`READBIT-1:0] buffer_data3 [`MIC_NUMBER-1 : 0];
logic signed [`READBIT-1:0] buffer_data4 [`MIC_NUMBER-1 : 0];
logic signed [`READBIT-1:0] buffer_data5 [`MIC_NUMBER-1 : 0];

logic [2*(`READBIT+4)-7:0] add_square_data1;
logic [2*(`READBIT+4)-7:0] add_square_data2;
logic [2*(`READBIT+4)-7:0] add_square_data3;
logic [2*(`READBIT+4)-7:0] add_square_data4;
logic [2*(`READBIT+4)-7:0] add_square_data5;


//paraSRAM
logic         SRAM_write_enable  [`SRAM_PARALLEL-2:0];
logic [12:0]  SRAM_write_address_w [`SRAM_PARALLEL-2:0];
logic [12:0]  SRAM_write_address_r [`SRAM_PARALLEL-2:0];
logic [15:0]  SRAM_write_data    [`SRAM_PARALLEL-2:0];
logic [12:0]  SRAM_read_address_w  [`SRAM_PARALLEL-1:0];
logic [12:0]  SRAM_read_address_r  [`SRAM_PARALLEL-1:0];
logic [15:0]  SRAM_read_data     [`SRAM_PARALLEL-1:0];
//5 for VGA

//VGA
logic VGA_finish;
logic VGA_start_display;

genvar delta_concate_idx;
generate
    for(delta_concate_idx=0;delta_concate_idx<`MIC_NUMBER;delta_concate_idx = delta_concate_idx+1) begin : assignPEs
        assign delta_concate[delta_concate_idx] = {
            delta_array1[delta_concate_idx], 
            delta_array2[delta_concate_idx], 
            delta_array3[delta_concate_idx], 
            delta_array4[delta_concate_idx], 
            delta_array5[delta_concate_idx]};
    end
endgenerate

assign sign_coordinate_x[0] = column_r * 8 - (640 >> 1);
assign sign_coordinate_y[0] = row_r * 8 - (480 >> 1);

assign sign_coordinate_x[1] = (column_r + 1) * 8 - (640 >> 1);
assign sign_coordinate_y[1] = row_r * 8 - (480 >> 1);

assign sign_coordinate_x[2] = (column_r + 2) * 8 - (640 >> 1);
assign sign_coordinate_y[2] = row_r * 8 - (480 >> 1);

assign sign_coordinate_x[3] = (column_r + 3) * 8 - (640 >> 1);
assign sign_coordinate_y[3] = row_r * 8 - (480 >> 1);

assign sign_coordinate_x[4] = (column_r + 4) * 8 - (640 >> 1);
assign sign_coordinate_y[4] = row_r * 8 - (480 >> 1);

Delta_generator delta_generator0(
    .p_x(sign_coordinate_x[0]),
    .p_y(sign_coordinate_y[0]),
    .delta(delta_array1)
);
Delta_generator delta_generator1(
    .p_x(sign_coordinate_x[1]),
    .p_y(sign_coordinate_y[1]),
    .delta(delta_array2)
);
Delta_generator delta_generator2(
    .p_x(sign_coordinate_x[2]),
    .p_y(sign_coordinate_y[2]),
    .delta(delta_array3)
);
Delta_generator delta_generator3(
    .p_x(sign_coordinate_x[3]),
    .p_y(sign_coordinate_y[3]),
    .delta(delta_array4)
);
Delta_generator delta_generator4(
    .p_x(sign_coordinate_x[4]),
    .p_y(sign_coordinate_y[4]),
    .delta(delta_array5)
);

genvar idx;
generate
    for(idx=0;idx<`MIC_NUMBER;idx = idx+1) begin : PEs
        ring_buffer ring_buffer0(
         .i_50M_clk(i_50M_clk),
         .i_BCLK(i_BCLK),
         .i_LRCK(i_LRCK),
         .i_rst(i_rst),
         .i_start(i_start),
         .i_data(i_mic_data[idx]),
         .i_delta_concate(delta_concate[idx]),
         .o_buffer_data(buffer_data_concate[idx]),
         .o_initial_finish(ringbuffer_initial_finish[idx])
        );
    end
endgenerate


genvar buffer_idx;
generate
    for(buffer_idx=0;buffer_idx<`MIC_NUMBER;buffer_idx = buffer_idx+1) begin : buffer_idxPEs
        deconcatenate deconcatenate0(
            .i_before_con(buffer_data_concate[buffer_idx]),
            .o_parallel1(buffer_data1[buffer_idx]),
            .o_parallel2(buffer_data2[buffer_idx]),
            .o_parallel3(buffer_data3[buffer_idx]),
            .o_parallel4(buffer_data4[buffer_idx]),
            .o_parallel5(buffer_data5[buffer_idx])
        );
    end
endgenerate

Add_Square Add_Square1(
	.i_data(buffer_data1),
	.o_add_square_data(add_square_data1)                
); 
Add_Square Add_Square2(
	.i_data(buffer_data2),
	.o_add_square_data(add_square_data2)                
); 
Add_Square Add_Square3(
	.i_data(buffer_data3),
	.o_add_square_data(add_square_data3)                
); 
Add_Square Add_Square4(
	.i_data(buffer_data4),
	.o_add_square_data(add_square_data4)                
); 
Add_Square Add_Square5(
	.i_data(buffer_data5),
	.o_add_square_data(add_square_data5)                
); 

VGA VGA0(
    .i_rst(i_rst),
    .i_clk_25M(i_25M_clk),
    .i_start_display(VGA_start_display),
    .o_VGA_B(VGA_B),
	.o_VGA_BLANK_N(VGA_BLANK_N),
	.o_VGA_CLK(VGA_CLK),
	.o_VGA_G(VGA_G),
	.o_VGA_HS(VGA_HS),
	.o_VGA_R(VGA_R),
	.o_VGA_SYNC_N(VGA_SYNC_N),
	.o_VGA_VS(VGA_VS),
	.i_display_data(SRAM_read_data[5]),
    .o_access_address(SRAM_read_address_r[5]),
    .o_finish(VGA_finish)
);

genvar en_idx;
generate
    for(en_idx=0; en_idx<`PARALLEL; en_idx=en_idx+1) begin
        assign SRAM_write_enable[en_idx] = ((state_r == S_ITERATE) && (counter_50M_clk_r < ((`PIXEL_COLUMN)*(`PIXEL_ROW) / 5 + 1)) && (counter_50M_clk_r > 0)) ? 1'b1 : 1'b0;
    end
endgenerate 

assign SRAM_write_data[0] = add_square_data1 + SRAM_read_data[0];
assign SRAM_write_data[1] = add_square_data2 + SRAM_read_data[1];
assign SRAM_write_data[2] = add_square_data3 + SRAM_read_data[2];
assign SRAM_write_data[3] = add_square_data4 + SRAM_read_data[3];
assign SRAM_write_data[4] = add_square_data5 + SRAM_read_data[4];

paraSRAM paraSRAM0(
    .i_clk(i_50M_clk),
    .i_rst(i_rst),
    .i_write_enable(SRAM_write_enable),
    .i_write_address(SRAM_write_address_r),
	.i_write_data(SRAM_write_data),
	.i_read_address(SRAM_read_address_r),
	.o_read_data(SRAM_read_data)
);

always_comb begin
    state_w = state_r;
    case(state_r)
        S_IDLE: if(i_start) state_w = S_INITIAL;
        S_INITIAL: if(ringbuffer_initial_finish[0]) state_w = S_ITERATE;
        S_ITERATE: if(L_counter_r == `L && counter_50M_clk_r == 0) state_w = S_VGA;
    endcase
end

always_comb begin
    counter_50M_clk_w = counter_50M_clk_r;
    column_w = column_r;
    row_w = row_r;
    VGA_start_display = 0;
    SRAM_write_address_w[0] = SRAM_write_address_r[0];
    SRAM_write_address_w[1] = SRAM_write_address_r[1];
    SRAM_write_address_w[2] = SRAM_write_address_r[2];
    SRAM_write_address_w[3] = SRAM_write_address_r[3];
    SRAM_write_address_w[4] = SRAM_write_address_r[4];
    SRAM_read_address_w[0] = SRAM_read_address_r[0];
    SRAM_read_address_w[1] = SRAM_read_address_r[1];
    SRAM_read_address_w[2] = SRAM_read_address_r[2];
    SRAM_read_address_w[3] = SRAM_read_address_r[3];
    SRAM_read_address_w[4] = SRAM_read_address_r[4];
    case(state_r)
        S_IDLE: begin
            counter_50M_clk_w = 0;
            column_w = 0;
            row_w = 0;
            SRAM_write_address_w[0] = 13'bz;
            SRAM_write_address_w[1] = 13'bz;
            SRAM_write_address_w[2] = 13'bz;
            SRAM_write_address_w[3] = 13'bz;
            SRAM_write_address_w[4] = 13'bz;
            SRAM_read_address_w[0] = 13'bz;
            SRAM_read_address_w[1] = 13'bz;
            SRAM_read_address_w[2] = 13'bz;
            SRAM_read_address_w[3] = 13'bz;
            SRAM_read_address_w[4] = 13'bz;
        end
        S_INITIAL: begin
            counter_50M_clk_w = 0;
            column_w = 0;
            row_w = 0;
            SRAM_write_address_w[0] = 13'bz;
            SRAM_write_address_w[1] = 13'bz;
            SRAM_write_address_w[2] = 13'bz;
            SRAM_write_address_w[3] = 13'bz;
            SRAM_write_address_w[4] = 13'bz;
            SRAM_read_address_w[0] = 13'bz;
            SRAM_read_address_w[1] = 13'bz;
            SRAM_read_address_w[2] = 13'bz;
            SRAM_read_address_w[3] = 13'bz;
            SRAM_read_address_w[4] = 13'bz;
        end
        S_ITERATE: begin
            if(counter_50M_clk_r == `NUM_50M ) counter_50M_clk_w = 0;
            else counter_50M_clk_w = counter_50M_clk_r + 1;
            if(counter_50M_clk_r < (`PIXEL_COLUMN)*(`PIXEL_ROW) / 5) begin 
                if(column_r == `PIXEL_COLUMN - 5) begin
                    column_w = 0;
                    row_w = row_r + 1;
                end
                else begin
                    column_w = column_r + 5;
                end

                if(row_r == (`PIXEL_ROW - 1) && column_r == (`PIXEL_COLUMN - 5)) begin //row_r == 29 && column_r == 35
                    row_w = 0;
                end
            end

            if(counter_50M_clk_r < (`PIXEL_COLUMN)*(`PIXEL_ROW) / 5 && counter_50M_clk_r >= 0) begin
                SRAM_write_address_w[0] = column_r + row_r * (`PIXEL_COLUMN);
                SRAM_write_address_w[1] = column_r + 1 + row_r * (`PIXEL_COLUMN);
                SRAM_write_address_w[2] = column_r + 2 + row_r * (`PIXEL_COLUMN);
                SRAM_write_address_w[3] = column_r + 3 + row_r * (`PIXEL_COLUMN);
                SRAM_write_address_w[4] = column_r + 4 + row_r * (`PIXEL_COLUMN);
                SRAM_read_address_w[0] = column_r + row_r * (`PIXEL_COLUMN);
                SRAM_read_address_w[1] = column_r + 1 + row_r * (`PIXEL_COLUMN);
                SRAM_read_address_w[2] = column_r + 2 + row_r * (`PIXEL_COLUMN);
                SRAM_read_address_w[3] = column_r + 3 + row_r * (`PIXEL_COLUMN);
                SRAM_read_address_w[4] = column_r + 4 + row_r * (`PIXEL_COLUMN);
            end
            else begin
                SRAM_write_address_w[0] = 13'bz;
                SRAM_write_address_w[1] = 13'bz;
                SRAM_write_address_w[2] = 13'bz;
                SRAM_write_address_w[3] = 13'bz;
                SRAM_write_address_w[4] = 13'bz;
                SRAM_read_address_w[0] = 13'bz;
                SRAM_read_address_w[1] = 13'bz;
                SRAM_read_address_w[2] = 13'bz;
                SRAM_read_address_w[3] = 13'bz;
                SRAM_read_address_w[4] = 13'bz;
            end
            
        end
        S_VGA : begin
            counter_50M_clk_w = 0;
            column_w = 0;
            row_w = 0;
            VGA_start_display = 1;
        end
    endcase
end

always_comb begin
    L_counter_w = L_counter_r;
    case(state_r)
        S_IDLE: begin
            L_counter_w = 0;
        end
        S_INITIAL: begin
            L_counter_w = 0;
        end
        S_ITERATE: begin
            if(L_counter_r == `L - 1) L_counter_w = 0;
            else L_counter_w = L_counter_r + 1;
        end
        S_VGA: begin
            L_counter_w = 0;
        end
    endcase
end

always_ff @ (posedge i_50M_clk or posedge i_rst) begin
    if(i_rst) begin
        counter_50M_clk_r <= 0;
        state_r <= 0;
        column_r <= 0;
        row_r <= 0;
        SRAM_write_address_r[0] = 0;
        SRAM_write_address_r[1] = 0;
        SRAM_write_address_r[2] = 0;
        SRAM_write_address_r[3] = 0;
        SRAM_write_address_r[4] = 0;
        SRAM_read_address_r[0] = 0;
        SRAM_read_address_r[1] = 0;
        SRAM_read_address_r[2] = 0;
        SRAM_read_address_r[3] = 0;
        SRAM_read_address_r[4] = 0;
    end
    else begin
        counter_50M_clk_r <= counter_50M_clk_w;
        state_r <= state_w;
        column_r <= column_w;
        row_r <= row_w;
        SRAM_write_address_r[0] = SRAM_write_address_w[0];
        SRAM_write_address_r[1] = SRAM_write_address_w[1];
        SRAM_write_address_r[2] = SRAM_write_address_w[2];
        SRAM_write_address_r[3] = SRAM_write_address_w[3];
        SRAM_write_address_r[4] = SRAM_write_address_w[4];
        SRAM_read_address_r[0] = SRAM_read_address_w[0];
        SRAM_read_address_r[1] = SRAM_read_address_w[1];
        SRAM_read_address_r[2] = SRAM_read_address_w[2];
        SRAM_read_address_r[3] = SRAM_read_address_w[3];
        SRAM_read_address_r[4] = SRAM_read_address_w[4];
    end
end
always_ff @ (posedge i_LRCK or posedge i_rst) begin
    if(i_rst) begin
        L_counter_r <= 0;
    end
    else begin
        L_counter_r <= L_counter_w;
    end
end
endmodule