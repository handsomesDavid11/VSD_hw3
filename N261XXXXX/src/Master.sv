`include "../include/AXI_define.svh"

module Master(
     input clk,
     input rst,
     //send from CPU 
     input read,
     input write,
     input [`AXI_STRB_BITS-1:0] write_type,
     input [`AXI_DATA_BITS-1:0] data_in,
     input [`AXI_ADDR_BITS-1:0] addr_in,
     /*
     input WEB,
     input [31:0] BWEB,
     input CEB,
     */
     //receive from master to cpu
     output logic [`AXI_DATA_BITS-1:0] data_out,
     output logic stall,
     //AXI
     //WRITE ADDRESS
	output logic [`AXI_ID_BITS-1:0] AWID,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR,
	output logic [`AXI_LEN_BITS-1:0] AWLEN,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE,
	output logic [1:0] AWBURST,
	output logic AWVALID,
	input AWREADY,
	//WRITE DATA
	output logic [`AXI_DATA_BITS-1:0] WDATA,
	output logic [`AXI_STRB_BITS-1:0] WSTRB,
	output logic WLAST,
	output logic WVALID,
	input WREADY,
	
	//WRITE RESPONSE
	input [`AXI_ID_BITS-1:0] BID,
	input [1:0] BRESP,
	input BVALID,
	output logic BREADY,

	//READ ADDRESS0
	output logic [`AXI_ID_BITS-1:0] ARID,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR,
	output logic [`AXI_LEN_BITS-1:0] ARLEN,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE,
	output logic [1:0] ARBURST,
	output logic ARVALID,
	input ARREADY,
	
	//READ DATA0
	input [`AXI_ID_BITS-1:0] RID,
	input [`AXI_DATA_BITS-1:0] RDATA,
	input [1:0] RRESP,
	input RLAST,
	input RVALID,
	output logic RREADY
	


);
     logic [2:0] cur_state, next_state;

     localparam [2:0]    INIT        = 3'b000,
                         READADDR    = 3'b001,
                         READDATA    = 3'b010,
                         WRITEADDR   = 3'b011,
                         WRITEDATA   = 3'b100,
                         RESPONSE    = 3'b101;

     logic AR_done, RD_done, AW_done, WD_done, RES_done;
     assign AR_done  = ARVALID & ARREADY;
     assign RD_done  = RVALID  & RREADY;
     assign AW_done  = AWVALID & AWREADY;
     assign WD_done  = WVALID  & WREADY;
     assign RES_done = BVALID  & BREADY; 

     always_ff @(posedge clk or negedge rst) begin
          cur_state <= ~rst ? INIT : next_state;
     end

     always_comb begin
     case(cur_state)
          INIT: begin
               if(ARVALID) begin
                    if(AR_done)
                         next_state = READDATA;
                    else
                         next_state = READADDR;
               end
               else if(AWVALID)begin
                    if(AW_done)
                         next_state = WRITEDATA;
                    else
                         next_state = WRITEADDR;
               end
               else 
                    next_state = INIT;
          end
          READADDR: begin

               if(AR_done)
                    next_state = READDATA;
               else
                    next_state = READADDR;
          end
          WRITEADDR: begin
               if(AW_done)
                    next_state = WRITEDATA;
               else 
                    next_state = WRITEADDR;
          
          end
          READDATA: begin
               if(RD_done)
                    next_state = INIT;
               else 
                    next_state = READDATA;
          end
          WRITEDATA:begin
               if(WD_done)
                    next_state = RESPONSE;
               else
                    next_state = WRITEDATA;
          end
          default: begin
               if(RES_done)
                    next_state = INIT;
               else
                    next_state = RESPONSE;
          end
          
        
     endcase
     end

     logic r, w;

     always_ff @(posedge clk or negedge rst) begin
        if(~rst) begin
            r <= 1'b0;
            w <= 1'b0;
        end else begin
            r <= 1'b1;
            w <= 1'b1;
        end
    end
     //read address(AR)
     assign ARID    = `AXI_ID_BITS'b0;
     assign ARADDR  = addr_in;
     assign ARLEN   = `AXI_LEN_BITS'h0;
     assign ARSIZE  = `AXI_SIZE_BITS'b10;
     assign ARBURST = `AXI_BURST_INC;

     always_comb begin
          if(cur_state == INIT)
               ARVALID = read & r;
          else if(cur_state == READADDR)
               ARVALID = 1'b1;
          else 
               ARVALID = 1'b0;

     end
     //write address(AW)
     assign AWID    = `AXI_ID_BITS'b0;
     assign AWADDR  = addr_in;
     assign AWLEN   = `AXI_LEN_BITS'h0;
     assign AWSIZE  = `AXI_SIZE_BITS'b10;
     assign AWBURST = `AXI_BURST_INC;

     always_comb begin
          if(cur_state == INIT)
               AWVALID = write & w;
          else if(cur_state == WRITEADDR)
               AWVALID = 1'b1;
          else 
               AWVALID = 1'b0;
     end
     //read data(RD)
     logic [`AXI_DATA_BITS-1:0] reg_RDATA;

     assign data_out = RD_done ? RDATA :  reg_RDATA;


     always_ff@(posedge clk or negedge rst) begin
          if(~rst) 
               reg_RDATA <= `AXI_DATA_BITS'b0;
          else 
               reg_RDATA <= (RD_done) ? RDATA :reg_RDATA;
     
     end

     assign RREADY = (cur_state == READDATA)?1'b1:1'b0;
     
     //write data(WD)
     assign WSTRB   = write_type;
     assign WLAST   = 1'b1;
     assign WDATA   = data_in;

     assign WVALID  = (cur_state == WRITEDATA)? 1'b1:1'b0;

     //response
     assign BREADY  = ((cur_state == RESPONSE)|WD_done)? 1'b1:1'b0;

     assign stall   = (read & ~RD_done) | (write & ~WD_done);

endmodule