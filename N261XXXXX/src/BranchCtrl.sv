module BranchCtrl(
     input  wire_zeroFlag,
     input  [1:0] Branch,
     output reg [1:0] BranchCtrl

);

     localparam [1:0]    PC_4      = 2'b00,
                         PC_IMM    = 2'b01,
                         PC_IMMRS1 = 2'b10;

     localparam [1:0]    None_branch = 2'b00,
                         JALR_branch = 2'b01,
                         B_branch    = 2'b10,
                         J_branch    = 2'b11;


     always_comb begin
          case(Branch)
               None_branch:begin
                    BranchCtrl = PC_4;
               end
               JALR_branch:begin
                    BranchCtrl = PC_IMMRS1;
               end
               B_branch:begin
                    if(wire_zeroFlag)
                         BranchCtrl = PC_IMM;
                    else
                         BranchCtrl = PC_4;

               end
               J_branch:begin
                    BranchCtrl = PC_IMM;
               end
               default: begin
                    BranchCtrl = PC_4;
               end

          endcase
     end
endmodule