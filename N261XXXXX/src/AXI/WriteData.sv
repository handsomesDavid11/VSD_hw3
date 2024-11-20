// `include "../include/AXI_define.svh"

module WriteData(
     input clk,
     input rst,
     //master 0 doesn't receive data form Write data

     //master 1 to AXI
    // input [`AXI_ID_BITS-1:0]      WID_M1,
     input [`AXI_DATA_BITS-1:0]    WDATA_M1,
     input [`AXI_STRB_BITS-1:0]    WSTRB_M1,
     input  WLAST_M1,
     input  WVALID_M1,
     // AXI to master1
     output logic WREADY_M1,

     //AXI to slave0
     //output logic [`AXI_IDS_BITS-1:0]   WID_S0,
     output logic [`AXI_DATA_BITS-1:0]  WDATA_S0,
     output logic [`AXI_STRB_BITS-1:0]  WSTRB_S0,
     output logic WLAST_S0,
     output logic WVALID_S0,

     input WREADY_S0,
     //AXI to slave1
     //output logic [`AXI_IDS_BITS-1:0]   WID_S1,
     output logic [`AXI_DATA_BITS-1:0]  WDATA_S1,
     output logic [`AXI_STRB_BITS-1:0]  WSTRB_S1,
     output logic WLAST_S1,
     output logic WVALID_S1,

     input WREADY_S1,

     //AXI to slave default
     //output logic [`AXI_IDS_BITS-1:0]   WID_default,
     output logic [`AXI_DATA_BITS-1:0]  WDATA_default,
     output logic [`AXI_STRB_BITS-1:0]  WSTRB_default,
     output logic WLAST_default,
     output logic WVALID_default,

     input WREADY_default,

     input AWVALID_S0,
     input AWVALID_S1,
     input [`AXI_LEN_BITS-1:0] AWLEN_S1,
     input AWVALID_default

);
    // logic [`AXI_IDS_BITS-1:0] WID_m_to_s;
     logic [`AXI_DATA_BITS-1:0] WDATA_m_to_s;
     logic [`AXI_STRB_BITS-1:0] WSTRB_m_to_s;
     logic WLAST_m_to_s;
     logic WVALID_m_to_s;

     logic READY;
     logic [2:0] slave;
     

     // signals from master 1
     assign WDATA_m_to_s  = WDATA_M1;
     assign WSTRB_m_to_s  = WSTRB_M1;
     assign WLAST_m_to_s  = WLAST_M1;
     assign WVALID_m_to_s = WVALID_M1;
     //signals to master1
     assign WREADY_M1  = READY & WVALID_m_to_s;

     //----------------------slave----------------------//
     //slave 0
     assign WDATA_S0  = WDATA_m_to_s;
     assign WSTRB_S0  =(WVALID_S0)?WSTRB_m_to_s: `AXI_STRB_BITS'b1111;
     assign WLAST_S0  = WLAST_m_to_s;
     //slave 1
     assign WDATA_S1  = WDATA_m_to_s;
     assign WSTRB_S1  = (WVALID_S1)?WSTRB_m_to_s: `AXI_STRB_BITS'b1111;
     assign WLAST_S1  = WLAST_m_to_s;
     //slave default
     assign WDATA_default  = WDATA_m_to_s;
     assign WSTRB_default  = WSTRB_m_to_s;
     assign WLAST_default  = WLAST_m_to_s;

     logic reg_WVALID_S0,reg_WVALID_S1,reg_WVALID_default;

    assign slave = {(reg_WVALID_default | AWVALID_default), (reg_WVALID_S1 | AWVALID_S1), (reg_WVALID_S0 | AWVALID_S0)};
     always_ff @(posedge clk or negedge rst) begin
          if(~rst) begin
               reg_WVALID_S0 <= 1'b0;
               reg_WVALID_S1 <= 1'b0;
               reg_WVALID_default <= 1'b0;
          end else begin
               reg_WVALID_S0 <= (AWVALID_S0)? 1'b1:((WVALID_m_to_s & READY & WLAST_m_to_s)? 1'b0:reg_WVALID_S0);
               reg_WVALID_S1 <= (AWVALID_S1)? 1'b1:((WVALID_m_to_s & READY & WLAST_m_to_s)? 1'b0:reg_WVALID_S1);
               reg_WVALID_default <= (AWVALID_default)? 1'b1:((WVALID_m_to_s & READY & WLAST_m_to_s)? 1'b0:reg_WVALID_default);
          end
     end
     always_comb begin
          case(slave)
          3'b001:begin
               READY = WREADY_S0;
               {WVALID_default, WVALID_S1, WVALID_S0} = {2'b0, WVALID_m_to_s};
          end
          3'b010:begin
               READY = WREADY_S1;
               {WVALID_default, WVALID_S1, WVALID_S0} = {1'b0,WVALID_m_to_s,1'b0};
          end
          3'b100:begin
               READY = WREADY_default;
               {WVALID_default, WVALID_S1, WVALID_S0} = {WVALID_m_to_s,2'b0};
          end

          default: begin
                READY = 1'b1;
                {WVALID_default, WVALID_S1, WVALID_S0} = 3'b0;
          end

          endcase

     end



endmodule