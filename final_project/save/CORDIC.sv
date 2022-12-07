module CORDIC(
	input                i_50M_clk            ,
	input                i_valid              ,
	input  signed [31:0] i_x                  ,
	input  signed [31:0] i_y                  ,
	output signed [31:0] o_euclidean_distance ,
	output               o_ready                  
);   

parameter S_IDLE = 2'd0;
parameter S_OUTPUT = 2'd1;

logic [1:0] state_r, state_w;

logic signed [31:0] x0, y0;
logic signed [31:0] x1, y1;
logic signed [31:0] x2, y2;
logic signed [31:0] x3, y3;
logic signed [31:0] x4, y4;
logic signed [31:0] x5, y5;
logic signed [31:0] x6, y6;
logic signed [31:0] x7, y7;
logic signed [31:0] x8, y8;
logic signed [31:0] x9, y9;
logic signed [31:0] x10, y10;
logic signed [31:0] x11, y11;
logic signed [31:0] x12, y12;
logic signed [31:0] x13, y13;
logic signed [31:0] x14, y14;
logic signed [31:0] x15, y15;
logic signed [31:0] x16, y16;
logic signed [15:0] euclidean_distance_r ,euclidean_distance_w;



always_comb begin 
    state_w = state_r;
    case(state)
        S_IDLE : begin
            if(i_valid) begin
                state_w = S_OUTPUT;
            end
            else begin
                state_w = S_IDLE;
            end
        end
        S_OUTPUT : begin
            if(i_valid) begin
                state_w = S_OUTPUT;
            end
            else begin
                state_w = S_IDLE;
            end
        end
    endcase
end
always_comb begin 
    case(state)
        S_IDLE : begin
            
        end
        S_OUTPUT : begin
            
        end
    endcase
end

always_comb begin 
    if(y0[31])begin
        x1 = x0 - y0;
        y1 = y0 + x0;
    end
    else begin
        x1 = x0 + y0;
        y1 = y0 - x0;
    end

    if(y1[31])begin
        x2 = x1 - (y1 >>> 1);
        y2 = y1 + (x1 >>> 1);
    end
    else begin
        x2 = x1 + (y1 >>> 1);
        y2 = y1 - (x1 >>> 1);
    end

    if(y2[31])begin
        x3 = x2 - (y2 >>> 2);
        y3 = y2 + (x2 >>> 2);
    end
    else begin
        x3 = x2 + (y2 >>> 2);
        y3 = y2 - (x2 >>> 2);
    end

    if(y3[31])begin
        x4 = x3 - (y3 >>> 3);
        y4 = y3 + (x3 >>> 3);
    end
    else begin
        x4 = x3 + (y3 >>> 3);
        y4 = y3 - (x3 >>> 3);
    end

    if(y4[31])begin
        x5 = x4 - (y4 >>> 4);
        y5 = y4 + (x4 >>> 4);
    end
    else begin
        x5 = x4 + (y4 >>> 4);
        y5 = y4 - (x4 >>> 4);
    end

    if(y5[31])begin
        x6 = x5 - (y5 >>> 5);
        y6 = y5 + (x5 >>> 5);
    end
    else begin
        x6 = x5 + (y5 >>> 5);
        y6 = y5 - (x5 >>> 5);
    end

    if(y6[31])begin
        x7 = x6 - (y6 >>> 6);
        y7 = y6 + (x6 >>> 6);
    end
    else begin
        x7 = x6 + (y6 >>> 6);
        y7 = y6 - (x6 >>> 6);
    end

    if(y7[31])begin
        x8 = x7 - (y7 >>> 7);
        y8 = y7 + (x7 >>> 7);
    end
    else begin
        x8 = x7 + (y7 >>> 7);
        y8 = y7 - (x7 >>> 7);
    end

    if(y8[31])begin
        x9 = x8 - (y8 >>> 8);
        y9 = y8 + (x8 >>> 8);
    end
    else begin
        x9 = x8 + (y8 >>> 8);
        y9 = y8 - (x8 >>> 8);
    end

    if(y9[31])begin
        x10 = x9 - (y9 >>> 9);
        y10 = y9 + (x9 >>> 9);
    end
    else begin
        x10 = x9 + (y9 >>> 9);
        y10 = y9 - (x9 >>> 9);
    end

    if(y10[31])begin
        x11 = x10 - (y10 >>> 10);
        y11 = y10 + (x10 >>> 10);
    end
    else begin
        x11 = x10 + (y10 >>> 10);
        y11 = y10 - (x10 >>> 10);
    end

    if(y11[31])begin
        x12 = x11 - (y11 >>> 11);
        y12 = y11 + (x11 >>> 11);
    end
    else begin
        x12 = x11 + (y11 >>> 11);
        y12 = y11 - (x11 >>> 11);
    end

    if(y12[31])begin
        x13 = x12 - (y12 >>> 12);
        y13 = y12 + (x12 >>> 12);
    end
    else begin
        x13 = x12 + (y12 >>> 12);
        y13 = y12 - (x12 >>> 12);
    end

    if(y13[31])begin
        x14 = x13 - (y13 >>> 13);
        y14 = y13 + (x13 >>> 13);
    end
    else begin
        x14 = x13 + (y13 >>> 13);
        y14 = y13 - (x13 >>> 13);
    end

    if(y14[31])begin
        x15 = x14 - (y14 >>> 14);
        y15 = y14 + (x14 >>> 14);
    end
    else begin
        x15 = x14 + (y14 >>> 14);
        y15 = y14 - (x14 >>> 14);
    end

    if(y15[31])begin
        x16 = x15 - (y15 >>> 15);
        y16 = y15 + (x15 >>> 15);
    end
    else begin
        x16 = x15 + (y15 >>> 15);
        y16 = y15 - (x15 >>> 15);
    end
