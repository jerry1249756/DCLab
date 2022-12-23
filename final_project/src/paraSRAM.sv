/*
this module works as an parallel multiport-SRAM with read and write access
by the address. The memory size is 4800=80*60.

need to define proper  NUM_PARALLEL inside the module. 
*/

`define SRAM_PARALLEL  6

module paraSRAM (
    input         i_clk,
	input 		  i_rst,
	input 		  i_write_enable [`SRAM_PARALLEL-2:0],
    input [12:0]  i_write_address [`SRAM_PARALLEL-2:0],
	input [15:0]  i_write_data    [`SRAM_PARALLEL-2:0],
	input [12:0]  i_read_address  [`SRAM_PARALLEL-1:0],
	output [15:0] o_read_data     [`SRAM_PARALLEL-1:0]
);

localparam num_data = (`PIXEL_COLUMN) * (`PIXEL_ROW);
//logic [15:0] mem[num_data-1 : 0] =  '{default:0};

logic [15:0] mem_r[num_data-1:0];
logic [15:0] mem_w[num_data-1:0];

// assign [12:0] write_address_0 = i_write_address[0];
// assign [12:0] write_address_1 = i_write_address[1];
// assign [12:0] write_address_2 = i_write_address[2];
// assign [12:0] write_address_3 = i_write_address[3];
// assign [12:0] write_address_4 = i_write_address[4];

// assign [12:0] read_address_0 = i_read_address[0];
// assign [12:0] read_address_1 = i_read_address[1];
// assign [12:0] read_address_2 = i_read_address[2];
// assign [12:0] read_address_3 = i_read_address[3];
// assign [12:0] read_address_4 = i_read_address[4];

// assign [15:0] write_data_0 = i_write_data[0];
// assign [15:0] write_data_1 = i_write_data[1];
// assign [15:0] write_data_2 = i_write_data[2];
// assign [15:0] write_data_3 = i_write_data[3];
// assign [15:0] write_data_4 = i_write_data[4];

// assign [15:0] o_read_data[0] = mem_r[read_address_0];

integer i;
integer j;

genvar idx;
generate
	for(idx=0; idx<`SRAM_PARALLEL; idx=idx+1) begin: Gen_output
        assign o_read_data[idx] = mem_r[i_read_address[idx]];
    end
endgenerate

always@(*) begin
	for (i=0; i<num_data; i=i+1) begin
		mem_w[i] = mem_r[i];
	end
	for (j=0; j<`SRAM_PARALLEL-1; j=j+1) begin
		if(i_write_enable[j]) mem_w[i_write_address[j]] = i_write_data[j];
	end
end


// genvar idx;
// generate
// 	for(idx=0; idx<`SRAM_PARALLEL; idx=idx+1) begin: Gen_output
//         assign o_read_data[idx] = mem[i_read_address[idx]];
// 		always_ff@(posedge i_clk) begin
// 			mem[i_write_address[idx]] <= i_write_data[idx];
// 		end
//     end
// endgenerate

always@(posedge i_clk or posedge i_rst) begin
	if (i_rst) begin
		for(i=0; i<num_data; i=i+1) mem_r[i] <= 0;
	end
	else begin
		for(i=0; i<num_data; i=i+1) mem_r[i] <= mem_w[i];
	end
end


endmodule



