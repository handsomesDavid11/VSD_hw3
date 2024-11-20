module MEM(


     input clk,
     input rst,
//--------------------------control unit--------------------------//
     input        EXE_RDSrc,
     input        EXE_MemtoReg,
     input        EXE_MemWrite,
     input        EXE_MemRead,
     input        EXE_RegWrite,
     input        EXE_FRegWrite,
//--------------------------
     input [31:0] EXE_pc_to_reg,
     input [31:0] EXE_ALU_out,
     input [31:0] EXE_rs2_data,
     input [4:0] EXE_rd_addr,
     input [2:0] EXE_funct3,


     output reg MEM_MemtoReg,
     output reg MEM_RegWrite,
     output reg MEM_FRegWrite,
     output reg [31:0] MEM_rd_data,    
     output reg [31:0] MEM_Dout,    //data from data mem
     output reg [4:0] MEM_rd_addr,
     //output reg [31:0] wire_mem_rd_data,
//---------------------------Data memory------------------------//
     input [31:0] Dout,
     output reg wire_chip_select,                    //chip select
     output reg [3:0] wire_WE,                   //write enable 
     output reg [31:0] wire_Din ,                //data in 
     output [31:0] wire_mem_rd_data,

     input MEMWB_RegWrite

);

     

     assign wire_mem_rd_data = (EXE_RDSrc) ? EXE_pc_to_reg : EXE_ALU_out;
     assign wire_chip_select =!( EXE_MemRead | EXE_MemWrite);






    always_comb begin
        wire_WE = 4'b1111;
        if(EXE_MemWrite) begin
            case (EXE_funct3)
                3'b000: // SB
                    wire_WE[EXE_ALU_out[1:0]] = 1'b0;
                3'b001: // SH
                    wire_WE[{EXE_ALU_out[1], 1'b0}+:2] = 2'b0;
                default: // SW
                    wire_WE = 4'b0000;
            endcase
        end
    end    

     always_comb begin
        wire_Din = 32'b0;
        case (EXE_funct3)
            3'b000: // SB
                wire_Din[{EXE_ALU_out[1:0], 3'b0}+:8] = EXE_rs2_data[7:0];
            3'b001: // SH
                wire_Din[{EXE_ALU_out[1], 4'b0}+:16] = EXE_rs2_data[15:0];
            default : // SW
                wire_Din = EXE_rs2_data;
        endcase
    end



always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            MEM_MemtoReg    <= 1'b0;
            MEM_RegWrite    <= 1'b0;
            MEM_FRegWrite    <= 1'b0;
            MEM_rd_data     <= 32'b0;
            MEM_Dout        <= 32'b0;
            MEM_rd_addr     <= 5'b0;
        end else begin
                if(MEMWB_RegWrite) begin
                    MEM_MemtoReg    <= EXE_MemtoReg;
                    MEM_RegWrite    <= EXE_RegWrite;
                    MEM_FRegWrite    <= EXE_FRegWrite;
                

            if(EXE_RDSrc)
                MEM_rd_data <= EXE_pc_to_reg;
            else
                MEM_rd_data <= EXE_ALU_out;

 
            case(EXE_funct3)
                3'b010: // LW
                    MEM_Dout <= Dout;
                3'b000: // LB
                    MEM_Dout <= {{24{Dout[7]}}, Dout[7:0]};
                3'b001: // LH
                    MEM_Dout <= {{16{Dout[15]}}, Dout[15:0]};
                3'b100: // LBU
                    MEM_Dout <= {24'b0, Dout[7:0]};
                3'b101: // LHU
                    MEM_Dout <= {16'b0, Dout[15:0]};
                default:
                    MEM_Dout <= 32'b0;
            endcase // EXE_funct3

            MEM_rd_addr     <= EXE_rd_addr;
        end
        end
    end

     

     



endmodule