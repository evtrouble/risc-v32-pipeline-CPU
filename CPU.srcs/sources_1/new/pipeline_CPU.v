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

module pipeline_CPU(
    input clk,
    input rstn,
    input [15:0]sw_i,
);

    reg[`ADDR_SIZE-1:0]pc;
    
    //IF/ID pipeline registers
    reg[`ADDR_SIZE-1:0] pc_IF_ID;
    reg[`INSTR_SIZE-1:0]instr_IF_ID; 
    
    //ID/EX pipeline registers
    reg[`XLEN-1:0]      rd1_ID_EX, rd2_ID_EX, immout_ID_EX;
    reg [3:0]           aluctrl_ID_EX;
    reg                 alusrc_ID_EX, regwrite_ID_EX, memwrite_ID_EX, memtoreg_ID_EX; 
    reg[1:0]            lwhb_ID_EX, swhb_ID_EX;
    reg                 lunsigned_ID_EX;
    reg[`RFIDX_WIDTH-1:0]rs1_ID_EX,   rs2_ID_EX,   rd_ID_EX;
    
    //EX/MEM pipeline registers
    reg                 memwrite_EX_MEM, regwrite_EX_MEM, memtoreg_EX_MEM;
    reg[`XLEN-1:0]      aluout_EX_MEM, writedata_EX_MEM;
    reg                 lunsigned_EX_MEM;
    reg[1:0]            lwhb_EX_MEM, swhb_EX_MEM;
    reg[`RFIDX_WIDTH-1:0]rd_EX_MEM;
    
    //MEM/WB pipeline registers
    reg[`XLEN-1:0]      writedata_MEM_WB, readdata_MEM_WB;
    reg                 regwrite_MEM_WB, memtoreg_MEM_WB;
    reg[`RFIDX_WIDTH-1:0]rd_MEM_WB;
   
    //IF
    wire[`INSTR_SIZE-1:0]instr_IF;
    wire[`ADDR_SIZE-1:0] pc_IF;
    wire[`ADDR_SIZE-1:0] pc_change_IF;
    
    //ID
    wire[`ADDR_SIZE-1:0] pc_ID;
    wire[`ADDR_SIZE-1:0] pc_change;
    wire[6:0]            opcode_ID;           
    wire[2:0]            funct3_ID;  
    wire[`RFIDX_WIDTH-1:0]rs1_ID,   rs2_ID,   rd_ID;
    wire[6:0]            funct7_ID;  
    wire[`XLEN-1:0]      rd1_ID, rd2_ID;

    wire[3:0]            aluctrl_ID;           // for the EX stage 
    wire                 alusrc_ID;            
    wire[1:0]            alusrca_ID; 
    wire                 memwrite_ID, lunsigned_ID;
    wire[1:0]            lwhb_ID, swhb_ID;
    wire                 memtoreg_ID, regwrite_ID;
    wire                 pcsrc_ID;
    wire[4:0]            immctrl_ID;
    wire                 zero_ID, lt_ID;
    wire[`XLEN-1:0]      immout_ID;
    wire                 jal_ID, jalr_ID, bunsigned_ID;
    wire                 bchange_ID;

    wire[11:0]          iimm_ID;                // for EXT module 
    wire[11:0]	      	simm_ID;
    wire[11:0]          bimm_ID;
    wire[19:0]	      	uimm_ID;
    wire[19:0]          jimm_ID;

    wire                bubbling_ID, bubbling2_ID;      //pause signals
    wire[1:0]           forwardA_ID, forwardB_ID;
    wire[`XLEN-1:0]     cmp_rd1_ID, cmp_rd2_ID;
    
    //EX  
    wire[3:0]            aluctrl_EX;        
    wire                 alusrc_EX;
    wire[`XLEN-1:0]      alu_rs1_EX, alu_rs2_EX, imm_EX, aluout_EX, rd2_EX, rd1_EX;
    wire[`XLEN-1:0]      alu_rs2_temp_EX;
    wire[`RFIDX_WIDTH-1:0]rs1_EX, rs2_EX, rd_EX;
    wire[1:0]            forwardA_EX, forwardB_EX;      //forwarding signals
    wire                 memtoreg_EX, regwrite_EX;

    //MEM
    wire[`ADDR_SIZE-1:0] dmemaddr_MEM;
    wire                 memwrite_MEM, regwrite_MEM;
    wire[`XLEN-1:0]      readdata_MEM, writedata_MEM;
    wire[1:0]            lwhb_MEM, swhb_MEM;
    wire                 lunsigned_MEM;
    wire[`XLEN_WIDTH-1:0]rd_MEM;
    wire                 memtoreg_MEM;

    //WB
    wire                 regwrite_WB, memtoreg_WB;
    wire[`XLEN-1:0]      writedata_WB;
    wire[`XLEN-1:0]      writedata_rs1_WB, writedata_rs2_WB;
    wire[`XLEN_WIDTH-1:0]rd_WB;
   
   initial begin
      //$readmemh("riscv32_sim1.dat", U_imem.RAM);
      pc <= 0;
    end
   
    //frequency division
    reg[31:0]clkdiv;
    wire Clk_CPU;
    always@(posedge clk or negedge rstn) begin
        if(!rstn)begin clkdiv<=0;end
        else if(sw_i[0])clkdiv<=clkdiv;
        else clkdiv<=clkdiv+1'b1; end
    assign Clk_CPU=(sw_i[15])? clkdiv[27] : clkdiv[25];

    assign pc_IF = pc;

    //IF
  // imem U_imem( Clk_CPU, pc_IF, instr_IF);
    wire[9:0] addr_temp=pc_IF[11:2];
    imem U_mem(.a(addr_temp),.spo(instr_IF));

    always @(posedge Clk_CPU)begin
        if(bubbling2_ID)instr_IF_ID <= `INSTR_SIZE'b0;  //Pause for 2 cycles
        else if(bubbling_ID)instr_IF_ID <= instr_IF_ID; //Pause for 1 cycle
        else if(pcsrc_ID)instr_IF_ID <= `INSTR_SIZE'b0; //for jump
        else instr_IF_ID <= instr_IF;       
        
        pc_IF_ID <= (bubbling_ID?pc_ID:pc_IF);
    end
   
    mux2 mux_pc_src(.CTRL(pcsrc_ID), .rs1(pc_IF+4), .rs2(pc_change), .rd(pc_change_IF));   //next instruction or new address
     
    //IF/ID
    always@(posedge Clk_CPU) 
    begin
        if(pc>=`MAX_INSTR_NUM<<2)begin
            pc<=(`MAX_INSTR_NUM<<2);
            $stop;
        end
        else if(bubbling2_ID)begin pc<=pc_ID;end    //pause for 2 cycles
        else if(bubbling_ID)begin pc<=pc;end        //pause for 1 cycle
        else begin pc<=pc_change_IF;end
    end
    
    //ID
   assign opcode_ID = instr_IF_ID[6:0];   
   assign funct3_ID = instr_IF_ID[14:12];  
   assign rs1_ID    = instr_IF_ID[19:15];
   assign rs2_ID    = instr_IF_ID[24:20];
   assign rd_ID     = instr_IF_ID[11:7];   
   assign funct7_ID = instr_IF_ID[31:25];
   assign pc_ID     = pc_IF_ID;
   assign pc_change = (jalr_ID?cmp_rd1_ID:pc_ID)+(immout_ID<<1);    //jal, jalr, branch
    
   hazarddetection U_hazarddetection(.memtoreg_EX(memtoreg_EX), .regwrite(regwrite_EX), .bchange(bchange_ID), .rd_EX(rd_EX), 
                                    .memtoreg_MEM(memtoreg_MEM), .rs1(rs1_ID), .rs2(rs2_ID), .bubbling(bubbling_ID), 
                                    .rd_MEM(rd_MEM), .bubbling2(bubbling2_ID)); //check hazard

   regfile U_rf(.clk(Clk_CPU), .ra1(rs1_ID), .ra2(rs2_ID), .rd1(rd1_ID), .rd2(rd2_ID), .we3(regwrite_WB),
            .wa3(rd_WB), .wd3(writedata_WB));

   forward U_forwardA_ID(.regwrite_MEM(regwrite_MEM), .rd_MEM(rd_MEM), .regwrite_WB(regwrite_WB),
            .rd_WB(rd_WB), .rs(rs1_ID), .CTRL_forward(forwardA_ID));
   forward U_forwardB_ID(.regwrite_MEM(regwrite_MEM), .rd_MEM(rd_MEM), .regwrite_WB(regwrite_WB),
             .rd_WB(rd_WB), .rs(rs2_ID), .CTRL_forward(forwardB_ID));
   mux3 mux_cmp_rs1_src(.CTRL(forwardA_ID), .rs1(rd1_ID), .rs2(dmemaddr_MEM), .rs3(writedata_WB), .rd(cmp_rd1_ID));
   mux3 mux_cmp_rs2_src(.CTRL(forwardB_ID), .rs1(rd2_ID), .rs2(dmemaddr_MEM), .rs3(writedata_WB), .rd(cmp_rd2_ID));

   cmp U_cmp(.a(cmp_rd1_ID), .b(cmp_rd2_ID), .op_unsigned(bunsigned_ID), .zero(zero_ID), .lt(lt_ID));  //for conditional jump 

   controller  c(.clk(Clk_CPU), .reset(rstn), .opcode(opcode_ID), .funct3(funct3_ID), .funct7(funct7_ID),
                 .zero(zero_ID), .lt(lt_ID), .immctrl(immctrl_ID), .jal(jal_ID), .bchange(bchange_ID),
                 .jalr(jalr_ID), .bunsigned(bunsigned_ID), .pcsrc(pcsrc_ID), .aluctrl(aluctrl_ID), 
                 .alusrc(alusrc_ID), .alusrca(alusrca_ID), .memwrite(memwrite_ID), .lunsigned(lunsigned_ID), 
                 .lwhb(lwhb_ID), .swhb(swhb_ID), .memtoreg(memtoreg_ID), .regwrite(regwrite_ID));
   
   assign iimm_ID   = instr_IF_ID[31:20];                                 
   assign simm_ID	= {instr_IF_ID[31:25],instr_IF_ID[11:7]};                      
   assign bimm_ID	= {instr_IF_ID[31],instr_IF_ID[7],instr_IF_ID[30:25],instr_IF_ID[11:8]};   
   assign uimm_ID	= instr_IF_ID[31:12];                                    
   assign jimm_ID	= {instr_IF_ID[31],instr_IF_ID[19:12],instr_IF_ID[20],instr_IF_ID[30:21]}; 

   //immediate expansion
   EXT EXT(.iimm(iimm_ID), .simm(simm_ID), .bimm(bimm_ID), .uimm(uimm_ID), .jimm(jimm_ID), 
            .immctrl(immctrl_ID), .immout(immout_ID));
   
   //ID/EX
   always @(posedge Clk_CPU)begin
        immout_ID_EX    <= immout_ID;
        case(alusrca_ID)
            2'b00:  rd1_ID_EX <= rd1_ID;
            2'b01:  rd1_ID_EX <= pc_ID + 4;     //for jal, jalr
            2'b10:  rd1_ID_EX <= pc_ID;         //for auipc
            default:rd1_ID_EX <= rd1_ID;
        endcase
        rd2_ID_EX       <= rd2_ID;
        regwrite_ID_EX  <= (bubbling_ID?0:regwrite_ID);     //nop
        memwrite_ID_EX  <= (bubbling_ID?0:memwrite_ID);     //nop, for store
        memtoreg_ID_EX  <= memtoreg_ID;       //for load
        aluctrl_ID_EX   <= aluctrl_ID;        //for alu module
        alusrc_ID_EX    <= alusrc_ID;
        lwhb_ID_EX      <= lwhb_ID;           //for load type
        swhb_ID_EX      <= swhb_ID;           //for store type
        lunsigned_ID_EX <= lunsigned_ID;
        rs1_ID_EX       <= (pcsrc_ID?5'b0:rs1_ID);      //for forwarding
        rs2_ID_EX       <= rs2_ID;
        rd_ID_EX        <= rd_ID;
   end
   
    //EX
    assign aluctrl_EX  = aluctrl_ID_EX;
    assign alusrc_EX   = alusrc_ID_EX;
    assign rd1_EX      = rd1_ID_EX;
    assign rd2_EX      = rd2_ID_EX;
    assign imm_EX      = immout_ID_EX;
    assign rs1_EX      = rs1_ID_EX;
    assign rs2_EX      = rs2_ID_EX;
    assign rd_EX       = rd_ID_EX;
    assign memtoreg_EX = memtoreg_ID_EX;
    assign regwrite_EX = regwrite_ID_EX;

    forward U_forwardA_EX(.regwrite_MEM(regwrite_MEM), .rd_MEM(rd_MEM), .regwrite_WB(regwrite_WB),  //check rs1 forwarding
            .rd_WB(rd_WB), .rs(rs1_EX), .CTRL_forward(forwardA_EX));
    forward U_forwardB_EX(.regwrite_MEM(regwrite_MEM), .rd_MEM(rd_MEM), .regwrite_WB(regwrite_WB),  //check rs2 forwarding
             .rd_WB(rd_WB), .rs(rs2_EX), .CTRL_forward(forwardB_EX));
    mux3 mux_alu_rs1_src(.CTRL(forwardA_EX), .rs1(rd1_EX), .rs2(dmemaddr_MEM), .rs3(writedata_WB), .rd(alu_rs1_EX));    //from ID, MEM or WB
    mux3 mux_alu_rs2_temp_src(.CTRL(forwardB_EX), .rs1(rd2_EX), .rs2(dmemaddr_MEM), .rs3(writedata_WB), .rd(alu_rs2_temp_EX));  //from ID, MEM or WB
    mux2 mux_alu_rs2_src(.CTRL(alusrc_EX), .rs1(alu_rs2_temp_EX), .rs2(imm_EX), .rd(alu_rs2_EX));   //from register rs2 or imm

   alu alu(.a(alu_rs1_EX), .b(alu_rs2_EX), .aluctrl(aluctrl_EX), .aluout(aluout_EX));

   //EX/MEM
   always @(posedge Clk_CPU)begin
        regwrite_EX_MEM  <= regwrite_EX;    //for WB stage
        aluout_EX_MEM    <= aluout_EX;
        writedata_EX_MEM <= alu_rs2_temp_EX;
        memtoreg_EX_MEM  <= memtoreg_EX;    //for load
        lwhb_EX_MEM      <= lwhb_ID_EX;     //for load type
        swhb_EX_MEM      <= swhb_ID_EX;     //for store type
        lunsigned_EX_MEM <= lunsigned_ID_EX;
        rd_EX_MEM        <= rd_EX;
        memwrite_EX_MEM  <= memwrite_ID_EX; //for store
   end
   
    //MEM
    assign dmemaddr_MEM = aluout_EX_MEM;
    assign writedata_MEM = writedata_EX_MEM;
    assign memwrite_MEM  = memwrite_EX_MEM;
    assign lwhb_MEM      = lwhb_EX_MEM;
    assign swhb_MEM      = swhb_EX_MEM;
    assign lunsigned_MEM = lunsigned_EX_MEM;
    assign rd_MEM        = rd_EX_MEM;
    assign regwrite_MEM  = regwrite_EX_MEM;
    assign memtoreg_MEM  = memtoreg_EX_MEM;

   dmem U_dmem(.clk(Clk_CPU), .we(memwrite_MEM), .a(dmemaddr_MEM), .wd(writedata_MEM),
            .lwhb(lwhb_MEM), .swhb(swhb_MEM), .lunsigned(lunsigned_MEM), .rd(readdata_MEM));

    //MEM/WB
    always @(posedge Clk_CPU)begin
        readdata_MEM_WB  <= readdata_MEM;
        writedata_MEM_WB <= dmemaddr_MEM;
        regwrite_MEM_WB  <= regwrite_MEM;
        memtoreg_MEM_WB  <= memtoreg_MEM;
        rd_MEM_WB        <= rd_MEM;
   end

   //WB
   assign regwrite_WB      = regwrite_MEM_WB;
   assign writedata_rs2_WB = readdata_MEM_WB;
   assign writedata_rs1_WB = writedata_MEM_WB;
   assign memtoreg_WB      = memtoreg_MEM_WB;
   assign rd_WB            = rd_MEM_WB;
   mux2 mux_MemtoReg(.CTRL(memtoreg_WB), .rs1(writedata_rs1_WB), .rs2(writedata_rs2_WB), .rd(writedata_WB));//from alu or mem

endmodule
