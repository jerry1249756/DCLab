module SRAM (
    input i_clk,
	input i_write, //0: read, 1: write
    input [19:0] i_address,
	inout [15:0] io_data
);

parameter num_data = 20'b11111111111111111111;
logic [15:0] mem[num_data : 0] =  '{default:0};
logic [15:0] write_data;
//logic[5:0] idx;
assign io_data = (i_write == 1'b0) ? mem[i_address] : 16'bz; //data as output
assign write_data = (i_write == 1'b1) ? io_data : 16'b0;   //data as input
always_ff @(posedge i_clk) begin
	if(i_write==1'b1) mem[i_address] <= write_data;
	
/*	for(idx =0; idx <32; idx = idx+1) begin
		$display("idx:", 28, "data: ", mem[28], "\n");
		$display("idx:", 29, "data: ", mem[29], "\n");
		$display("idx:", 30, "data: ", mem[30], "\n");
		$display("idx:", 31, "data: ", mem[31], "\n");
		
	end
	$display("\n");
	*/
end


endmodule

