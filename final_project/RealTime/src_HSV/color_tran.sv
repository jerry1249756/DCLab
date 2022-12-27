`define H_MAX 255
`define S 178
`define V 255
module HSV_to_RGB(
    input [15:0] i_data,
    output [$clog2(256)-1:0] R,
    output [$clog2(256)-1:0] G,
    output [$clog2(256)-1:0] B
);

logic [$clog2(`H_MAX)-1:0] H;
assign H = (16'hffff - i_data) >> 8;
logic [2:0] quotient;
logic [$clog2(`H_MAX)-1:0] remainder;
logic [7:0] p; 
logic [$clog2(`H_MAX)+8:0] q, t;
logic [$clog2(256)-1:0] R_reg, G_reg, B_reg;

assign quotient = H/43;
assign remainder = (H%43)*6;
assign p = 8'd77;
assign q = (`V * (255 - ((`S * remainder) >> 8 ))) >> 8;
assign t = (`V * (255 - ((`S * (255-remainder)) >> 8 ))) >> 8;

assign R = R_reg;
assign G = G_reg;
assign B = B_reg;

always_comb begin
    case(quotient)
        3'd0: begin
            R_reg = `V;
            G_reg = t;
            B_reg = p;
        end
        3'd1: begin
            R_reg = q;
            G_reg = `V;
            B_reg = p;
        end
        3'd2: begin
            R_reg = p;
            G_reg = `V;
            B_reg = t;
        end
        3'd3: begin
            R_reg = p;
            G_reg = q;
            B_reg = `V;
        end
        3'd4: begin
            R_reg = t;
            G_reg = p;
            B_reg = `V;
        end
        default: begin
            R_reg = `V;
            G_reg = p;
            B_reg = q;
        end

        
    endcase
end
    
endmodule