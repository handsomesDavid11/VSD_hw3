`include "../include/AXI_define.svh"

module DMA_slave (
     input clk,
     input rst,

     input [`AXI_IDS_BITS-1:0] AWID_S,
	input [`AXI_ADDR_BITS-1:0] AWADDR_S,
	input [`AXI_LEN_BITS-1:0] AWLEN_S,
	input [`AXI_SIZE_BITS-1:0] AWSIZE_S,
	input [1:0] AWBURST_S,
	input AWVALID_S,
	output logic AWREADY_S,
	//WRITE DATA
	input [`AXI_DATA_BITS-1:0] WDATA_S,
	input [`AXI_STRB_BITS-1:0] WSTRB_S,
	input WLAST_S,
	input WVALID_S,
	output logic WREADY_S,
	
	//WRITE RESPONSE
	output logic [`AXI_IDS_BITS-1:0] BID_S,
	output logic [1:0] BRESP_S,
	output logic BVALID_S,
	input BREADY_S,

	//READ ADDRESS
	input [`AXI_IDS_BITS-1:0] ARID_S,
	input [`AXI_ADDR_BITS-1:0] ARADDR_S,
	input [`AXI_LEN_BITS-1:0] ARLEN_S,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_S,
	input [1:0] ARBURST_S,
	input ARVALID_S,
	output logic ARREADY_S,
	
	//READ DATA
	output logic [`AXI_IDS_BITS-1:0] RID_S,
	output logic [`AXI_DATA_BITS-1:0] RDATA_S,
	output logic [1:0] RRESP_S,
	output logic RLAST_S,
	output logic RVALID_S,
	input RREADY_S,

     output logic [31:0] DMASRC,   
     output logic [31:0] DMADST,
     output logic [31:0] DMALEN,
     output logic  DMAEN
);
          localparam [2:0]    ADDR         = 3'b000,
                         READDATA     = 3'b001,
                         WRITEDATA    = 3'b010,
                         RESPONSE     = 3'b011;


     logic AR_done, RD_done, AW_done, WD_done, RES_done;
     assign AR_done  = ARVALID_S & ARREADY_S;
     assign RD_done  = RVALID_S  & RREADY_S;
     assign AW_done  = AWVALID_S & AWREADY_S;
     assign WD_done  = WVALID_S  & WREADY_S;
     assign RES_done = BVALID_S  & BREADY_S; 

     logic RD_done_last, WD_done_last;
     assign RD_done_last = RLAST_S & RD_done;
     assign WD_done_last = WLAST_S & WD_done;


     always_ff @(posedge ACLK or negedge ARESETn) begin
          if(~ARESETn)
               cur_state <= ADDR;
          else 
               cur_state <= next_state;
     end

     always_comb begin
          case(cur_state)
               ADDR: begin
                    if(AW_done & WD_done)
                         next_state = RESPONSE;
                    else if(AW_done)
                         next_state = WRITEDATA;
                    else if(AR_done)
                         next_state = READDATA;
                    else 
                         next_state = ADDR;
               end
               READDATA: begin
                    if(RD_done_last & AW_done)
                         next_state = WRITEDATA;
                    else if(RD_done_last & AR_done)
                         next_state = READDATA;
                    else if(RD_done_last)
                         next_state = ADDR;
                    else 
                         next_state = READDATA;
               end
               WRITEDATA: begin
                    if(WD_done_last)
                         next_state = RESPONSE;
                    else
                         next_state = WRITEDATA;
               end
               default: begin
                    if(RES_done & AW_done)
                         next_state = WRITEDATA;
                    else if(RES_done & AR_done)
                         next_state = READDATA;
                    else if(RES_done)
                         next_state = ADDR;
                    else 
                         next_state = RESPONSE;
               end
          endcase

     end
     logic [2:0] DMA_ADDR;
     logic [`AXI_IDS_BITS -1:0] IDS;
     logic [`AXI_DATA_BITS-1:0] RDATA;
     logic [`AXI_LEN_BITS -1:0] LEN;
     logic [`AXI_STRB_BITS-1:0] WSTRB;

     always_ff @(posedge clk or posedge rst) begin
          if (rst) begin
               DMA_ADDR  <= 3'h0;
               IDS       <= `AXI_IDS_BITS'h0;
               LEN       <= `AXI_LEN_BITS'h0;
               WSTRB     <= `AXI_STRB_BITS'h0;

          end  
          else begin

               
          
          end

     end




     always_ff @(posedge clk or posedge rst) begin
          if(rst) begin
               DMASRC <= 32'b0;
               DMADST <= 32'b0;
               DMALEN <= 32'b0;
               DMAEN  <= 1'b0;
          end
          else if ()

     end


endmodule