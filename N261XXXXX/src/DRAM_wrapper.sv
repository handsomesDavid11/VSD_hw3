// `include "AXI_define.svh"
`include "../include/AXI_define.svh"
module SRAM_wrapper (
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
	input RREADY_S


);

     logic CEB;
     logic WEB;
     logic [31:0] BWEB;
     logic [13:0] A;
     logic [31:0] DI;
     logic [31:0] DO;

     logic [2:0] cur_state, next_state;

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
     //address
     always_comb begin
          case(cur_state)
               ADDR:
                    AWREADY_S = 1'b1;
               RESPONSE:
                    AWREADY_S = RES_done;
               READDATA:
                    AWREADY_S = RD_done;
               default:
                    AWREADY_S = 1'b0;
          endcase
     end

     always_comb begin
          case(cur_state)
               ADDR:
                    ARREADY_S = ~AWVALID_S;
               RESPONSE:
                    ARREADY_S = 1'b0;
               READDATA:
                    ARREADY_S = 1'b0;
               default:/* default */
                    ARREADY_S = 1'b0;
          endcase
     end

     assign WREADY_S = (cur_state == WRITEDATA) ? 1'b1:1'b0;
     assign BVALID_S = (cur_state == RESPONSE)  ? 1'b1:1'b0;
     assign RVALID_S = (cur_state == READDATA)  ? 1'b1:1'b0;

     assign RRESP_S  = `AXI_RESP_OKAY;
     assign BRESP_S  = `AXI_RESP_OKAY;

     logic [`AXI_IDS_BITS-1:0] reg_ARID, reg_AWID;
     
     always_ff @(posedge ACLK or negedge ARESETn) begin
          if(~ARESETn) begin
               reg_ARID <= `AXI_IDS_BITS'b0;
               reg_AWID <= `AXI_IDS_BITS'b0;
          end     
          else begin

               reg_ARID <= (AR_done)? ARID_S: reg_ARID;
               reg_AWID <= (AW_done)? AWID_S: reg_AWID;
          end
     end
     
     assign RID_S = reg_ARID;
     assign BID_S = reg_AWID;

     logic [`AXI_LEN_BITS-1:0] reg_ARLEN, reg_AWLEN;
     always_ff @(posedge ACLK or negedge ARESETn)begin
          if(~ARESETn)begin
               reg_ARLEN <= `AXI_LEN_BITS'b0;
               reg_AWLEN <= `AXI_LEN_BITS'b0;
          end
          else begin
               reg_ARLEN <= (AR_done)? ARLEN_S:reg_ARLEN;
               reg_AWLEN <= (AW_done)? AWLEN_S:reg_AWLEN;
          end
     end

     logic [`AXI_LEN_BITS-1:0] cnt;

     always_ff @(posedge ACLK or negedge ARESETn) begin
          if(~ARESETn)
               cnt <= `AXI_LEN_BITS'h0;
          else begin
               case(cur_state)
                    READDATA: cnt <= (RD_done_last)? `AXI_LEN_BITS'b0:((RD_done)? cnt+ `AXI_LEN_BITS'b1:cnt);
                    WRITEDATA:cnt <= (WD_done_last)? `AXI_LEN_BITS'b0:((WD_done)? cnt+`AXI_LEN_BITS'b1:cnt);
               endcase
          end

          
     end
     assign RLAST_S = (cnt == reg_ARLEN);


     logic reg_RVALID;
     always_ff @(posedge ACLK or negedge ARESETn) begin
          if(~ARESETn) 
               reg_RVALID <= 1'b0;
          else 
               reg_RVALID <= RVALID_S;
     end

     logic [`AXI_DATA_BITS-1:0] reg_RDATA;
     always_ff @(posedge ACLK or negedge ARESETn) begin
          if(~ARESETn) 
               reg_RDATA <= `AXI_DATA_BITS'b0;
          else 
               reg_RDATA <= (RVALID_S & ~reg_RVALID) ? DO : reg_RDATA;
     end

     assign RDATA_S = (RVALID_S & reg_RVALID) ? reg_RDATA : DO;
    
     always_comb begin
          case(WSTRB_S)
               4'b1111:
                    BWEB = 32'b11111111111111111111111111111111;
               4'b1110:
                    BWEB = 32'b11111111111111111111111100000000;
               4'b1101:
                    BWEB = 32'b11111111111111110000000011111111;
               4'b1100:
                    BWEB = 32'b11111111111111110000000000000000;
               4'b1011:
                    BWEB = 32'b11111111000000001111111111111111;
               4'b1010:
                    BWEB = 32'b11111111000000001111111100000000;
               4'b1001:
                    BWEB = 32'b11111111000000000000000011111111;
               4'b1000:
                    BWEB = 32'b11111111000000000000000000000000;
               4'b0111:
                    BWEB = 32'b00000000111111111111111111111111;
               4'b0110:
                    BWEB = 32'b00000000111111111111111100000000;
               4'b0101:
                    BWEB = 32'b00000000111111110000000011111111;
               4'b0100:
                    BWEB = 32'b00000000111111110000000000000000;
               4'b0011:
                    BWEB = 32'b00000000000000001111111111111111;
               4'b0010:
                    BWEB = 32'b00000000000000001111111100000000;
               4'b0001:
                    BWEB = 32'b00000000000000000000000011111111;
               default:
                    BWEB = 32'b00000000000000000000000000000000;
          endcase
     end


     
     


     assign DI = WDATA_S;


     logic [13:0] reg_RADDR, reg_WADDR;
     always_ff @(posedge ACLK or negedge ARESETn) begin
        if (~ARESETn) begin
            reg_RADDR  <= 14'b0;
            reg_WADDR  <= 14'b0;
        end
        else begin
            reg_RADDR  <= AR_done? ARADDR_S[15:2] : reg_RADDR;
            reg_WADDR  <= AW_done? AWADDR_S[15:2] : reg_WADDR;
        end
     end

     always_comb begin
        case(cur_state)
            ADDR:
                A = (AW_done)? AWADDR_S[15:2]:ARADDR_S[15:2];
            READDATA:
                A = reg_RADDR;
            WRITEDATA:
                A = reg_WADDR;
            default:
                A = ~RES_done? reg_WADDR:(AW_done ? AWADDR_S[15:2]:ARADDR_S[15:2]);
        endcase
    end

     always_comb begin
        case (cur_state)
            ADDR:
                CEB = !(AWVALID_S | ARVALID_S);
            default : 
                CEB = 1'b0;
        endcase
    end

     always_comb begin
        case (cur_state)
          ADDR:
               WEB = ~AWVALID_S & AR_done;
          READDATA:
               WEB = 1'b1;
          default : 
                WEB = 1'b0;
        endcase
    end




  
  TS1N16ADFPCLLLVTA512X45M4SWSHOD i_SRAM (
     .SLP(1'b0),
     .DSLP(1'b0),
     .SD(1'b0),
     .PUDELAY(),
     .CLK(ACLK),
	.CEB(CEB),
	.WEB(WEB),
     .A(A),
	.D(DI),
     .BWEB(BWEB),
     .RTSEL(2'b01),
     .WTSEL(2'b01),
     .Q(DO)
);


endmodule
