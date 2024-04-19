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

module forward(
    input regwrite_MEM,
    input[`RFIDX_WIDTH-1:0] rd_MEM,
    input regwrite_WB, 
    input[`RFIDX_WIDTH-1:0] rd_WB,
    input[`RFIDX_WIDTH-1:0] rs,
    output reg[1:0] CTRL_forward
    );
    
    always@(*)begin 
        if(regwrite_MEM && rd_MEM && rd_MEM == rs)begin CTRL_forward<=2'b10;end
        else if(regwrite_WB && rd_WB && rd_WB == rs)begin CTRL_forward<=2'b01;end
        else begin CTRL_forward<=2'b00;end
       end

endmodule