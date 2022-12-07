module Clock_Generate(
    input i_fast_50M_clk,
    input i_rst,
    output o_slow_25M_clk
);

logic flag_25_r, flag_25_w;
assign o_slow_25M_clk = flag_25_r;

always_comb begin
    flag_25_w = !flag_25_r;
end


always_ff @(posedge i_fast_50M_clk or posedge i_rst) begin
	if(i_rst)begin
        flag_25_r <= 0;
	end
	else begin
        flag_25_r <= flag_25_w;
	end
end
endmodule

