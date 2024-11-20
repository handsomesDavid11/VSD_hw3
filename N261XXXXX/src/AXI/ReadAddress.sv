//`include "../include/AXI_define.svh"
//`include "../src/AXI/ Arbiter.sv"
//`include "../src/AXI/Decoder.sv"

module ReadAddress (
     input clk,
     input rst,
//---------------------------master---------------------------//
     //master0 send to AXI
     input [`AXI_ADDR_BITS-1:0] ARADDR_M0, //data address
     input [`AXI_ID_BITS-1:0] ARID_M0, 
     input [`AXI_LEN_BITS-1:0] ARLEN_M0,
     input [`AXI_SIZE_BITS-1:0] ARSIZE_M0,
     //
     input [1:0] ARBURST_M0,
     input ARVALID_M0,
     //M0 receive
     output ARREADY_M0,

     //master1
     input [`AXI_ADDR_BITS-1:0] ARADDR_M1,
     input [`AXI_ID_BITS-1:0] ARID_M1,
     input [`AXI_LEN_BITS-1:0] ARLEN_M1,
     input [`AXI_SIZE_BITS-1:0] ARSIZE_M1,
     //
     input [1:0] ARBURST_M1,
     input ARVALID_M1,
     //output
     output ARREADY_M1,


//---------------------------slave---------------------------//
     //slave0 
     output logic [`AXI_IDS_BITS-1:0] ARID_S0,
     output logic [`AXI_ADDR_BITS-1:0] ARADDR_S0,
     output logic [`AXI_LEN_BITS-1:0] ARLEN_S0,
     output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S0,
     output logic ARVALID_S0,
     output logic [1:0] ARBURST_S0,

     input ARREADY_S0,

     //slave1 
     output logic [`AXI_IDS_BITS-1:0] ARID_S1,
     output logic [`AXI_ADDR_BITS-1:0] ARADDR_S1,
     output logic [`AXI_LEN_BITS-1:0] ARLEN_S1,
     output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S1,
     output logic ARVALID_S1,
     output logic [1:0] ARBURST_S1,

     input ARREADY_S1,

    //Slave default
    output logic [`AXI_IDS_BITS-1:0] ARID_default,
    output logic [`AXI_ADDR_BITS-1:0] ARADDR_default,
    output logic [`AXI_LEN_BITS-1:0] ARLEN_default,
    output logic [`AXI_SIZE_BITS-1:0] ARSIZE_default,
    output logic [1:0] ARBURST_default,
    output logic ARVALID_default,
    //SlavesD send
    input ARREADY_default

);
//---------------------------arbiter result---------------------------//
     logic [`AXI_IDS_BITS-1:0] IDS_M;
     logic [`AXI_ADDR_BITS-1:0] ADDR_M;
     logic [`AXI_LEN_BITS-1:0] LEN_M;
     logic [`AXI_SIZE_BITS-1:0] SIZE_M;
     logic VALID_M;
     logic [1:0] BURST_M;

//---------------------
     logic tmp_ARVALID_S0;
     logic tmp_ARVALID_S1;
     logic tmp_ARVALID_default;
     logic busy_S0;
     logic busy_S1;
     logic busy_default;
     logic reg_ARREADY_S0;
     logic reg_ARREADY_S1;
     logic reg_ARREADY_default;



//---------------------------slave 0---------------------------//

     assign ARID_S0        = IDS_M;
     assign ARADDR_S0      = ADDR_M;     
     assign ARLEN_S0       = LEN_M;
     assign ARSIZE_S0      = SIZE_M;     
     assign ARBURST_S0     = BURST_M;    

//---------------------------slave 1---------------------------//

     assign ARID_S1        = IDS_M;
     assign ARADDR_S1      = ADDR_M;     
     assign ARLEN_S1       = LEN_M;
     assign ARSIZE_S1      = SIZE_M;     
     assign ARBURST_S1     = BURST_M;    

//---------------------------slave default---------------------------//

     assign ARID_default        = IDS_M;
     assign ARADDR_default      = ADDR_M;     
     assign ARLEN_default       = LEN_M;
     assign ARSIZE_default      = SIZE_M;     
     assign ARBURST_default     = BURST_M;    

     logic READY_S;

     assign busy_S0       = reg_ARREADY_S0 & ~ARREADY_S0;
     assign busy_S1       = reg_ARREADY_S1 & ~ARREADY_S1;
     assign busy_default = reg_ARREADY_default & ~ARREADY_default;

     assign ARVALID_S0       = busy_S0? 1'b0:tmp_ARVALID_S0;
     assign ARVALID_S1       = busy_S1? 1'b0:tmp_ARVALID_S1;
     assign ARVALID_default = busy_default? 1'b0:tmp_ARVALID_default;

     always_ff@(posedge clk or negedge rst) begin
        if(~rst) begin
            reg_ARREADY_S0       <= 1'b0;
            reg_ARREADY_S1       <= 1'b0;
            reg_ARREADY_default  <= 1'b0;
        end else begin
            reg_ARREADY_S0       <= ARREADY_S0? 1'b1:reg_ARREADY_S0;
            reg_ARREADY_S1       <= ARREADY_S1? 1'b1:reg_ARREADY_S1;
            reg_ARREADY_default <= ARREADY_default? 1'b1:reg_ARREADY_default;
        end
    end  


Arbiter Arbiter(
     .clk(clk),
     .rst(rst),
     //from master 0
     .ID_M0(ARID_M0),
     .ADDR_M0(ARADDR_M0),
     .LEN_M0(ARLEN_M0),
     .SIZE_M0(ARSIZE_M0),
     .BURST_M0(ARBURST_M0),
     .VALID_M0(ARVALID_M0),
     //output
     .READY_M0(ARREADY_M0),

     // from master 1 
     .ID_M1(ARID_M1),
     .ADDR_M1(ARADDR_M1),
     .LEN_M1(ARLEN_M1),
     .SIZE_M1(ARSIZE_M1),
     .BURST_M1(ARBURST_M1),
     .VALID_M1(ARVALID_M1),
     //output
     .READY_M1(ARREADY_M1),

     // send to slave
     .IDS_M(IDS_M),
     .ADDR_M(ADDR_M),
     .LEN_M(LEN_M),
     .SIZE_M(SIZE_M),
     .BURST_M(BURST_M),
     .VALID_M(VALID_M),

     .READY_M(READY_S)

);
Decoder Decoder(
     //input valid, addr
     .VALID(VALID_M),
     .ADDR(ADDR_M),
     //output 
     .VALID_S0(tmp_ARVALID_S0),
     .VALID_S1(tmp_ARVALID_S1),
     .VALID_default(tmp_ARVALID_default),

     //READY input
     .READY_S0(ARREADY_S0),
     .READY_S1(ARREADY_S1),
     .READY_default(ARREADY_default),
     //ready output
     .READY_S(READY_S)

);



endmodule