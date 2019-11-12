	component KBandIPsubPro_KBand21_0 is
		port (
			reset_reset  : in  std_logic                      := 'X';             -- reset
			iADN1_data   : in  std_logic_vector(7 downto 0)   := (others => 'X'); -- data
			oADN1_ready  : out std_logic;                                         -- ready
			iADN1_valid  : in  std_logic                      := 'X';             -- valid
			oArrow_data  : out std_logic_vector(127 downto 0);                    -- data
			iArrow_ready : in  std_logic                      := 'X';             -- ready
			oArrow_valid : out std_logic;                                         -- valid
			clock_int    : in  std_logic                      := 'X';             -- clk
			clock_ext    : in  std_logic                      := 'X';             -- clk
			iParameters  : in  std_logic_vector(31 downto 0)  := (others => 'X'); -- export
			iADN2_data   : in  std_logic_vector(7 downto 0)   := (others => 'X'); -- data
			iADN2_valid  : in  std_logic                      := 'X';             -- valid
			oADN2_ready  : out std_logic                                          -- ready
		);
	end component KBandIPsubPro_KBand21_0;

	u0 : component KBandIPsubPro_KBand21_0
		port map (
			reset_reset  => CONNECTED_TO_reset_reset,  --          reset.reset
			iADN1_data   => CONNECTED_TO_iADN1_data,   --          iADN1.data
			oADN1_ready  => CONNECTED_TO_oADN1_ready,  --               .ready
			iADN1_valid  => CONNECTED_TO_iADN1_valid,  --               .valid
			oArrow_data  => CONNECTED_TO_oArrow_data,  --         oArrow.data
			iArrow_ready => CONNECTED_TO_iArrow_ready, --               .ready
			oArrow_valid => CONNECTED_TO_oArrow_valid, --               .valid
			clock_int    => CONNECTED_TO_clock_int,    -- clock_internal.clk
			clock_ext    => CONNECTED_TO_clock_ext,    -- clock_external.clk
			iParameters  => CONNECTED_TO_iParameters,  --     Parameters.export
			iADN2_data   => CONNECTED_TO_iADN2_data,   --          iADN2.data
			iADN2_valid  => CONNECTED_TO_iADN2_valid,  --               .valid
			oADN2_ready  => CONNECTED_TO_oADN2_ready   --               .ready
		);

