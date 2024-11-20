module controlUnit(
     input [6:0]opcode,


     output reg [2:0] ImmType,
     output reg [2:0] ALUOp,

     output reg PCtoRegSrc,
     output reg RDSrc,
     output reg ALUSrc,
     output reg MemtoReg,
     output reg MemWrite,
     output reg MemRead,
     output reg RegWrite,
     output logic Rs1Sel,
     output logic Rs2Sel,
     output logic ALUSel,
     output logic FRegWrite,

     output reg [1:0] Branch
);
//------------------------the state of immediate---------------------------//
     localparam [2:0]    I_Imm = 3'b000,
                         S_Imm = 3'b001,
                         B_Imm = 3'b010,
                         U_Imm = 3'b011,
                         J_Imm = 3'b100;
//-------------------------the state of ALUOP------------------------------//
     localparam [2:0]    R_type      = 3'b000,
                         I_type      = 3'b001,
                         ADD_type    = 3'b010,
                         JALR_type =   3'b011,
                         B_type      = 3'b100,
                         LUI_type    = 3'b101,
                         CSR_type    = 3'b110,
                         F_type      = 3'b111;
                         

//-------------------------the state of branch control---------------------//
     localparam [1:0]    None_branch = 2'b00,
                         JALR_branch = 2'b01,
                         B_branch    = 2'b10,
                         J_branch    = 2'b11;

//---------------According opcode to output control signal----------------//
     always_comb begin
     case (opcode)

//----------------------------FADD--------------------------------//
          7'b1010011:begin
               ImmType    = I_Imm;
               ALUOp      = F_type;
               PCtoRegSrc = 1'b0;   
               ALUSrc     = 1'b1;   
               RDSrc      = 1'b0;   
               MemtoReg   = 1'b0;
               MemWrite   = 1'b0;
               MemRead    = 1'b0;
               RegWrite   = 1'b0;
               Rs1Sel     = 1'b1;
               Rs2Sel     = 1'b1;
               ALUSel     = 1'b1;
               FRegWrite  = 1'b1;
               Branch     = None_branch;
          end

//-----------------------------FLW  --------------------------------//
          7'b0000111:begin
               ImmType    = I_Imm;
               ALUOp      = ADD_type;
               PCtoRegSrc = 1'b0;   
               ALUSrc     = 1'b0;   
               RDSrc      = 1'b0;   
               MemtoReg   = 1'b1;
               MemWrite   = 1'b0;
               MemRead    = 1'b1;
               RegWrite   = 1'b0;
               Rs1Sel     = 1'b0;
               Rs2Sel     = 1'b0;
               ALUSel     = 1'b0;
               FRegWrite  = 1'b1;
               Branch     = None_branch;
          end
//------------------------------ FSW   --------------------------------//
          7'b0100111: begin
               ImmType    = S_Imm;
               ALUOp      = ADD_type;
               PCtoRegSrc = 1'b0;   //don't care
               ALUSrc     = 1'b0;   
               RDSrc      = 1'b0;   //don't care
               MemtoReg   = 1'b0;
               MemWrite   = 1'b1;
               MemRead    = 1'b0;
               RegWrite   = 1'b0;
               Rs1Sel     = 1'b0;
               Rs2Sel     = 1'b1;
               ALUSel     = 1'b0;
               FRegWrite  = 1'b0;
               Branch     = None_branch;
          end




          //R_type
          7'b0110011:begin
               ImmType    = I_Imm;  //don't care
               ALUOp      = R_type;
               PCtoRegSrc = 1'b0;   //don't care
               ALUSrc     = 1'b1;   // reg
               RDSrc      = 1'b0;   // ALU
               MemtoReg   = 1'b0;
               MemWrite   = 1'b0;
               MemRead    = 1'b0;
               RegWrite   = 1'b1;
               Rs1Sel     = 1'b0;
               Rs2Sel     = 1'b0;
               ALUSel     = 1'b0;
               FRegWrite  = 1'b0;

               Branch     = None_branch;

          end

               

          //LW and LB
          7'b0000011:begin
               ImmType    = I_Imm;
               ALUOp      = ADD_type;
               PCtoRegSrc = 1'b0;   //don't care
               ALUSrc     = 1'b0;   
               RDSrc      = 1'b0;   //don't care
               MemtoReg   = 1'b1;
               MemWrite   = 1'b0;
               MemRead    = 1'b1;
               RegWrite   = 1'b1;
               Rs1Sel     = 1'b0;
               Rs2Sel     = 1'b0;
               ALUSel     = 1'b0;
               FRegWrite  = 1'b0;
               Branch     = None_branch;
          end
          //I_type
          7'b0010011:begin
               ImmType    = I_Imm;
               ALUOp      = I_type;
               PCtoRegSrc = 1'b0;   //don't care
               ALUSrc     = 1'b0;   
               RDSrc      = 1'b0;   
               MemtoReg   = 1'b0;
               MemWrite   = 1'b0;
               MemRead    = 1'b0;
               RegWrite   = 1'b1;
               Rs1Sel     = 1'b0;
               Rs2Sel     = 1'b0;
               ALUSel     = 1'b0;
               FRegWrite  = 1'b0;
               Branch     = None_branch;
          end

          //JALR !!!!!!!
          7'b1100111:begin
               ImmType    = I_Imm;
               ALUOp      = JALR_type;
               PCtoRegSrc = 1'b0;   //don't care
               ALUSrc     = 1'b0;   
               RDSrc      = 1'b1;   //don't care
               MemtoReg   = 1'b0;
               MemWrite   = 1'b0;
               MemRead    = 1'b0;
               RegWrite   = 1'b1;
               Rs1Sel     = 1'b0;
               Rs2Sel     = 1'b0;
               ALUSel     = 1'b0;
               FRegWrite  = 1'b0;
               Branch     = JALR_branch;
          
          end

          //S_type ok
          7'b0100011: begin
               ImmType    = S_Imm;
               ALUOp      = ADD_type;
               PCtoRegSrc = 1'b0;   //don't care
               ALUSrc     = 1'b0;   
               RDSrc      = 1'b0;   //don't care
               MemtoReg   = 1'b0;
               MemWrite   = 1'b1;
               MemRead    = 1'b0;
               RegWrite   = 1'b0;
               Rs1Sel     = 1'b0;
               Rs2Sel     = 1'b0;
               ALUSel     = 1'b0;
               FRegWrite  = 1'b0;
               Branch     = None_branch;
          end

          //B_type
          7'b1100011: begin
               ImmType    = B_Imm;
               ALUOp      = B_type;
               PCtoRegSrc = 1'b0;   //don't care
               ALUSrc     = 1'b1;   
               RDSrc      = 1'b0;   //don't care
               MemtoReg   = 1'b0;
               MemWrite   = 1'b0;
               MemRead    = 1'b0;
               RegWrite   = 1'b0;
               Rs1Sel     = 1'b0;
               Rs2Sel     = 1'b0;
               ALUSel     = 1'b0;
               FRegWrite  = 1'b0;
               Branch     = B_branch;

          end


