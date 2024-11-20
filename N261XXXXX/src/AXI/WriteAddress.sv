`include "../include/AXI_define.svh"
`include "../src/AXI/Arbiter.sv"
`include "../src/AXI/Decoder.sv"

module WriteAddress(
     input clk,
     input rst,



     //master 1 send AXI
     input [`AXI_ID_BITS-1:0]   AWID_M1,
     input [`AXI_ADDR_BITS-1:0] AWADDR_M1,
     input [`AXI_LEN_BITS-1:0]  AWLEN_M1,
     input [`AXI_SIZE_BITS-1:0] AWSIZE_M1,
     input [1:0]                AWBURST_M1,
     input                      AWVALID_M1,

     //master receive
     output logic                  AWREADY_M1,

     //slave receive from AXI
     output logic [`AXI_IDS_BITS-1:0]  AWID_S0,
     output logic [`AXI_ADDR_BITS-1:0] AWADDR_S0,
     output logic [`AXI_LEN_BITS-1:0]  AWLEN_S0,
     output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S0,
     output logic [1:0]                AWBURST_S0,
     output logic                      AWVALID_S0,
     // slave send AXI
     input AWREADY_S0,


     output logic [`AXI_IDS_BITS-1:0]  AWID_S1,
     output logic [`AXI_ADDR_BITS-1:0] AWADDR_S1,
     output logic [`AXI_LEN_BITS-1:0]  AWLEN_S1,
     output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S1,
     output logic [1:0]                AWBURST_S1,
     output logic                      AWVALID_S1,
     // slave send
     input AWREADY_S1,


     //slave receive firm AXI
     output logic [`AXI_IDS_BITS-1:0]  AWID_default,
     output logic [`AXI_ADDR_BITS-1:0] AWADDR_default,
     output logic [`AXI_LEN_BITS-1:0]  AWLEN_default,
     output logic [`AXI_SIZE_BITS-1:0] AWSIZE_default,
     output logic [1:0]                AWBURST_default,
     output logic                      AWVALID_default,
     // slave send
     input AWREADY_default

      
);
     logic [`AXI_IDS_BITS-1:0] IDS_M;
     logic [`AXI_ADDR_BITS-1:0] ADDR_M;
     logic [`AXI_LEN_BITS-1:0] LEN_M;
     logic [`AXI_SIZE_BITS-1:0] SIZE_M;
     logic [1:0] BURST_M;
     logic VALID_M;


     logic tmp_AWVALID_S0;
     logic tmp_AWVALID_S1;
     logic tmp_AWVALID_default;
     logic busy_S0;
     logic busy_S1;
     logic busy_default;
     logic reg_AWREADY_S0;
     logic reg_AWREADY_S1;
     logic reg_AWREADY_default;
     
     // slave 0 
     assign AWID_S0      = IDS_M;
     assign AWADDR_S0    = ADDR_M;
     assign AWLEN_S0     = LEN_M;
     assign AWSIZE_S0    = SIZE_M;
     assign AWBURST_S0   = BURST_M;

     // slave 1
     assign AWID_S1      = IDS_M;
     assign AWADDR_S1    = ADDR_M;
     assign AWLEN_S1     = LEN_M;
     assign AWSIZE_S1    = SIZE_M;
     assign AWBURST_S1   = BURST_M;

     // slave default
     assign AWID_default      = IDS_M;
     assign AWADDR_default    = ADDR_M;
     assign AWLEN_default     = LEN_M;
     assign AWSIZE_default    = SIZE_M;
     assign AWBURST_default   = BURST_M;

     logic READY_S;
     logic ARREADY_M0;

/*
     assign busy_S0       = reg_AWREADY_S0 & ~AWREADY_S0;
     assign busy_S1       = reg_AWREADY_S1 & ~AWREADY_S1;
     assign busy_default = reg_AWREADY_default & ~AWREADY_default;

     assign AWVALID_S0       = busy_S0? 1'b0:tmp_AWVALID_S0;
     assign AWVALID_S1       = busy_S1? 1'b0:tmp_AWVALID_S1;
     assign AWVALID_default  = busy_default? 1'b0:tmp_AWVALID_default;

     always_ff@(posedge clk or negedge rst) begin
        if(~rst) begin
            reg_AWREADY_S0       <= 1'b0;
            reg_AWREADY_S1       <= 1'b0;
            reg_AWREADY_default <= 1'b0;
        end else begin
            reg_AWREADY_S0       <= AWREADY_S0? 1'b1:reg_AWREADY_S0;
            reg_AWREADY_S1       <= AWREADY_S1? 1'b1:reg_AWREADY_S1;
            reg_AWREADY_default <= AWREADY_default? 1'b1:reg_AWREADY_default;
        end
    end  
*/
     Arbiter Arbiter(
     .clk(clk),
     .rst(rst),

     .ID_M0(`AXI_ID_BITS'b0),
     .ADDR_M0(`AXI_ADDR_BITS'b0),
     .LEN_M0(`AXI_LEN_BITS'b0),
     .SIZE_M0(`AXI_SIZE_BITS'b0),
     .BURST_M0(2'b0),
     .VALID_M0(1'b0),
     //output the slave ready
     .READY_M0(ARREADY_M0),

     // master 1 
     .ID_M1(AWID_M1),
     .ADDR_M1(AWADDR_M1),
     .LEN_M1(AWLEN_M1),
     .SIZE_M1(AWSIZE_M1),
     .BURST_M1(AWBURST_M1),
     .VALID_M1(AWVALID_M1),
     //
     .READY_M1(AWREADY_M1),

     .IDS_M(IDS_M),
     .ADDR_M(ADDR_M),
     .LEN_M(LEN_M),
     .SIZE_M(SIZE_M),
     .BURST_M(BURST_M),
     .VALID_M(VALID_M),
     //input 
     .READY_M(READY_S)
 
);
     
     Decoder Decoder(
     // valid
     .VALID(VALID_M),
     .ADDR(ADDR_M),
     // select which valid is high
     .VALID_S0(AWVALID_S0),
     .VALID_S1(AWVALID_S1),
     .VALID_default(AWVALID_default),

     //READY
     .READY_S0(AWREADY_S0),
     .READY_S1(AWREADY_S1),
     .READY_default(AWREADY_default),
     //output the slave ready or not
     .READY_S(READY_S)

);








endmodule