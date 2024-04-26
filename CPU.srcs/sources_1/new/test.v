`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/29 10:18:09
// Design Name: 
// Module Name: test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module test(
  input clk,
  input rstn,
  input [15:0]sw_i,
  output [7:0]disp_an_o,
  output [7:0]disp_seg_o
);

reg CLK;
reg reset;

  //pipeline_CPU myCPU(.clk(CLK), .rstn(reset), .sw_i(sw_i[15:0]),
//                  .disp_an_o(disp_an_o), .disp_seg_o(disp_seg_o))
  pipeline_CPU myCPU(.clk(clk), .rstn(rstn), .sw_i(sw_i[15:0]),
                  .disp_an_o(disp_an_o), .disp_seg_o(disp_seg_o))

endmodule
