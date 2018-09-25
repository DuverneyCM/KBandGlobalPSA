
module KBandIPsubAffine (
	clk_clk,
	clk_int_clk,
	kbandinput_1_csr_irq_irq,
	kbandoutput_csr_irq_irq,
	m0_waitrequest,
	m0_readdata,
	m0_readdatavalid,
	m0_burstcount,
	m0_writedata,
	m0_address,
	m0_write,
	m0_read,
	m0_byteenable,
	m0_debugaccess,
	reset_reset_n,
	sfpga_waitrequest,
	sfpga_readdata,
	sfpga_readdatavalid,
	sfpga_burstcount,
	sfpga_writedata,
	sfpga_address,
	sfpga_write,
	sfpga_read,
	sfpga_byteenable,
	sfpga_debugaccess,
	slw_waitrequest,
	slw_readdata,
	slw_readdatavalid,
	slw_burstcount,
	slw_writedata,
	slw_address,
	slw_write,
	slw_read,
	slw_byteenable,
	slw_debugaccess);	

	input		clk_clk;
	input		clk_int_clk;
	output		kbandinput_1_csr_irq_irq;
	output		kbandoutput_csr_irq_irq;
	input		m0_waitrequest;
	input	[127:0]	m0_readdata;
	input		m0_readdatavalid;
	output	[4:0]	m0_burstcount;
	output	[127:0]	m0_writedata;
	output	[29:0]	m0_address;
	output		m0_write;
	output		m0_read;
	output	[15:0]	m0_byteenable;
	output		m0_debugaccess;
	input		reset_reset_n;
	output		sfpga_waitrequest;
	output	[63:0]	sfpga_readdata;
	output		sfpga_readdatavalid;
	input	[0:0]	sfpga_burstcount;
	input	[63:0]	sfpga_writedata;
	input	[17:0]	sfpga_address;
	input		sfpga_write;
	input		sfpga_read;
	input	[7:0]	sfpga_byteenable;
	input		sfpga_debugaccess;
	output		slw_waitrequest;
	output	[31:0]	slw_readdata;
	output		slw_readdatavalid;
	input	[0:0]	slw_burstcount;
	input	[31:0]	slw_writedata;
	input	[16:0]	slw_address;
	input		slw_write;
	input		slw_read;
	input	[3:0]	slw_byteenable;
	input		slw_debugaccess;
endmodule
