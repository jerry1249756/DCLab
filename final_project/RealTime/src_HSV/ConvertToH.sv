`define H_MAX 255

module ConvertToH(
    input [15:0] i_data,
    output [$clog(`H_MAX)-1 : 0] o_data
);

logic [15:0] invert_data;
assign invert_data = 16'hffff - i_data;

assign o_data = invert_data >> 8;

endmodule