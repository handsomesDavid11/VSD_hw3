
module DefaultSlave (
    input clk,    // Clock
    input rst,  // Asynchronous reset active high

    // DA receive
    input [`AXI_IDS_BITS-1:0] ARID_default,
    input [`AXI_ADDR_BITS-1:0] ARADDR_default,
    input [`AXI_LEN_BITS-1:0] ARLEN_default,
    input [`AXI_SIZE_BITS-1:0] ARSIZE_default,
    input [1:0] ARBURST_default,
    input ARVALID_default,
    // DA send
    output logic ARREADY_default,

    // DR send
    output logic [`AXI_IDS_BITS-1:0] RID_default,
    output logic [`AXI_DATA_BITS-1:0] RDATA_default,
    output logic [1:0] RRESP_default,
    output logic RLAST_default,
    output logic RVALID_default,
    // DR receive
    input RREADY_default,

    // WA receive
    input [`AXI_IDS_BITS-1:0] AWID_default,
    input [`AXI_ADDR_BITS-1:0] AWADDR_default,
    input [`AXI_LEN_BITS-1:0] AWLEN_default,
    input [`AXI_SIZE_BITS-1:0] AWSIZE_default,
    input [1:0] AWBURST_default,
    input AWVALID_default,
    // WA send
    output logic AWREADY_default,

    // WD receive
    input [`AXI_DATA_BITS-1:0] WDATA_default,
    input [`AXI_STRB_BITS-1:0] WSTRB_default,
    input WLAST_default,
    input WVALID_default,
    // WD send
    output logic WREADY_default,

    // WR send
    output logic [`AXI_IDS_BITS-1:0] BID_default,
    output logic [1:0] BRESP_default,
    output logic BVALID_default,
    // WR receive
    input BREADY_default
);

    logic [1:0] cur_state, next_state;
    logic AR_done, RD_done, AW_done, WD_done, RES_done;
    assign AR_done  = ARVALID_default & ARREADY_default;
    assign RD_done  = RVALID_default  & RREADY_default;
    assign AW_done  = AWVALID_default & AWREADY_default;
    assign WD_done  = WVALID_default  & WREADY_default;
    assign RES_done = BVALID_default  & BREADY_default; 

    logic RD_done_last, WD_done_last;
    assign RD_done_last = RLAST_default & RD_done;
    assign WD_done_last = WLAST_default & WD_done;

    parameter [1:0] ADDR        = 2'b00,
                    DATAREAD    = 2'b01,
                    DATAWRITE   = 2'b10,
                    RESPONSE    = 2'b11;

    always_ff @(posedge clk or negedge rst) begin
        if(~rst) begin
            cur_state <= 2'b00;
        end else begin
            cur_state <= next_state;
        end
    end

    always_comb begin
        case(cur_state)
            ADDR: begin
                if(ARREADY_default & ARVALID_default)
                    next_state = DATAREAD;
                else if (AWREADY_default & AWVALID_default)
                    next_state = DATAWRITE;
                else
                    next_state = ADDR;
            end
            DATAREAD: begin
                if(RVALID_default & RREADY_default)
                    next_state = ADDR;
                else
                    next_state = DATAREAD;
            end
            DATAWRITE: begin
                //if(WLAST_default)
                if(WREADY_default & WVALID_default & WLAST_default)
                    next_state = RESPONSE;
                else
                    next_state = DATAWRITE;
            end
            RESPONSE: begin
                if(BVALID_default & BREADY_default)
                    next_state = ADDR;
                else
                    next_state = RESPONSE;
            end
        endcase // cur_state
    end

    logic tmp_ARLEN;

    always_ff @(posedge clk or negedge rst) begin
        if(~rst)
            tmp_ARLEN <= 1'b0;
        else
            tmp_ARLEN <= (ARREADY_default & ARVALID_default)? ARLEN_default:tmp_ARLEN;
    end

    // RA, R
    assign ARREADY_default = ((cur_state == ADDR))? 1'b1:1'b0;
    always_ff @(posedge clk or negedge rst) begin
        if(~rst) begin
            RID_default <= 8'b0;
        end else begin
            RID_default <= (ARREADY_default & ARVALID_default)? ARID_default:RID_default;
        end
    end
    assign RDATA_default = `AXI_DATA_BITS'b0;
    assign RRESP_default = `AXI_RESP_DECERR;
    //assign RLAST_default = 1'b1;



    logic [`AXI_LEN_BITS-1:0] reg_ARLEN, reg_AWLEN;
     always_ff @(posedge ACLK or negedge ARESETn)begin
          if(~ARESETn)begin
               reg_ARLEN <= `AXI_LEN_BITS'b0;
               reg_AWLEN <= `AXI_LEN_BITS'b0;
          end
          else begin
               reg_ARLEN <= (AR_done)? ARLEN_default:reg_ARLEN;
               reg_AWLEN <= (AW_done)? AWLEN_default:reg_AWLEN;
          end
     end

    logic [`AXI_LEN_BITS-1:0] cnt;

     always_ff @(posedge ACLK or negedge ARESETn) begin
          if(~ARESETn)
               cnt <= `AXI_LEN_BITS'h0
          else begin
               case(cur_state)
                    READDATA: cnt <= (RD_done_last)? `AXI_LEN_BITS'b0:((RD_done)? cnt+ `AXI_LEN_BITS'b1:cnt);
                    WRITEDATA:cnt <= (WD_done_last)? `AXI_LEN_BITS'b0:((WD_done)? cnt+`AXI_LEN_BITS'b1:cnt);
               endcase
          end

          
     end
     assign RLAST_default = (cnt == reg_ARLEN);



    /*

    always_ff @(posedge clk or negedge rst) begin
        if(~rst)
            RLAST_default <= 1'b1;
        else begin
            if(ARREADY_default & ARVALID_default) begin
                if(ARLEN_default == 4'b1)
                    RLAST_default <= 1'b0;
                else
                    RLAST_default <= 1'b1; 
            end
            else if(RVALID_default & RREADY_default) begin
                if((tmp_ARLEN == 4'b1) & (RLAST_default == 1'b0))
                    RLAST_default <= 1'b1;
            end
        end
    end
    */


    assign RVALID_default = (cur_state == DATAREAD)? 1'b1:1'b0;

    // AW
    assign AWREADY_default = (AWVALID_default & (cur_state == ADDR))? 1'b1:1'b0;
    always_ff @(posedge clk or negedge rst) begin
        if(~rst) begin
            BID_default <= 8'b0;
        end else begin
            BID_default <= (AWREADY_default & AWVALID_default)? AWID_default:BID_default;
        end
    end
    assign WREADY_default = (WVALID_default && (cur_state == DATAWRITE));
    assign BRESP_default = `AXI_RESP_DECERR;
    assign BVALID_default = (cur_state == RESPONSE)? 1'b1:1'b0;



endmodule 