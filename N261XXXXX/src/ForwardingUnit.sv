module ForwardingUnit(
     input MEM_RegWrite,
     input EXE_RegWrite,
     input EXE_FRegWrite,
     input MEM_FRegWrite,
     input Rs1Sel,
     input Rs2Sel,
     input [4:0] rs1_addr,
     input [4:0] rs2_addr,
     input [4:0] MEM_rd_addr, 
     input [4:0] EXE_rd_addr,
     output reg [1:0] FDSignal1,
     output reg [1:0] FDSignal2,
     output reg [1:0] F_FDSignal1,
     output reg [1:0] F_FDSignal2
);
     always_comb begin
     if((EXE_FRegWrite && rs1_addr==EXE_rd_addr && Rs1Sel ==1 )||(EXE_RegWrite && rs1_addr==EXE_rd_addr && Rs1Sel==0 ))
          FDSignal1 = 2'b01;
     else if((MEM_RegWrite && rs1_addr==MEM_rd_addr && Rs1Sel==0)||(MEM_FRegWrite && rs1_addr==MEM_rd_addr && Rs1Sel==1 ))
          FDSignal1 = 2'b10;
     else
          FDSignal1 = 2'b00;


     if((EXE_FRegWrite && rs2_addr==EXE_rd_addr && Rs2Sel ==1 )||(EXE_RegWrite && rs2_addr==EXE_rd_addr && Rs2Sel==0))
          FDSignal2 = 2'b01;
     else if((MEM_RegWrite && rs2_addr==MEM_rd_addr && Rs2Sel==0)||(MEM_FRegWrite && rs2_addr==MEM_rd_addr && Rs2Sel==1 ))
          FDSignal2 = 2'b10;
     else
          FDSignal2 = 2'b00;
     end
     



endmodule