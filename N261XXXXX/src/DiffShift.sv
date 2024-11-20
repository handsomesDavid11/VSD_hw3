module DiffShift(
			input [32:0] fra_sub,
			input [7:0] exp1,
			output reg [32:0] sub_diff,
			output [7:0] exp_sub
			
			);

reg [4:0] shift;

always @(fra_sub)
begin
	casex (fra_sub)
		33'b1_1xxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx :	
		begin
			sub_diff = fra_sub;
			shift = 5'd0;

		end
		33'b1_01xx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : 	
		begin						
			//sub_diff = fra_sub <<5'd1;

			sub_diff = {fra_sub[31:0],1'b0};
			shift = 5'd1;
		end
		33'b1_001x_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : 	
		begin						
			//sub_diff = fra_sub <<5'd2;
					shift = 5'd2;
			sub_diff = {fra_sub[30:0],2'b0};
			end

		33'b1_0001_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : 	
		begin 							
			//sub_diff = fra_sub <<5'd3;
					shift = 5'd3;
			sub_diff = {fra_sub[29:0],3'b0};
			end

		33'b1_0000_1xxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : 	
		begin						
			//sub_diff = fra_sub <<5'd4;
				shift = 5'd4;
				sub_diff = {fra_sub[28:0],4'b0};
				end

		33'b1_0000_01xx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : 	
		begin						
			//sub_diff = fra_sub <<5'd5;
				shift = 5'd5;
				sub_diff = {fra_sub[27:0],5'b0};
				end

		33'b1_0000_001x_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : 	
		begin						
			//sub_diff = fra_sub <<5'd6;
				shift = 5'd6;
				sub_diff = {fra_sub[26:0],6'b0};
				end

		33'b1_0000_0001_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : 	
		begin						
			//sub_diff = fra_sub <<5'd7;
				shift = 5'd7;
				sub_diff = {fra_sub[25:0],7'b0};
				end

		33'b1_0000_0000_1xxx_xxxx_xxxx_xxxx_xxxx_xxxx : 	
		begin						
			//sub_diff = fra_sub <<5'd8;
				shift = 5'd8;
				sub_diff = {fra_sub[24:0],8'b0};
				end

		33'b1_0000_0000_01xx_xxxx_xxxx_xxxx_xxxx_xxxx : 	
		begin						
			//sub_diff = fra_sub <<5'd9;
				shift = 5'd9;
				sub_diff = {fra_sub[23:0],9'b0};
				end

		33'b1_0000_0000_001x_xxxx_xxxx_xxxx_xxxx_xxxx : 	
		begin						
			//sub_diff = fra_sub <<5'd10;
				shift = 5'd10;
				sub_diff = {fra_sub[22:0],10'b0};
				end

		33'b1_0000_0000_0001_xxxx_xxxx_xxxx_xxxx_xxxx : 	
		begin						
			//sub_diff = fra_sub <<5'd11;
				shift = 5'd11;
				sub_diff = {fra_sub[21:0],11'b0};
				end

		33'b1_0000_0000_0000_1xxx_xxxx_xxxx_xxxx_xxxx : 	
		begin						
			//sub_diff = fra_sub <<5'd12;
				shift = 5'd12;
				sub_diff = {fra_sub[20:0],12'b0};
				end

		33'b1_0000_0000_0000_01xx_xxxx_xxxx_xxxx_xxxx : 	
		begin						
			//sub_diff = fra_sub <<5'd13;
				shift = 5'd13;
				sub_diff = {fra_sub[19:0],13'b0};
				end

		33'b1_0000_0000_0000_001x_xxxx_xxxx_xxxx_xxxx : 	
		begin						
			//sub_diff = fra_sub <<5'd14;
				shift = 5'd14;
				sub_diff = {fra_sub[18:0],14'b0};
				end

		33'b1_0000_0000_0000_0001_xxxx_xxxx_xxxx_xxxx : 	
		begin						
			//sub_diff = fra_sub <<5'd15;
				shift = 5'd15;
				sub_diff = {fra_sub[17:0],15'b0};
				end

		33'b1_0000_0000_0000_0000_1xxx_xxxx_xxxx_xxxx : 	
		begin						
			//sub_diff = fra_sub <<5'd16;
				shift = 5'd16;
				sub_diff = {fra_sub[16:0],16'b0};
				end

		33'b1_0000_0000_0000_0000_01xx_xxxx_xxxx_xxxx : 	
		begin						
			//sub_diff = fra_sub <<5'd17;
					shift = 5'd17;
			sub_diff = {fra_sub[15:0],17'b0};
			end

		33'b1_0000_0000_0000_0000_001x_xxxx_xxxx_xxxx : 	
		begin						
			//sub_diff = fra_sub <<5'd18;
				shift = 5'd18;
				sub_diff = {fra_sub[14:0],18'b0};
				end

		33'b1_0000_0000_0000_0000_0001_xxxx_xxxx_xxxx : 	
		begin						
			//sub_diff = fra_sub <<5'd19;
				shift = 5'd19;
			sub_diff = {fra_sub[13:0],19'b0};
			end

		33'b1_0000_0000_0000_0000_0000_1xxx_xxxx_xxxx :	
		begin						
			//sub_diff = fra_sub <<5'd20;
				shift = 5'd20;
			sub_diff = {fra_sub[12:0],20'b0};
			end

		33'b1_0000_0000_0000_0000_0000_01xx_xxxx_xxxx : 	
		begin						
			//sub_diff = fra_sub <<5'd21;
				shift = 5'd21;
				sub_diff = {fra_sub[11:0],21'b0};
				end

		33'b1_0000_0000_0000_0000_0000_001x_xxxx_xxxx : 	
		begin						
			//sub_diff = fra_sub <<5'd22;
				shift = 5'd22;
				sub_diff = {fra_sub[10:0],22'b0};
				end

		33'b1_0000_0000_0000_0000_0000_0001_xxxx_xxxx : 	
		begin						
			//sub_diff = fra_sub <<5'd23;
				shift = 5'd23;
				sub_diff = {fra_sub[9:0],23'b0};
				end

		33'b1_0000_0000_0000_0000_0000_0000_xxxx_xxxx : 	
		begin						
			//sub_diff = fra_sub <<5'd24;
					shift = 5'd24;
			sub_diff = {fra_sub[8:0],24'b0};
			end
		default : 	begin
					sub_diff = (~fra_sub) + 1'b1;
						shift = 5'd0;
					sub_diff = {fra_sub[7:0],25'b0};
					end

	endcase
end
assign exp_sub = exp1 - shift;

endmodule