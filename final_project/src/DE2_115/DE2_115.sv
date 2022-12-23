module DE2_115 (
	input CLOCK_50,
	input CLOCK2_50,
	input CLOCK3_50,
	input ENETCLK_25,
	input SMA_CLKIN,
	output SMA_CLKOUT,
	output [8:0] LEDG,
	output [17:0] LEDR,
	input [3:0] KEY,
	input [17:0] SW, //slide switches
	output [6:0] HEX0,
	output [6:0] HEX1,
	output [6:0] HEX2,
	output [6:0] HEX3,
	output [6:0] HEX4,
	output [6:0] HEX5,
	output [6:0] HEX6,
	output [6:0] HEX7,
	output LCD_BLON,
	inout [7:0] LCD_DATA,
	output LCD_EN,
	output LCD_ON,
	output LCD_RS,
	output LCD_RW,
	output UART_CTS,
	input UART_RTS,
	input UART_RXD,
	output UART_TXD,
	inout PS2_CLK,
	inout PS2_DAT,
	inout PS2_CLK2,
	inout PS2_DAT2,
	output SD_CLK,
	inout SD_CMD,
	inout [3:0] SD_DAT,
	input SD_WP_N,
	output [7:0] VGA_B,
	output VGA_BLANK_N,
	output VGA_CLK,
	output [7:0] VGA_G,
	output VGA_HS,
	output [7:0] VGA_R,
	output VGA_SYNC_N,
	output VGA_VS,
	input AUD_ADCDAT,
	inout AUD_ADCLRCK,
	inout AUD_BCLK,
	output AUD_DACDAT,
	inout AUD_DACLRCK,
	output AUD_XCK,
	output EEP_I2C_SCLK,
	inout EEP_I2C_SDAT,
	output I2C_SCLK,
	inout I2C_SDAT,
	output ENET0_GTX_CLK,
	input ENET0_INT_N,
	output ENET0_MDC,
	input ENET0_MDIO,
	output ENET0_RST_N,
	input ENET0_RX_CLK,
	input ENET0_RX_COL,
	input ENET0_RX_CRS,
	input [3:0] ENET0_RX_DATA,
	input ENET0_RX_DV,
	input ENET0_RX_ER,
	input ENET0_TX_CLK,
	output [3:0] ENET0_TX_DATA,
	output ENET0_TX_EN,
	output ENET0_TX_ER,
	input ENET0_LINK100,
	output ENET1_GTX_CLK,
	input ENET1_INT_N,
	output ENET1_MDC,
	input ENET1_MDIO,
	output ENET1_RST_N,
	input ENET1_RX_CLK,
	input ENET1_RX_COL,
	input ENET1_RX_CRS,
	input [3:0] ENET1_RX_DATA,
	input ENET1_RX_DV,
	input ENET1_RX_ER,
	input ENET1_TX_CLK,
	output [3:0] ENET1_TX_DATA,
	output ENET1_TX_EN,
	output ENET1_TX_ER,
	input ENET1_LINK100,
	input TD_CLK27,
	input [7:0] TD_DATA,
	input TD_HS,
	output TD_RESET_N,
	input TD_VS,
	inout [15:0] OTG_DATA,
	output [1:0] OTG_ADDR,
	output OTG_CS_N,
	output OTG_WR_N,
	output OTG_RD_N,
	input OTG_INT,
	output OTG_RST_N,
	input IRDA_RXD,
	output [12:0] DRAM_ADDR,
	output [1:0] DRAM_BA,
	output DRAM_CAS_N,
	output DRAM_CKE,
	output DRAM_CLK,
	output DRAM_CS_N,
	inout [31:0] DRAM_DQ,
	output [3:0] DRAM_DQM,
	output DRAM_RAS_N,
	output DRAM_WE_N,
	output [19:0] SRAM_ADDR,
	output SRAM_CE_N,
	inout [15:0] SRAM_DQ,
	output SRAM_LB_N,
	output SRAM_OE_N,
	output SRAM_UB_N,
	output SRAM_WE_N,
	output [22:0] FL_ADDR,
	output FL_CE_N,
	inout [7:0] FL_DQ,
	output FL_OE_N,
	output FL_RST_N,
	input FL_RY,
	output FL_WE_N,
	output FL_WP_N,
	inout [35:0] GPIO,
	input HSMC_CLKIN_P1,
	input HSMC_CLKIN_P2,
	input HSMC_CLKIN0,
	output HSMC_CLKOUT_P1,
	output HSMC_CLKOUT_P2,
	output HSMC_CLKOUT0,
	inout [3:0] HSMC_D,
	input [16:0] HSMC_RX_D_P,
	output [16:0] HSMC_TX_D_P,
	inout [6:0] EX_IO
);

