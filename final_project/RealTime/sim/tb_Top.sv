`timescale 1ns/1ns

module tb_TOP;

parameter	cycle_50M = 20;
parameter	cycle_25M = 40;
parameter   bclk_cycle = 312.5;
parameter	lr_cycle = 20000;

//parameter all1_16bit = 65535;   // parameter  all1_16bit = (1 << 16) - 1
logic 		i_clk_50M, i_clk_25M, i_bclk, i_lrck;
logic       i_rst;
logic       i_start;

logic random_data [15:0];
logic [19:0] o_SRAM_ADDR, SRAM_address;
wire [15:0] io_SRAM_DQ; 

// SRAM 
logic o_SRAM_WE_N, o_SRAM_CE_N, o_SRAM_OE_N, o_SRAM_LB_N, o_SRAM_UB_N;

//logic [19:0] o_SRAM_ADDR, SRAM_address;
//wire [15:0] io_SRAM_DQ; 

// SRAM 
//logic o_SRAM_WE_N, o_SRAM_CE_N, o_SRAM_OE_N, o_SRAM_LB_N, o_SRAM_UB_N;
//logic SRAM_write;

logic [7:0] VGA_R, VGA_G, VGA_B;
logic VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS;

integer i;

initial i_clk_50M = 0;
always #(cycle_50M/2.0) i_clk_50M = ~i_clk_50M;

initial i_clk_25M = 0;
always #(cycle_25M/2.0) i_clk_25M = ~i_clk_25M;

initial i_bclk = 0;
always #(bclk_cycle/2.0) i_bclk = ~i_bclk;

initial i_lrck = 0;
always #(lr_cycle/2.0) i_lrck = ~i_lrck;

//assign SRAM_address = o_SRAM_ADDR;
//assign SRAM_write = ~o_SRAM_WE_N;

assign SRAM_address = o_SRAM_ADDR;
assign SRAM_write = ~o_SRAM_WE_N;

Top top0(
    .i_50M_clk(i_clk_50M),
	.i_25M_clk(i_clk_25M),
    .i_BCLK(i_bclk), 
    .i_LRCK(i_lrck),
    .i_rst(i_rst), 
    .i_start(i_start), 
    .i_mic_data(random_data),

	//SRAM
	.o_SRAM_ADDR(o_SRAM_ADDR), 
	.io_SRAM_DQ(io_SRAM_DQ),  
	.o_SRAM_WE_N(o_SRAM_WE_N), 
	.o_SRAM_CE_N(o_SRAM_CE_N), 
	.o_SRAM_OE_N(o_SRAM_OE_N), 
	.o_SRAM_LB_N(o_SRAM_LB_N), 
	.o_SRAM_UB_N(o_SRAM_UB_N),
	//VGA
	.VGA_R(VGA_R),
	.VGA_G(VGA_G),
    .VGA_B(VGA_B),
    .VGA_BLANK_N(VGA_BLANK_N),
    .VGA_CLK(VGA_CLK),
    .VGA_HS(VGA_HS),
    .VGA_SYNC_N(VGA_SYNC_N),
    .VGA_VS(VGA_VS)
);

SRAM SRAM0(
	.i_clk(i_clk_50M),
	.i_write(SRAM_write),
	.i_address(SRAM_address),
	.io_data(io_SRAM_DQ)
);


initial begin	
	#(lr_cycle*3000);
	$finish;
end

initial begin
	$fsdbDumpfile("tb_TOP.fsdb");
	$fsdbDumpvars(0, tb_TOP, "+all");
end


initial begin
    forever begin
        @(negedge i_bclk) begin
			for(i=0; i<16; i=i+1) random_data[i] = $urandom() & 1;
		end
    end
end

initial begin	
	i_clk_50M = 0;
	i_clk_25M = 0;
    i_bclk  = 0;
	i_lrck 	= 0;
	i_rst = 0;
    i_start = 0;
	
	@(negedge i_clk_50M);
	@(negedge i_clk_50M);
	@(negedge i_clk_50M) i_rst = 1;
	@(negedge i_clk_50M) i_rst = 0; 

	@(negedge i_clk_50M);
	@(negedge i_clk_50M);
	@(negedge i_clk_50M);
	#(lr_cycle*15);
	@(negedge i_clk_50M) i_start = 1;
	@(negedge i_clk_50M) i_start = 0;
end


endmodule