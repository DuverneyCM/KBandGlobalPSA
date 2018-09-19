
module FFT_sub (
	clk_clk,
	reset_reset_n,
	s0_waitrequest,
	s0_readdata,
	s0_readdatavalid,
	s0_burstcount,
	s0_writedata,
	s0_address,
	s0_write,
	s0_read,
	s0_byteenable,
	s0_debugaccess,
	sgdma_from_fft_csr_irq_irq,
	sgdma_to_fft_csr_irq_irq,
	to_ddr_waitrequest,
	to_ddr_readdata,
	to_ddr_readdatavalid,
	to_ddr_burstcount,
	to_ddr_writedata,
	to_ddr_address,
	to_ddr_write,
	to_ddr_read,
	to_ddr_byteenable,
	to_ddr_debugaccess);	

	input		clk_clk;
	input		reset_reset_n;
	output		s0_waitrequest;
	output	[31:0]	s0_readdata;
	output		s0_readdatavalid;
	input	[0:0]	s0_burstcount;
	input	[31:0]	s0_writedata;
	input	[18:0]	s0_address;
	input		s0_write;
	input		s0_read;
	input	[3:0]	s0_byteenable;
	input		s0_debugaccess;
	output		sgdma_from_fft_csr_irq_irq;
	output		sgdma_to_fft_csr_irq_irq;
	input		to_ddr_waitrequest;
	input	[63:0]	to_ddr_readdata;
	input		to_ddr_readdatavalid;
	output	[4:0]	to_ddr_burstcount;
	output	[63:0]	to_ddr_writedata;
	output	[29:0]	to_ddr_address;
	output		to_ddr_write;
	output		to_ddr_read;
	output	[7:0]	to_ddr_byteenable;
	output		to_ddr_debugaccess;
endmodule
