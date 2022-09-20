module LED (
	input  i_clk,
	input  i_state,
   input  [3:0] i_random_out,
	output [8:0] o_LEDG,
	output [17:0] o_LEDR
);

parameter Test_LEDG = 9'b001100110;
parameter Test_LEDR = 18'b0011_0011_0011_0011_00;

logic [8:0] LEDG;
logic [17:0] LEDR;

assign o_LEDG = LEDG;
assign o_LEDR = LEDR;


always_comb begin
	LEDG = Test_LEDG;
	LEDR = Test_LEDR;
end

endmodule