end



always_ff @(posedge i_50M_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
		state_r <= S_IDLE;
        
	end
	else begin
		state_r <= state_w;

	end
end

endmodule

/*module CORDIC_Euclidean_Distance(
    CLK_50M,RST_N,
    x,y,
    start,
    finished,
    angle,
    distance
);
input               CLK_50M;
input               RST_N;
input     [31:0]    x;
input     [31:0]    y;
input               start;
output              finished;
output    [15:0]    angle;
output    [15:0]    distance;

`define angle0  32'd2949120        //45¢X*2^16
`define angle1  32'd1740992        //26.5651¢X*2^16
`define angle2  32'd919872        //14.0362¢X*2^16
`define angle3  32'd466944        //7.1250¢X*2^16
`define angle4  32'd234368        //3.5763¢X*2^16
`define angle5  32'd117312        //1.7899¢X*2^16
`define angle6  32'd58688        //0.8952¢X*2^16
`define angle7  32'd29312        //0.4476¢X*2^16
`define angle8  32'd14656        //0.2238¢X*2^16
`define angle9  32'd7360            //0.1119¢X*2^16
`define angle10 32'd3648            //0.0560¢X*2^16
`define angle11 32'd1856            //0.0280¢X*2^16
`define angle12 32'd896            //0.0140¢X*2^16
`define angle13 32'd448            //0.0070¢X*2^16
`define angle14 32'd256            //0.0035¢X*2^16
`define angle15 32'd128            //0.0018¢X*2^16
//parameter Pipeline = 16;
//parameter K = 32'h09b74;    //K=0.607253*2^16,32'h09b74,
reg signed     [15:0]         angle;
reg      [15:0]         distance;
reg signed     [31:0]         x0=0,y0=0,z0=0;
reg signed     [31:0]         x1=0,y1=0,z1=0;
reg signed     [31:0]         x2=0,y2=0,z2=0;
reg signed     [31:0]         x3=0,y3=0,z3=0;
reg signed     [31:0]         x4=0,y4=0,z4=0;
reg signed     [31:0]         x5=0,y5=0,z5=0;
reg signed     [31:0]         x6=0,y6=0,z6=0;
reg signed     [31:0]         x7=0,y7=0,z7=0;
reg signed     [31:0]         x8=0,y8=0,z8=0;
reg signed     [31:0]         x9=0,y9=0,z9=0;
reg signed     [31:0]         x10=0,y10=0,z10=0;
reg signed     [31:0]         x11=0,y11=0,z11=0;
reg signed     [31:0]         x12=0,y12=0,z12=0;
reg signed     [31:0]         x13=0,y13=0,z13=0;
reg signed     [31:0]         x14=0,y14=0,z14=0;
reg signed     [31:0]         x15=0,y15=0,z15=0;
reg signed     [31:0]         x16=0,y16=0,z16=0;
reg            [ 4:0]         count;
always@ (posedge CLK_50M or negedge RST_N) begin
    if(!RST_N)
      count <= 4'b00;
    else if( start ) begin
        if( count!=5'd18 )
        count <= count+1'b1;
      else if( count == 5'd18 )
        count <= count;
    end
    else
      count <= 5'h00;
end
assign finished = (count == 5'd18)?1'b1:1'b0;
always @ (posedge CLK_50M or negedge RST_N)
begin
    if(!RST_N)
    begin
        x0 <= 1'b0;
        y0 <= 1'b0;
        z0 <= 1'b0;
    end
    else
    begin
        x0 <= x<<16;
        y0 <= y<<16;
        z0 <= 32'h00;
    end
end
always @ (posedge CLK_50M or negedge RST_N)
begin
    if(!RST_N)
    begin
        x1 <= 1'b0;
        y1 <= 1'b0;
        z1 <= 1'b0;
    end
    else if(y0[31])
    begin
      x1 <= x0 - y0;
      y1 <= y0 + x0;
      z1 <= z0 - `angle0;
    end
    else
    begin
      x1 <= x0 + y0;
      y1 <= y0 - x0;
      z1 <= z0 + `angle0;
    end
end
always @ (posedge CLK_50M or negedge RST_N)
begin
    if(!RST_N)
    begin
        x2 <= 1'b0;
        y2 <= 1'b0;
        z2 <= 1'b0;
    end
    else if(y1[31])
   begin
        x2 <= x1 - (y1 >>> 1);
        y2 <= y1 + (x1 >>> 1);
        z2 <= z1 - `angle1;
   end
   else
   begin
       x2 <= x1 + (y1 >>> 1);
       y2 <= y1 - (x1 >>> 1);
       z2 <= z1 + `angle1;
   end
end
always @ (posedge CLK_50M or negedge RST_N)
begin
    if(!RST_N)
    begin
        x3 <= 1'b0;
        y3 <= 1'b0;
        z3 <= 1'b0;
    end
    else if(y2[31])
   begin
       x3 <= x2 - (y2 >>> 2);
       y3 <= y2 + (x2 >>> 2);
       z3 <= z2 - `angle2;
   end
   else
   begin
       x3 <= x2 + (y2 >>> 2);
       y3 <= y2 - (x2 >>> 2);
       z3 <= z2 + `angle2;
   end
end
always @ (posedge CLK_50M or negedge RST_N)
begin
    if(!RST_N)
    begin
        x4 <= 1'b0;
        y4 <= 1'b0;
        z4 <= 1'b0;
    end
    else if(y3[31])
   begin
       x4 <= x3 - (y3 >>> 3);
       y4 <= y3 + (x3 >>> 3);
       z4 <= z3 - `angle3;
   end
   else
   begin
       x4 <= x3 + (y3 >>> 3);
       y4 <= y3 - (x3 >>> 3);
       z4 <= z3 + `angle3;
   end
end
always @ (posedge CLK_50M or negedge RST_N)
begin
    if(!RST_N)
    begin
        x5 <= 1'b0;
        y5 <= 1'b0;
        z5 <= 1'b0;
    end
    else if(y4[31])
   begin
       x5 <= x4 - (y4 >>> 4);
       y5 <= y4 + (x4 >>> 4);
       z5 <= z4 - `angle4;
   end
   else
   begin
       x5 <= x4 + (y4 >>> 4);
       y5 <= y4 - (x4 >>> 4);
       z5 <= z4 + `angle4;
   end
end
always @ (posedge CLK_50M or negedge RST_N)
begin
    if(!RST_N)
    begin
        x6 <= 1'b0;
        y6 <= 1'b0;
        z6 <= 1'b0;
    end
    else if(y5[31])
   begin
       x6 <= x5 - (y5 >>> 5);
       y6 <= y5 + (x5 >>> 5);
       z6 <= z5 - `angle5;
   end
   else
   begin
       x6 <= x5 + (y5 >>> 5);
       y6 <= y5 - (x5 >>> 5);
       z6 <= z5 + `angle5;
   end
end
always @ (posedge CLK_50M or negedge RST_N)
begin
    if(!RST_N)
    begin
        x7 <= 1'b0;
        y7 <= 1'b0;
        z7 <= 1'b0;
    end
    else if(y6[31])
   begin
       x7 <= x6 - (y6 >>> 6);
       y7 <= y6 + (x6 >>> 6);
       z7 <= z6 - `angle6;
   end
   else
   begin
       x7 <= x6 + (y6 >>> 6);
       y7 <= y6 - (x6 >>> 6);
       z7 <= z6 + `angle6;
   end
end
always @ (posedge CLK_50M or negedge RST_N)
begin
    if(!RST_N)
    begin
        x8 <= 1'b0;
        y8 <= 1'b0;
        z8 <= 1'b0;
    end
    else if(y7[31])
   begin
       x8 <= x7 - (y7 >>> 7);
       y8 <= y7 + (x7 >>> 7);
       z8 <= z7 - `angle7;
   end
   else
   begin
       x8 <= x7 + (y7 >>> 7);
       y8 <= y7 - (x7 >>> 7);
       z8 <= z7 + `angle7;
   end
end
always @ (posedge CLK_50M or negedge RST_N)
begin
    if(!RST_N)
    begin
        x9 <= 1'b0;
        y9 <= 1'b0;
        z9 <= 1'b0;
    end
    else if(y8[31])
   begin
       x9 <= x8 - (y8 >>> 8);
       y9 <= y8 + (x8 >>> 8);
       z9 <= z8 - `angle8;
   end
   else
   begin
       x9 <= x8 + (y8 >>> 8);
       y9 <= y8 - (x8 >>> 8);
       z9 <= z8 + `angle8;
   end
end
always @ (posedge CLK_50M or negedge RST_N)
begin
    if(!RST_N)
    begin
        x10 <= 1'b0;
        y10 <= 1'b0;
        z10 <= 1'b0;
    end
    else if(y9[31])
   begin
       x10 <= x9 - (y9 >>> 9);
       y10 <= y9 + (x9 >>> 9);
       z10 <= z9 - `angle9;
   end
   else
   begin
       x10 <= x9 + (y9 >>> 9);
       y10 <= y9 - (x9 >>> 9);
       z10 <= z9 + `angle9;
   end
end
always @ (posedge CLK_50M or negedge RST_N)
begin
    if(!RST_N)
    begin
        x11 <= 1'b0;
        y11 <= 1'b0;
        z11 <= 1'b0;
    end
    else if(y10[31])
   begin
       x11 <= x10 - (y10 >>> 10);
       y11 <= y10 + (x10 >>> 10);
       z11 <= z10 - `angle10;
   end
   else
   begin
       x11 <= x10 + (y10 >>> 10);
       y11 <= y10 - (x10 >>> 10);
       z11 <= z10 + `angle10;
   end
end
always @ (posedge CLK_50M or negedge RST_N)
begin
    if(!RST_N)
    begin
        x12 <= 1'b0;
        y12 <= 1'b0;
        z12 <= 1'b0;
    end
    else if(y11[31])
   begin
       x12 <= x11 - (y11 >>> 11);
       y12 <= y11 + (x11 >>> 11);
       z12 <= z11 - `angle11;
   end
   else
   begin
       x12 <= x11 + (y11 >>> 11);
       y12 <= y11 - (x11 >>> 11);
       z12 <= z11 + `angle11;
   end
end
always @ (posedge CLK_50M or negedge RST_N)
begin
    if(!RST_N)
    begin
        x13 <= 1'b0;
        y13 <= 1'b0;
        z13 <= 1'b0;
    end
    else if(y12[31])
   begin
       x13 <= x12 - (y12 >>> 12);
       y13 <= y12 + (x12 >>> 12);
       z13 <= z12 - `angle12;
   end
   else
   begin
       x13 <= x12 + (y12 >>> 12);
       y13 <= y12 - (x12 >>> 12);
       z13 <= z12 + `angle12;
   end
end
always @ (posedge CLK_50M or negedge RST_N)
begin
    if(!RST_N)
    begin
        x14 <= 1'b0;
        y14 <= 1'b0;
        z14 <= 1'b0;
    end
    else if(y13[31])
   begin
       x14 <= x13 - (y13 >>> 13);
       y14 <= y13 + (x13 >>> 13);
       z14 <= z13 - `angle13;
   end
   else
   begin
       x14 <= x13 + (y13 >>> 13);
       y14 <= y13 - (x13 >>> 13);
       z14 <= z13 + `angle13;
   end
end
always @ (posedge CLK_50M or negedge RST_N)
begin
    if(!RST_N)
    begin
        x15 <= 1'b0;
        y15 <= 1'b0;
        z15 <= 1'b0;
    end
    else if(y14[31])
   begin
       x15 <= x14 - (y14 >>> 14);
       y15 <= y14 + (x14 >>> 14);
       z15 <= z14 - `angle14;
   end
   else
   begin
       x15 <= x14 + (y14 >>> 14);
       y15 <= y14 - (x14 >>> 14);
       z15 <= z14 + `angle14;
   end
end
always @ (posedge CLK_50M or negedge RST_N)
begin
    if(!RST_N)
    begin
        x16 <= 1'b0;
        y16 <= 1'b0;
        z16 <= 1'b0;
    end
    else if(y15[31])
   begin
       x16 <= x15 - (y15 >>> 15);
       y16 <= y15 + (x15 >>> 15);
       z16 <= z15 - `angle15;
   end
   else
   begin
       x16 <= x15 + (y15 >>> 15);
       y16 <= y15 - (x15 >>> 15);
       z16 <= z15 + `angle15;
   end
end
wire[31:0]  distance_tmp;
wire[31:0]  distance_tmp1;
wire[31:0]  distance_tmp2;
assign distance_tmp = x16>>6;
assign distance_tmp1 = distance_tmp+distance_tmp+distance_tmp+distance_tmp+distance_tmp+distance_tmp+distance_tmp;
assign distance_tmp2 = x16>>1;
always @ (posedge CLK_50M or negedge RST_N)
begin
    if(!RST_N)
    begin
        angle <= 1'b0;
        distance   <= 16'b0;
    end
    else
    begin
        angle <= z16>>16;
        distance <= (distance_tmp1+distance_tmp2)>>16;  //x16*0.607253
    end
end
endmodule*/