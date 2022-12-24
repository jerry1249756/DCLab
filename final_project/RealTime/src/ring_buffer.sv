//////.new version
//////////////////////////////Open when you need testbench 
`define L  32
`define DELTA_START  74
`define DELTA_LAST  127
`define BUFFER_LENGTH  85
`define READBIT 24

module ring_buffer(
    input i_50M_clk,
    input i_BCLK,
    input i_LRCK, 
    input i_rst,
    input i_start,
    input i_data,
    input [$clog2(`DELTA_LAST)-1 :0] i_delta,
    input i_change_pointer,
    input i_black_finish,
    input i_color_finish,
    output signed [`READBIT-1:0] o_buffer_data,
    output o_initial_finish
);

integer i;

localparam S_IDLE = 0;
localparam S_INITIAL = 1;
localparam S_ITERATE = 2;
localparam S_CLEAR = 3;

logic [1:0] state_r, state_w;
logic [$clog2(`BUFFER_LENGTH)-1:0] pointer_r, pointer_w;
logic [$clog2(`BUFFER_LENGTH)-1:0] iterate_pointer_r, iterate_pointer_w;
logic signed [`READBIT-1:0] buffer_r [`BUFFER_LENGTH-1:0];
logic signed [`READBIT-1:0] buffer_w [`BUFFER_LENGTH-1:0];
logic change_state_flag_r, change_state_flag_w;
logic signed [`READBIT-1:0] buffer_output_r, buffer_output_w ;

logic signed [`READBIT-1:0] i_newrecord_data;

assign o_initial_finish = change_state_flag_r && (pointer_r == 0);
assign o_buffer_data = buffer_output_r;


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
        S_ITERATE: begin
            if(i_black_finish) state_w = S_CLEAR;
        end
        S_CLEAR: begin
            if(i_color_finish) state_w = S_INITIAL;
        end
    endcase
end

always_comb begin
    pointer_w = pointer_r;
    change_state_flag_w = change_state_flag_r;
    iterate_pointer_w = iterate_pointer_r;
    case(state_r)
        S_IDLE: begin
            pointer_w = 0;
            change_state_flag_w = 0;
            iterate_pointer_w = 0;
        end
        S_INITIAL: begin
            iterate_pointer_w = 0;
            if(pointer_r == `BUFFER_LENGTH - 1) begin
                pointer_w = 0;
                change_state_flag_w = 1;
            end
            else pointer_w = pointer_r + 1;
        end
        S_ITERATE: begin
            change_state_flag_w = 0;
            pointer_w = 0;
            if(i_change_pointer && iterate_pointer_r < `L-1) iterate_pointer_w = iterate_pointer_r + 1;
        end
        S_CLEAR: begin
            pointer_w = 0;
            iterate_pointer_w = 0;
            change_state_flag_w = 0;
        end
    endcase
end


always@(*) begin
    for(i=0; i<`BUFFER_LENGTH; i=i+1) buffer_w[i] = buffer_r[i];
    if(state_r == S_IDLE || state_r == S_CLEAR) begin
        for(i=0; i<`BUFFER_LENGTH; i=i+1) buffer_w[i] = 0;
    end
    else if (state_r == S_INITIAL) begin
        buffer_w[pointer_r] = i_newrecord_data;
    end
end


always_comb begin
    buffer_output_w = buffer_output_r;
    if(state_r == S_ITERATE ) begin
        buffer_output_w = buffer_r[`DELTA_LAST - i_delta + iterate_pointer_r];
    end
end


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
        buffer_output_r <= 0;
        iterate_pointer_r <= 0;
	end
	else begin
        state_r <= state_w;
        change_state_flag_r <= change_state_flag_w;
        buffer_output_r <= buffer_output_w;
        iterate_pointer_r <= iterate_pointer_w;
	end
end

endmodule