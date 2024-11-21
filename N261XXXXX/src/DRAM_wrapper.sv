// `include "AXI_define.svh"
`include "../include/AXI_define.svh"
module DRAM_wrapper (
     input ACLK,
     input ARESETn,


  //AXI
     //WRITE ADDRESS
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
     output reg CSn,
     output reg [3:0] WEn,
     output reg RASn, 
     output reg CASn,
     output reg [10:0] A,
     output reg [31:0] D,
     input [31:0] Q,
     input VALID

);



     logic [2:0] cur_state, next_state;

     localparam [2:0]    INIT      = 3'b000,
                         ACT       = 3'b001,
                         READ      = 3'b010,
                         WRITE     = 3'b011,
                         PRE       = 3'b101;
 
     




     logic AR_done, RD_done, AW_done, WD_done, RES_done;
     assign AR_done  = ARVALID_S & ARREADY_S;
     assign RD_done  = RVALID_S  & RREADY_S;
     assign AW_done  = AWVALID_S & AWREADY_S;
     assign WD_done  = WVALID_S  & WREADY_S;
     assign RES_done = BVALID_S  & BREADY_S; 

     logic RD_done_last, WD_done_last;
     assign RD_done_last = RLAST_S & RD_done;
     assign WD_done_last = WLAST_S & WD_done;


     
     logic [2:0] delay_cnt;
     logic [2:0] cur_state, next_state;
     logic delay_done;
     //--------------------------delay done assign------------------------//
     assign delay_done = (cur_state == READ) ? delay_cnt == 3'b101 : delay_cnt[2];


     //------------------------" write  signal control-------------------//
     logic write;
     //----------------------------- Dram FSM-----------------------------//
     
     always_ff @(posedge ACLK or negedge ARESETn) begin
          if(~ARESETn)
               cur_state <= INIT;
          else 
               cur_state <= next_state;
     end

     always_comb begin
          case(cur_state):
               INIT: begin
                    if(AR_done | AW_done)
                         next_state = ACT;
                    else
                         next_state = INIT;
                    
               end
               // when receive address actvity DRAM
               ACT: begin
                    if(delay_done) begin
                         if(write)
                              next_state = WRITE;
                         else
                              next_state = READ;
                    end
                    else
                         next_state = ACT;
               end
               READ: begin
                    if(delay_done & RD_done_last)
                         next_state = PRE;
                    else
                         next_state = READ;
               end
               // write has delay??  row to column delay
               WRITE: begin
                    if(delay_done & WD_done_last)
                         next_state = PRE;
                    else
                         next_state = WRITE;
               end
               PRE:begin
                    if(delay_done)
                         next_state = INIT;
                    else 
                         next_state = PRE;
               end
          endcase
     end

//-----------------------------count delay------------------------------//
always_ff @(posedge ACLK or negedge ARESETn) begin
     if(~rst)
          delay_cnt <= 3'b0;
     else begin
     case(cur_state)
          INIT:
               delay_cnt <= 3'b0;
          default:
               delay_cnt <= (delay_done)? 3'b0 : delay_cnt + 3'b1;
     endcase
     end
end

//-------------------------------- input signal store-------------------------//
reg




endmodule