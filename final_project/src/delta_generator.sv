`define PIXEL_ROW  45
`define PIXEL_COLUMN  60

module Coordinate_generator(
    input signed [$clog2(`PIXEL_COLUMN)-1:0] p_x,
    input signed [$clog2(`PIXEL_ROW)-1:0] p_y,
    output signed [8:0] real_x[15:0],
    output signed [8:0] real_y[15:0]
);
    genvar idx;
    generate
        for(idx=0; idx<4; idx=idx+1) begin: Geny1
            assign real_y[idx] = p_y + 120;
        end
        for(idx=4; idx<8; idx=idx+1) begin: Geny2
            assign real_y[idx] = p_y + 40;
        end
        for(idx=8; idx<12; idx=idx+1) begin: Geny3
            assign real_y[idx] = p_y - 40;
        end
        for(idx=12; idx<16; idx=idx+1) begin: Geny4
            assign real_y[idx] = p_y - 120;
        end
        for(idx=0; idx<16; idx=idx+4) begin: Genx1
            assign real_x[idx] = p_x + 120;
        end
        for(idx=1; idx<16; idx=idx+4) begin: Genx2
            assign real_x[idx] = p_x + 40;
        end
        for(idx=2; idx<16; idx=idx+4) begin: Genx3
            assign real_x[idx] = p_x - 40;
        end
        for(idx=3; idx<16; idx=idx+4) begin: Genx4
            assign real_x[idx] = p_x - 120;
        end
    endgenerate
endmodule

module mapping(
    input  [18:0] num ,
    output [7:0]  delta
);
    /* inside operator is supported for 2017.3 SystemVerilog, which is not supported by Quartus II.

    function [7:0] f (input [18:0]idx);
		case(idx) inside
			[19'd0: 19'd3844]:        f=8'd147;//62
			[19'd3845: 19'd12544]:    f=8'd148;//112
			[19'd12545: 19'd21316]:   f=8'd149;//146
			[19'd21317: 19'd29929]:   f=8'd150;//173
			[19'd29930: 19'd38809]:   f=8'd151;//197
			[19'd38810: 19'd47961]:   f=8'd152;//219
			[19'd47962: 19'd57121]:   f=8'd153;//239
            [19'd57122: 19'd66049]:   f=8'd154;//257
            [19'd66050: 19'd75076]:   f=8'd155;//274
            [19'd75077: 19'd84100]:   f=8'd156;//290
            [19'd84101: 19'd93636]:   f=8'd157;//306
            [19'd93637: 19'd103041]:  f=8'd158;//321
            [19'd103042: 19'd112225]: f=8'd159;//335
            [19'd112226: 19'd121801]: f=8'd160;//349
            [19'd121802: 19'd131044]: f=8'd161;//362
            [19'd131045: 19'd140625]: f=8'd162;//375
            [19'd140626: 19'd150544]: f=8'd163;//388
            [19'd150545: 19'd160000]: f=8'd164;//400
            [19'd160001: 19'd169744]: f=8'd165;//412
            [19'd169745: 19'd179776]: f=8'd166;//424
            [19'd179777: 19'd190096]: f=8'd167;//436
            [19'd190097: 19'd199809]: f=8'd168;//447
            [19'd199810: 19'd209764]: f=8'd169;//458
            [19'd209765: 19'd219961]: f=8'd170;//469
            [19'd219962: 19'd229441]: f=8'd171;//479
            [19'd229442: 19'd240100]: f=8'd172;//490
            [19'd240101: 19'd250000]: f=8'd173;//500
            [19'd250001: 19'd260100]: f=8'd174;//510
            [19'd260101: 19'd270400]: f=8'd175;//520
            [19'd270401: 19'd280900]: f=8'd176;//530
            [19'd280901: 19'd291600]: f=8'd177;//540
            [19'd291601: 19'd302500]: f=8'd178;//550
            default:                  f=8'd179;
		endcase
	endfunction  */
    logic [7:0] data_out;
    assign delta = data_out;

    logic [18:0] parameter_array[0:31] = '{19'd3844, 
    19'd12544, 19'd21316, 19'd29929, 19'd38809, 19'd47961, 19'd57121, 19'd66049, 19'd75076, 19'd84100, 19'd93636, 
    19'd103041, 19'd112225, 19'd121801, 19'd131044, 19'd140625, 19'd150544, 19'd160000, 19'd169744, 19'd179776, 
    19'd190096, 19'd199809, 19'd209764, 19'd219961, 19'd229441, 19'd240100, 19'd250000, 19'd260100, 19'd270400, 
    19'd280900, 19'd291600, 19'd302500};
    logic [31:0] a ;
    
    genvar i;
    generate
        for(i=0; i<32; i=i+1) begin: Gena
            assign a[i] = (num>parameter_array[i])? 1'b1 : 1'b0;
        end
    endgenerate


    always_comb begin  
        case(a)
            32'h00000000: data_out = 8'd147;
            32'h00000001: data_out = 8'd148;
            32'h00000003: data_out = 8'd149;
            32'h00000007: data_out = 8'd150;
            32'h0000000f: data_out = 8'd151;
            32'h0000001f: data_out = 8'd152;
            32'h0000003f: data_out = 8'd153;
            32'h0000007f: data_out = 8'd154;
            32'h000000ff: data_out = 8'd155;
            32'h000001ff: data_out = 8'd156;
            32'h000003ff: data_out = 8'd157;
            32'h000007ff: data_out = 8'd158;
            32'h00000fff: data_out = 8'd159;
            32'h00001fff: data_out = 8'd160;
            32'h00003fff: data_out = 8'd161;
            32'h00007fff: data_out = 8'd162;
            32'h0000ffff: data_out = 8'd163;
            32'h0001ffff: data_out = 8'd164;
            32'h0003ffff: data_out = 8'd165;
            32'h0007ffff: data_out = 8'd166;
            32'h000fffff: data_out = 8'd167;
            32'h001fffff: data_out = 8'd168;
            32'h003fffff: data_out = 8'd169;
            32'h007fffff: data_out = 8'd170;
            32'h00ffffff: data_out = 8'd171;
            32'h01ffffff: data_out = 8'd172;
            32'h03ffffff: data_out = 8'd173;
            32'h07ffffff: data_out = 8'd174;
            32'h0fffffff: data_out = 8'd175;
            32'h1fffffff: data_out = 8'd176;
            32'h3fffffff: data_out = 8'd177;
            32'h7fffffff: data_out = 8'd178;
            default:      data_out = 8'd179;
        endcase
    end

endmodule

module Delta_generator (
    input signed [$clog2(`PIXEL_COLUMN)-1:0] p_x,
    input signed [$clog2(`PIXEL_ROW)-1:0] p_y,
    output [7:0] delta[15:0]
);
    
    logic signed [8:0] real_x[15:0], real_y[15:0];
    logic [18:0] radius_square[15:0];

    Coordinate_generator c0(
        .p_x(p_x),
        .p_y(p_y),
        .real_x(real_x),
        .real_y(real_y)
    );

    genvar idx;
    generate
        for(idx=0; idx<16; idx=idx+1) begin: Genr
            assign radius_square[idx] = real_x[idx]*real_x[idx] + real_y[idx]*real_y[idx];
        end
    endgenerate
    generate
        for(idx=0; idx<16; idx=idx+1) begin: Mappings
            mapping m0(
                .num(radius_square[idx]),
                .delta(delta[idx])
            );
        end
    endgenerate

    
endmodule