`timescale 1 ps/ 1 ps                                     
module tb_CORDIC_Euclidean_Distance;                                    
// Inputs                                                   
reg                               CLK_50M;                                
reg                               RST_N;                                  
reg                          start;   
reg       [31:0]    x;     
reg       [31:0]    y;     
wire          [31:0]         angle;   
wire      [31:0]    distance;                                                       
wire              [31:0]         Cos;                                  
// Instantiate the Unit Under Test (UUT)                                                                            
CORDIC_Euclidean_Distance u1
(
    .CLK_50M ( CLK_50M  ),
    .RST_N   ( RST_N    ),
    .x       ( x        ),
    .y       ( y        ),
    .start   ( start    ),
    .finished( finished ),
    .angle   ( angle    ),
    .distance( distance )
);                                                      
initial                                                   
begin                                                     
    #0 CLK_50M = 1'b0;                                      
       start = 1'b0;                                        
     x = 9'h00;
     y = 9'h00;                                      
    #100 RST_N = 1'b0;                                      
    #100 RST_N = 1'b1;                                      
    #100 start = 1'b1;                                      
         x = 9'd100;     
         y = 9'd100;                                
    #10000 $finish;                                       
end                                                       
always #100                                               
begin                                                     
    CLK_50M = ~CLK_50M;                                     
end           
initial begin
	$fsdbDumpfile("CORDIC.fsdb");
	$fsdbDumpvars(0, "+mda");
end                                            
endmodule