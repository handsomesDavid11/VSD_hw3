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

     // to DRAM
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
     
     always_ff @(posedge ACLK or negedge ARESETn) begin
          if(~ARESETn) begin
               write <= 1'b0;
          end
          else begin
               case(cur_state)
                    INIT:begin
                         if(AW_done)
                              write <= 1'b1;
                    end
                    ACT: begin
                         write <= write;
                    end
                    default:
                         write <= 1'b0;

               endcase

          end
     end

     //----------------------------- DRAM FSM-----------------------------//
     
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
          if(~ARESETn)
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
//-------------------------------read count-----------------------------------//
     logic [`AXI_LEN_BITS-1:0] read_cnt;
     always_ff @(posedge ACLK or negedge ARESETn) begin
          if(~ARESETn) 
               read_cnt     <=   `AXI_LEN_BITS'b0;
          else begin
               case(cur_state)
                    READ:
                         read_cnt <= RD_done ? read_cnt + `AXI_LEN_BITS'b1:read_cnt;
                    default:
                         read_cnt <= `AXI_LEN_BITS'b0;
               endcase
          end
     end



//-------------------------------- input RA/WA store-------------------------//
     logic [`AXI_IDS_BITS-1:0] reg_ID;
     logic [`AXI_ADDR_BITS-1:0] reg_ADDR;
     logic [`AXI_LEN_BITS  -1:0] reg_LEN;
     logic [`AXI_SIZE_BITS -1:0] reg_SIZE;
     logic [1:0] reg_BURST;

     always_ff @(posedge ACLK or negedge ARESETn) begin
          if(~ARESETn) begin
               reg_ID         <= `AXI_IDS_BITS'b0;
               reg_ADDR       <= `AXI_ADDR_BITS'b0;
               reg_LEN        <= `AXI_LEN_BITS'b0;
               reg_SIZE       <= `AXI_SIZE_BITS'b0;
               reg_BURST      <= 2'b0;
          end
          else if (AR_done) begin
               reg_ID         <= ARID_S;
               reg_ADDR       <= ARADDR_S;
               reg_LEN        <= ARLEN_S;
               reg_SIZE       <= ARSIZE_S;
               reg_BURST      <= ARBURST_S;
          end
          else if (AW_done) begin
               reg_ID         <= ARID_S;
               reg_ADDR       <= ARADDR_S;
               reg_LEN        <= ARLEN_S;
               reg_SIZE       <= ARSIZE_S;
               reg_BURST      <= ARBURST_S;
          end
     end
//--------------------------- output singnal and data to DRAM-----------------------//
//only init can activity DRAM, and every state need wait 5 cycle at least
     always_comb begin
          case(cur_state)
               INIT: begin
                    CSn  = 1'b1;
                    RASn = 1'b1;
                    CASn = 1'b1;
                    WEn  = 4'b1111;
                    A    = reg_ADDR[22:12];
                    D    = `DATA_BITS'h0;
               end
               ACT:begin
                    CSn  = 1'b0;
                    RASn = (delay_cnt == 3'b0)? 1'b0:1'b1;
                    CASn = 1'b1;
                    WEn  = 4'b1111;
                    A    = reg_ADDR[22:12];
                    D    = WDATA;

               end
               READ: begin
                    CSn  = 1'b0;
                    RASn = 1'b1;
                    CASn = (delay_cnt == 3'b0)? 1'b0:1'b1;
                    WEn  = 4'b1111;
                    A    = reg_ADDR[11:2] + read_cnt[1:0];
                    D    = WDATA;

               end
               WRITE: begin
                    CSn  = 1'b0;
                    RASn = 1'b1;
                    CASn = (delay_cnt == 3'b0)? 1'b0:1'b1;
                    WEn  = (delay_cnt == 3'b0)? WSTRB:4'b1111;
                    A    = reg_ADDR[11:2] ;
                    D    = reg_WDATA;


               end
               default: begin
                    CSn  = 1'b0;
                    RASn = (delay_cnt == 3'b0)? 1'b0:1'b1;
                    CASn = 1'b1;
                    WEn  = (delay_cnt == 3'b0)? 4'b0:4'b1111;
                    A    = reg_ADDR[22:12] ;
                    D    = `DATA_BITS'h0;
               end
          endcase
     end


//-------------------------------AW/AR ready signal control---------------------//
     always_comb begin
          case(cur_state)
               INIT: begin
                    ARREADY_S = ~AWVALID;
                    AWREADY_S = 1'b1;
               end
               default: begin
                    ARREADY_S = 1'b0;
                    AWREADY_S = 1'b0;
               end

          endcase

     end

     always_comb begin
          case (cur_state)
               WRITE:
                    WREADY_S = 1'b1;
               default:
                    WREADY_S = 1'b0;
          endcase
     end
     always_comb begin
          case (cur_state)
               READ: begin
                    RVALID_S = VALID;
                    BVALID_S = 1'b0;
               end
               PRE: begin
                    RVALID_S = 1'b0;
                    BVALID_S = (delay_cnt == 3'b0)? 1'b1: 1'b0;
               end
               default : begin 
                    RVALID_S = 1'b0;
                    BVALID_S = 1'b0;
               end
          endcase
     end

     logic [`DATA_BITS -1:0] reg_RDATA;

     always_ff @(posedge ACLK or negedge ARESETn) begin
          if(~ARESETn) begin
               reg_RDATA <= `DATA_BITS'b0;
          end 
          else begin
               reg_RDATA <= DRAM_valid? Q:reg_RDATA;
          end
     end

     assign RID_S   = reg_ID;
     assign RDATA_S = VALID? Q : reg_RDATA;
     assign RRESP_S = `AXI_RESP_OKAY;

     assign RLAST_S = (read_cnt == reg_LEN);
     assign BID_S   = reg_ID;
     assign BRESP_S = `AXI_RESP_OKAY;

    




endmodule