// `include "../include/AXI_define.svh"


module WriteRespone(
     input clk,
     input rst,
     //master 0
     /*
     output logic [`AXI_ID_BITS-1:0] BID_M0,
     output logic [1:0]   BRESP_M0,
     output logic         BVALID_M0,
     //master 0 send
     input          BREADY_M0,
     */
     //master 1
     output logic [`AXI_ID_BITS-1:0] BID_M1,
     output logic [1:0]   BRESP_M1,
     output logic         BVALID_M1,
     //master 1 send
     input          BREADY_M1,

     //slave 0
     input [`AXI_IDS_BITS-1:0] BID_S0,
     input [1:0]   BRESP_S0,
     input         BVALID_S0,
     //
     output   logic  BREADY_S0,

     //slave 0
     input [`AXI_IDS_BITS-1:0] BID_S1,
     input [1:0]   BRESP_S1,
     input         BVALID_S1,
     //
     output   logic  BREADY_S1,

     //slave default
     input [`AXI_IDS_BITS-1:0] BID_default,
     input [1:0]   BRESP_default,
     input         BVALID_default,
     //
     output   logic  BREADY_default

);
     logic [2:0] slave;
     logic [1:0] master;
     logic READY_m_to_s;


     logic [`AXI_ID_BITS-1:0] BID_s_to_m;
     logic [1:0]              BRESP_s_to_m;
     logic                    BVALID_s_to_m;
     // select slave
     always_comb begin
          if(BVALID_default)
               slave = 3'b100;
          else if (BVALID_S1)
               slave = 3'b010;
          else if (BVALID_S0)
               slave = 3'b001;
          else 
               slave = 3'b000;
     end
     always_comb begin
          case(master)
               2'b10: begin
                    READY_m_to_s = BREADY_M1;
                    BVALID_M1 = BVALID_s_to_m;
               end
               default: begin
                    READY_m_to_s = 1'b1;
                    BVALID_M1 = 1'b0; 
               end
          endcase
     end



     //m0
     assign BID_M0    = BID_s_to_m;
     assign BRESP_M0  = BRESP_s_to_m;

     //m1
     assign BID_M1    = BID_s_to_m;
     assign BRESP_M1  = BRESP_s_to_m;

     always_comb begin
          case(slave)
               3'b001:begin
                    master         = BID_S0[5:4];
                    BID_s_to_m     = BID_S0;
                    BRESP_s_to_m   = BRESP_S0;
                    BVALID_s_to_m  = BVALID_S0;
                    {BREADY_default,BREADY_S1,BREADY_S0} = {2'b0,READY_m_to_s & BVALID_S0};
               end

               3'b010, 3'b011:begin
                    master         = BID_S1[5:4];
                    BID_s_to_m     = BID_S1[`AXI_ID_BITS-1:0];
                    BRESP_s_to_m   = BRESP_S1;
                    BVALID_s_to_m  = BVALID_S1;
                    {BREADY_default,BREADY_S1,BREADY_S0} = {1'b0,READY_m_to_s & BVALID_S1,1'b0};
               end

               3'b100, 3'b101, 3'b110, 3'b111:begin
                    master         = BID_default[5:4];
                    BID_s_to_m     = BID_default[`AXI_ID_BITS-1:0];
                    BRESP_s_to_m   = BRESP_default;
                    BVALID_s_to_m  = BVALID_default;

                    {BREADY_default,BREADY_S1,BREADY_S0} = {READY_m_to_s & BVALID_default,2'b0};
               end
               default:begin
                    master         = 2'b0;
                    BID_s_to_m     = `AXI_ID_BITS'b0;
                    BRESP_s_to_m   = 2'b0;
                    BVALID_s_to_m  = 1'b0;

                    {BREADY_default,BREADY_S1,BREADY_S0} = 3'b0;
               end



          endcase
     
     end




endmodule