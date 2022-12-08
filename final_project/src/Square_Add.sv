module Add_Square(
	input signed [`READBIT-1:0] i_data [`MIC_NUMBER-1:0],
	output       [34:0]           o_add_square_data                
); 
    //`READBIT = 16
    logic signed [19:0] sum;
    logic signed [17:0] sum_part[3:0];
	logic [39:0] add_square;
    assign sum_part[0] = i_data[0] + i_data[1] + i_data[2] + i_data[3];
    assign sum_part[1] = i_data[4] + i_data[5] + i_data[6] + i_data[7];
    assign sum_part[2] = i_data[8] + i_data[9] + i_data[10]+ i_data[11];
    assign sum_part[3] = i_data[12]+ i_data[13]+ i_data[14]+ i_data[15];
    assign sum = sum_part[0] + sum_part[1] + sum_part[2] + sum_part[3];
	assign add_square = sum * sum;
	assign o_add_square_data = add_square[39:5];

endmodule



