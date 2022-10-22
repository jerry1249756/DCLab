`timescale 1ns/100ps

module Lab3_Top_test;

<<<<<<< HEAD
parameter	BCLK_cycle = 651.0; //10k HZ TOP
parameter	hundredk_cycle = 10000.0; //12M HZ DAC ADC 
parameter	lr_cycle = BCLK_cycle*160;
parameter	i_clk_cycle = 83.0;
=======
parameter	BCLK_cycle = 10.0; //10k HZ TOP
parameter	hundredk_cycle = 10.0; //12M HZ DAC ADC 
parameter	lr_cycle = 400.0;
parameter	i_clk_cycle = 10.0;
>>>>>>> 8b5fe5b580ec10c02ba6a1eb7d910bd574e80395

logic i_rst_n, i_clk, i_key_0, i_key_1, i_key_2;
logic [4:0]  i_speed; 
logic [19:0] o_SRAM_ADDR; 

logic o_SRAM_WE_N, o_SRAM_CE_N, o_SRAM_OE_N, o_SRAM_LB_N, o_SRAM_UB_N;
logic i_clk_100k, o_I2C_SCLK,  i_AUD_ADCDAT, i_AUD_ADCLRCK_r, i_AUD_BCLK_r, i_AUD_DACLRCK_r, o_AUD_DACDAT;

wire i_AUD_ADCLRCK, i_AUD_BCLK, i_AUD_DACLRCK, io_I2C_SDAT;
wire [15:0] io_SRAM_DQ; 
/*
logic i2c_write, sram_write;

assign i2c_write = (io_I2C_SDAT == 1'bz)? 1'b0 : 1'b1;
assign sram_write = (io_SRAM_DQ == 16'bz)? 1'b0 : 1'b1;
*/
initial i_clk = 0;
always #(i_clk_cycle/2.0) i_clk = ~i_clk;

initial i_AUD_BCLK_r = 0;
always #(BCLK_cycle/2.0) i_AUD_BCLK_r = ~i_AUD_BCLK_r;

initial i_clk_100k = 0;
always #(hundredk_cycle/2.0) i_clk_100k = ~i_clk_100k;

initial i_AUD_DACLRCK_r = 0;
always #(lr_cycle/2.0) i_AUD_DACLRCK_r = ~i_AUD_DACLRCK_r;

initial i_AUD_ADCLRCK_r = 0;
always #(lr_cycle/2.0) i_AUD_ADCLRCK_r = ~i_AUD_ADCLRCK_r;

assign i_AUD_BCLK = (1)? i_AUD_BCLK_r : 1'bz; //output
assign i_AUD_DACLRCK = (1)? i_AUD_DACLRCK_r : 1'bz;
assign i_AUD_ADCLRCK = (1)? i_AUD_ADCLRCK_r : 1'bz;


logic SRAM_write;
logic [19:0] SRAM_address;
logic [15:0] SRAM_data_r;

//wire [15:0] SRAM_data;

//reg [15:0] SRAM_data_get;

//assign SRAM_data = io_SRAM_DQ 

//assign io_SRAM_DQ  = (SRAM_write != 1'b1) ? SRAM_data : 16'd0; // sram_dq as input

assign SRAM_address = o_SRAM_ADDR;
assign SRAM_write = ~o_SRAM_WE_N;

Top Top0(
	.i_rst_n(i_rst_n), //
	.i_clk(i_clk),   //
	.i_key_0(i_key_0),  //record
	.i_key_1(i_key_1), //play
	.i_key_2(i_key_2), //stop
	.i_speed(i_speed), 
	.o_SRAM_ADDR(o_SRAM_ADDR), 
	.io_SRAM_DQ(io_SRAM_DQ),  //IO
	.o_SRAM_WE_N(o_SRAM_WE_N), 
	.o_SRAM_CE_N(o_SRAM_CE_N), 
	.o_SRAM_OE_N(o_SRAM_OE_N), 
	.o_SRAM_LB_N(o_SRAM_LB_N), 
	.o_SRAM_UB_N(o_SRAM_UB_N),
	.i_clk_100k(i_clk_100k), //
	.o_I2C_SCLK(o_I2C_SCLK),
	.io_I2C_SDAT(io_I2C_SDAT), //IO
	.i_AUD_ADCDAT(i_AUD_ADCDAT), 
	.i_AUD_ADCLRCK(i_AUD_ADCLRCK), //IO
	.i_AUD_BCLK(i_AUD_BCLK), //IO
	.i_AUD_DACLRCK(i_AUD_DACLRCK), //IO
	.o_AUD_DACDAT(o_AUD_DACDAT)
);

SRAM SRAM0(
	.i_clk(i_AUD_BCLK),
	.i_write(SRAM_write),
	.i_address(SRAM_address),
	.io_data(io_SRAM_DQ)
);

initial begin
	$fsdbDumpfile("Lab3_Top_test.fsdb");
	$fsdbDumpvars(0, Lab3_Top_test, "+all");
end

initial begin	
	#(i_clk_cycle*100000);
	$finish;
end


initial begin	
	i_rst_n = 1'b1;
	i_key_0 = 1'b0;
	i_key_2 = 1'b0;
	i_key_1 = 1'b0;
	@(negedge i_clk); 
	@(negedge i_clk); 
	@(negedge i_clk); 
	@(negedge i_clk); 
	i_rst_n = 1'b0;
	#(i_clk_cycle*1);
	i_rst_n = 1'b1;
	//start record
	#(i_clk_cycle*10000); 
	i_key_0 = 1'b1;
	#(i_clk_cycle*1);
	i_key_0 = 1'b0;

	#(i_clk_cycle*10000);

	//pause record
	i_key_0 = 1'b1;
	#(i_clk_cycle*1);
	i_key_0 = 1'b0;

	#(i_clk_cycle*5000);

	i_key_0 = 1'b1;
	#(i_clk_cycle*1);
	i_key_0 = 1'b0;

	#(i_clk_cycle*20000);
	/*
	//stop record
	i_key_2 = 1'b1;
	#(i_clk_cycle*1);
	i_key_2 = 1'b0;
	*/
	#(i_clk_cycle*10000);
	//start play 
	i_key_1 = 1'b1;
	#(i_clk_cycle*1);
	i_key_1 = 1'b0;

	#(i_clk_cycle*12000);

	//pause play
	i_key_1 = 1'b1;
	#(i_clk_cycle*1);
	i_key_1 = 1'b0;

	#(i_clk_cycle*2000);

	//continue play
	i_key_1 = 1'b1;
	#(i_clk_cycle*1);
	i_key_1 = 1'b0;

	#(i_clk_cycle*5000);

	//stop play 
	//i_key_2 = 1'b1;
	//#(i_clk_cycle*1);
	//i_key_2 = 1'b0;

end

always @(*) begin
	if(i_AUD_BCLK == 1'b0) begin
		i_AUD_ADCDAT = 16'b0010100110010101 * ($random % 600);
		#(BCLK_cycle);
	end
	else begin
		i_AUD_ADCDAT = 16'b0000000000000000;
	end
end

initial begin 
	i_speed = 5'b01001;
end

endmodule
