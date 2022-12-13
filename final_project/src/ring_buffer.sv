module RingBuffer(
    input i_clk,
    input i_fast_clk,
    input i_BCLK,
    input i_LRCK,
    input i_rst,
    input i_initial_start,
    input i_iterate_start,
    input i_change_pointer,
    input i_data,
    input [$clog2(`DELTA_LAST)-1:0] i_delta,
    output signed [`READBIT-1:0] o_L_buffer_data,
    output signed [`READBIT-1:0] o_buffer_data
    //output [15:0] test
);

integer i;

localparam S_IDLE = 0;
localparam S_INITIAL = 1;
localparam S_ITERATE = 2;

logic signed [`READBIT-1:0] i_newrecord_data;
logic [1:0] state_r, state_w;
logic signed [`READBIT-1:0] buffer_r [`BUFFER_LENGTH-1:0];
logic signed [`READBIT-1:0] buffer_w [`BUFFER_LENGTH-1:0];
logic [$clog2(`BUFFER_LENGTH)-1:0] pointer_r, pointer_w;
logic signed [`READBIT-1:0] output_r, output_w;
logic signed [`READBIT-1:0] L_output_r, L_output_w;

assign o_buffer_data = output_r;
assign o_L_buffer_data = L_output_r;

logic initial_start_r, initial_start_w;
logic iterate_start_r, iterate_start_w;

logic i_recorder_initial_start;
assign i_recorder_initial_start = initial_start_r;

//assign test = {14'b0,initial_start_r,iterate_start_r};

Recorder recorder0(
    .i_clk(i_clk),
    .i_BCLK(i_BCLK),
    .i_LRCK(i_LRCK),
    .i_rst(i_rst),
    .i_start(i_recorder_initial_start),
    .i_data(i_data),
    .o_data(i_newrecord_data)
);


always_comb begin
    initial_start_w = initial_start_r;
    iterate_start_w = iterate_start_r;
    if(i_initial_start) initial_start_w = 1;
    if(i_iterate_start) iterate_start_w = 1;
end



//state
always_comb begin
    state_w = state_r;
    case(state_r)
        S_IDLE: if(initial_start_r) state_w = S_INITIAL;
        S_INITIAL: if(iterate_start_r) state_w = S_ITERATE;
    endcase
end

//pointer
always_comb begin
    pointer_w = pointer_r;
    case(state_r)
        S_IDLE: begin
            pointer_w = 0;
        end
        S_INITIAL, S_ITERATE: begin
            if(i_change_pointer) begin
                if(pointer_r == `BUFFER_LENGTH - 1) pointer_w = 0;
                else pointer_w = pointer_r + 1;
            end
        end
    endcase
end

// buffer replace
always@(*) begin
    for(i=0; i<`BUFFER_LENGTH; i=i+1) buffer_w[i] = buffer_r[i];
    if(state_r == S_IDLE) begin
        for(i=0; i<`BUFFER_LENGTH; i=i+1) buffer_w[i] = 0;
    end
    else begin
        if(i_change_pointer) buffer_w[pointer_r] = i_newrecord_data;
    end
end

// output
always_comb begin
    output_w = output_r;
    if(state_r == S_ITERATE || state_r == S_INITIAL) begin
        if(i_delta-`DELTA_START+pointer_r <= `BUFFER_LENGTH-1) output_w = buffer_r[i_delta-`DELTA_START+pointer_r];
        else output_w = buffer_r[i_delta-`DELTA_START+pointer_r-`BUFFER_LENGTH];
    end
end

// L_output 
always_comb begin
    L_output_w = L_output_r;
    if(state_r == S_ITERATE) begin
        if(i_delta-`DELTA_START+pointer_r < `L) L_output_w = buffer_r[i_delta-`DELTA_START+pointer_r-`L+`BUFFER_LENGTH];
        else L_output_w = buffer_r[i_delta-`DELTA_START+pointer_r-`L];
    end
end

always@(posedge i_clk or posedge i_rst) begin
	if(i_rst)begin
        state_r <= 0;
        for(i=0; i<`BUFFER_LENGTH ; i=i+1) buffer_r[i] <= 0;
        pointer_r <= 0;
        output_r <= 0;
        L_output_r <= 0;
	end
	else begin
        state_r <= state_w;
        for(i=0; i<`BUFFER_LENGTH; i=i+1) buffer_r[i] <= buffer_w[i] ;
        pointer_r <= pointer_w;
        output_r <= output_w;
        L_output_r <= L_output_w;
	end
end

always@(posedge i_fast_clk or posedge i_rst) begin
	if(i_rst)begin
        initial_start_r <= 0;
        iterate_start_r <= 0;
	end
	else begin
        initial_start_r <= initial_start_w;
        iterate_start_r <= iterate_start_w;
	end
end



endmodule