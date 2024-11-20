`include "RegisterFile.sv"
`include "ImmediateGenerator.sv"
`include "controlUnit.sv"

module ID(
     input clk,
     input rst,

     input [31:0]     IF_pc_out,
     input [31:0]     IF_instr_out,
     input [31:0]     WB_rd_data,
     input [4:0]      WB_rd_addr,
     input            WB_RegWrite,
     input            WB_FRegWrite,


     

     input CtrlSignalFlush,

     //data  
     output reg [31:0] ID_rs1,
     output reg [31:0] ID_rs2,

     output reg [31:0] ID_pc_out,
     output reg [2:0]  ID_funct3,
     output reg [4:0]  ID_funct5,
     output reg [6:0]  ID_funct7,
     output reg [4:0]  ID_rs1_addr,
     output reg [4:0]  ID_rs2_addr,
     output reg [4:0]  ID_rd_addr,
     output reg [31:0] ID_imm,
     //control unit
     output reg [2:0] ID_ALUOp,
     output reg ID_PCtoRegSrc,
     output reg ID_ALUSrc,
     output reg ID_RDSrc,
     output reg ID_MemtoReg,
     output reg ID_MemWrite,
     output reg ID_MemRead,
     output reg ID_RegWrite,
     output reg ID_FRegWrite,
     output reg ID_ALUSel,
     output reg [1:0] ID_Branch,

     output logic [11:0] imm,
     output logic Rs1Sel,
     output logic Rs2Sel,
     output logic [4:0] rs1_addr,
     output logic [4:0] rs2_addr,
     input IDEXE_RegWrite

);
     
     assign rs1_addr = IF_instr_out[19:15];
     assign rs2_addr = IF_instr_out[24:20];

     //assign ID_pc_out <= IF_pc_out; //
     //assign ID_rs1_addr = IF_instr_out[19:15];
     //assign ID_rs2_addr = IF_instr_out[24:20];

     //register output
     wire [31:0] wire_rs1,wire_rs2;
     // immediate generator
     wire [31:0] wire_imm;

     wire [2:0] wire_ALUOP;
     wire wire_PCtoRegSrc;
     wire wire_RDSrc;
     wire wire_ALUSrc;
     wire wire_MemtoReg;
     wire wire_MemWrite;
     wire wire_MemRead;
     wire wire_RegWrite;
     wire [1:0] wire_Branch;
     //the wire of floating register 
     //wire [4:0] WB_Frd_addr;
     //wire [31:0] WB_Frd_data;
     wire [31:0] wire_Frs1;
     wire [31:0] wire_Frs2;
     wire wire_ALUSel;
     wire wire_Rs1Sel;
     wire wire_Rs2Sel;



     RegisterFile FRegisterFile(
          .clk(clk),
          .rst(rst),
          .reg_write(WB_FRegWrite),

          .rs1_addr(IF_instr_out[19:15]),
          .rs2_addr(IF_instr_out[24:20]),
          .WB_rd_addr(WB_rd_addr),
          .WB_rd_data(WB_rd_data),
          //output
          .rs1_data(wire_Frs1),
          .rs2_data(wire_Frs2)
     );
 


     RegisterFile RegisterFile(
          .clk(clk),
          .rst(rst),
          .reg_write(WB_RegWrite),

          .rs1_addr(IF_instr_out[19:15]),
          .rs2_addr(IF_instr_out[24:20]),
          .WB_rd_addr(WB_rd_addr),
          .WB_rd_data(WB_rd_data),
          //output
          .rs1_data(wire_rs1),
          .rs2_data(wire_rs2)
     );




     //immediate control wire
     wire [2:0] wire_imm_type;

     ImmediateGenerator ImmediateGenerator(
          .imm_type(wire_imm_type),
          .IF_instr_out(IF_instr_out),
          .imm(wire_imm)
     );
     controlUnit controlUnit(
          .opcode(IF_instr_out[6:0]),
          //output 
          
          .ImmType(wire_imm_type),
          .ALUOp(wire_ALUOP),
          .PCtoRegSrc(wire_PCtoRegSrc),
          .RDSrc(wire_RDSrc),
          .ALUSrc(wire_ALUSrc),
          .MemtoReg(wire_MemtoReg),
          .MemWrite(wire_MemWrite),
          .MemRead(wire_MemRead),
          .RegWrite(wire_RegWrite),
          .FRegWrite(wire_FRegWrite),
          .Rs1Sel(wire_Rs1Sel),
          .Rs2Sel(wire_Rs2Sel),
          .ALUSel(wire_ALUSel),
          .Branch(wire_Branch)

     );
          
     always_ff@(posedge clk or posedge rst)  begin
          if(rst) begin 

               ID_pc_out   <= 32'b0;
               ID_rs1      <= 32'b0;
               ID_rs2      <= 32'b0;
               ID_funct3   <= 3'b0;
               ID_funct5   <= 5'b0;
               ID_funct7   <= 7'b0;
               ID_rs1_addr <= 5'b0;
               ID_rs2_addr <= 5'b0;
               ID_rd_addr  <= 5'b0;
               ID_imm      <= 32'b0;
               Rs1Sel      <= 1'b0;
               Rs2Sel      <= 1'b0;
               imm         <= 12'b0;

               

               //the wires of control unit

               ID_ALUOp       <= 3'b0;
               ID_PCtoRegSrc  <= 1'b0;
               ID_ALUSrc      <= 1'b0;
               ID_RDSrc       <= 1'b0;
               ID_MemtoReg    <= 1'b0;
               ID_MemWrite    <= 1'b0;
               ID_MemRead     <= 1'b0;
               ID_RegWrite    <= 1'b0;
               ID_Branch      <= 2'b0;
               ID_ALUSel      <= 1'b0;
               ID_FRegWrite   <= 1'b0;
              
          end
          else     begin
               if(IDEXE_RegWrite) begin
                    ID_rs1_addr <= IF_instr_out[19:15];
                    ID_rs2_addr <= IF_instr_out[24:20];
                    imm         <= IF_instr_out[31:20];

                    if(wire_Rs1Sel)
                         ID_rs1 <= wire_Frs1;
                    else
                         ID_rs1 <= wire_rs1;

                    if(wire_Rs2Sel)
                         ID_rs2 <= wire_Frs2;
                    else
                         ID_rs2 <= wire_rs2;


                    ID_pc_out   <= IF_pc_out;
                    ID_funct3   <= IF_instr_out[14:12];
                    ID_funct5   <= IF_instr_out[31:27];
                    ID_funct7   <= IF_instr_out[31:25];
                    ID_rd_addr  <= IF_instr_out[11:7];
                    ID_imm      <= wire_imm;
                    Rs1Sel      <= wire_Rs1Sel;
                    Rs2Sel      <= wire_Rs2Sel;

                    //control unit output
                    ID_ALUOp       <= wire_ALUOP;
                    ID_PCtoRegSrc  <= wire_PCtoRegSrc;
                    ID_ALUSrc      <= wire_ALUSrc;
                    ID_RDSrc       <= wire_RDSrc;
                    ID_MemtoReg    <= wire_MemtoReg;

                    ID_MemWrite   <= (CtrlSignalFlush) ? 1'b0 : wire_MemWrite;
                    ID_MemRead    <= (CtrlSignalFlush) ? 1'b0 : wire_MemRead;
                    ID_RegWrite   <= (CtrlSignalFlush) ? 1'b0 : wire_RegWrite;
                    ID_Branch     <= (CtrlSignalFlush) ? 2'b0 : wire_Branch;
                    ID_ALUSel     <=(CtrlSignalFlush) ? 1'b0 : wire_ALUSel;
                    ID_FRegWrite  <= (CtrlSignalFlush) ? 1'b0 : wire_FRegWrite;
               end
               else if ((~IDEXE_RegWrite) & CtrlSignalFlush) begin // IM stall
                    ID_MemWrite <= 1'b0;
                    ID_MemRead  <= 1'b0;
                    ID_RegWrite <= 1'b0;
               end
          end
          end



     


endmodule