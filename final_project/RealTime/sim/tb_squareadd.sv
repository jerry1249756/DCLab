`timescale 1ns/1ns

module tb_squareadd;

parameter	cycle = 20.0;
// parameter   bclk_cycle = 312.5;
// parameter	lr_cycle = 20000.0;
logic 		i_clk;
logic       i_rst;

logic signed [23:0] i_data [15:0];
logic [15:0]i_sram;



logic [15:0] o_data;
integer i;

initial i_clk = 0;
always #(cycle/2.0) i_clk = ~i_clk;

// initial i_bclk = 0;
// always #(bclk_cycle/2.0) i_bclk = ~i_bclk;

// initial i_lrck = 0;
// always #(lr_cycle/2.0) i_lrck = ~i_lrck;

parameter temp = 24'hffffff;
parameter temp1 = 24'hffff;

Add_Square r0(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_data(i_data),
    .i_addsquare_sramread(i_sram),
    .o_add_square_data(o_data)
    
);

initial begin
	$fsdbDumpfile("tb_squareadd.fsdb");
	$fsdbDumpvars(0, tb_squareadd, "+all");
end

initial begin	
	#(cycle*1000);
	$finish;
end

initial begin	
	i_rst = 0;
 
	@(negedge i_clk);
	@(negedge i_clk);
	@(negedge i_clk) i_rst = 1;
	@(negedge i_clk) i_rst = 0; 
end

// initial begin
//     i_change_pointer = 0;
//     forever begin
//         #(cycle*15000)
//         // #(cycle*0.1)
//         // i_change_pointer = 1;
//         // #(cycle*0.8)
//         // i_change_pointer = 0;
//         @(negedge i_clk) i_change_pointer = 1;
//         @(negedge i_clk) i_change_pointer = 0;
//     end
// end

initial begin
	for (i=0; i<16 ; i=i+1) i_data[i] = 0;
	forever begin
        for (i=0; i<16 ; i=i+1) begin
            @(negedge i_clk) i_data[i] = $urandom() & temp;
        end    
	end
end

initial begin	
	i_sram = 0;
	forever begin
        
         @(negedge i_clk) i_sram = $urandom() & temp1;
        
	end
end

endmodule