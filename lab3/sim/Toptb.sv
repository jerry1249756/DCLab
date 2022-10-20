`timescale 1us/1us

module Top_test;

parameter cycle = 100.0;

logic i_rst_n, i_clk, i_key_0, i_key_1, i_key_2;
logic [4:0]  i_speed; 
logic [19:0] o_SRAM_ADDR; 
logic [15:0] io_SRAM_DQ; 
logic o_SRAM_WE_N, o_SRAM_CE_N, o_SRAM_OE_N, o_SRAM_LB_N, o_SRAM_UB_N;
logic i_clk_100k, o_I2C_SCLK, io_I2C_SDAT, i_AUD_ADCDAT, i_AUD_ADCLRCK, i_AUD_BCLK, i_AUD_DACLRCK, o_AUD_DACDAT;

logic i2c_write, sram_write;

assign i2c_write = (io_I2C_SDAT == 1'bz?) 1'b0 : 1'b1;
assign sram_write = (io_SRAM_DQ == 16'bz?) 1'b0 : 1'b1;

Top Top0(
	.i_rst_n(i_rst_n), 
	.i_clk(i_clk),   
	.i_key_0(i_key_0), 
	.i_key_1(i_key_1), 
	.i_key_2(i_key_2), 
	.i_speed(i_speed), 
	.o_SRAM_ADDR(o_SRAM_ADDR), 
	.io_SRAM_DQ(io_SRAM_DQ),  
	.o_SRAM_WE_N(o_SRAM_WE_N), 
	.o_SRAM_CE_N(o_SRAM_CE_N), 
	.o_SRAM_OE_N(o_SRAM_OE_N), 
	.o_SRAM_LB_N(o_SRAM_LB_N), 
	.o_SRAM_UB_N(_SRAM_UB_N),
	.i_clk_100k(i_clk_100k),
	.o_I2C_SCLK(o_I2C_SCLK),
	.io_I2C_SDAT(io_I2C_SDAT), 
	.i_AUD_ADCDAT(i_AUD_ADCDAT),
	.i_AUD_ADCLRCK(i_AUD_ADCLRCK),
	.i_AUD_BCLK(i_AUD_BCLK),
	.i_AUD_DACLRCK(i_AUD_DACLRCK),
	.o_AUD_DACDAT(o_AUD_DACDAT)
);

initial i_clk = 0;
always #(cycle/2.0) i_clk = ~i_clk;
initial begin
	$fsdbDumpfile("Lab3_Top_test.fsdb");
	$fsdbDumpvars(0, Top_test, "+all");
end


initial begin	
 

	$finish;
end