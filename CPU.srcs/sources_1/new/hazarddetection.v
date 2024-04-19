`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/29 10:09:25
// Design Name: 
// Module Name: pipeline_CPU
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

module hazarddetection(
    input memtoreg_EX, bchange, regwrite, memtoreg_MEM, 
    input[`RFIDX_WIDTH-1:0] rd_EX, rs1, rs2, rd_MEM,
    output reg bubbling, bubbling2
    );
    
    always@(*)begin
      if(rd_EX && (rd_EX == rs1 || rd_EX == rs2) && bchange && memtoreg_EX) //pause for 2 cycles
        bubbling2<=1;
      else bubbling2<=0;

      if(rd_EX && (rd_EX == rs1 || rd_EX == rs2) && ((bchange && regwrite) || memtoreg_EX))bubbling<=1; //pause for 1 cycle
      else if(rd_MEM && (rd_MEM == rs1 || rd_MEM == rs2) && bchange && memtoreg_MEM)bubbling<=1;
      else bubbling<=0;
    end
    
endmodule