logic CLK_25M, CLK_3p2M, CLK_50k;

altpll pll0( // generate with qsys, please follow lab2 tutorials
	.clk_clk(CLOCK_50),
	.reset_reset_n(~KEY[0]),
	.altpll_0_c25m_clk(CLK_25M),
	.altpll_0_c3p2m_clk(CLK_3p2M),
	.altpll_0_c50k_clk(CLK_50k)
	//.altpll_800k_clk(CLK_800K)
);

// you can decide key down settings on your own, below is just an example

logic mic_data [0 : `MIC_NUMBER-1];
assign GPIO[1] = 1'bz;
assign GPIO[3] = 1'bz;
assign GPIO[5] = 1'bz;
assign GPIO[7] = 1'bz;
assign GPIO[9] = 1'bz;
assign GPIO[11] = 1'bz;
assign GPIO[13] = 1'bz;
assign GPIO[15] = 1'bz;
assign GPIO[17] = 1'bz;
assign GPIO[19] = 1'bz;
assign GPIO[21] = 1'bz;
assign GPIO[23] = 1'bz;
assign GPIO[25] = 1'bz;
assign GPIO[27] = 1'bz;
assign GPIO[29] = 1'bz;
assign GPIO[31] = 1'bz;

assign mic_data[0] = GPIO[1];
assign mic_data[1] = GPIO[3];
assign mic_data[2] = GPIO[5];
assign mic_data[3] = GPIO[7];
assign mic_data[4] = GPIO[9];
assign mic_data[5] = GPIO[11];
assign mic_data[6] = GPIO[13];
assign mic_data[7] = GPIO[15];
assign mic_data[8] = GPIO[17];
assign mic_data[9] = GPIO[19];
assign mic_data[10] = GPIO[21];
assign mic_data[11] = GPIO[23];
assign mic_data[12] = GPIO[25];
assign mic_data[13] = GPIO[27];
assign mic_data[14] = GPIO[29];
assign mic_data[15] = GPIO[31];

assign GPIO[0] = CLK_3p2M;
assign GPIO[2] = CLK_3p2M;
assign GPIO[4] = CLK_3p2M;
assign GPIO[6] = CLK_3p2M;
assign GPIO[8] = CLK_3p2M;
assign GPIO[10] = CLK_3p2M;
assign GPIO[12] = CLK_3p2M;
assign GPIO[14] = CLK_3p2M;

assign GPIO[16] = CLK_3p2M;
assign GPIO[18] = CLK_3p2M;
assign GPIO[20] = CLK_3p2M;
assign GPIO[22] = CLK_3p2M;
assign GPIO[24] = CLK_3p2M;
assign GPIO[26] = CLK_3p2M;
assign GPIO[28] = CLK_3p2M;
assign GPIO[30] = CLK_3p2M;

logic [1:0] state;

Top top0(
	.i_50M_clk(CLOCK_50),
	.i_25M_clk(CLK_25M),
	.i_BCLK(CLK_3p2M),
	.i_LRCK(CLK_50k),
	.i_rst(~KEY[0]),
	.i_start(~KEY[1]),
	.i_mic_data(mic_data),

	/*.o_SRAM_ADDR(SRAM_ADDR),
	.io_SRAM_DQ(SRAM_DQ), 
	.o_SRAM_WE_N(SRAM_WE_N),
	.o_SRAM_CE_N(SRAM_CE_N),
	.o_SRAM_OE_N(SRAM_OE_N),
	.o_SRAM_LB_N(SRAM_LB_N),
	.o_SRAM_UB_N(SRAM_UB_N),*/
	
	.VGA_R(VGA_R),
	.VGA_G(VGA_G),
	.VGA_B(VGA_B),
	.VGA_BLANK_N(VGA_BLANK_N),
	.VGA_CLK(VGA_CLK),
	.VGA_HS(VGA_HS),
	.VGA_SYNC_N(VGA_SYNC_N),
	.VGA_VS(VGA_VS),
	
	.o_state(state)
);

SevenHexDecoder seven_dec0(
	.i_hex(state),
	.o_seven_ten(HEX1),
	.o_seven_one(HEX0)
);
/*
SevenHexDecoder32 seven_dec1(
	.i_hex(rec_addrress[19:15]),
	.o_seven_ten(HEX3),
	.o_seven_one(HEX2)
);*/


// comment those are use for display
// assign HEX0 = '1;
// assign HEX1 = '1;
//assign HEX2 = '1;
//assign HEX3 = '1;
//assign HEX4 = '1;
//assign HEX5 = '1;
//assign HEX6 = '1;
//assign HEX7 = '1;

endmodule
