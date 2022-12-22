`timescale 1us/1us

module Average_test;

parameter cycle = 100.0;

logic i_clk;
logic i_rst, i_valid, i_stop, i_calc_valid;
logic [8:0]  p_x, p_y;
logic [15:0] i_new, i_old;
logic [19:0] SRAM_addr;
logic [15:0] SRAM_data_input, SRAM_data_output;

initial i_clk = 0;
always #(cycle/2.0) i_clk = ~i_clk;


Average a0(
    .i_50M_clk(i_clk)            ,
	.i_rst(i_rst)              ,
	.i_init_valid(i_valid)              ,
    .i_calc_valid(i_calc_valid), 
    .i_stop(i_stop)                ,
    .i_px(p_x)                 ,
    .i_py(p_y)                 ,
	.i_new_data(i_new)           ,
	.i_old_data(i_old)           ,
	.i_sram_data_read(SRAM_data_input)         ,
    .o_sram_data_write(SRAM_data_output) ,
	.o_SRAM_addr(SRAM_addr)           //addr = 640x +y     
);


initial begin
	$fsdbDumpfile("Average_test.fsdb");
	$fsdbDumpvars(0, Average_test, "+all");
end

initial begin	
	i_clk = 0;
    i_rst = 0;
    i_valid = 0;
    i_calc_valid = 0;
    i_stop = 0;
    i_stop = 0;
    p_x =0;
    p_y =0;
    SRAM_data_input = 3;
    @(posedge i_clk);
    i_rst = 1;
    @(posedge i_clk);
    i_rst = 0;
    @(posedge i_clk);
    i_valid=1;
    i_new = 1000000000;
    i_old = 0;
    @(posedge i_clk);
    i_valid=0;
    @(posedge i_clk);@(posedge i_clk);
    p_x =1;
    p_y =0;
    i_new = 800000000;
    i_old = 200000000;
     @(posedge i_clk);@(posedge i_clk);
    p_x =2;
    p_y =0;
    i_new = 500000000;
    i_old = 100000000;
     @(posedge i_clk);@(posedge i_clk);
    p_x =3;
    p_y =0;
    i_new = 1000000002;
    i_old = 500000000;
     @(posedge i_clk);@(posedge i_clk);
    p_x =4;
    p_y =0;
    i_new = 200000000;
    i_old = 100000000;
     @(posedge i_clk);@(posedge i_clk);
    p_x =0;
    p_y =0;
    i_new = 8;
    i_old = 5;
    SRAM_data_input = 20000000;
    i_calc_valid = 1;
     @(posedge i_clk);
     i_calc_valid = 0;
     @(posedge i_clk);
    p_x =1;
    p_y =0;
    i_new = 5;
    i_old = 6;
     @(posedge i_clk);@(posedge i_clk);
    p_x =2;
    p_y =0;
    i_new = 0;
    i_old = 0;
    @(posedge i_clk);    @(posedge i_clk);
    p_x =3;
    p_y =0;
    i_new = 800000000000;
    i_old = 600000000;
    @(posedge i_clk);@(posedge i_clk);
    p_x =4;
    p_y =0;
    i_stop = 1;
   @(posedge i_clk);@(posedge i_clk);
   @(posedge i_clk);@(posedge i_clk);
   @(posedge i_clk);@(posedge i_clk);
   i_stop = 0;
    p_x =0;
    p_y =0;
    @(posedge i_clk);@(posedge i_clk);
    p_x =1;
    p_y =0;
    @(posedge i_clk);@(posedge i_clk);
    p_x =2;
    p_y =0;
    @(posedge i_clk);@(posedge i_clk);
    p_x =3;
    p_y =0;
    @(posedge i_clk);
    @(posedge i_clk);
    p_x =4;
    p_y =0;
    @(posedge i_clk);@(posedge i_clk);
	$finish;
end

endmodule