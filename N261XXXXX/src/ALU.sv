module ALU(
     input [31:0] rs1,
     input [31:0] rs2,
     input [4:0]  ALUCtrl,
     input [63:0] instret, 
     input [63:0]   cycle,
     output reg zeroFlag,
     output reg [31:0] ALU_out

);


localparam [4:0]    ALU_ADD        = 5'b00000,
                    ALU_SUB         = 5'b00001,
                    ALU_SLL         = 5'b00010,
                    ALU_SLT         = 5'b00011,
                    ALU_SLTU        = 5'b00100,
                    ALU_XOR         = 5'b00101,
                    ALU_SRL         = 5'b00110,
                    ALU_SRA         = 5'b00111,
                    ALU_OR          = 5'b01000,
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
                    ALU_MULHU       = 5'b11001;
                    


     wire signed [31:0] signed_rs1;
     wire signed [31:0] signed_rs2;
     wire  [31:0] sum;
     wire  [63:0] pro_uu;
     wire  [63:0] pro_ss;
     wire  [63:0] pro_su;


     assign signed_rs1 = rs1;
     assign signed_rs2 = rs2;
     assign sum        = rs1+rs2; 
     assign pro_uu     = rs1*rs2;
     assign pro_ss     = signed_rs1*signed_rs2;
     assign pro_su     = signed_rs1*$signed({1'b0,rs2});


     always_comb begin
     case (ALUCtrl)
          ALU_ADD    :     ALU_out = sum;
          ALU_SUB    :     ALU_out = rs1 - rs2;
          ALU_SLL    :     ALU_out = rs1 << rs2[4:0];
          ALU_SLT    :     ALU_out = (signed_rs1 < signed_rs2) ? 32'b1:32'b0;     
          ALU_SLTU   :     ALU_out = (rs1 < rs2) ? 32'b1:32'b0;
          ALU_XOR    :     ALU_out = rs1 ^ rs2;
          ALU_SRL    :     ALU_out = rs1 >> rs2[4:0];
          ALU_SRA    :     ALU_out = signed_rs1 >>> rs2[4:0];
          ALU_OR     :     ALU_out = rs1 | rs2;
          ALU_AND    :     ALU_out = rs1 & rs2;
          ALU_JALR   :     ALU_out = {sum[31:1],1'b0};
          ALU_IMM    :     ALU_out = rs2;
          ALU_INSTRH :     ALU_out = instret[63:32];          
          ALU_INSTR  :     ALU_out = instret[31:0];
          ALU_CYCLEH :     ALU_out = cycle[63:32];
          ALU_CYCLE  :     ALU_out = cycle[31:0];
          ALU_MUL    :     ALU_out = pro_uu[31:0];
          ALU_MULH   :     ALU_out = pro_ss[63:32];
          ALU_MULHSU :     ALU_out = pro_su[63:32];
          ALU_MULHU  :     ALU_out = pro_uu[63:32];
          default :    ALU_out = 32'b0;
     endcase
     end

     always_comb begin
     case (ALUCtrl)      
     
          ALU_BEQ :    zeroFlag =  (rs1 == rs2) ? 1'b1 : 1'b0;
          ALU_BNE :    zeroFlag =  (rs1 != rs2) ? 1'b1 : 1'b0;
          ALU_BLT :    zeroFlag =  (signed_rs1  < signed_rs2) ? 1'b1 : 1'b0; 
          ALU_BGE :    zeroFlag =  (signed_rs1 >= signed_rs2) ? 1'b1 : 1'b0;
          ALU_BLTU:    zeroFlag =  (rs1 <  rs2) ? 1'b1 : 1'b0;
          default:    zeroFlag =  (rs1 >= rs2) ? 1'b1 : 1'b0;
          
     
     endcase

     end






endmodule