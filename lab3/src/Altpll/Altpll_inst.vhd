	component Altpll is
		port (
			reset_reset_n   : in  std_logic := 'X'; -- reset_n
			clk_clk         : in  std_logic := 'X'; -- clk
			altpll_0_c0_clk : out std_logic;        -- clk
			altpll_1_c0_clk : out std_logic         -- clk
		);
	end component Altpll;

	u0 : component Altpll
		port map (
			reset_reset_n   => CONNECTED_TO_reset_reset_n,   --       reset.reset_n
			clk_clk         => CONNECTED_TO_clk_clk,         --         clk.clk
			altpll_0_c0_clk => CONNECTED_TO_altpll_0_c0_clk, -- altpll_0_c0.clk
			altpll_1_c0_clk => CONNECTED_TO_altpll_1_c0_clk  -- altpll_1_c0.clk
		);

