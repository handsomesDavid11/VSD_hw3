module FRegisterFile(
     input clk,
     input rst,
     input reg_write,

     input [4:0] rs1_addr,
     input [4:0] rs2_addr,

     input [4:0] WB_rd_addr,
     input [31:0] WB_rd_data,

     output reg [31:0] rs1_data,  
     output reg [31:0] rs2_data

);

reg [31:0] register[31:0];



assign rs1_data = register[rs1_addr] ;
assign rs2_data = register[rs2_addr] ;
integer i;
always_ff@(posedge clk or posedge rst) begin
     if(rst) begin
          for(i=0;i<32;i++)begin
               register[i]<=32'b0;
          end
     end
     else if(reg_write && WB_rd_addr!=5'b0)begin

          register[WB_rd_addr]<=WB_rd_data;
     end

end
endmodule