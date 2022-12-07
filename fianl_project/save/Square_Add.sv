module Square_Add(
	input                i_50M_clk                ,
	input                i_rst_n                  ,
	input                i_valid                  ,
	input  signed [23:0] i_data            [11:0] ,
	output signed [15:0] o_square_add_data        ,
	output               o_ready                  
);   

parameter S_IDLE = 2'd0;
parameter S_OUT = 2'd1;


logic [1:0] state_r, state_w;
logic [51:0] square_add_data_r, square_add_data_w;

assign o_square_add_data = (state_r == S_OUT)? square_add_data_r[63:48] : 16'bz;
assign o_ready = (state_r == S_OUT)? 1 : 0;
//state
always_comb begin
	state_w = state_r;
	case(state_r)
		S_IDLE : begin
			if(i_valid) begin
				state_w = S_OUT;
			end
			else begin
				state_w = S_IDLE;
			end
		end
		S_OUT : begin
			if(i_valid) begin
				state_w = S_OUT;
			end
			else begin
				state_w = S_IDLE;
			end
		end
	endcase
end

always_comb begin
	square_add_data_w = square_add_data_r;
	case(state_r)
		S_IDLE : begin
			square_add_data_w = i_data[0]*i_data[0] + 
								i_data[1]*i_data[1] +
								i_data[2]*i_data[2] +
								i_data[3]*i_data[3] +
								i_data[4]*i_data[4] +
								i_data[5]*i_data[5] +
								i_data[6]*i_data[6] +
								i_data[7]*i_data[7] +
								i_data[8]*i_data[8] +
								i_data[9]*i_data[9] +
								i_data[10]*i_data[10] +
								i_data[11]*i_data[11];
		end
		S_OUT : begin
			square_add_data_w = i_data[0]*i_data[0] + 
								i_data[1]*i_data[1] +
								i_data[2]*i_data[2] +
								i_data[3]*i_data[3] +
								i_data[4]*i_data[4] +
								i_data[5]*i_data[5] +
								i_data[6]*i_data[6] +
								i_data[7]*i_data[7] +
								i_data[8]*i_data[8] +
								i_data[9]*i_data[9] +
								i_data[10]*i_data[10] +
								i_data[11]*i_data[11];
		end
	endcase
end


always_ff @(posedge i_50M_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
		 state_r <= S_IDLE;
		 square_add_data_r <= 64'd0;
	end
	else begin
		state_r <= state_w;
		square_add_data_r <= square_add_data_w;
	end
end



endmodule

/*module ROM_Square(             
	input  signed [11:0] i_x         ,
	output signed [23:0] o_x_square                 
);   

logic [23:0] data [11:0];

always @(*) begin
    data[0]  <= 24'd0;
    data[1]  <= 24'd1;
    data[2]  <= 24'd4;
    data[3]  <= 24'd9;
    data[4]  <= 24'd16;
    data[5]  <= 24'd25;
    data[6]  <= 24'd36;
    data[7]  <= 24'd49;             
    data[8]  <= 24'd64;
    data[9]  <= 24'd81;
    data[10] <= 24'd100;
	data[10] <= 24'd100;
    data[12] <= 24'd121;
    data[13] <= 24'd;
    data[14] <= 24'd;
    data[15] <= 24'd
     
endmodule*/