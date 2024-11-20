module CSR(
     input clk,
     input rst,
     input ID_MemRead,
     input [4:0] ID_rd_addr,
     input [4:0] rs1_addr,
     input [4:0] rs2_addr,
     input [1:0] BranchCtrl,
     input IM_stall,
     input DM_stall,
     output logic [63:0] cycle,
     output logic [63:0] instret

);
     localparam     PC_4      = 2'b00;
     always_ff @(posedge clk, posedge rst)begin
          
          if(rst) begin
               cycle          <= 64'b0;
               instret        <= 64'b0;
          end
          
          else begin
               if(~IM_stall && ~DM_stall)begin
                    cycle          <= cycle+1'b1;
                    if(cycle>64'b1)begin
                    
                         if(BranchCtrl != PC_4) 
                              instret   <= instret - 1'b1;
                         else if(ID_MemRead && ((ID_rd_addr==rs1_addr) || (ID_rd_addr==rs2_addr)))
                              instret   <= instret ;
                         else
                              instret   <= instret + 1'b1;
                    end
               end
          end

     end


endmodule