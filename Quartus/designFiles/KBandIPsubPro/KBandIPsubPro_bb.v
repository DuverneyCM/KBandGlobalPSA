module KBandIPsubPro (
		input  wire         m0_waitrequest,           //                   m0.waitrequest
		input  wire [127:0] m0_readdata,              //                     .readdata
		input  wire         m0_readdatavalid,         //                     .readdatavalid
		output wire [4:0]   m0_burstcount,            //                     .burstcount
		output wire [127:0] m0_writedata,             //                     .writedata
		output wire [29:0]  m0_address,               //                     .address
		output wire         m0_write,                 //                     .write
		output wire         m0_read,                  //                     .read
		output wire [15:0]  m0_byteenable,            //                     .byteenable
		output wire         m0_debugaccess,           //                     .debugaccess
		output wire         kbandinput_1_csr_irq_irq, // kbandinput_1_csr_irq.irq
		output wire         kbandinput_2_csr_irq_irq, // kbandinput_2_csr_irq.irq
		output wire         kbandoutput_csr_irq_irq,  //  kbandoutput_csr_irq.irq
		input  wire         clk_clk,                  //                  clk.clk
		input  wire         reset_reset_n,            //                reset.reset_n
		input  wire         clk_int_clk,              //              clk_int.clk
		output wire         sfpga_waitrequest,        //                sfpga.waitrequest
		output wire [63:0]  sfpga_readdata,           //                     .readdata
		output wire         sfpga_readdatavalid,      //                     .readdatavalid
		input  wire [0:0]   sfpga_burstcount,         //                     .burstcount
		input  wire [63:0]  sfpga_writedata,          //                     .writedata
		input  wire [17:0]  sfpga_address,            //                     .address
		input  wire         sfpga_write,              //                     .write
		input  wire         sfpga_read,               //                     .read
		input  wire [7:0]   sfpga_byteenable,         //                     .byteenable
		input  wire         sfpga_debugaccess,        //                     .debugaccess
		output wire         slw_waitrequest,          //                  slw.waitrequest
		output wire [31:0]  slw_readdata,             //                     .readdata
		output wire         slw_readdatavalid,        //                     .readdatavalid
		input  wire [0:0]   slw_burstcount,           //                     .burstcount
		input  wire [31:0]  slw_writedata,            //                     .writedata
		input  wire [16:0]  slw_address,              //                     .address
		input  wire         slw_write,                //                     .write
		input  wire         slw_read,                 //                     .read
		input  wire [3:0]   slw_byteenable,           //                     .byteenable
		input  wire         slw_debugaccess           //                     .debugaccess
	);
endmodule

