`timescale 1us/1us

module tb_DSPtest;

parameter	cycle = 100.0;
parameter   lr_cycle = 3800;


logic clk, lr_clk, rst_n;


initial clk = 0;
always #(cycle/2.0) clk = ~clk;


initial lr_clk = 0;
always #(lr_cycle/2.0) lr_clk = ~lr_clk;


AudDSPtest dsp_test (
    .i_rst_n(rst_n),
    .i_clk(clk),
    .i_daclrck(lr_clk)
);


initial begin
	$fsdbDumpfile("tb_DSPtest.fsdb");
	$fsdbDumpvars(0, tb_DSPtest, "+all");
end

initial begin	
	#(cycle*11000);
	$finish;
end


initial begin	
	rst_n = 1;
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
    @(negedge clk) rst_n = 0;
    @(negedge clk) rst_n = 1;
	@(negedge clk);
  

end


endmodule