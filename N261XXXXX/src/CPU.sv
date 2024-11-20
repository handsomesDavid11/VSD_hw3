`include "ID.sv"
`include "IF.sv"
`include "EXE.sv"
`include "MEM.sv"
`include "WB.sv"
`include "HazardCtrl.sv"
`include "SRAM_wrapper.sv"
`include "ForwardingUnit.sv"
`include "CSR.sv"
//`include "AXI_define.svh"

module CPU(
     input clk,
     input rst,

     //IF1 
     //send instrtion address
     output logic instr_read,
     output logic [31:0] instr_addr,
     //receive 
     input [31:0] instr_out,

     //mem
     //send
     output logic data_read,
     output logic data_write,
     output logic [3:0] write_type,
     output logic [31:0] data_addr,
     output logic [31:0] data_in,
     

     //receive
     input [31:0] Dout,

     //stall
     input IM_stall,
     input DM_stall


);



     //IM DM stall
     logic IDEXE_RegWrite;
     logic EXEMEM_RegWrite;
     logic MEMWB_RegWrite;








//------------------------ the wire of IF------------------------//

     wire [1:0] BranchCtrl;
     wire [31:0] pc_imm;
     wire [31:0] pc_immrs1;
     wire InstrFlush;
     wire IFID_RegWrite;
     wire PC_write;
     //wire [31:0] instr_out;
     wire [31:0] IF_pc_out;
     wire [31:0] IF_instr_out;
     wire [31:0] pc_out;
     wire [4:0]  ID_rs1_addr;
     wire [4:0]  ID_rs2_addr;
     wire [4:0]  ID_rd_addr;
     wire CtrlSignalFlush;
     wire [4:0]  rs1_addr;
     wire [4:0]  rs2_addr;
     logic [63:0] cycle; 
     logic [63:0] instret;
IF1 IF1(
    .clk(clk),  
    .rst(rst),
    .BranchCtrl(BranchCtrl),               
    .pc_imm(pc_imm),
    .pc_immrs1(pc_immrs1),
     //data hazard
    .InstrFlush(InstrFlush),               
    .IFID_RegWrite(IFID_RegWrite),         
    .PC_write(PC_write),       
     //IM output
    .instr_out(instr_out),                 

    //output
    .IF_pc_out(IF_pc_out),                 //if register output
    .IF_instr_out(IF_instr_out),           //if register output
    .pc_out(pc_out)                        // to memory
);




//----------------------------ID state-------------------------------//
     wire [31:0]  WB_rd_data;
     wire [4:0]   WB_rd_addr;
     wire         WB_RegWrite;
     wire         WB_FRegWrite;
     
     wire [31:0] ID_rs1;
     wire [31:0] ID_rs2;
     wire [31:0] ID_pc_out;
     wire [2:0]  ID_funct3;
     wire [4:0]  ID_funct5;
     wire [6:0]  ID_funct7;
     wire [31:0] wire_mem_rd_data;

     wire [31:0] ID_imm;

     wire [2:0] ID_ALUOp;
     wire ID_PCtoRegSrc;
     wire ID_ALUSrc;
     wire ID_RDSrc;
     wire ID_MemtoReg;
     wire ID_MemWrite;
     wire ID_MemRead;
     wire ID_RegWrite;
     wire ID_FRegWrite;
     wire [1:0] ID_Branch; 
     wire ID_ALUSel;
     wire Rs1Sel;
     wire Rs2Sel;
     wire [11:0] wire_imm;

