`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/29 10:53:30
// Design Name: 
// Module Name: EXT
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

module EXT(
    input	[11:0]			iimm, //instr[31:20], 12 bits
	input	[11:0]			simm, //instr[31:25, 11:7], 12 bits
	input	[11:0]			bimm, //instrD[31], instrD[7], instrD[30:25], instrD[11:8], 12 bits
	input	[19:0]			uimm,//instrD[31:12], 20 bits
	input	[19:0]			jimm,//instrD[31], instrD[19:12], instrD[20], instrD[30:21], 20 bits
	input	[4:0]			 immctrl,

	output	reg [`XLEN-1:0] 	immout);
  always  @(*)begin
	 case (immctrl)
		`IMM_CTRL_ITYPE:	immout <= {{{`XLEN-12}{iimm[11]}}, iimm[11:0]};
		`IMM_CTRL_UTYPE:	immout <= {uimm[19:0], 12'b0};
		`IMM_CTRL_STYPE: immout <= {{{`XLEN-12}{simm[11]}}, simm[11:0]};
        `IMM_CTRL_BTYPE: immout <= {{{`XLEN-12}{bimm[11]}}, bimm[11:0]};
        `IMM_CTRL_JTYPE: immout <= {{{`XLEN-20}{jimm[19]}}, jimm[19:0]};
		default:			      immout <= `XLEN'b0;
	 endcase
	 end
endmodule
