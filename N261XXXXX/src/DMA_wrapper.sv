module DMA_wrapper (
     //master to  AXI
     //Address write
     output logic [`AXI_ID_BITS-1:0] AWID_M,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_M,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_M,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_M,
	output logic [1:0] AWBURST_M,
	output logic AWVALID_M,
	input AWREADY_M,
	
	//WRITE DATA
	output logic [`AXI_DATA_BITS-1:0] WDATA_M,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_M,
	output logic WLAST_M,
	output logic WVALID_M,
	input WREADY_M,
     //WRITE RESPONSE
	input [`AXI_ID_BITS-1:0] BID_M,
	input [1:0] BRESP_M,
	input BVALID_M,
	output logic BREADY_M,

     output logic [`AXI_ID_BITS-1:0] ARID_M,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_M,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_M,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_M,
	output logic [1:0] ARBURST_M,
	output logic ARVALID_M,
	input ARREADY_M,
	
	//READ DATA0
	input [`AXI_ID_BITS-1:0] RID_M,
	input [`AXI_DATA_BITS-1:0] RDATA_M,
	input [1:0] RRESP_M,
	input RLAST_M,
	input RVALID_M,
	output logic RREADY_M,

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

     output logic interrupt

);
     logic [31:0] DMASRC, DMADST;
     logic [31:0] DMALEN;  //Total length of the data
     logic DMAEN;  // Enable the DMA

     DMA_master DMA_master(
          
          
     ); 
     DMA_slave DMA_slave(

     );


endmodule
