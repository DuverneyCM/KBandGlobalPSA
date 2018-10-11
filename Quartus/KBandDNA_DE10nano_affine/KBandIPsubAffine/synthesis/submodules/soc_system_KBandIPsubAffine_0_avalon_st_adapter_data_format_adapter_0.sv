// (C) 2001-2016 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// (C) 2001-2013 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.

 
// $Id: //acds/rel/13.1/ip/.../avalon-st_data_format_adapter.sv.terp#1 $
// $Revision: #1 $
// $Date: 2013/09/21 $
// $Author: dmunday $


// --------------------------------------------------------------------------------
//| Avalon Streaming Data Adapter
// --------------------------------------------------------------------------------

`timescale 1ns / 100ps

// ------------------------------------------
// Generation parameters:
//   output_name:        soc_system_KBandIPsubAffine_0_avalon_st_adapter_data_format_adapter_0
//   usePackets:         false
//   hasInEmpty:         false
//   inEmptyWidth:       0
//   hasOutEmpty:        false 
//   outEmptyWidth:      0
//   inDataWidth:        32
//   outDataWidth:       128
//   channelWidth:       0
//   inErrorWidth:       0
//   outErrorWidth:      0
//   inSymbolsPerBeat:   4
//   outSymbolsPerBeat:  16
//   maxState:           15
//   stateWidth:         4
//   maxChannel:         0
//   symbolWidth:        8
//   numMemSymbols:      15
//   symbolWidth:        8


// ------------------------------------------

 
module soc_system_KBandIPsubAffine_0_avalon_st_adapter_data_format_adapter_0 (
 // Interface: in
 output reg         in_ready,
 input              in_valid,
 input [32-1 : 0]    in_data,
 // Interface: out
 input                out_ready,
 output reg           out_valid,
 output reg [128-1: 0]  out_data,

  // Interface: clk
 input              clk,
 // Interface: reset
 input              reset_n

);



   // ---------------------------------------------------------------------
   //| Signal Declarations
   // ---------------------------------------------------------------------
   reg         state_read_addr;
   wire [4-1:0]   state_from_memory;
   reg  [4-1:0]   state;
   reg  [4-1:0]   new_state;
   reg  [4-1:0]   state_d1;
    
   reg            in_ready_d1;
   reg            mem_readaddr; 
   reg            mem_readaddr_d1;
   reg            a_ready;
   reg            a_valid;
   reg            a_channel;
   reg [8-1:0]    a_data0; 
   reg [8-1:0]    a_data1; 
   reg [8-1:0]    a_data2; 
   reg [8-1:0]    a_data3; 
   reg            a_startofpacket;
   reg            a_endofpacket;
   reg            a_empty;
   reg            a_error;
   reg            b_ready;
   reg            b_valid;
   reg            b_channel;
   reg  [128-1:0]   b_data;
   reg            b_startofpacket; 
   wire           b_startofpacket_wire; 
   reg            b_endofpacket; 
   reg            b_empty;   
   reg            b_error; 
   reg            mem_write0;
   reg  [8-1:0]   mem_writedata0;
   wire [8-1:0]   mem_readdata0;
   wire           mem_waitrequest0;
   reg  [8-1:0]   mem0[0:0];
   reg            mem_write1;
   reg  [8-1:0]   mem_writedata1;
   wire [8-1:0]   mem_readdata1;
   wire           mem_waitrequest1;
   reg  [8-1:0]   mem1[0:0];
   reg            mem_write2;
   reg  [8-1:0]   mem_writedata2;
   wire [8-1:0]   mem_readdata2;
   wire           mem_waitrequest2;
   reg  [8-1:0]   mem2[0:0];
   reg            mem_write3;
   reg  [8-1:0]   mem_writedata3;
   wire [8-1:0]   mem_readdata3;
   wire           mem_waitrequest3;
   reg  [8-1:0]   mem3[0:0];
   reg            mem_write4;
   reg  [8-1:0]   mem_writedata4;
   wire [8-1:0]   mem_readdata4;
   wire           mem_waitrequest4;
   reg  [8-1:0]   mem4[0:0];
   reg            mem_write5;
   reg  [8-1:0]   mem_writedata5;
   wire [8-1:0]   mem_readdata5;
   wire           mem_waitrequest5;
   reg  [8-1:0]   mem5[0:0];
   reg            mem_write6;
   reg  [8-1:0]   mem_writedata6;
   wire [8-1:0]   mem_readdata6;
   wire           mem_waitrequest6;
   reg  [8-1:0]   mem6[0:0];
   reg            mem_write7;
   reg  [8-1:0]   mem_writedata7;
   wire [8-1:0]   mem_readdata7;
   wire           mem_waitrequest7;
   reg  [8-1:0]   mem7[0:0];
   reg            mem_write8;
   reg  [8-1:0]   mem_writedata8;
   wire [8-1:0]   mem_readdata8;
   wire           mem_waitrequest8;
   reg  [8-1:0]   mem8[0:0];
   reg            mem_write9;
   reg  [8-1:0]   mem_writedata9;
   wire [8-1:0]   mem_readdata9;
   wire           mem_waitrequest9;
   reg  [8-1:0]   mem9[0:0];
   reg            mem_write10;
   reg  [8-1:0]   mem_writedata10;
   wire [8-1:0]   mem_readdata10;
   wire           mem_waitrequest10;
   reg  [8-1:0]   mem10[0:0];
   reg            mem_write11;
   reg  [8-1:0]   mem_writedata11;
   wire [8-1:0]   mem_readdata11;
   wire           mem_waitrequest11;
   reg  [8-1:0]   mem11[0:0];
   reg            mem_write12;
   reg  [8-1:0]   mem_writedata12;
   wire [8-1:0]   mem_readdata12;
   wire           mem_waitrequest12;
   reg  [8-1:0]   mem12[0:0];
   reg            mem_write13;
   reg  [8-1:0]   mem_writedata13;
   wire [8-1:0]   mem_readdata13;
   wire           mem_waitrequest13;
   reg  [8-1:0]   mem13[0:0];
   reg            mem_write14;
   reg  [8-1:0]   mem_writedata14;
   wire [8-1:0]   mem_readdata14;
   wire           mem_waitrequest14;
   reg  [8-1:0]   mem14[0:0];
   reg            sop_mem_writeenable;
   reg            sop_mem_writedata;
   wire           mem_waitrequest_sop; 

   wire           state_waitrequest;
   reg            state_waitrequest_d1; 

   reg            in_channel = 0;
   reg            out_channel;

   reg in_startofpacket = 0;
   reg in_endofpacket   = 0;
   reg out_startofpacket;
   reg out_endofpacket;

   reg  [4-1:0] in_empty = 0;
   reg  [16-1:0] out_empty;

   reg in_error = 0;
   reg out_error; 

   wire           error_from_mem;
   reg            error_mem_writedata;
   reg          error_mem_writeenable;

   reg  [4-1:0]   state_register;
   reg            sop_register; 
   reg            error_register;
   reg  [8-1:0]   data0_register;
   reg  [8-1:0]   data1_register;
   reg  [8-1:0]   data2_register;
   reg  [8-1:0]   data3_register;
   reg  [8-1:0]   data4_register;
   reg  [8-1:0]   data5_register;
   reg  [8-1:0]   data6_register;
   reg  [8-1:0]   data7_register;
   reg  [8-1:0]   data8_register;
   reg  [8-1:0]   data9_register;
   reg  [8-1:0]   data10_register;
   reg  [8-1:0]   data11_register;
   reg  [8-1:0]   data12_register;
   reg  [8-1:0]   data13_register;
   reg  [8-1:0]   data14_register;

   // ---------------------------------------------------------------------
   //| Input Register Stage
   // ---------------------------------------------------------------------
   always @(posedge clk or negedge reset_n) begin
      if (!reset_n) begin
         a_valid   <= 0;
         a_channel <= 0;
         a_data0   <= 0;
         a_data1   <= 0;
         a_data2   <= 0;
         a_data3   <= 0;
         a_startofpacket <= 0;
         a_endofpacket   <= 0;
         a_empty <= 0; 
         a_error <= 0;
      end else begin
         if (in_ready) begin
            a_valid   <= in_valid;
            a_channel <= in_channel;
            a_error   <= in_error;
            a_data0 <= in_data[31:24];
            a_data1 <= in_data[23:16];
            a_data2 <= in_data[15:8];
            a_data3 <= in_data[7:0];
            a_startofpacket <= in_startofpacket;
            a_endofpacket   <= in_endofpacket;
            a_empty         <= 0; 
            if (in_endofpacket)
               a_empty <= in_empty;
         end
      end 
   end

   always @* begin 
      state_read_addr = in_channel;
   end
   

   // ---------------------------------------------------------------------
   //| State & Memory Keepers
   // ---------------------------------------------------------------------
   always @(posedge clk or negedge reset_n) begin
      if (!reset_n) begin
         in_ready_d1          <= 0;
         state_d1             <= 0;
         mem_readaddr_d1      <= 0;
         state_waitrequest_d1 <= 0;
      end else begin
         in_ready_d1          <= in_ready;
         state_d1             <= state;
         mem_readaddr_d1      <= mem_readaddr;
         state_waitrequest_d1 <= state_waitrequest;
      end
   end
   
   always @(posedge clk or negedge reset_n) begin
      if (!reset_n) begin
         state_register <= 0;
         sop_register   <= 0;
         data0_register <= 0;
         data1_register <= 0;
         data2_register <= 0;
         data3_register <= 0;
         data4_register <= 0;
         data5_register <= 0;
         data6_register <= 0;
         data7_register <= 0;
         data8_register <= 0;
         data9_register <= 0;
         data10_register <= 0;
         data11_register <= 0;
         data12_register <= 0;
         data13_register <= 0;
         data14_register <= 0;
         error_register <= 0;
      end else begin
         state_register <= new_state;
         if (sop_mem_writeenable)
            sop_register   <= sop_mem_writedata;
         if (a_valid)
            error_register <= error_mem_writedata;
         if (mem_write0)
            data0_register <= mem_writedata0;
         if (mem_write1)
            data1_register <= mem_writedata1;
         if (mem_write2)
            data2_register <= mem_writedata2;
         if (mem_write3)
            data3_register <= mem_writedata3;
         if (mem_write4)
            data4_register <= mem_writedata4;
         if (mem_write5)
            data5_register <= mem_writedata5;
         if (mem_write6)
            data6_register <= mem_writedata6;
         if (mem_write7)
            data7_register <= mem_writedata7;
         if (mem_write8)
            data8_register <= mem_writedata8;
         if (mem_write9)
            data9_register <= mem_writedata9;
         if (mem_write10)
            data10_register <= mem_writedata10;
         if (mem_write11)
            data11_register <= mem_writedata11;
         if (mem_write12)
            data12_register <= mem_writedata12;
         if (mem_write13)
            data13_register <= mem_writedata13;
         if (mem_write14)
            data14_register <= mem_writedata14;
         end
      end
   
      assign state_from_memory = state_register;
      assign b_startofpacket_wire = sop_register;
      assign mem_readdata0 = data0_register;
      assign mem_readdata1 = data1_register;
      assign mem_readdata2 = data2_register;
      assign mem_readdata3 = data3_register;
      assign mem_readdata4 = data4_register;
      assign mem_readdata5 = data5_register;
      assign mem_readdata6 = data6_register;
      assign mem_readdata7 = data7_register;
      assign mem_readdata8 = data8_register;
      assign mem_readdata9 = data9_register;
      assign mem_readdata10 = data10_register;
      assign mem_readdata11 = data11_register;
      assign mem_readdata12 = data12_register;
      assign mem_readdata13 = data13_register;
      assign mem_readdata14 = data14_register;
      assign error_from_mem = error_register;
   
   // ---------------------------------------------------------------------
   //| State Machine
   // ---------------------------------------------------------------------
   always @* begin

      
   b_ready = (out_ready || ~out_valid);

   a_ready   = 0;
   b_data    = 0;
   b_valid   = 0;
   b_channel = a_channel;
   b_error   = a_error;
      
   state = state_from_memory;
   if (~in_ready_d1)
      state = state_d1;
         
   error_mem_writedata = error_from_mem | a_error;
   if (state == 0)
      error_mem_writedata = a_error;
   b_error = error_mem_writedata;
      
   new_state           = state;
   mem_write0          = 0;
   mem_writedata0      = a_data0;
   mem_write1          = 0;
   mem_writedata1      = a_data0;
   mem_write2          = 0;
   mem_writedata2      = a_data0;
   mem_write3          = 0;
   mem_writedata3      = a_data0;
   mem_write4          = 0;
   mem_writedata4      = a_data0;
   mem_write5          = 0;
   mem_writedata5      = a_data0;
   mem_write6          = 0;
   mem_writedata6      = a_data0;
   mem_write7          = 0;
   mem_writedata7      = a_data0;
   mem_write8          = 0;
   mem_writedata8      = a_data0;
   mem_write9          = 0;
   mem_writedata9      = a_data0;
   mem_write10          = 0;
   mem_writedata10      = a_data0;
   mem_write11          = 0;
   mem_writedata11      = a_data0;
   mem_write12          = 0;
   mem_writedata12      = a_data0;
   mem_write13          = 0;
   mem_writedata13      = a_data0;
   mem_write14          = 0;
   mem_writedata14      = a_data0;
   sop_mem_writeenable = 0;

   b_endofpacket = a_endofpacket;
      
   b_startofpacket = 0;
      
   b_empty = 0;
       
   case (state) 
            0 : begin
            mem_writedata0 = a_data0;
            mem_writedata1 = a_data1;
            mem_writedata2 = a_data2;
            mem_writedata3 = a_data3;
            a_ready = 1;
            if (a_valid) begin
               new_state = state+1'b1;
               mem_write0 = 1;
               mem_write1 = 1;
               mem_write2 = 1;
               mem_write3 = 1;
            end
         end
         1 : begin
            mem_writedata0 = mem_readdata0;
            mem_writedata1 = mem_readdata1;
            mem_writedata2 = mem_readdata2;
            mem_writedata3 = mem_readdata3;
            mem_writedata4 = a_data0;
            mem_writedata5 = a_data1;
            mem_writedata6 = a_data2;
            mem_writedata7 = a_data3;
            a_ready = 1;
            if (a_valid) begin
               new_state = state+1'b1;
               mem_write0 = 1;
               mem_write1 = 1;
               mem_write2 = 1;
               mem_write3 = 1;
               mem_write4 = 1;
               mem_write5 = 1;
               mem_write6 = 1;
               mem_write7 = 1;
            end
         end
         2 : begin
            mem_writedata0 = mem_readdata0;
            mem_writedata1 = mem_readdata1;
            mem_writedata2 = mem_readdata2;
            mem_writedata3 = mem_readdata3;
            mem_writedata4 = mem_readdata4;
            mem_writedata5 = mem_readdata5;
            mem_writedata6 = mem_readdata6;
            mem_writedata7 = mem_readdata7;
            mem_writedata8 = a_data0;
            mem_writedata9 = a_data1;
            mem_writedata10 = a_data2;
            mem_writedata11 = a_data3;
            a_ready = 1;
            if (a_valid) begin
               new_state = state+1'b1;
               mem_write0 = 1;
               mem_write1 = 1;
               mem_write2 = 1;
               mem_write3 = 1;
               mem_write4 = 1;
               mem_write5 = 1;
               mem_write6 = 1;
               mem_write7 = 1;
               mem_write8 = 1;
               mem_write9 = 1;
               mem_write10 = 1;
               mem_write11 = 1;
            end
         end
         3 : begin
            b_data[127:120] = mem_readdata0;
            b_data[119:112] = mem_readdata1;
            b_data[111:104] = mem_readdata2;
            b_data[103:96] = mem_readdata3;
            b_data[95:88] = mem_readdata4;
            b_data[87:80] = mem_readdata5;
            b_data[79:72] = mem_readdata6;
            b_data[71:64] = mem_readdata7;
            b_data[63:56] = mem_readdata8;
            b_data[55:48] = mem_readdata9;
            b_data[47:40] = mem_readdata10;
            b_data[39:32] = mem_readdata11;
            b_data[31:24] = a_data0;
            b_data[23:16] = a_data1;
            b_data[15:8] = a_data2;
            b_data[7:0] = a_data3;
            if (out_ready || ~out_valid) begin
               a_ready = 1;
               if (a_valid) 
               begin
                  new_state = state+1'b1;
                  b_valid = 1;
               end
            end
         end
         4 : begin
            mem_writedata0 = a_data0;
            mem_writedata1 = a_data1;
            mem_writedata2 = a_data2;
            mem_writedata3 = a_data3;
            a_ready = 1;
            if (a_valid) begin
               new_state = state+1'b1;
               mem_write0 = 1;
               mem_write1 = 1;
               mem_write2 = 1;
               mem_write3 = 1;
            end
         end
         5 : begin
            mem_writedata0 = mem_readdata0;
            mem_writedata1 = mem_readdata1;
            mem_writedata2 = mem_readdata2;
            mem_writedata3 = mem_readdata3;
            mem_writedata4 = a_data0;
            mem_writedata5 = a_data1;
            mem_writedata6 = a_data2;
            mem_writedata7 = a_data3;
            a_ready = 1;
            if (a_valid) begin
               new_state = state+1'b1;
               mem_write0 = 1;
               mem_write1 = 1;
               mem_write2 = 1;
               mem_write3 = 1;
               mem_write4 = 1;
               mem_write5 = 1;
               mem_write6 = 1;
               mem_write7 = 1;
            end
         end
         6 : begin
            mem_writedata0 = mem_readdata0;
            mem_writedata1 = mem_readdata1;
            mem_writedata2 = mem_readdata2;
            mem_writedata3 = mem_readdata3;
            mem_writedata4 = mem_readdata4;
            mem_writedata5 = mem_readdata5;
            mem_writedata6 = mem_readdata6;
            mem_writedata7 = mem_readdata7;
            mem_writedata8 = a_data0;
            mem_writedata9 = a_data1;
            mem_writedata10 = a_data2;
            mem_writedata11 = a_data3;
            a_ready = 1;
            if (a_valid) begin
               new_state = state+1'b1;
               mem_write0 = 1;
               mem_write1 = 1;
               mem_write2 = 1;
               mem_write3 = 1;
               mem_write4 = 1;
               mem_write5 = 1;
               mem_write6 = 1;
               mem_write7 = 1;
               mem_write8 = 1;
               mem_write9 = 1;
               mem_write10 = 1;
               mem_write11 = 1;
            end
         end
         7 : begin
            b_data[127:120] = mem_readdata0;
            b_data[119:112] = mem_readdata1;
            b_data[111:104] = mem_readdata2;
            b_data[103:96] = mem_readdata3;
            b_data[95:88] = mem_readdata4;
            b_data[87:80] = mem_readdata5;
            b_data[79:72] = mem_readdata6;
            b_data[71:64] = mem_readdata7;
            b_data[63:56] = mem_readdata8;
            b_data[55:48] = mem_readdata9;
            b_data[47:40] = mem_readdata10;
            b_data[39:32] = mem_readdata11;
            b_data[31:24] = a_data0;
            b_data[23:16] = a_data1;
            b_data[15:8] = a_data2;
            b_data[7:0] = a_data3;
            if (out_ready || ~out_valid) begin
               a_ready = 1;
               if (a_valid) 
               begin
                  new_state = state+1'b1;
                  b_valid = 1;
               end
            end
         end
         8 : begin
            mem_writedata0 = a_data0;
            mem_writedata1 = a_data1;
            mem_writedata2 = a_data2;
            mem_writedata3 = a_data3;
            a_ready = 1;
            if (a_valid) begin
               new_state = state+1'b1;
               mem_write0 = 1;
               mem_write1 = 1;
               mem_write2 = 1;
               mem_write3 = 1;
            end
         end
         9 : begin
            mem_writedata0 = mem_readdata0;
            mem_writedata1 = mem_readdata1;
            mem_writedata2 = mem_readdata2;
            mem_writedata3 = mem_readdata3;
            mem_writedata4 = a_data0;
            mem_writedata5 = a_data1;
            mem_writedata6 = a_data2;
            mem_writedata7 = a_data3;
            a_ready = 1;
            if (a_valid) begin
               new_state = state+1'b1;
               mem_write0 = 1;
               mem_write1 = 1;
               mem_write2 = 1;
               mem_write3 = 1;
               mem_write4 = 1;
               mem_write5 = 1;
               mem_write6 = 1;
               mem_write7 = 1;
            end
         end
         10 : begin
            mem_writedata0 = mem_readdata0;
            mem_writedata1 = mem_readdata1;
            mem_writedata2 = mem_readdata2;
            mem_writedata3 = mem_readdata3;
            mem_writedata4 = mem_readdata4;
            mem_writedata5 = mem_readdata5;
            mem_writedata6 = mem_readdata6;
            mem_writedata7 = mem_readdata7;
            mem_writedata8 = a_data0;
            mem_writedata9 = a_data1;
            mem_writedata10 = a_data2;
            mem_writedata11 = a_data3;
            a_ready = 1;
            if (a_valid) begin
               new_state = state+1'b1;
               mem_write0 = 1;
               mem_write1 = 1;
               mem_write2 = 1;
               mem_write3 = 1;
               mem_write4 = 1;
               mem_write5 = 1;
               mem_write6 = 1;
               mem_write7 = 1;
               mem_write8 = 1;
               mem_write9 = 1;
               mem_write10 = 1;
               mem_write11 = 1;
            end
         end
         11 : begin
            b_data[127:120] = mem_readdata0;
            b_data[119:112] = mem_readdata1;
            b_data[111:104] = mem_readdata2;
            b_data[103:96] = mem_readdata3;
            b_data[95:88] = mem_readdata4;
            b_data[87:80] = mem_readdata5;
            b_data[79:72] = mem_readdata6;
            b_data[71:64] = mem_readdata7;
            b_data[63:56] = mem_readdata8;
            b_data[55:48] = mem_readdata9;
            b_data[47:40] = mem_readdata10;
            b_data[39:32] = mem_readdata11;
            b_data[31:24] = a_data0;
            b_data[23:16] = a_data1;
            b_data[15:8] = a_data2;
            b_data[7:0] = a_data3;
            if (out_ready || ~out_valid) begin
               a_ready = 1;
               if (a_valid) 
               begin
                  new_state = state+1'b1;
                  b_valid = 1;
               end
            end
         end
         12 : begin
            mem_writedata0 = a_data0;
            mem_writedata1 = a_data1;
            mem_writedata2 = a_data2;
            mem_writedata3 = a_data3;
            a_ready = 1;
            if (a_valid) begin
               new_state = state+1'b1;
               mem_write0 = 1;
               mem_write1 = 1;
               mem_write2 = 1;
               mem_write3 = 1;
            end
         end
         13 : begin
            mem_writedata0 = mem_readdata0;
            mem_writedata1 = mem_readdata1;
            mem_writedata2 = mem_readdata2;
            mem_writedata3 = mem_readdata3;
            mem_writedata4 = a_data0;
            mem_writedata5 = a_data1;
            mem_writedata6 = a_data2;
            mem_writedata7 = a_data3;
            a_ready = 1;
            if (a_valid) begin
               new_state = state+1'b1;
               mem_write0 = 1;
               mem_write1 = 1;
               mem_write2 = 1;
               mem_write3 = 1;
               mem_write4 = 1;
               mem_write5 = 1;
               mem_write6 = 1;
               mem_write7 = 1;
            end
         end
         14 : begin
            mem_writedata0 = mem_readdata0;
            mem_writedata1 = mem_readdata1;
            mem_writedata2 = mem_readdata2;
            mem_writedata3 = mem_readdata3;
            mem_writedata4 = mem_readdata4;
            mem_writedata5 = mem_readdata5;
            mem_writedata6 = mem_readdata6;
            mem_writedata7 = mem_readdata7;
            mem_writedata8 = a_data0;
            mem_writedata9 = a_data1;
            mem_writedata10 = a_data2;
            mem_writedata11 = a_data3;
            a_ready = 1;
            if (a_valid) begin
               new_state = state+1'b1;
               mem_write0 = 1;
               mem_write1 = 1;
               mem_write2 = 1;
               mem_write3 = 1;
               mem_write4 = 1;
               mem_write5 = 1;
               mem_write6 = 1;
               mem_write7 = 1;
               mem_write8 = 1;
               mem_write9 = 1;
               mem_write10 = 1;
               mem_write11 = 1;
            end
         end
         15 : begin
            b_data[127:120] = mem_readdata0;
            b_data[119:112] = mem_readdata1;
            b_data[111:104] = mem_readdata2;
            b_data[103:96] = mem_readdata3;
            b_data[95:88] = mem_readdata4;
            b_data[87:80] = mem_readdata5;
            b_data[79:72] = mem_readdata6;
            b_data[71:64] = mem_readdata7;
            b_data[63:56] = mem_readdata8;
            b_data[55:48] = mem_readdata9;
            b_data[47:40] = mem_readdata10;
            b_data[39:32] = mem_readdata11;
            b_data[31:24] = a_data0;
            b_data[23:16] = a_data1;
            b_data[15:8] = a_data2;
            b_data[7:0] = a_data3;
            if (out_ready || ~out_valid) begin
               a_ready = 1;
               if (a_valid) 
               begin
                  new_state = 0;
                  b_valid = 1;
               end
            end
         end

   endcase

      in_ready = (a_ready || ~a_valid);

      mem_readaddr = in_channel; 
      if (~in_ready)
         mem_readaddr = mem_readaddr_d1;

      
      sop_mem_writedata = 0;
      if (a_valid)
         sop_mem_writedata = a_startofpacket;
      if (b_ready && b_valid && b_startofpacket)
         sop_mem_writeenable = 1;

   end


   // ---------------------------------------------------------------------
   //| Output Register Stage
   // ---------------------------------------------------------------------
   always @(posedge clk or negedge reset_n) begin
      if (!reset_n) begin
         out_valid         <= 0;
         out_data          <= 0;
         out_channel       <= 0;
         out_startofpacket <= 0;
         out_endofpacket   <= 0;
         out_empty         <= 0;
         out_error         <= 0;
      end else begin
         if (out_ready || ~out_valid) begin
            out_valid         <= b_valid;
            out_data          <= b_data;
            out_channel       <= b_channel; 
            out_startofpacket <= b_startofpacket;
            out_endofpacket   <= b_endofpacket;
            out_empty         <= b_empty;
            out_error         <= b_error;
         end
      end 
   end
   



endmodule

   

