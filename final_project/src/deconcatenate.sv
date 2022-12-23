`define PARALLEL 5

module deconcatenate(
    input [24*`PARALLEL-1:0] i_before_con,
    output [23:0] o_parallel1,
    output [23:0] o_parallel2,
    output [23:0] o_parallel3,
    output [23:0] o_parallel4,
    output [23:0] o_parallel5

);

assign o_parallel5 = i_before_con[23:0];
assign o_parallel4 = i_before_con[47:24];
assign o_parallel3 = i_before_con[71:48];
assign o_parallel2 = i_before_con[95:72];
assign o_parallel1 = i_before_con[119:96];

endmodule

