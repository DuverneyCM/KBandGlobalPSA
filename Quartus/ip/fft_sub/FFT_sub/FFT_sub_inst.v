	FFT_sub u0 (
		.clk_clk                    (<connected-to-clk_clk>),                    //                    clk.clk
		.reset_reset_n              (<connected-to-reset_reset_n>),              //                  reset.reset_n
		.s0_waitrequest             (<connected-to-s0_waitrequest>),             //                     s0.waitrequest
		.s0_readdata                (<connected-to-s0_readdata>),                //                       .readdata
		.s0_readdatavalid           (<connected-to-s0_readdatavalid>),           //                       .readdatavalid
		.s0_burstcount              (<connected-to-s0_burstcount>),              //                       .burstcount
		.s0_writedata               (<connected-to-s0_writedata>),               //                       .writedata
		.s0_address                 (<connected-to-s0_address>),                 //                       .address
		.s0_write                   (<connected-to-s0_write>),                   //                       .write
		.s0_read                    (<connected-to-s0_read>),                    //                       .read
		.s0_byteenable              (<connected-to-s0_byteenable>),              //                       .byteenable
		.s0_debugaccess             (<connected-to-s0_debugaccess>),             //                       .debugaccess
		.sgdma_from_fft_csr_irq_irq (<connected-to-sgdma_from_fft_csr_irq_irq>), // sgdma_from_fft_csr_irq.irq
		.sgdma_to_fft_csr_irq_irq   (<connected-to-sgdma_to_fft_csr_irq_irq>),   //   sgdma_to_fft_csr_irq.irq
		.to_ddr_waitrequest         (<connected-to-to_ddr_waitrequest>),         //                 to_ddr.waitrequest
		.to_ddr_readdata            (<connected-to-to_ddr_readdata>),            //                       .readdata
		.to_ddr_readdatavalid       (<connected-to-to_ddr_readdatavalid>),       //                       .readdatavalid
		.to_ddr_burstcount          (<connected-to-to_ddr_burstcount>),          //                       .burstcount
		.to_ddr_writedata           (<connected-to-to_ddr_writedata>),           //                       .writedata
		.to_ddr_address             (<connected-to-to_ddr_address>),             //                       .address
		.to_ddr_write               (<connected-to-to_ddr_write>),               //                       .write
		.to_ddr_read                (<connected-to-to_ddr_read>),                //                       .read
		.to_ddr_byteenable          (<connected-to-to_ddr_byteenable>),          //                       .byteenable
		.to_ddr_debugaccess         (<connected-to-to_ddr_debugaccess>)          //                       .debugaccess
	);

