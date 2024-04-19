`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/29 10:22:56
// Design Name: 
// Module Name: regfile
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

`include "defines.v"

module regfile(
  input                      	clk,
  input  [`RFIDX_WIDTH-1:0]  	ra1, ra2,
  output [`XLEN-1:0]          rd1, rd2,

  input                      	we3, 
  input  [`RFIDX_WIDTH-1:0]  	wa3,
  input  [`XLEN-1:0]          wd3
  
  );

  reg [`XLEN-1:0] rf[`RFREG_NUM-1:0];
  
 integer i = 0;
 initial begin
    for(i=0;i<`RFREG_NUM;i=i+1)begin
        if(i==2)rf[i]<=`DMEM_SIZE-4;//sp
        else rf[i]<=0;end
  end
  // three ported register file
  // read two ports combinationally
  // write third port on falling edge of clock
  // register 0 hardwired to 0

  always @(negedge clk)begin
      if (we3 && wa3!=0)
      begin
        rf[wa3] <= wd3;
      end
    end 

  assign rd1=(ra1!=0)?rf[ra1]:0;
  assign rd2=(ra2!=0)?rf[ra2]:0;

endmodule
