module ALU_ctrl(
     input  [2:0]  ALUOp,
     input  [2:0]  funct3,
     input  [4:0]  funct5,
     input  [6:0]  funct7,
     input  [11:0] imm,
     output logic [4:0] ALUCtrl,
     output logic FALUCtrl

);
     localparam          FADD        =1'b0,  
                         FSUB        =1'b1;       


     localparam [2:0]    R_type      = 3'b000,
                         I_type      = 3'b001,
                         ADD_type    = 3'b010,
                         JALR_type   = 3'b011,
                         B_type      = 3'b100,
                         LUI_type    = 3'b101,
                         CSR_type    = 3'b110,
                         F_type      = 3'b111;

     localparam [4:0]    ALU_ADD        = 5'b00000,
                         ALU_SUB         = 5'b00001,
                         ALU_SLL         = 5'b00010,
                         ALU_SLT         = 5'b00011,
                         ALU_SLTU        = 5'b00100,
                         ALU_XOR         = 5'b00101,
                         ALU_SRL         = 5'b00110,
                         ALU_SRA         = 5'b00111,
                         ALU_OR          = 5'b01000,//8
                         ALU_AND         = 5'b01001,
                         ALU_JALR        = 5'b01010,
                         ALU_BEQ         = 5'b01011,
                         ALU_BNE         = 5'b01100,
                         ALU_BLT         = 5'b01101,
                         ALU_BGE         = 5'b01110,
                         ALU_BLTU        = 5'b01111,
                         ALU_BGEU        = 5'b10000,
                         ALU_IMM         = 5'b10001,
                         ALU_INSTRH      = 5'b10010,
                         ALU_INSTR       = 5'b10011,
                         ALU_CYCLEH      = 5'b10100,
                         ALU_CYCLE       = 5'b10101,
                         ALU_MUL         = 5'b10110,
                         ALU_MULH        = 5'b10111,
                         ALU_MULHSU      = 5'b11000,
                         ALU_MULHU       = 5'b11001
                         ;

     always_comb begin
     case (ALUOp)
          R_type:begin
               case (funct3) 
                    3'd0:
                         if(funct7 == 7'b0000000)
                              ALUCtrl = ALU_ADD;
                         else if(funct7 == 7'b0000001)
                              ALUCtrl = ALU_MUL;
                         else
                              ALUCtrl = ALU_SUB;
                    3'b001:
                         if(funct7 == 7'b0000001)
                              ALUCtrl = ALU_MULH;
                         else 
                              ALUCtrl = ALU_SLL;
                    3'b010:
                         if(funct7 == 7'b0000001)
                              ALUCtrl = ALU_MULHSU;
                         else
                              ALUCtrl = ALU_SLT;
                    3'b011:
                         if(funct7 == 7'b0000001)
                              ALUCtrl = ALU_MULHU;
                         else
                              ALUCtrl = ALU_SLTU;
                    3'b100:
                              ALUCtrl = ALU_XOR;
                    3'b101:
                         if(funct7 == 7'b0000000)
                              ALUCtrl = ALU_SRL;
                         else
                              ALUCtrl = ALU_SRA;
                    3'b110:
                              ALUCtrl = ALU_OR;
                    default:
                              ALUCtrl = ALU_AND;
                    
                    
               endcase
          end                                
          
          I_type:begin
               case(funct3)
                    3'b000:
                              ALUCtrl = ALU_ADD;
                    3'b010:
                              ALUCtrl = ALU_SLT;
                    3'b011:
                              ALUCtrl = ALU_SLTU;
                    3'b100:
                              ALUCtrl = ALU_XOR;
                    3'b110:
                              ALUCtrl = ALU_OR;
                    3'b111:
                              ALUCtrl = ALU_AND;
                    3'b001:
                              ALUCtrl = ALU_SLL;
                    default:
                         if(funct7 == 7'b0)
                              ALUCtrl = ALU_SRL;
                         else      
                              ALUCtrl = ALU_SRA;
               endcase
     
          end
          ADD_type: begin

                              ALUCtrl = ALU_ADD;

          end

          JALR_type: begin

                              ALUCtrl = ALU_JALR;

          end

          B_type: begin
               case(funct3)
                    3'b000:
                              ALUCtrl = ALU_BEQ;
                    3'b001:
                              ALUCtrl = ALU_BNE;
                    3'b100:
                              ALUCtrl = ALU_BLT;
                    3'b101:
                              ALUCtrl = ALU_BGE;
                    3'b110:
                              ALUCtrl = ALU_BLTU;
                    default:
                              ALUCtrl = ALU_BGEU;
               endcase
          end

          LUI_type: begin
                    
                              ALUCtrl = ALU_IMM;
          end

          CSR_type: begin
               case(imm)
               12'b110010000010:
                              ALUCtrl = ALU_INSTRH;
               12'b110000000010:
                              ALUCtrl = ALU_INSTR;
               12'b110010000000:
                              ALUCtrl = ALU_CYCLEH;
               default:
                              ALUCtrl = ALU_CYCLE;
               endcase
          end
          default: begin
               case(funct5)
               5'b00000:
                              FALUCtrl = 1'b0;
               default:
                              FALUCtrl = 1'b1;
               endcase
          end

     endcase

     end
  
endmodule