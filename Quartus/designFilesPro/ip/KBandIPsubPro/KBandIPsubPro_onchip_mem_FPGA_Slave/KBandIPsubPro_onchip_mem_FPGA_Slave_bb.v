module KBandIPsubPro_onchip_mem_FPGA_Slave (
		input  wire         clk,        //   clk1.clk
		input  wire [13:0]  address,    //     s1.address
		input  wire         clken,      //       .clken
		input  wire         chipselect, //       .chipselect
		input  wire         write,      //       .write
		output wire [127:0] readdata,   //       .readdata
		input  wire [127:0] writedata,  //       .writedata
		input  wire [15:0]  byteenable, //       .byteenable
		input  wire         reset,      // reset1.reset
		input  wire         reset_req   //       .reset_req
	);
endmodule

