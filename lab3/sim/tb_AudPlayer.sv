`timescale 1us/1us

module tb_AudPlayer;

parameter	cycle = 100.0;
parameter	lr_cycle = 3800.0;

logic 		i_bclk, i_daclrck;
logic 		i_rst_n, i_en;

logic o_aud_dacdat;
logic [15:0] i_dac_data;

initial i_bclk = 0;
always #(cycle/2.0) i_bclk = ~i_bclk;

initial i_daclrck = 0;
always #(lr_cycle/2.0) i_daclrck = ~i_daclrck;


AudPlayer Player0(
	.i_rst_n(i_rst_n),
	.i_bclk(i_bclk),
    .i_daclrck(i_daclrck),
	.i_en(i_en), 
	.i_dac_data(i_dac_data), 
	.o_aud_dacdat(o_aud_dacdat)
);  


initial begin
	$fsdbDumpfile("tb_AudPlayer.fsdb");
	$fsdbDumpvars(0, tb_AudPlayer, "+all");
end

initial begin	
	#(cycle*2000);
	$finish;
end

initial begin	
	i_bclk 	= 0;
	i_daclrck 	= 0;
	i_rst_n = 1;
	i_en = 1'b0;

	@(negedge i_bclk);
	@(negedge i_bclk);
	@(negedge i_bclk) i_rst_n = 0;
	@(negedge i_bclk) i_rst_n = 1; 
	@(negedge i_bclk);
	@(negedge i_bclk);
	@(negedge i_bclk);
	@(negedge i_bclk);
	@(negedge i_bclk);
	@(negedge i_bclk);
	@(negedge i_bclk);
	#(cycle*50);
	@(negedge i_bclk);
	@(negedge i_bclk);
	@(negedge i_bclk);
	i_en = 1'b1;
end


always @(*) begin
	
	if(i_daclrck == 1'b1) begin
		i_dac_data = 16'b0010100110010101 * ($random % 600);
		#(cycle);
		//flag = 1'b0;
	end
	else begin
		i_dac_data = 16'b0000000000000000;
	end
end


endmodule
