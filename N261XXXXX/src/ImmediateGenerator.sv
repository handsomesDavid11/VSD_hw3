module ImmediateGenerator(
     input [2:0]imm_type,
     input [31:0] IF_instr_out,
     output reg [31:0] imm
);
     localparam [2:0] I_IMM=3'b000,
                       S_IMM=3'b001,
                       B_IMM=3'b010,
                       U_IMM=3'b011,
                       J_IMM=3'b100;

     always_comb begin
          case(imm_type)
               I_IMM:    imm = {{20{IF_instr_out[31]}},IF_instr_out[31:20]};
               S_IMM:    imm = {{20{IF_instr_out[31]}},IF_instr_out[31:25],IF_instr_out[11:7]};
               B_IMM:    imm = {{20{IF_instr_out[31]}},
                              IF_instr_out[31],
                              IF_instr_out[7],
                              IF_instr_out[30:25],
                              IF_instr_out[11:8],1'b0};
               U_IMM:    imm = {IF_instr_out[31:12],12'b0} ;
               default:  imm = {{11{IF_instr_out[31]}},
                              IF_instr_out[31],
                              IF_instr_out[19:12],
                              IF_instr_out[20],
                              IF_instr_out[30:21],
                              1'b0
                              };

          endcase



     end

endmodule