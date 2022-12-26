`define MIC_NUMBER 16
`define READBIT 24
`define TRUNCATE_BIT 23
`define L 32 ////// only use 2^x 

module Add_Square(
	input i_clk,
    input i_rst,
    input signed [`READBIT-1:0] i_data [`MIC_NUMBER-1:0],
    input        [15:0]           i_addsquare_sramread,
	output       [15:0]           o_add_square_data                
); 
    //`READBIT = 16
    logic [15:0] output_r, output_w;

    logic [15+`TRUNCATE_BIT:0] add_zero_sram ;
    assign add_zero_sram[15+`TRUNCATE_BIT -:16] = i_addsquare_sramread ;
    assign add_zero_sram[`TRUNCATE_BIT-1:0] = 0;

    logic signed [`READBIT + 3:0] sum;
    logic signed [`READBIT + 1:0] sum_part[3:0];
	logic signed [(`READBIT+4)*2-1:0] add_square;
    logic [(`READBIT+4)*2-2-$clog2(`L):0] temp_shift_output;

    assign sum_part[0] = i_data[0] + i_data[1] + i_data[2] + i_data[3];
    assign sum_part[1] = i_data[4] + i_data[5] + i_data[6] + i_data[7];
    assign sum_part[2] = i_data[8] + i_data[9] + i_data[10]+ i_data[11];
    assign sum_part[3] = i_data[12]+ i_data[13]+ i_data[14]+ i_data[15];
    assign sum = sum_part[0] + sum_part[1] + sum_part[2] + sum_part[3];
	assign add_square = sum * sum;
    
	assign temp_shift_output = add_square[(`READBIT+4)*2-2:$clog2(`L)];


    logic [15+`TRUNCATE_BIT : 0] temp_data;
    assign temp_data = add_zero_sram + temp_shift_output; 



    assign o_add_square_data = output_r;

    always_comb begin
        output_w = temp_data[15+`TRUNCATE_BIT -:16];
    end



    always_ff @ (posedge i_clk or posedge i_rst) begin
        if(i_rst) begin
            output_r <= 0;
        end
        else begin
            output_r <= output_w;
        end
    end

endmodule


