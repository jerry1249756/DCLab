
`timescale 1us/1us

module tb_AudDSP;

parameter	cycle = 2000.0;
parameter	fast_cycle = 50.0;

logic 		i_clk, i_fastclk;
logic 		i_rst_n, i_start, i_pause, i_stop, i_fast, i_slow_0, i_slow_1, dsp_finished;

logic [3:0]  i_speed;
logic [15:0] data_play;
logic [15:0] dac_data;
logic [19:0] addr_play;



initial i_clk = 0;
always #(cycle/2.0) i_clk = ~i_clk;

initial i_fastclk = 0;
always #(fast_cycle/2.0) i_fastclk = ~i_fastclk;

AudDSP dsp0(
	.i_rst_n(i_rst_n),
	.i_clk(i_fastclk),
	.i_start(i_start),
	.i_pause(i_pause),
	.i_stop(i_stop),
	.i_speed(i_speed),
	.i_fast(i_fast),
	.i_slow_0(i_slow_0), // constant interpolation
	.i_slow_1(i_slow_1), // linear interpolation
	.i_daclrck(i_clk),
	.i_sram_data(data_play),
	.o_dac_data(dac_data),
	.o_sram_addr(addr_play),
	.o_DSP_finished(dsp_finished)
);

initial begin
	$fsdbDumpfile("tb_AudDSP.fsdb");
	$fsdbDumpvars(0, tb_AudDSP, "+all");
end

initial begin	
	#(cycle*110000);
	$finish;
end

initial begin
    //i_stop = 0;
    //i_pause = 0;
    i_fast = 0;
    i_slow_0 = 0;
    i_slow_1 = 1;
    
end

initial begin	
	//i_clk 	= 0;
	//i_AUD_DACLRCK = 0;
	i_rst_n = 1;
	i_start	= 0;

	@(negedge i_clk);
	@(negedge i_clk);
	@(negedge i_clk) i_rst_n = 0;
	@(negedge i_clk) i_rst_n = 1; 

	
	#(fast_cycle);
	i_start = 1;
	#(fast_cycle);
	i_start = 0;
	#(fast_cycle);

end

initial begin
    i_speed = 4;
    #(0.5*cycle);
	#(cycle * (i_speed + 1));
	data_play = 24'h111111;
    while(data_play >= 0) begin
        #(cycle * i_speed)
        data_play = data_play - 25;
    end
end



initial begin	
	i_stop = 0;
	i_pause = 0;
	#(0.5 * cycle)
	#(cycle*100);
	
	#(fast_cycle);
	i_pause = 1'b1;
	#(fast_cycle);
	i_pause = 1'b0;
	#(fast_cycle);
	#(cycle*100);
	
	#(fast_cycle);
	i_pause = 1'b1;
	#(fast_cycle);
	i_pause = 1'b0;
	#(fast_cycle);
	#(cycle*100);

	#(cycle*1000);
	
	#(fast_cycle);
	i_stop = 1;
	#(fast_cycle);
	i_stop = 0;
	#(fast_cycle);
end


endmodule