ID ID(
     .clk(clk),
     .rst(rst),

     .IF_pc_out(IF_pc_out),
     .IF_instr_out(IF_instr_out),
     .WB_rd_data(WB_rd_data),
     .WB_rd_addr(WB_rd_addr),  
     .WB_RegWrite(WB_RegWrite),
     .WB_FRegWrite(WB_FRegWrite),
     .CtrlSignalFlush(CtrlSignalFlush),
     //output
     .ID_rs1(ID_rs1),
     .ID_rs2(ID_rs2),
     .ID_pc_out(ID_pc_out),
     .ID_funct3(ID_funct3),
     .ID_funct5(ID_funct5),
     .ID_funct7(ID_funct7),
     .ID_rs1_addr(ID_rs1_addr),
     .ID_rs2_addr(ID_rs2_addr),
     .ID_rd_addr(ID_rd_addr),
     .ID_imm(ID_imm),   
     //control unit
     .ID_ALUOp(ID_ALUOp),
     .ID_PCtoRegSrc(ID_PCtoRegSrc),
     .ID_ALUSrc(ID_ALUSrc),
     .ID_RDSrc(ID_RDSrc),
     .ID_MemtoReg(ID_MemtoReg),
     .ID_MemWrite(ID_MemWrite),
     .ID_MemRead(ID_MemRead),
     .ID_RegWrite(ID_RegWrite),
     .ID_Branch(ID_Branch),
     .ID_ALUSel(ID_ALUSel),
     .ID_FRegWrite(ID_FRegWrite),
     .imm(wire_imm),
     .Rs1Sel(Rs1Sel),
     .Rs2Sel(Rs2Sel),
     //address
     .rs1_addr(rs1_addr),
     .rs2_addr(rs2_addr),
     .IDEXE_RegWrite(IDEXE_RegWrite)


);
     wire [31:0] EXE_pc_to_reg;
     wire [31:0] EXE_ALU_out;
     wire [31:0] EXE_rs2_data;
     wire [4:0] EXE_rd_addr;
     wire      EXE_RDSrc;
     wire      EXE_MemtoReg;
     wire      EXE_MemWrite;
     wire      EXE_MemRead;
     wire      EXE_RegWrite;
     wire      EXE_FRegWrite;

     wire [2:0] EXE_funct3;
     wire [1:0] FDSignal1;
     wire [1:0] FDSignal2;
     wire [1:0] F_FDSignal1;
     wire [1:0] F_FDSignal2;

//------------------------------------------------------------//
     wire MEM_MemtoReg;
     wire MEM_RegWrite;
     wire MEM_FRegWrite;
     wire [31:0] MEM_rd_data;
     wire [31:0] MEM_Dout;   
     wire [4:0] MEM_rd_addr;
   //  wire [31:0] Dout;
     wire wire_chip_select;  
     wire [3:0] wire_WE;     
     wire [31:0] wire_Din;




EXE EXE(
     .clk(clk),
     .rst(rst),
     .FDSignal1(FDSignal1),
     .FDSignal2(FDSignal2),
     .F_FDSignal1(F_FDSignal1),
     .F_FDSignal2(F_FDSignal2),
     .MEM_rd_data(wire_mem_rd_data),
     .WB_rd_data(WB_rd_data),
     .imm(wire_imm),
     .ID_rs1(ID_rs1),
     .ID_rs2(ID_rs2),
     .ID_pc_out(ID_pc_out),
     .ID_imm(ID_imm), 
     .ID_funct3(ID_funct3),
     .ID_funct5(ID_funct5),
     .ID_funct7(ID_funct7),
     .ID_rs1_addr(ID_rs1_addr),
     .ID_rs2_addr(ID_rs2_addr),
     .ID_rd_addr(ID_rd_addr),

     //control unit
     .ID_ALUOp(ID_ALUOp),
     .ID_PCtoRegSrc(ID_PCtoRegSrc),
     .ID_ALUSrc(ID_ALUSrc),
     .ID_RDSrc(ID_RDSrc),
     .ID_MemtoReg(ID_MemtoReg),
     .ID_MemWrite(ID_MemWrite),
     .ID_MemRead(ID_MemRead),
     .ID_RegWrite(ID_RegWrite),
     .ID_Branch(ID_Branch),
     .ID_FRegWrite(ID_FRegWrite),
     .ID_ALUSel(ID_ALUSel),
     //CSR input
     .cycle(cycle),
     .instret(instret),
     
     //output
     .EXE_pc_to_reg(EXE_pc_to_reg),
     .EXE_ALU_out(EXE_ALU_out),
     .EXE_rs2_data(EXE_rs2_data),
     .EXE_rd_addr(EXE_rd_addr),
     .EXE_RDSrc(EXE_RDSrc),
     .EXE_MemtoReg(EXE_MemtoReg),
     .EXE_MemWrite(EXE_MemWrite),
     .EXE_MemRead(EXE_MemRead),
     .EXE_RegWrite(EXE_RegWrite),
     .EXE_FRegWrite(EXE_FRegWrite),
     .wire_BranchCtrl(BranchCtrl),
     .EXE_funct3(EXE_funct3),
     .pc_imm(pc_imm),
     .pc_immrs1(pc_immrs1),
     .EXEMEM_RegWrite(EXEMEM_RegWrite)
);



