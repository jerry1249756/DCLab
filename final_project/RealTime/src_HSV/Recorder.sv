`define READBIT 24

module Recorder(
    input i_clk,
    input i_BCLK,
    input i_LRCK,
    input i_rst,
    input i_start,
    input i_data,
    output signed [`READBIT-1:0] o_data
);

localparam S_IDLE = 0;
localparam S_REC = 1;

logic state_r, state_w;
logic [4:0] counter_r, counter_w;
logic signed [23:0] data_r, data_w;
logic signed [23:0] o_data_r, o_data_w;

// assign o_data = o_data_r[23-:`READBIT];

logic signed [23:0] BandPassInput; 
logic signed [23:0] BandPassOutput;
assign BandPassInput = o_data_r;
assign o_data = BandPassOutput;//{BandPassOutput[36], BandPassOutput[34:12]}; 


filter bandpass0(
    .i_clk(i_clk),
    .i_clk_en(1'b1),
    .i_rst(i_rst),
    .filter_in(BandPassInput),
    .filter_out(BandPassOutput)
);



//state
always_comb begin
    state_w = state_r;
    if(!state_r && i_start) state_w = S_REC;
end

always_comb begin
    o_data_w = data_r;
end

//BCLK bit counter 
always_comb begin
    counter_w = counter_r;
    case(state_r)
        S_IDLE: counter_w = 0;
        S_REC: begin
            if(!i_LRCK) counter_w = 0;
            else begin
                if(counter_r < 25) counter_w = counter_r + 1;
            end
        end
    endcase
end

// update output data
always_comb begin
    data_w = data_r;
    case(state_r)
        S_IDLE: data_w = 0;
        S_REC: begin
            if(counter_r > 0 && counter_r < 25) data_w[23 - counter_r + 1] = i_data; 
        end
    endcase
end

always_ff @(posedge i_clk or posedge i_rst) begin
    if(i_rst)begin
        state_r <= 0;
	end
	else begin
        state_r <= state_w;
	end
end

always_ff @(posedge i_BCLK or posedge i_rst) begin
    if(i_rst)begin
        counter_r <= 0;
        data_r <= 0;
	end
	else begin
        counter_r <= counter_w;
        data_r <= data_w;
	end
end

always_ff @(posedge i_LRCK or posedge i_rst) begin
    if(i_rst) begin
        o_data_r <= 0;
    end
    else begin
        o_data_r <= o_data_w;
    end
end

endmodule