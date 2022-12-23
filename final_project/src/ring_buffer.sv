//////.src version
//////////////////////////////Open when you need testbench 
`define L  32
`define DELTA_START  147
`define DELTA_LAST  179
`define BUFFER_LENGTH  64
`define PARALLEL 5
`define READBIT 24

module ring_buffer(
    input i_50M_clk,
    input i_BCLK,
    input i_LRCK, 
    input i_rst,
    input i_start,
    input i_data,
    input [8*`PARALLEL-1:0] i_delta_concate,
    output [24*`PARALLEL-1:0] o_buffer_data,
    // output [24*`PARALLEL-1:0] o_L_buffer_data,
    output o_initial_finish
);

integer i;

localparam S_IDLE = 0;
localparam S_INITIAL = 1;
localparam S_ITERATE = 2;

logic [1:0] state_r, state_w;
logic [$clog2(`BUFFER_LENGTH)-1:0] pointer_r, pointer_w;
logic [23:0] buffer_r [`BUFFER_LENGTH-1:0];
logic [23:0] buffer_w [`BUFFER_LENGTH-1:0];
logic change_state_flag_r, change_state_flag_w;
logic [23:0] buffer_output_r [4:0];
logic [23:0] buffer_output_w [4:0];
// logic [23:0] L_buffer_output_r [4:0];
// logic [23:0] L_buffer_output_w [4:0];
logic [7:0] i_delta [`PARALLEL-1:0];
logic [23:0] i_newrecord_data;

assign o_initial_finish = change_state_flag_r && (pointer_r == 0);
assign o_buffer_data = {buffer_output_r[0], buffer_output_r[1], buffer_output_r[2], buffer_output_r[3], buffer_output_r[4]};
// assign o_L_buffer_data = {L_buffer_output_r[0], L_buffer_output_r[1], L_buffer_output_r[2], L_buffer_output_r[3], L_buffer_output_r[4]};
assign o_L_buffer_data = 0;

assign i_delta[4] = i_delta_concate[7:0];
assign i_delta[3] = i_delta_concate[15:8];
assign i_delta[2] = i_delta_concate[23:16];
assign i_delta[1] = i_delta_concate[31:24];
assign i_delta[0] = i_delta_concate[39:32];

Recorder recorder0(
    .i_clk(i_50M_clk),
    .i_BCLK(i_BCLK),
    .i_LRCK(i_LRCK),
    .i_rst(i_rst),
    .i_start(i_start),
    .i_data(i_data),
    .o_data(i_newrecord_data)
);



always_comb begin
    state_w = state_r;
    case(state_r) 
        S_IDLE: begin
            if(i_start) state_w = S_INITIAL;
        end
        S_INITIAL: begin
            if(change_state_flag_r && pointer_r == 0) state_w = S_ITERATE;
        end
    endcase
end

always_comb begin
    pointer_w = pointer_r;
    change_state_flag_w = change_state_flag_r;
    case(state_r)
        S_INITIAL: begin
            if(pointer_r == `BUFFER_LENGTH - 1) begin
                pointer_w = 0;
                change_state_flag_w = 1;
            end
            else pointer_w = pointer_r + 1;
        end
        S_ITERATE: begin
            change_state_flag_w = 0;
            if(pointer_r == `BUFFER_LENGTH - 1) pointer_w = 0;
            else pointer_w = pointer_r + 1;
        end
    endcase
end


always@(*) begin
    for(i=0; i<`BUFFER_LENGTH; i=i+1) buffer_w[i] = buffer_r[i];
    if(state_r == S_IDLE) begin
        for(i=0; i<`BUFFER_LENGTH; i=i+1) buffer_w[i] = 0;
    end
    else if (state_r == S_INITIAL) begin
        buffer_w[pointer_r] = i_newrecord_data;
    end
end


always@(*) begin
    for(i=0; i<`PARALLEL; i=i+1) buffer_output_w[i] = buffer_output_r[i];
    if(state_r == S_ITERATE && pointer_r < `L) begin
        for(i=0; i<`PARALLEL; i=i+1) begin
            // if(i_delta[i]-`DELTA_START+pointer_r <= `BUFFER_LENGTH-1) buffer_output_w[i] = buffer_r[i_delta[i]-`DELTA_START+pointer_r];
            // else buffer_output_w[i] = buffer_r[i_delta[i]-`DELTA_START+pointer_r-`BUFFER_LENGTH];
            buffer_output_w[i] = buffer_r[`DELTA_LAST-i_delta[i]+pointer_r];
        end
    end
end


// always@(*) begin
//     for(i=0; i<`PARALLEL; i=i+1) L_buffer_output_w[i] = L_buffer_output_r[i];
//     if(state_r == S_ITERATE) begin
//         for(i=0; i<`PARALLEL; i=i+1) begin
//             if(i_delta[i]-`DELTA_START+pointer_r < `L) L_buffer_output_w[i] = buffer_r[i_delta[i]-`DELTA_START+pointer_r-`L+`BUFFER_LENGTH];
//             else L_buffer_output_w[i] = buffer_r[i_delta[i]-`DELTA_START+pointer_r-`L];
//         end
//     end
// end





always@(posedge i_LRCK or posedge i_rst) begin
	if(i_rst)begin
        pointer_r <= 0;
        for(i=0; i<`BUFFER_LENGTH ; i=i+1) buffer_r[i] <= 0;
	end
	else begin
        pointer_r <= pointer_w;
        for(i=0; i<`BUFFER_LENGTH; i=i+1) buffer_r[i] <= buffer_w[i];
	end
end

always@(posedge i_50M_clk or posedge i_rst) begin
	if(i_rst)begin
        state_r <= 0;
        change_state_flag_r <= 0;
        for(i=0; i<`PARALLEL; i=i+1) buffer_output_r[i] <= 0;
        // for(i=0; i<`PARALLEL; i=i+1) L_buffer_output_w[i] <= 0;
	end
	else begin
        state_r <= state_w;
        change_state_flag_r <= change_state_flag_w;
        for(i=0; i<`PARALLEL; i=i+1) buffer_output_r[i] <= buffer_output_w[i];
        // for(i=0; i<`PARALLEL; i=i+1) L_buffer_output_r[i] <= L_buffer_output_w[i];
	end
end

endmodule