module Program_Counter( 
     input rst,
     input clk,
     input PC_write,
     input [31:0] pc_in,
     output reg [31:0] pc_out
);

always_ff @(posedge rst or posedge clk) begin
     if(rst)
          pc_out <= 32'b0;
     else 
          if(PC_write)
          pc_out <= pc_in;
end

endmodule