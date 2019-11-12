	KBandIPsubPro_KBandOutput u0 (
		.clock_clk                    (_connected_to_clock_clk_),                    //   input,    width = 1,            clock.clk
		.reset_n_reset_n              (_connected_to_reset_n_reset_n_),              //   input,    width = 1,          reset_n.reset_n
		.csr_writedata                (_connected_to_csr_writedata_),                //   input,   width = 32,              csr.writedata
		.csr_write                    (_connected_to_csr_write_),                    //   input,    width = 1,                 .write
		.csr_byteenable               (_connected_to_csr_byteenable_),               //   input,    width = 4,                 .byteenable
		.csr_readdata                 (_connected_to_csr_readdata_),                 //  output,   width = 32,                 .readdata
		.csr_read                     (_connected_to_csr_read_),                     //   input,    width = 1,                 .read
		.csr_address                  (_connected_to_csr_address_),                  //   input,    width = 3,                 .address
		.descriptor_slave_write       (_connected_to_descriptor_slave_write_),       //   input,    width = 1, descriptor_slave.write
		.descriptor_slave_waitrequest (_connected_to_descriptor_slave_waitrequest_), //  output,    width = 1,                 .waitrequest
		.descriptor_slave_writedata   (_connected_to_descriptor_slave_writedata_),   //   input,  width = 128,                 .writedata
		.descriptor_slave_byteenable  (_connected_to_descriptor_slave_byteenable_),  //   input,   width = 16,                 .byteenable
		.csr_irq_irq                  (_connected_to_csr_irq_irq_),                  //  output,    width = 1,          csr_irq.irq
		.mm_write_address             (_connected_to_mm_write_address_),             //  output,   width = 32,         mm_write.address
		.mm_write_write               (_connected_to_mm_write_write_),               //  output,    width = 1,                 .write
		.mm_write_byteenable          (_connected_to_mm_write_byteenable_),          //  output,   width = 16,                 .byteenable
		.mm_write_writedata           (_connected_to_mm_write_writedata_),           //  output,  width = 128,                 .writedata
		.mm_write_waitrequest         (_connected_to_mm_write_waitrequest_),         //   input,    width = 1,                 .waitrequest
		.st_sink_data                 (_connected_to_st_sink_data_),                 //   input,  width = 128,          st_sink.data
		.st_sink_valid                (_connected_to_st_sink_valid_),                //   input,    width = 1,                 .valid
		.st_sink_ready                (_connected_to_st_sink_ready_)                 //  output,    width = 1,                 .ready
	);

