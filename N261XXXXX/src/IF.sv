`include "Program_Counter.sv"

module IF1 (
    input clk,  
    input rst,
    input [1:0] BranchCtrl,
    input [31:0] pc_imm,
    input [31:0] pc_immrs1,

    input InstrFlush,
    input IFID_RegWrite,

    input PC_write,

    input [31:0] instr_out,//memory output

    output reg [31:0] IF_pc_out,//if register output
    output reg [31:0] IF_instr_out,//if register output

    output reg [31:0] pc_out//
);
     localparam [1:0]    PC_4      = 2'b00,
                         PC_IMM    = 2'b01,
                         PC_IMMRS1 = 2'b10;

     reg [31:0] pc_4;

     reg [31:0] wire_pc_out;//pc's result
     reg [31:0] pc_in;

     assign pc_4   = wire_pc_out+32'd4;
     assign pc_out = wire_pc_out;
     
     always_comb begin
          case (BranchCtrl)
               PC_4:      pc_in = pc_4;
               PC_IMM:    pc_in = pc_imm;
               default:   pc_in = pc_immrs1;
          endcase
     end

//----------------- program counter------------//
     Program_Counter Program_Counter(
          .rst(rst),
          .clk(clk),
          .PC_write(PC_write),
          .pc_in(pc_in),
          .pc_out(wire_pc_out)
     );

//-----------------instruction flush-----------//
     always_ff @(posedge clk or posedge rst) begin
          if(rst) begin
               IF_pc_out <= 32'b0;
               IF_instr_out <= 32'b0;
          end
          else if(IFID_RegWrite)begin
                    IF_pc_out <= pc_out;
                    if(InstrFlush)
                         IF_instr_out <= 32'b0;
                    else
                         IF_instr_out <= instr_out;
               end
               
     end

     
     

endmodule