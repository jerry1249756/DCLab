module RingBuffer(
    input i_clk,
    input i_BCLK,
    input i_LRCK,
    input i_rst,
    input i_start,
    input i_data,
    input [7:0] i_delta,
    output [23:0] o_L_buffer_data,
    output [23:0] o_buffer_data
);

localparam S_IDLE = 0;
localparam S_INITIAL = 1;
localparam S_ITERATE = 2;

localparam L = 30;
localparam DELTA_START = 147;
localparam DELTA_LAST = 169;
localparam BUFFER_LENGTH = L + DELTA_LAST - DELTA_START + 1;
localparam PIXEL_LENGTH = 10000;

logic [23:0] i_newrecord_data;
logic [1:0] state_r, state_w;
logic [BUFFER_LENGTH-1:0][23:0] buffer_r, buffer_w;
logic [$clog2(BUFFER_LENGTH)-1:0] pointer_r, pointer_w;
logic [$clog2(BUFFER_LENGTH)-1:0] pointer_save_r, pointer_save_w;
logic [23:0] buffer_save_r, buffer_save_w;
logic [$clog2(PIXEL_LENGTH)-1:0] counter_r, counter_w;
logic [23:0] output_r, output_w;
logic [23:0] L_output_r, L_output_w;
logic change_state_flag;

assign o_buffer_data = output_r;
assign o_L_buffer_data = L_output_r;

Recorder recorder0(
    .i_clk(i_clk),
    .i_BCLK(i_BCLK),
    .i_LRCK(i_LRCK),
    .i_rst(i_rst),
    .i_start(i_start),
    .i_data(i_data),
    .o_data(i_newrecord_data)
);

//state
always_comb begin
    state_w = state_r;
    case(state_r)
        S_IDLE: if(i_start) state_w = S_INITIAL;
        S_INITIAL: if(change_state_flag && pointer_r == 0) state_w = S_ITERATE;
    endcase
end

//pointer
always_comb begin
    case(state_r)
        S_IDLE: begin
            pointer_w = 0;
            pointer_save_w = 0;
        end
        S_INITIAL: begin
            pointer_save_w = 0;
            if(pointer_r == BUFFER_LENGTH) begin
                pointer_w = 0;
                change_state_flag = 1;
            end
            else pointer_w = pointer_r + 1;
        end
        S_ITERATE: begin
            pointer_save_w = pointer_save_r;
            change_state_flag = 0;
            if(counter_r == PIXEL_LENGTH-1) begin
                if(pointer_r == BUFFER_LENGTH-1) begin
                    pointer_w = 0;
                    pointer_save_w = 0;
                end
                else begin
                    pointer_w = pointer_r + 1;
                    pointer_save_w = pointer_r + 1;
                end
            end
            else pointer_w = pointer_save_r;
        end
    endcase
end

// counter
always_comb begin
    counter_w = counter_r;
    if(state_r == S_ITERATE) begin
        if(counter_r == PIXEL_LENGTH - 1) counter_w = 0;
        else counter_w = counter_r + 1;
    end
end

//input buffer and buffer replace
always_comb begin
    buffer_w = buffer_r;
    buffer_save_w = buffer_save_r;
    case(state_r)
        S_INITIAL: begin
            buffer_w[pointer_r-1] = i_newrecord_data;
            buffer_save_w = buffer_r[0];
        end
        S_ITERATE:
            if(counter_r == PIXEL_LENGTH-1) begin
                buffer_w[pointer_r] = i_newrecord_data;
                buffer_save_w = i_newrecord_data;
            end
            else begin
                if(pointer_save_r == 0) buffer_w[BUFFER_LENGTH-1] = buffer_save_r;
                else buffer_w[pointer_save_r-1] = buffer_save_r;
            end
    endcase
end

// output
always_comb begin
    output_w = output_r;
    if(state_r == S_ITERATE) begin
        if(i_delta-DELTA_START+pointer_r <= BUFFER_LENGTH-1) output_w = buffer_r[i_delta-DELTA_START+pointer_r];
        else output_w = buffer_r[i_delta-DELTA_START+pointer_r-BUFFER_LENGTH];
    end
end

// L_output 
always_comb begin
    L_output_w = L_output_r;
    if(state_r == S_ITERATE) begin
        if(i_delta-DELTA_START+pointer_r < L) L_output_w = buffer_r[i_delta-DELTA_START+pointer_r-L+BUFFER_LENGTH];
        else L_output_w = buffer_r[i_delta-DELTA_START+pointer_r-L];
    end
end


always_ff @(posedge i_LRCK or posedge i_rst) begin
	if(i_rst)begin
        buffer_r <= 0;
        pointer_r <= 0;
	end
	else begin
        buffer_r <= buffer_w;
        pointer_r <= pointer_w;
	end
end

always_ff @(posedge i_clk or posedge i_rst) begin
	if(i_rst)begin
        state_r <= 0;
        counter_r <= 0;
        output_r <= 0;
        pointer_save_r <= 0;
        buffer_save_r <= 0;
        L_output_r <= 0;
	end
	else begin
        state_r <= state_w;
        counter_r <= counter_w;
        output_r <= output_w;
        L_output_r <= L_output_w;
        pointer_save_r <= pointer_save_w;
        buffer_save_r <= buffer_save_w;
	end
end

endmodule