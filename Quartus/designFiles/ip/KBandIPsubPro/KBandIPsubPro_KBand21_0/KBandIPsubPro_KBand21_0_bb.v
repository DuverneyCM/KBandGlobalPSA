module KBandIPsubPro_KBand21_0 (
		input  wire         reset_reset,  //          reset.reset
		input  wire [7:0]   iADN1_data,   //          iADN1.data
		output wire         oADN1_ready,  //               .ready
		input  wire         iADN1_valid,  //               .valid
		output wire [127:0] oArrow_data,  //         oArrow.data
		input  wire         iArrow_ready, //               .ready
		output wire         oArrow_valid, //               .valid
		input  wire         clock_int,    // clock_internal.clk
		input  wire         clock_ext,    // clock_external.clk
		input  wire [31:0]  iParameters,  //     Parameters.export
		input  wire [7:0]   iADN2_data,   //          iADN2.data
		input  wire         iADN2_valid,  //               .valid
		output wire         oADN2_ready   //               .ready
	);
endmodule

