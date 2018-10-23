	KBandIPsubAffine u0 (
		.clk_clk                  (<connected-to-clk_clk>),                  //                  clk.clk
		.clk_int_clk              (<connected-to-clk_int_clk>),              //              clk_int.clk
		.kbandinput_1_csr_irq_irq (<connected-to-kbandinput_1_csr_irq_irq>), // kbandinput_1_csr_irq.irq
		.kbandoutput_csr_irq_irq  (<connected-to-kbandoutput_csr_irq_irq>),  //  kbandoutput_csr_irq.irq
		.m0_waitrequest           (<connected-to-m0_waitrequest>),           //                   m0.waitrequest
		.m0_readdata              (<connected-to-m0_readdata>),              //                     .readdata
		.m0_readdatavalid         (<connected-to-m0_readdatavalid>),         //                     .readdatavalid
		.m0_burstcount            (<connected-to-m0_burstcount>),            //                     .burstcount
		.m0_writedata             (<connected-to-m0_writedata>),             //                     .writedata
		.m0_address               (<connected-to-m0_address>),               //                     .address
		.m0_write                 (<connected-to-m0_write>),                 //                     .write
		.m0_read                  (<connected-to-m0_read>),                  //                     .read
		.m0_byteenable            (<connected-to-m0_byteenable>),            //                     .byteenable
		.m0_debugaccess           (<connected-to-m0_debugaccess>),           //                     .debugaccess
		.reset_reset_n            (<connected-to-reset_reset_n>),            //                reset.reset_n
		.sfpga_waitrequest        (<connected-to-sfpga_waitrequest>),        //                sfpga.waitrequest
		.sfpga_readdata           (<connected-to-sfpga_readdata>),           //                     .readdata
		.sfpga_readdatavalid      (<connected-to-sfpga_readdatavalid>),      //                     .readdatavalid
		.sfpga_burstcount         (<connected-to-sfpga_burstcount>),         //                     .burstcount
		.sfpga_writedata          (<connected-to-sfpga_writedata>),          //                     .writedata
		.sfpga_address            (<connected-to-sfpga_address>),            //                     .address
		.sfpga_write              (<connected-to-sfpga_write>),              //                     .write
		.sfpga_read               (<connected-to-sfpga_read>),               //                     .read
		.sfpga_byteenable         (<connected-to-sfpga_byteenable>),         //                     .byteenable
		.sfpga_debugaccess        (<connected-to-sfpga_debugaccess>),        //                     .debugaccess
		.slw_waitrequest          (<connected-to-slw_waitrequest>),          //                  slw.waitrequest
		.slw_readdata             (<connected-to-slw_readdata>),             //                     .readdata
		.slw_readdatavalid        (<connected-to-slw_readdatavalid>),        //                     .readdatavalid
		.slw_burstcount           (<connected-to-slw_burstcount>),           //                     .burstcount
		.slw_writedata            (<connected-to-slw_writedata>),            //                     .writedata
		.slw_address              (<connected-to-slw_address>),              //                     .address
		.slw_write                (<connected-to-slw_write>),                //                     .write
		.slw_read                 (<connected-to-slw_read>),                 //                     .read
		.slw_byteenable           (<connected-to-slw_byteenable>),           //                     .byteenable
		.slw_debugaccess          (<connected-to-slw_debugaccess>)           //                     .debugaccess
	);

