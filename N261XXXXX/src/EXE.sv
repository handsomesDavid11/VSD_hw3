`include "ALU_ctrl.sv"
`include "ALU.sv"
`include "FALU.sv"
`include "BranchCtrl.sv"


module EXE(
     input clk,
     input rst,
     input [1:0] FDSignal1,
     input [1:0] FDSignal2,
     input [1:0] F_FDSignal1,
     input [1:0] F_FDSignal2,

     input [31:0]   MEM_rd_data,
     input [31:0]   WB_rd_data,
     //data
     input [31:0]  ID_rs1,
     input [31:0]  ID_rs2,

     input [31:0]  ID_pc_out,
     input [31:0]  ID_imm, 

     input [2:0]   ID_funct3,
     input [4:0]   ID_funct5,
     input [6:0]   ID_funct7,
     input [4:0]   ID_rs1_addr,
     input [4:0]   ID_rs2_addr,
     input [4:0]   ID_rd_addr,

     //control signal wire 
     input [2:0]   ID_ALUOp,
     input         ID_PCtoRegSrc,
     input         ID_ALUSrc,
     input         ID_RDSrc,
     input         ID_MemtoReg,
     input         ID_MemWrite,
     input         ID_MemRead,
     input         ID_RegWrite,
     input [1:0]   ID_Branch,
     input         ID_FRegWrite,
     input         ID_ALUSel,

     input [11:0]  imm,
     input [63:0]  cycle,
     input [63:0]  instret,

     output reg [31:0] EXE_pc_to_reg,
     output reg [31:0] EXE_ALU_out,
     output reg [31:0] EXE_rs2_data,
     output reg [4:0] EXE_rd_addr,
     output reg      EXE_RDSrc,
     output reg      EXE_MemtoReg,
     output reg      EXE_MemWrite,
     output reg      EXE_MemRead,
     output reg      EXE_RegWrite,
     output reg      EXE_FRegWrite,
     output reg [1:0] wire_BranchCtrl,
     output reg [2:0] EXE_funct3,


     output reg [31:0] pc_imm,
     output reg [31:0] pc_immrs1,
     input EXEMEM_RegWrite


);


     wire wire_zeroFlag;
     wire [31:0] wire_ALU_out;
     wire [31:0] wire_FALU_out;
     wire [31:0] wire_pc_4;
     wire [31:0] wire_pc_imm;
     


//------------------------ pc+4 and pc+imm------------------------//
     assign wire_pc_4   = ID_pc_out + 4;
     assign wire_pc_imm = ID_pc_out + ID_imm;
     //mux 2  
//----------------- ID_pctoregsrc to chioce PC+4 or PC+imm--------?//
 
     assign pc_imm    = wire_pc_imm;
     assign pc_immrs1 = wire_ALU_out;
     assign zeroFlag  = wire_zeroFlag;



//-----------------------ALU src choice----------------------------//
     reg [31:0] ALUSrc1;
     reg [31:0] ALUSrc2;
     reg [31:0] wire_ALUSrc2;
     
     reg [31:0] F_ALUSrc1;
     reg [31:0] F_ALUSrc2;
   //assign  wire_ALUSrc2 = ID_rs2;
   //  assign  wire_ALUSrc2 = (ID_PCtoRegSrc) ? ID_rs2 : ID_imm;
     always_comb begin
          case(FDSignal1)
               2'b00:
                    ALUSrc1 = ID_rs1;
               2'b01:
                    ALUSrc1 = MEM_rd_data;
               default:
                    ALUSrc1 = WB_rd_data;
          endcase
     end

     always_comb begin
          case(FDSignal2)
               2'b00:
                    wire_ALUSrc2 = ID_rs2;
               2'b01:
                    wire_ALUSrc2 = MEM_rd_data;
               default:
                    wire_ALUSrc2 = WB_rd_data;//WB_rd_data
          endcase
     end
     assign  ALUSrc2 = (ID_ALUSrc) ?   wire_ALUSrc2:ID_imm;






//---------------------------ALU_control unit-----------------------//
     wire [2:0] wire_funct3;
     wire [4:0] wire_funct5;
     wire [6:0] wire_funct7;
     wire [2:0] wire_ALUOp;
     wire [4:0] wire_ALUCtrl;
     wire wire_FALUCtrl;
     // output
     


     assign wire_funct3 = ID_funct3;
     assign wire_funct5 = ID_funct5;

     assign wire_funct7 = ID_funct7;
     assign wire_ALUOp  = ID_ALUOp;

     ALU_ctrl ALU_ctrl(
          .ALUOp(wire_ALUOp),
          .imm(imm),
          .funct3(wire_funct3),
          .funct5(wire_funct5),
          .funct7(wire_funct7),
          .ALUCtrl(wire_ALUCtrl),
          .FALUCtrl(wire_FALUCtrl)
     );

     ALU ALU(
          .rs1(ALUSrc1),
          .rs2(ALUSrc2),
          .ALUCtrl(wire_ALUCtrl),
          .instret(instret), 
          .cycle(cycle),
          .zeroFlag(wire_zeroFlag),
          .ALU_out(wire_ALU_out)
     );

     FALU FALU(
          .rs1(ALUSrc1),
          .rs2(ALUSrc2),
          .FALUCtrl(wire_FALUCtrl),

          .ALU_out(wire_FALU_out)      



     );




     BranchCtrl BranchCtrl(
          .wire_zeroFlag(wire_zeroFlag),
          .Branch(ID_Branch),
          .BranchCtrl(wire_BranchCtrl)
     );



     always_ff @(posedge clk, posedge rst)begin
          if(rst) begin
               EXE_pc_to_reg <= 32'b0;
               EXE_ALU_out   <= 32'b0;
               EXE_rs2_data  <= 32'b0;
               EXE_rd_addr   <= 5'b0;
               EXE_funct3    <= 3'b0;

               EXE_RDSrc     <= 1'b0;
               EXE_MemtoReg  <= 1'b0;
               EXE_MemRead   <= 1'b0;
               EXE_MemWrite  <= 1'b0;
               EXE_RegWrite  <= 1'b0;
               EXE_FRegWrite  <= 1'b0;
          end   

          
          else begin
               if(EXEMEM_RegWrite)begin
                    if(ID_PCtoRegSrc)
                         EXE_pc_to_reg <=  wire_pc_imm;
                    else
                         EXE_pc_to_reg <=wire_pc_4;
                    
                    if(ID_ALUSel)
                         EXE_ALU_out   <= wire_FALU_out;
                    else
                         EXE_ALU_out   <= wire_ALU_out;
                    EXE_rs2_data  <= wire_ALUSrc2;

                    EXE_rd_addr   <= ID_rd_addr;
                    EXE_funct3    <= ID_funct3;

                    EXE_RDSrc     <= ID_RDSrc;
                    EXE_MemtoReg  <= ID_MemtoReg;
                    EXE_MemRead   <= ID_MemRead;
                    EXE_MemWrite  <= ID_MemWrite;
                    EXE_RegWrite  <= ID_RegWrite;
                    EXE_FRegWrite  <= ID_FRegWrite;
               end
          end   


     end


   

endmodule
