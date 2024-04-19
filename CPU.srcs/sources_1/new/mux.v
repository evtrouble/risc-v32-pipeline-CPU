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

module mux2(
    input CTRL,
    input[`XLEN-1:0] rs1, rs2,
    output[`XLEN-1:0] rd
    );

assign rd=(CTRL?rs2:rs1);

endmodule

module mux3(
    input[1:0] CTRL,    //forwarding signal
    input[`XLEN-1:0] rs1, rs2, rs3,
    output[`XLEN-1:0] rd
    );

reg[`XLEN-1:0] rd_temp;

always@(*)
    begin
        case (CTRL)
            2'b00: rd_temp<=rs1;
            2'b01:  rd_temp<=rs3;
            2'b10: rd_temp<=rs2;
            default:  rd_temp<=rs1;
        endcase   	
     end
        assign rd=rd_temp;  

endmodule