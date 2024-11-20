// `include "../include/AXI_define.svh"



module ReadData(
     input clk,
     input rst,
     //master 0 receive from AXI
     output [`AXI_ID_BITS-1:0]     RID_M0,
     output [`AXI_DATA_BITS-1:0]   RDATA_M0,
     output [1:0]                  RRESP_M0,
     output logic                  RLAST_M0,
     output logic                  RVALID_M0,
     //master 0 sent to slave
     input logic                   RREADY_M0,

     //master 1 receive from AXI
     output [`AXI_ID_BITS-1:0]     RID_M1,
     output [`AXI_DATA_BITS-1:0]   RDATA_M1,
     output [1:0]                  RRESP_M1,
     output logic                  RLAST_M1,
     output logic                  RVALID_M1,
     //master 1 sent to AXI
     input logic                   RREADY_M1,


     //SLAVE 0 sent to AXI
     input [`AXI_IDS_BITS-1:0]     RID_S0,
     input [`AXI_DATA_BITS-1:0]    RDATA_S0,
     input [1:0]                   RRESP_S0,
     input logic                   RLAST_S0,
     input logic                   RVALID_S0,
     //master 0 sent to AXI
     output logic                  RREADY_S0,


     //SLAVE 1 
     input [`AXI_IDS_BITS-1:0]     RID_S1,
     input [`AXI_DATA_BITS-1:0]    RDATA_S1,
     input [1:0]                   RRESP_S1,
     input logic                   RLAST_S1,
     input logic                   RVALID_S1,
     //master  sent to slave 1
     output logic                   RREADY_S1,

     //SLAVE default
     input [`AXI_IDS_BITS-1:0]     RID_default,
     input [`AXI_DATA_BITS-1:0]    RDATA_default,
     input [1:0]                   RRESP_default,
     input logic                   RLAST_default,
     input logic                   RVALID_default,
     //master  sent to slave default
     output logic                   RREADY_default

);
     logic [2:0] slave;
     logic [1:0] master;

     logic [`AXI_IDS_BITS-1:0]     RID_s_to_m;
     logic [`AXI_DATA_BITS-1:0]    RDATA_s_to_m;
     logic [1:0]                   RRESP_s_to_m;
     logic                         RLAST_s_to_m;    
     logic                         RVALID_s_to_m;

     logic                         RREADY_m_to_s;



     //M0
     assign RID_M0       = RID_s_to_m[`AXI_ID_BITS-1:0];
     assign RDATA_M0     = RDATA_s_to_m;
     assign RRESP_M0     = RRESP_s_to_m;
     assign RLAST_M0     = RLAST_s_to_m;


     //M1
     assign RID_M1       = RID_s_to_m[`AXI_ID_BITS-1:0];
     assign RDATA_M1     = RDATA_s_to_m;
     assign RRESP_M1     = RRESP_s_to_m;
     assign RLAST_M1     = RLAST_s_to_m;

//--------------------------select slave--------------------------//


     logic lock_S0;
     logic lock_S1;
     logic lock_S2;

     always_ff@(posedge clk or negedge rst) begin
          if(~rst) begin
               lock_S0 <= 1'b0;
               lock_S1 <= 1'b0;
               lock_S2 <= 1'b0;
          end
          else begin
               lock_S0 <= (RREADY_m_to_s & RLAST_S0)? 1'b0 : (RVALID_S0 & ~RVALID_S1 & ~RVALID_default) ? 1'b1 : lock_S0;
               lock_S1 <= (RREADY_m_to_s & RLAST_S1)? 1'b0 : (~lock_S0 & RVALID_S1 & ~RVALID_default) ? 1'b1 : lock_S1;
               lock_S2 <= (RREADY_m_to_s & RLAST_default)? 1'b0 : (~lock_S0 & ~lock_S1 & RVALID_default) ? 1'b1 : lock_S2;
          end
          end




     always_comb begin
        if((RVALID_default & ~(lock_S1 | lock_S0)) | lock_S2) slave = 3'b100;
        else if ((RVALID_S1 & ~lock_S0) | lock_S1) slave = 3'b010;
        else if (RVALID_S0 | lock_S0) slave = 3'b001;
        else slave = 3'b0;
     end


//--------------------------slave to master valid--------------------------//
     always_comb begin 
          case(master)
          2'b01:// master 1
          begin
               RREADY_m_to_s = RREADY_M0;
               {RVALID_M1,RVALID_M0} = { 1'b0,RVALID_s_to_m } ;
          
          end
          2'b10:// master 2
          begin
               RREADY_m_to_s = RREADY_M1;
               {RVALID_M1,RVALID_M0} = {  RVALID_s_to_m, 1'b0 } ;
          end
          default:
          begin
               RREADY_m_to_s = 1'b1;
               {RVALID_M1,RVALID_M0} = 2'b0;
          end

          endcase


     end


//--------------------------slave to master value--------------------------//
// to find which slave should do first and give value
     always_comb begin
          case(slave)
               3'b001:begin
                    master         = RID_S0[5:4];
                    RID_s_to_m     = RID_S0;
                    RDATA_s_to_m   = RDATA_S0;
                    RRESP_s_to_m   = RRESP_S0;
                    RLAST_s_to_m   = RLAST_S0;
                    RVALID_s_to_m  = RVALID_S0;

                    {RREADY_S0, RREADY_S1, RREADY_default}  = {RREADY_m_to_s & RVALID_S0,2'b0}; 
               end

               3'b010:begin
                    master         = RID_S1[5:4];
                    RID_s_to_m     = RID_S1;
                    RDATA_s_to_m   = RDATA_S1;
                    RRESP_s_to_m   = RRESP_S1;
                    RLAST_s_to_m   = RLAST_S1;
                    RVALID_s_to_m  = RVALID_S1; 

                    {RREADY_S0, RREADY_S1, RREADY_default}  = {1'b0,RREADY_m_to_s& RVALID_S1,1'b0};
               end

               3'b100:begin
                    master         = RID_default[5:4];
                    RID_s_to_m     = RID_default;
                    RDATA_s_to_m   = RDATA_default;
                    RRESP_s_to_m   = RRESP_default;
                    RLAST_s_to_m   = RLAST_default;
                    RVALID_s_to_m  = RVALID_default; 

                    {RREADY_S0, RREADY_S1, RREADY_default}  = {2'b0,RREADY_m_to_s& RVALID_default};
               end
               default:begin
                    master         = 2'b0;
                    RID_s_to_m     = `AXI_IDS_BITS'b0;
                    RDATA_s_to_m   = `AXI_DATA_BITS'b0;
                    RRESP_s_to_m   = 2'b0;
                    RLAST_s_to_m   = 1'b0;
                    RVALID_s_to_m  = 1'b0; 

                    {RREADY_S0, RREADY_S1, RREADY_default}  = 3'b0;
               end


          endcase


     end





endmodule