`timescale 1ns/1ns

module tb_Square_Add;

parameter cycle_50M = 20.0;

integer i;

logic 		i_50M_clk;
logic 		i_rst_n, i_valid;
logic signed [23:0] i_data  [11:0];

logic signed [63:0] o_square_add_data;
logic o_ready;

initial i_50M_clk = 0;
always #(cycle_50M/2.0) i_50M_clk = ~i_50M_clk;


Square_Add Square_Add0(
	.i_50M_clk(i_50M_clk), 
	.i_rst_n(i_rst_n),
	.i_valid(i_valid),
	.i_data(i_data),
	.o_square_add_data(o_square_add_data),
	.o_ready(o_ready)
);  


initial begin
	$fsdbDumpfile("Square_Add.fsdb");
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
	for(i=0 ; i<12 ; i++) begin
		i_data[i] <= 12'd1;
	end
	@(negedge i_50M_clk);
	i_valid <= 1;
	for(i=0 ; i<12 ; i++) begin
		i_data[i] <= 12'd2;
	end
	@(negedge i_50M_clk);
	i_valid <= 1;
	for(i=0 ; i<12 ; i++) begin
		i_data[i] <= 12'd3;
	end
	@(negedge i_50M_clk);
	i_valid <= 1;
	for(i=0 ; i<12 ; i++) begin
		i_data[i] <= 12'd4;
	end
	@(negedge i_50M_clk);
	i_valid <= 0;
	@(negedge i_50M_clk);
	@(negedge i_50M_clk);
	@(negedge i_50M_clk);
	@(negedge i_50M_clk);
	i_valid <= 1;
	for(i=0 ; i<12 ; i++) begin
		i_data[i] <= 12'd5;
	end
	@(negedge i_50M_clk);
	i_valid <= 1;
	for(i=0 ; i<12 ; i++) begin
		i_data[i] <= 12'd6;
	end
	@(negedge i_50M_clk);
	i_valid <= 1;
	for(i=0 ; i<12 ; i++) begin
		i_data[i] <= 12'd8;
	end
	@(negedge i_50M_clk);
	i_valid <= 1;
	for(i=0 ; i<12 ; i++) begin
		i_data[i] <= 12'd10;
	end
	@(negedge i_50M_clk);
	i_valid <= 0;
end




endmodule
