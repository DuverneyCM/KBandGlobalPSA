	KBandIPsubPro_KBand21_0 u0 (
		.reset_reset  (_connected_to_reset_reset_),  //   input,    width = 1,          reset.reset
		.iADN1_data   (_connected_to_iADN1_data_),   //   input,    width = 8,          iADN1.data
		.oADN1_ready  (_connected_to_oADN1_ready_),  //  output,    width = 1,               .ready
		.iADN1_valid  (_connected_to_iADN1_valid_),  //   input,    width = 1,               .valid
		.oArrow_data  (_connected_to_oArrow_data_),  //  output,  width = 128,         oArrow.data
		.iArrow_ready (_connected_to_iArrow_ready_), //   input,    width = 1,               .ready
		.oArrow_valid (_connected_to_oArrow_valid_), //  output,    width = 1,               .valid
		.clock_int    (_connected_to_clock_int_),    //   input,    width = 1, clock_internal.clk
		.clock_ext    (_connected_to_clock_ext_),    //   input,    width = 1, clock_external.clk
		.iParameters  (_connected_to_iParameters_),  //   input,   width = 32,     Parameters.export
		.iADN2_data   (_connected_to_iADN2_data_),   //   input,    width = 8,          iADN2.data
		.iADN2_valid  (_connected_to_iADN2_valid_),  //   input,    width = 1,               .valid
		.oADN2_ready  (_connected_to_oADN2_ready_)   //  output,    width = 1,               .ready
	);

