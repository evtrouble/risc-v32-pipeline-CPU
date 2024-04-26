`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/29 10:18:09
// Design Name: 
// Module Name: imem
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

//module imem(input clk
//            input  [`ADDR_SIZE-1:0]   a,
//            output [`INSTR_SIZE-1:0]  rd);

// reg  [`INSTR_SIZE-1:0] RAM[`IMEM_SIZE-1:0];
//
// assign rd = RAM[a[11:2]]; // instruction size aligned
//endmodule

module dmem(input           	         clk, we,
            input  [`XLEN-1:0]        a, wd,
            input  [1:0]              lwhb, swhb,
            input                     lunsigned,
            output reg[`XLEN-1:0]        rd);

  reg  [7:0] RAM[`DMEM_SIZE-1:0];
 
  //wire[`DMEM_SIZE_WIDTH-1:0] addr=a[11:2]; // word aligned

  integer j = 0;
    initial begin
        for(j = 0; j < `DMEM_SIZE; j = j + 1)begin
            RAM[j] <= 0;
        end
    end

  always @(posedge clk)begin
    if(we)
        case (swhb)
            `DM_byte:
                RAM[a] <= wd[7:0];//sb
            `DM_halfword:begin
                RAM[a] <= wd[7:0];//sh 
                RAM[a+1] <= wd[15:8];
            end
            `DM_word: begin
                RAM[a] <= wd[7:0];//sw
                RAM[a+1] <= wd[15:8];
                RAM[a+2] <= wd[23:16];
                RAM[a+3] <= wd[31:24];
            end
        endcase   	  
  end
  
  always@(*)begin
      if(lunsigned)
        case (lwhb)
          `DM_byte:
                  rd <= {24'b0, RAM[a][7:0]};//lbu
          `DM_halfword:
                  rd <= {16'b0, RAM[a+1][7:0], RAM[a][7:0]};//lhu
          default: rd <= 32'b0;
        endcase
      else
        case (lwhb)
            `DM_byte:
                rd <= {{24{RAM[a][7]}}, RAM[a][7:0]};//lb
            `DM_halfword:
                rd <= {{16{RAM[a+1][7]}}, RAM[a+1][7:0], RAM[a][7:0]};//lh
            `DM_word: //lw
                rd <= {RAM[a+3][7:0], RAM[a+2][7:0], RAM[a+1][7:0], RAM[a][7:0]};
            default: rd <= 32'b0;
        endcase
  end
  
endmodule

