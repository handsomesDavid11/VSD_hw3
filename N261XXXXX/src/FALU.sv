`include "DiffShift.sv"

module FALU(
     input [31:0] rs1,
     input [31:0] rs2,
     input  FALUCtrl,


     output logic [31:0] ALU_out


);
// compare rs1 and rs2
     logic comp;
     logic operator;

     logic [31:0] oper1;
     logic [31:0] oper2;

     logic sign;

     logic [7:0]  exp1;
     logic [7:0]  exp2;
     logic [7:0]  exp2_1;
     logic [31:0] fra1;
     logic [31:0] fra2;
     logic [32:0] fra_add;


     logic [30:0] add_sum;



     logic [31:0] fra2_1;


     logic        sign1;
     logic        sign2;
     logic        round_up;
     logic [7:0]  exp_diff;

     

     logic [31:0] fra_sub_comple;
     logic [32:0] fra_sub;
     logic [32:0] sub_diff;
     logic [30:0] sub_result;
     logic [7:0] exp_sub;
     logic [4:0] shift;
     logic GuardBit;
     logic RoundBit;
     logic StickyBit;
     logic MBit; 
     logic RoundUp;
     logic SGuardBit;
     logic SRoundBit;
     logic SStickyBit;
     logic SMBit; 
     logic SRoundUp;
     logic  [30:0]    wire_add_sum;
     logic  [30:0]    wire_sub_result;
     
     //compare operand oper1 > oper2
     assign {comp,oper1,oper2}=(rs1[30:0]<rs2[30:0]) ? {1'b1,rs2,rs1} : {1'b0,rs1,rs2};
     
     //assign exp
     assign exp1 = oper1[30:23];
     assign exp2 = oper2[30:23];
     always_comb begin
          if(FALUCtrl)begin
               if(comp)
                    sign = ~oper1[31];
               else
                    sign = oper1[31];
          end
          else 
               sign = oper1[31];
     end
     
     always_comb begin
          if(FALUCtrl)
               operator = oper1[31]^oper2[31];
          else 
               operator = ~(oper1[31]^oper2[31]);
     end
     always_comb begin
          fra1 = (|oper1[30:23]) ? {1'b1,oper1[22:0],8'b0} : {1'b0,oper1[22:0],8'b0};
          fra2 = (|oper2[30:23]) ? {1'b1,oper2[22:0],8'b0} : {1'b0,oper2[22:0],8'b0};
          exp_diff  = oper1[30:23] - oper2[30:23];
          fra2_1    = fra2 >> exp_diff; //110011 -> 1100  shift = 2
          exp2_1    = oper2[30:23] + exp_diff;


     end
     always_comb begin
          if(operator) begin
               fra_add = fra1 +fra2_1;
               if(fra_add[32])begin
                    add_sum[22:0]  = fra_add[31:9];
                    MBit           = fra_add[9];
                    GuardBit       = fra_add[8];
                    RoundBit       = fra_add[7];
                    StickyBit      = |fra_add[6:0];

               end
               else begin
                    add_sum[22:0]  = fra_add[30:8];
                    MBit           = fra_add[8];
                    GuardBit       = fra_add[7];
                    RoundBit       = fra_add[6];
                    StickyBit      = |fra_add[5:0];
               end
               if(fra_add[32])begin
                    add_sum[30:23]  = 1'b1+oper1[30:23];

               end
               else begin
                    add_sum[30:23]  = oper1[30:23];

               end
               RoundUp = (GuardBit & ((RoundBit | StickyBit) | MBit)) ;
               if(RoundUp)
                    wire_add_sum = add_sum+31'b1;
               else
                    wire_add_sum = add_sum;
          end
          else begin
              fra_sub_comple = ~(fra2_1) +32'b1;
              fra_sub = fra1 + fra_sub_comple;

               // fra_sub is the result of the substration

              sub_result[30:23] = exp_sub;

              sub_result[22:0]  = sub_diff[30:8];

              SMBit              = sub_diff[8];
              SGuardBit          = sub_diff[7];
              SRoundBit          = sub_diff[6];
              SStickyBit         = |sub_diff[5:0];
          end

     end
     
     DiffShift DiffShift(fra_sub,oper1[30:23],sub_diff,exp_sub);



     assign    SRoundUp = (SGuardBit & ((SRoundBit | SStickyBit) | SMBit)) ;

     
     assign    wire_sub_result = (SRoundUp)? sub_result+31'b1:sub_result;
     
     
     
     assign ALU_out = (operator)? {sign,wire_add_sum}:{sign,wire_sub_result};


        
     
     
     






endmodule