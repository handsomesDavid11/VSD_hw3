module HazardCtrl(
     input ID_MemRead,
     input [4:0] ID_rd_addr,
     input [4:0] rs1_addr,
     input [4:0] rs2_addr,
     input [1:0] BranchCtrl,
     input Rs1Sel,
     input Rs2Sel,
     input ID_FRegWrite,
     output reg PC_write,
     output reg instrFlush,
     output reg IFID_RegWrite,
     output reg CtrlSignalFlush,

     input IM_stall,
     output reg IDEXE_RegWrite,
     input DM_stall,
     output reg EXEMEM_RegWrite,
     output reg MEMWB_RegWrite

);

     localparam [1:0] PC4 = 2'b00, PCIMM = 2'b01, IMMRS1 = 2'b10;


     always_comb begin
          if(IM_stall | DM_stall)begin
               PC_write          = 1'b0;
               instrFlush        = 1'b0;
               IFID_RegWrite     = 1'b0;
               CtrlSignalFlush   = 1'b0;
               IDEXE_RegWrite    = 1'b0;
               EXEMEM_RegWrite   = 1'b0;
               MEMWB_RegWrite    = 1'b0;


          end
          
          else if( BranchCtrl != PC4)begin
               PC_write          = 1'b1;
               instrFlush        = 1'b1;
               IFID_RegWrite     = 1'b1;
               CtrlSignalFlush   = 1'b1;
               IDEXE_RegWrite    = 1'b1;
               EXEMEM_RegWrite   = 1'b1;
               MEMWB_RegWrite    = 1'b1;

          end
          else if( ID_MemRead && ((ID_rd_addr==rs1_addr) || (ID_rd_addr==rs2_addr))  )begin
               PC_write          = 1'b0;
               instrFlush        = 1'b0;
               IFID_RegWrite     = 1'b0;
               CtrlSignalFlush   = 1'b1;
               IDEXE_RegWrite    = 1'b1;
               EXEMEM_RegWrite   = 1'b1;
               MEMWB_RegWrite    = 1'b1;

          end
          else begin
               PC_write          = 1'b1;
               instrFlush        = 1'b0;
               IFID_RegWrite     = 1'b1;
               CtrlSignalFlush   = 1'b0;
               IDEXE_RegWrite    = 1'b1;
               EXEMEM_RegWrite   = 1'b1;
               MEMWB_RegWrite    = 1'b1;
          end

     end






endmodule