/*
this module works as an parallel multiport-SRAM with read and write access
by the address. The memory size is 4800=80*60.

need to define proper  NUM_PARALLEL inside the module. 
*/

`define NUM_PARALLEL  6

module paraSRAM (
    input         i_clk,
    input [12:0]  i_write_address [`NUM_PARALLEL-1:0],
	input [23:0]  i_write_data    [`NUM_PARALLEL-1:0],
	input [12:0]  i_read_address  [`NUM_PARALLEL-1:0],
	output [23:0] o_read_data     [`NUM_PARALLEL-1:0]
);

localparam num_data = 13'd4800;
logic [23:0] mem[num_data-1 : 0] =  '{default:0};

genvar idx;
generate
	for(idx=0; idx<`NUM_PARALLEL; idx=idx+1) begin: Gen_output
        assign o_read_data[idx] = mem[i_read_address[idx]];
		always_ff@(posedge i_clk) begin
			mem[i_write_address[idx]] <= i_write_data[idx];
		end
    end
endgenerate

endmodule

