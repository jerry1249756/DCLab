module Coordinate_generator(
    input i_clk,
    input signed [7:0] p_x,
    input signed [7:0] p_y,
    output signed [8:0] real_x[15:0],
    output signed [8:0] real_y[15:0]
);
    genvar idx;
    generate
        for(idx=0; idx<4; idx=idx+1) begin
            assign real_y[idx] = p_y + 90;
        end
        for(idx=4; idx<8; idx=idx+1) begin
            assign real_y[idx] = p_y + 30;
        end
        for(idx=8; idx<12; idx=idx+1) begin
            assign real_y[idx] = p_y - 30;
        end
        for(idx=12; idx<16; idx=idx+1) begin
            assign real_y[idx] = p_y - 90;
        end
        for(idx=0; idx<16; idx=idx+4) begin
            assign real_x[idx] = p_x + 90;
        end
        for(idx=1; idx<16; idx=idx+4) begin
            assign real_x[idx] = p_x + 30;
        end
        for(idx=2; idx<16; idx=idx+4) begin
            assign real_x[idx] = p_x - 30;
        end
        for(idx=3; idx<16; idx=idx+4) begin
            assign real_x[idx] = p_x - 90;
        end
    endgenerate
endmodule


module Delta_generator (
    input i_clk,
    input signed [7:0] p_x,
    input signed [7:0] p_y,
    output [7:0] delta[15:0]
);
    function [7:0] f (input [16:0]idx);
		case(idx) inside
			[17'd0: 17'd2116]:       f=8'd147;
			[17'd2117: 17'd7056]:    f=8'd148;
			[17'd7057: 17'd11881]:   f=8'd149;
			[17'd11882: 17'd16900]:  f=8'd150;
			[17'd16901: 17'd21904]:  f=8'd151;
			[17'd21905: 17'd26896]:  f=8'd152;
			[17'd26897: 17'd32041]:  f=8'd153;
            [17'd32042: 17'd37249]:  f=8'd154;
            [17'd37250: 17'd42436]:  f=8'd155;
            [17'd42437: 17'd47524]:  f=8'd156;
            [17'd47525: 17'd52900]:  f=8'd157;
            [17'd52901: 17'd58081]:  f=8'd158;
            [17'd58082: 17'd63504]:  f=8'd159;
            [17'd63505: 17'd68644]:  f=8'd160;
            [17'd68645: 17'd73984]:  f=8'd161;
            [17'd73985: 17'd79524]:  f=8'd162;
            [17'd79525: 17'd84681]:  f=8'd163;
            [17'd84682: 17'd90000]:  f=8'd164;
            [17'd90001: 17'd95481]:  f=8'd165;
            [17'd95482: 17'd101124]: f=8'd166;
            default:                 f=8'd167;
		endcase
	endfunction

    logic signed [8:0] real_x[15:0], real_y[15:0];
    logic [16:0] radius_square[15:0];

    Coordinate_generator c0(
        .i_clk(i_clk),
        .p_x(p_x),
        .p_y(p_y),
        .real_x(real_x),
        .real_y(real_y)
    );
     genvar idx;
     generate
        for(idx=0; idx<16; idx=idx+1)begin
            assign radius_square[idx] = real_x[idx]*real_x[idx] + real_y[idx]*real_y[idx];
            assign delta[idx] = f(radius_square[idx]);
        end
    endgenerate

    
endmodule