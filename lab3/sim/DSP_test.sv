module AudDSPtest (
	input 		  i_rst_n,
	input 		  i_clk,
	input 		  i_daclrck,
	output [10:0] counter1,
	output [10:0] counter2
);

logic [10:0] counter1_r, counter1_w;
logic [10:0] counter2_r, counter2_w;

assign counter1 = counter1_r;
assign counter2 = counter2_r;

always_comb begin
	counter1_w = counter1_r + 1;
	counter2_w = counter2_r + 1;
end

always_ff @(posedge i_daclrck or negedge i_rst_n) begin
	if (!i_rst_n) begin
		counter1_r <= 0;
	end
	else begin
		counter1_r <= counter1_w;
	end
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
		counter2_r <= 0;
	end
	else begin
		counter2_r <= counter2_w;
	end
end

endmodule