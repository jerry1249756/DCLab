	component Altpll is
		port (
			altpll_0_c25m_clk  : out std_logic;        -- clk
			altpll_0_c3p2m_clk : out std_logic;        -- clk
			altpll_0_c50k_clk  : out std_logic;        -- clk
			clk_clk            : in  std_logic := 'X'; -- clk
			reset_reset_n      : in  std_logic := 'X'  -- reset_n
		);
	end component Altpll;

	u0 : component Altpll
		port map (
			altpll_0_c25m_clk  => CONNECTED_TO_altpll_0_c25m_clk,  --  altpll_0_c25m.clk
			altpll_0_c3p2m_clk => CONNECTED_TO_altpll_0_c3p2m_clk, -- altpll_0_c3p2m.clk
			altpll_0_c50k_clk  => CONNECTED_TO_altpll_0_c50k_clk,  --  altpll_0_c50k.clk
			clk_clk            => CONNECTED_TO_clk_clk,            --            clk.clk
			reset_reset_n      => CONNECTED_TO_reset_reset_n       --          reset.reset_n
		);

