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
  pipeline_CPU myCPU(.clk(clk), .rstn(rstn), .sw_i(sw_i[15:0]))

    reg[`XLEN-1:0] display_data;
    reg[`RFIDX_WIDTH-1:0]  reg_addr;
    reg[`DMEM_SIZE_WIDTH-1:0]   dmem_addr;

    //choose data to display
    always @(*) begin
	    if (sw_i[1]) display_data<=myCPU.pc; //display pc
      else if (sw_i[2]) display_data<=myCPU.instr_IF_ID; //display instruction
	    else if (sw_i[3]) begin
		    reg_addr<=sw_i[9:5];
		    display_data<=myCPU.U_rf.rf[reg_addr];//display register value
            end
           else if (sw_i[4]) begin
		   dmem_addr<=sw_i[13:7];//display memory value
               display_data<={myCPU.U_dmem.RAM[dmem_addr+3][7:0], myCPU.U_dmem.RAM[dmem_addr+2][7:0], 
                    myCPU.U_dmem.RAM[dmem_addr+1][7:0], myCPU.U_dmem.RAM[dmem_addr][7:0]};
            end
            else display_data<=`XLEN'b0;
    end

    //display data
    seg7x16 u_seg7x16(
        .clk(clk),
        .rstn(rstn),
        .disp_mode(1'b0),
        .i_data(display_data),
        .o_seg(disp_seg_o),
        .o_sel(disp_an_o)
        );
   

endmodule