//--------------------AUIPC---------------------//
          7'b0010111: begin
               ImmType    = U_Imm;
               ALUOp      = ADD_type;//don't care
               PCtoRegSrc = 1'b1;   
               ALUSrc     = 1'b0;   //don't care
               RDSrc      = 1'b1;   
               MemtoReg   = 1'b0;
               MemWrite   = 1'b0;
               MemRead    = 1'b0;
               RegWrite   = 1'b1;
               Rs1Sel     = 1'b0;
               Rs2Sel     = 1'b0;
               ALUSel     = 1'b0;
               FRegWrite  = 1'b0;
               Branch     = None_branch;


          end
//-----------------------LUI-----------------------//
          7'b0110111:begin
               ImmType    = U_Imm;
               ALUOp      = LUI_type;
               PCtoRegSrc = 1'b0;   //don't care
               ALUSrc     = 1'b0;   
               RDSrc      = 1'b0;   
               MemtoReg   = 1'b0;
               MemWrite   = 1'b0;
               MemRead    = 1'b0;
               RegWrite   = 1'b1;
               Rs1Sel     = 1'b0;
               Rs2Sel     = 1'b0;
               ALUSel     = 1'b0;
               FRegWrite  = 1'b0;
               Branch     = None_branch;
          
          end

//----------------------J_type---------------------//
          7'b1101111:begin
               ImmType    = J_Imm;
               ALUOp      = ADD_type; //don't care
               PCtoRegSrc = 1'b0;   //pc+4 
               ALUSrc     = 1'b0;   //don't care
               RDSrc      = 1'b1;   
               MemtoReg   = 1'b0;   
               MemWrite   = 1'b0;
               MemRead    = 1'b0;  
               RegWrite   = 1'b1; 
               Rs1Sel     = 1'b0;
               Rs2Sel     = 1'b0;
               ALUSel     = 1'b0;
               FRegWrite  = 1'b0; 
               Branch     = J_branch;
          end
//----------------------CSR_type---------------------//
          7'b1110011:begin
               ImmType    = I_Imm;
               ALUOp      = CSR_type; //don't care
               PCtoRegSrc = 1'b0;   
               ALUSrc     = 1'b0;   //don't care
               RDSrc      = 1'b0;   
               MemtoReg   = 1'b0;   
               MemWrite   = 1'b0;
               MemRead    = 1'b0;  
               RegWrite   = 1'b1; 
               Rs1Sel     = 1'b0;
               Rs2Sel     = 1'b0;
               ALUSel     = 1'b0;
               FRegWrite  = 1'b0; 
               Branch     = None_branch;
          end



          default: begin
               ImmType    = I_Imm;
               ALUOp      = ADD_type;  
               PCtoRegSrc = 1'b0;  
               ALUSrc     = 1'b0;  
               RDSrc      = 1'b0; 
               MemtoReg   = 1'b0;
               MemWrite   = 1'b0;
               MemRead    = 1'b0;
               RegWrite   = 1'b0;
               Rs1Sel     = 1'b0;
               Rs2Sel     = 1'b0;
               ALUSel     = 1'b0;
               FRegWrite  = 1'b0;
               Branch     = None_branch;
          end
     endcase
     end



endmodule