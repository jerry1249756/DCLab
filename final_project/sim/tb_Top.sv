`timescale 1us/1us

module tb_TOP;

parameter	cycle = 10.0;
parameter   bclk_cycle = 100.0;
parameter	lr_cycle = 5800.0;

parameter all1_16bit = 65535;   // parameter  all1_16bit = (1 << 16) - 1
logic 		i_clk, i_bclk, i_lrck;
logic       i_rst;
logic       i_start;

logic [15:0] random_data;
logic [19:0] o_SRAM_ADDR, SRAM_address;
wire [15:0] io_SRAM_DQ; 

// SRAM 
logic o_SRAM_WE_N, o_SRAM_CE_N, o_SRAM_OE_N, o_SRAM_LB_N, o_SRAM_UB_N;
logic SRAM_write;

logic [7:0] VGA_R, VGA_G, VGA_B;
logic VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS;


initial i_clk = 0;
always #(cycle/2.0) i_clk = ~i_clk;

initial i_bclk = 0;
always #(bclk_cycle/2.0) i_bclk = ~i_bclk;

initial i_lrck = 0;
always #(lr_cycle/2.0) i_lrck = ~i_lrck;

assign SRAM_address = o_SRAM_ADDR;
assign SRAM_write = ~o_SRAM_WE_N;

Top top0(
    .i_50M_clk(i_clk),
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
	.i_clk(i_clk),
	.i_write(SRAM_write),
	.i_address(SRAM_address),
	.io_data(io_SRAM_DQ)
);


initial begin	
	#(cycle*5000000);
	$finish;
end

initial begin
	$fsdbDumpfile("tb_TOP.fsdb");
	$fsdbDumpvars(0, tb_TOP, "+all");
end


initial begin
    forever begin
        @(negedge i_clk) random_data = $urandom() & all1_16bit;
    end
end

initial begin	
	i_clk 	= 0;
    i_bclk  = 0;
	i_lrck 	= 0;
	i_rst = 0;
    i_start = 0;

	@(negedge i_clk);
	@(negedge i_clk);
	@(negedge i_clk) i_rst = 1;
	@(negedge i_clk) i_rst = 0; 

	@(negedge i_clk);
	@(negedge i_clk);
	@(negedge i_clk);
	#(cycle*15);
	@(negedge i_clk) i_start = 1;
	@(negedge i_clk) i_start = 0;
end


endmodule