MEM MEM(
     .clk(clk),
     .rst(rst),
     .EXE_RDSrc(EXE_RDSrc),
     .EXE_MemtoReg(EXE_MemtoReg),
     .EXE_MemWrite(EXE_MemWrite),
     .EXE_MemRead(EXE_MemRead),
     .EXE_RegWrite(EXE_RegWrite),
     .EXE_FRegWrite(EXE_FRegWrite),
     .EXE_pc_to_reg(EXE_pc_to_reg),
     .EXE_ALU_out(EXE_ALU_out),
     .EXE_rs2_data(EXE_rs2_data),
     .EXE_rd_addr(EXE_rd_addr),
     .EXE_funct3(EXE_funct3),
     //output
     .MEM_MemtoReg(MEM_MemtoReg),
     .MEM_RegWrite(MEM_RegWrite),
     .MEM_FRegWrite(MEM_FRegWrite),
     .MEM_rd_data(MEM_rd_data),    
     .MEM_Dout(MEM_Dout),    
     .MEM_rd_addr(MEM_rd_addr),

     //DM
     .Dout(Dout),
     .wire_chip_select(wire_chip_select),                    
     .wire_WE(wire_WE),                  
     .wire_Din(wire_Din) ,
     .wire_mem_rd_data(wire_mem_rd_data),
     .MEMWB_RegWrite(MEMWB_RegWrite)         

);



WB WB(
     .clk(clk),
     .rst(rst),
     .MEM_MemtoReg(MEM_MemtoReg),
     .MEM_RegWrite(MEM_RegWrite),
     .MEM_FRegWrite(MEM_FRegWrite),
     .MEM_rd_data(MEM_rd_data), //up    
     .MEM_Dout(MEM_Dout),    //data from data mem
     .MEM_rd_addr(MEM_rd_addr),
     //out    
     .WB_RegWrite(WB_RegWrite),
     .WB_FRegWrite(WB_FRegWrite),
     .WB_rd_data(WB_rd_data),
     .WB_rd_addr(WB_rd_addr)
);

//--------------------------hazardCtrl--------------------------//


ForwardingUnit ForwardingUnit(
     .MEM_RegWrite(MEM_RegWrite),
     .EXE_RegWrite(EXE_RegWrite),
     .EXE_FRegWrite(EXE_FRegWrite),
     .MEM_FRegWrite(MEM_FRegWrite),
     .Rs1Sel(Rs1Sel),
     .Rs2Sel(Rs2Sel),


     .rs1_addr(ID_rs1_addr),
     .rs2_addr(ID_rs2_addr),

     .MEM_rd_addr(MEM_rd_addr), 
     .EXE_rd_addr(EXE_rd_addr),
     .FDSignal1(FDSignal1),
     .FDSignal2(FDSignal2),
     .F_FDSignal1(F_FDSignal1),
     .F_FDSignal2(F_FDSignal2)

);

CSR CSR(
     .clk(clk),
     .rst(rst),
     .ID_MemRead(ID_MemRead),
     .ID_rd_addr(ID_rd_addr),
     .rs1_addr(rs1_addr),
     .rs2_addr(rs2_addr),
     .BranchCtrl(BranchCtrl),
     .cycle(cycle),
     .IM_stall(IM_stall),
     .DM_stall(DM_stall),
     .instret(instret)
    

);

HazardCtrl HazardCtrl(
     .ID_MemRead(ID_MemRead),
     .ID_rd_addr(ID_rd_addr),
     .ID_FRegWrite(ID_FRegWrite),
     .Rs1Sel(Rs1Sel),
     .Rs2Sel(Rs2Sel),
     .rs1_addr(rs1_addr),
     .rs2_addr(rs2_addr),
     .BranchCtrl(BranchCtrl),
     //output
     .PC_write(PC_write),
     .instrFlush(InstrFlush),
     .IFID_RegWrite(IFID_RegWrite),
     .CtrlSignalFlush(CtrlSignalFlush),

     .IM_stall(IM_stall),
     .IDEXE_RegWrite(IDEXE_RegWrite),
     .DM_stall(DM_stall),
     .EXEMEM_RegWrite(EXEMEM_RegWrite),
     .MEMWB_RegWrite(MEMWB_RegWrite)
);







     assign WEB          = EXE_MemWrite;
     assign BWEB         = wire_WE;
     assign CEB          = wire_chip_select;
     assign write_type   = wire_WE;
     assign data_addr    = EXE_ALU_out;
     assign data_in      = wire_Din;
     //
     assign instr_read   = 1'b1;
     assign data_read    = EXE_MemRead;
     assign data_write   = EXE_MemWrite;
     assign instr_addr   = pc_out;


endmodule