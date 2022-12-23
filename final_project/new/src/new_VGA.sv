`define PIXEL_ROW  60
`define PIXEL_COLUMN  80

module VGA(
    //de2-115
   input  i_rst,
   input  i_clk_25M,
   input i_start_display,
    output [7:0] o_VGA_B,
	output o_VGA_BLANK_N,
	output o_VGA_CLK,
	output [7:0] o_VGA_G,
	output o_VGA_HS,
	output [7:0] o_VGA_R,
	output o_VGA_SYNC_N,
	output o_VGA_VS,
	input [15:0] i_display_data,
    output [19:0] o_access_address,
    output o_finish
);

    // Variable definition
    logic [9:0] h_counter_r, h_counter_w;
    logic [9:0] v_counter_r, v_counter_w;
    logic hsync_r, hsync_w, vsync_r, vsync_w;
    logic [7:0] vga_r_r, vga_g_r, vga_b_r, vga_r_w, vga_g_w, vga_b_w;
    logic state_r, state_w;
    logic [19:0] access_address;
    
    // 640*480, refresh rate 60Hz
    // VGA clock rate 25.175MHz
    localparam H_SYNC   =   96;
    localparam H_BACK   =   40;
	 localparam H_LEFT   =   8;
    localparam H_ACT    =   640;
	 localparam H_RIGHT  =   8;
	 localparam H_FRONT  =   8;
    localparam H_VALID_LB  =  H_SYNC + H_BACK + H_LEFT ;  
	 localparam H_VALID_UB  =  H_SYNC + H_BACK + H_LEFT + H_ACT;  
    localparam H_TOTAL  =   800;  //800 effect:145~785
	 
    localparam V_SYNC   =   2;
    localparam V_BACK   =   25;
	 localparam V_TOP    =   8;
    localparam V_ACT    =   480;
	 localparam V_BOTTOM =   8;
	 localparam V_FRONT  =   2;
    localparam V_VALID_LB  =   V_SYNC + V_BACK + V_TOP; 
	 localparam V_VALID_UB  =   V_SYNC + V_BACK + V_TOP + V_ACT;
    localparam V_TOTAL  =   525; //525

    localparam S_IDLE    = 1'b0;
    localparam S_DISPLAY = 1'b1;
	 
	 localparam minimum = 16'd0;
	 localparam maximum = 16'b1111_1111_1111_1111; 
	 localparam half = (minimum + maximum) / 2;

     localparam onefour = 16'b1111_1111_1111_1111 >> 2; 
     localparam threefour = onefour + half; 

    // Output assignment
    assign o_VGA_CLK      =   i_clk_25M;
    assign o_VGA_HS       =   hsync_r;
    assign o_VGA_VS       =   vsync_r;
    assign o_VGA_R        =   vga_r_r;
    assign o_VGA_G        =   vga_g_r;
    assign o_VGA_B        =   vga_b_r;
    assign o_VGA_SYNC_N   =   1'b0;
    assign o_VGA_BLANK_N  =   1'b1;

    assign  hsync_r = (h_counter_r  <  H_SYNC ) ? 1'b0 : 1'b1;
    assign  vsync_r = (v_counter_r  <  V_SYNC ) ? 1'b0 : 1'b1;
    logic finish;
    assign o_finish = finish;
    assign o_access_address = access_address;
    
    // Coordinates
    always_comb begin
        case(state_r)
            S_IDLE: begin
                h_counter_w = 0;
            end
            S_DISPLAY: begin
                if (h_counter_r == (10'd800 - 1)) begin
                    h_counter_w = 0;
                end
                else begin
                    h_counter_w = h_counter_r + 10'd1;
                end
            end
        endcase
    end

    always_comb begin
        case(state_r)
            S_IDLE: begin
                v_counter_w = 0;
                finish = 1'b0;
            end
            S_DISPLAY: begin
                if (v_counter_r == (524) && h_counter_r == (10'd800 - 1)) begin
                    v_counter_w = 0;
                    finish = 1'b1;
                end
                else if (v_counter_r != (524) && h_counter_r == (10'd800 - 1)) begin
                    v_counter_w = v_counter_r + 1;
                    finish = 1'b0;
                end
                else begin
                    v_counter_w = v_counter_r;
                    finish = 1'b0;
                end
            end
        endcase
    end

    // Sync signals
    /*always_comb begin
        case(state_r)
            S_IDLE: begin
                hsync_w = 1'b1;
            end
            S_DISPLAY: begin
                if (h_counter_r == 0) begin
                    hsync_w = 1'b0;
                end
                else if (h_counter_r == H_SYNC -) begin
                    hsync_w = 1'b1;
                end
                else begin
                    hsync_w = hsync_r;
                end
            end
        endcase
    end*/
    /*
    always_comb begin
        case(state_r)
            S_IDLE: begin
                vsync_w = 1'b1;
            end
            S_DISPLAY: begin
                if (v_counter_r == 0) begin
                    vsync_w = 1'b0;
                end
                else if (v_counter_r == V_SYNC) begin
                    vsync_w = 1'b1;                 
                end
                else begin
                    vsync_w = vsync_r;
                end
            end
        endcase
    end*/
    
    // RGB data
    always_comb begin
        case(state_r)
            S_IDLE: begin
                access_address = 20'bz;
                vga_r_w = 8'b0;
                vga_g_w = 8'b0;
                vga_b_w = 8'b0;
            end
            S_DISPLAY: begin
                if(h_counter_r < (H_VALID_LB) || h_counter_r >= (H_VALID_LB + (`PIXEL_COLUMN * 4)) || v_counter_r < (V_VALID_LB) || v_counter_r >= (V_VALID_LB + (`PIXEL_ROW * 4))) begin
                    access_address = 20'dz;
                    vga_r_w = 8'b0;
                    vga_g_w = 8'b0;
                    vga_b_w = 8'b0;
                end
                else begin
                    /*
					if(h_counter_r < (H_VALID_LB + i_display_data) || h_counter_r > (H_TOTAL - i_display_data)) begin
						vga_r_w = 8'd200;
						vga_g_w = 8'd200;
						vga_b_w = 8'd200;
					end
					else begin
						vga_r_w = 8'd0;
						vga_g_w = 8'd0;
						vga_b_w = 8'd0;						  
					end
                    */
                    access_address = ((h_counter_r - H_VALID_LB) >> 2) + ((v_counter_r - V_VALID_LB) >> 2) * (`PIXEL_COLUMN);

					if(i_display_data >= minimum && half >= i_display_data) begin
						vga_r_w = 0;
						vga_g_w = ((16'd255)*i_display_data - (16'd255)*minimum)/(half - minimum);
						vga_b_w = 16'd255 - ((16'd255)*i_display_data - (16'd255)*minimum)/(half - minimum);
					end
					else begin
						vga_r_w = ((16'd255)*i_display_data - (16'd255)*half)/(maximum - half);
						vga_g_w = 16'd255 - ((16'd255)*i_display_data - (16'd255)*half)/(maximum - half);
						vga_b_w = 0;
					end
                    /*
                    if(i_display_data >= minimum && i_display_data <= onefour) begin
						vga_r_w = 0;
						vga_g_w = 0;
						vga_b_w = (8'd200 - 8'd32) * (i_display_data - 8'd0) / (onefour - 8'd0) + 8'd32;
					end
					else if (i_display_data > onefour && i_display_data <= half) begin
						vga_r_w = 0;
						vga_g_w = (8'd200 - 8'd32) * (i_display_data - onefour) / (half - onefour) + 8'd32;
						vga_b_w = (8'd32 - 8'd200) * (i_display_data - onefour) / (half - onefour) + 8'd200;
					end
                    else if (i_display_data > half && i_display_data <= threefour) begin
						vga_r_w = (8'd200 - 8'd32) * (i_display_data - half) / (threefour - half) + 8'd32;
						vga_g_w = (8'd32 - 8'd200) * (i_display_data - half) / (threefour - half) + 8'd200;
						vga_b_w = 0;
					end
                    else begin
						vga_r_w = (8'd32 - 8'd200) * (i_display_data - threefour) / (maximum - threefour) + 8'd200;
						vga_g_w = 0;
						vga_b_w = 0;
					end
                    */
                end
            end
        endcase
    end

    //FSM
    always_comb begin
        state_w = state_r;
        case(state_r)
            S_IDLE : begin
                if(i_start_display) begin
                    state_w = S_DISPLAY;
                end
            end
            S_DISPLAY : begin
                /*if(!i_start_display) begin
                    state_w = S_IDLE;
                end*/
            end
        endcase
    end

    // Flip-flop
    always_ff @(posedge i_clk_25M or posedge i_rst) begin
        if (i_rst) begin
            h_counter_r <= 0;   
            v_counter_r <= 0;
            //hsync_r <= 1'b1;
            //vsync_r <= 1'b1;
            vga_r_r <= 8'b0;
            vga_g_r <= 8'b0;
            vga_b_r <= 8'b0;
            state_r <= S_IDLE;
        end
        else begin
            h_counter_r <= h_counter_w;
            v_counter_r <= v_counter_w;
            //hsync_r <= hsync_w;
            //vsync_r <= vsync_w;
            vga_r_r <= vga_r_w;
            vga_g_r <= vga_g_w;
            vga_b_r <= vga_b_w;
            state_r <= state_w;
        end
    end
endmodule