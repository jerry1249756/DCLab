module VGA(
    input  i_rst,
    input  i_clk_25M,
    output [7:0] o_VGA_B,
	output o_VGA_BLANK_N,
	output o_VGA_CLK,
	output [7:0] o_VGA_G,
	output o_VGA_HS,
	output [7:0] o_VGA_R,
	output o_VGA_SYNC_N,
	output o_VGA_VS,
	input [15:0] i_display_data
);

    // Variable definition
    logic [9:0] h_counter_r, h_counter_w;
    logic [9:0] v_counter_r, v_counter_w;
    logic hsync_r, hsync_w, vsync_r, vsync_w;
    logic [7:0] vga_r_r, vga_g_r, vga_b_r, vga_r_w, vga_g_w, vga_b_w;
    logic [19:0] addr_display_r, addr_display_w;
    logic state_r, state_w;

    logic i_start_display;

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

    // Output assignment
    assign o_VGA_CLK      =   i_clk_25M;
    assign o_VGA_HS       =   hsync_r;
    assign o_VGA_VS       =   vsync_r;
    assign o_VGA_R        =   vga_r_r;
    assign o_VGA_G        =   vga_g_r;
    assign o_VGA_B        =   vga_b_r;
    assign o_VGA_SYNC_N   =   1'b0;
    assign o_VGA_BLANK_N  =   1'b1;

    assign i_start_display = 1'b1;

    // Coordinates
    always_comb begin
        case(state_r)
            S_IDLE: begin
                h_counter_w = 0;
            end
            S_DISPLAY: begin
                if (h_counter_r == 10'd800) begin
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
            end
            S_DISPLAY: begin
                if (v_counter_r == 525) begin
                    v_counter_w = 0;
                end
                else if (h_counter_r == 10'd800) begin
                    v_counter_w = v_counter_r + 1;
                end
                else begin
                    v_counter_w = v_counter_r;
                end
            end
        endcase
    end

    // Sync signals
    always_comb begin
        case(state_r)
            S_IDLE: begin
                hsync_w = 1'b1;
            end
            S_DISPLAY: begin
                if (h_counter_r == 0) begin
                    hsync_w = 1'b0;
                end
                else if (h_counter_r == H_SYNC) begin
                    hsync_w = 1'b1;
                end
                else begin
                    hsync_w = hsync_r;
                end
            end
        endcase
    end

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
    end

    // RGB data
    always_comb begin
        case(state_r)
            S_IDLE: begin
                addr_display_w = 20'd0;
                vga_r_w = 8'b0;
                vga_g_w = 8'b0;
                vga_b_w = 8'b0;
            end
            S_DISPLAY: begin
                if(addr_display_r == 20'd307200/*h_counter_r == 0 && v_counter_r == 0*/) begin
                    addr_display_w = 20'd0;
                    vga_r_w = 8'b0;
                    vga_g_w = 8'b0;
                    vga_b_w = 8'b0;
                end
                else if(h_counter_r < (H_VALID_LB) || h_counter_r > (H_VALID_UB) || v_counter_r < (V_VALID_LB) || v_counter_r >= (V_VALID_UB)) begin
                    addr_display_w = addr_display_r;
                    vga_r_w = 8'b0;
                    vga_g_w = 8'b0;
                    vga_b_w = 8'b0;
                end
                else begin
                    addr_display_w = addr_display_r + 20'd1;
						  if(h_counter_r < (H_VALID_LB + 100) || h_counter_r > (H_TOTAL - 100)) begin
							  vga_r_w = 0;
							  vga_g_w = 8'd200;
							  vga_b_w = 8'd200;
						  end
						  else begin
							  vga_r_w = 8'd0;
							  vga_g_w = 8'd0;
							  vga_b_w = 8'd0;						  
						  end
                end
            end
        endcase
    end

    //FSM
    always_comb begin
        if(i_start_display) begin
            state_w = S_DISPLAY;
        end
        else begin
            state_w = state_r;
        end
    end
    
    always_ff @(posedge i_clk_25M or posedge i_rst) begin
        if (i_rst) begin
            h_counter_r <= 0;   
            v_counter_r <= 0;
            hsync_r <= 1'b1;
            vsync_r <= 1'b1;
            vga_r_r <= 8'b0;
            vga_g_r <= 8'b0;
            vga_b_r <= 8'b0;
            addr_display_r <= 20'b0;
            state_r <= S_IDLE;
        end
        else begin
            h_counter_r <= h_counter_w;
            v_counter_r <= v_counter_w;
            hsync_r <= hsync_w;
            vsync_r <= vsync_w;
            vga_r_r <= vga_r_w;
            vga_g_r <= vga_g_w;
            vga_b_r <= vga_b_w;
            addr_display_r <= addr_display_w;
            state_r <= state_w;
        end
    end
endmodule