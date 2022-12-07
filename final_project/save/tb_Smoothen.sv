`timescale 1ns/1ns

module tb_Smoothen;

parameter cycle_50M = 20.0;

integer i;

logic 		i_50M_clk;
logic 		i_rst_n, i_valid;
logic signed [15:0] i_square_add_data_seq;
logic [19:0] i_SRAM_address;
logic [19:0] o_SRAM_address;
logic [15:0] o_SRAM_data;
logic o_ready;

initial i_50M_clk = 0;
always #(cycle_50M/2.0) i_50M_clk = ~i_50M_clk;


Smoothen Smoothen0(
	.i_50M_clk(i_50M_clk), 
	.i_rst_n(i_rst_n),
	.i_valid(i_valid),
	.i_SRAM_address(i_SRAM_address),
	.i_square_add_data_seq(i_square_add_data_seq),
	.o_SRAM_address(o_SRAM_address),
	.o_ready(o_ready),
	.o_SRAM_data(o_SRAM_data)
);  


initial begin
	$fsdbDumpfile("Smoothen.fsdb");
	$fsdbDumpvars(0, "+mda");
end

initial begin	
	#(cycle_50M*2000);
	$finish;
end

initial begin	
	i_50M_clk = 0;
	i_rst_n = 1;
	i_valid = 0;

	@(negedge i_50M_clk);
	@(negedge i_50M_clk);
	@(negedge i_50M_clk) i_rst_n = 0;
	@(negedge i_50M_clk) i_rst_n = 1; 

	@(negedge i_50M_clk);
	@(negedge i_50M_clk);
	@(negedge i_50M_clk);
	#(cycle_50M*15);
	@(negedge i_50M_clk);
	i_valid <= 1;
	@(negedge i_50M_clk);
	i_square_add_data_seq <= 16'd1;
	i_SRAM_address = 0;
	i_valid <= 0;
	@(negedge i_50M_clk);
	i_square_add_data_seq <= 16'd2;
	i_SRAM_address = 0;

end




endmodule
