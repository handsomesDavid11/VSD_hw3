module PriorityEncoder(
			input [32:0] fra_sub,
			input [7:0] exp1,
			output reg [32:0] sub_diff,
			output [7:0] exp_sub,
			output GuardBit,
			output RoundBit
			
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
			sub_diff = fra_sub << 1;
			shift = 5'd1;
		end
		33'b1_001x_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : 	
		begin						
				sub_diff = fra_sub << 2;
					shift = 5'd2;
			end

		33'b1_0001_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : 	
		begin 							
				sub_diff = fra_sub << 3;
					shift = 5'd3;
			end

		33'b1_0000_1xxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : 	
		begin						
				sub_diff = fra_sub << 4;
				shift = 5'd4;
				end

		33'b1_0000_01xx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : 	
		begin						
				sub_diff = fra_sub << 5;
				shift = 5'd5;
				end

		33'b1_0000_001x_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : 	
		begin						// 24'h020000
				sub_diff = fra_sub << 6;
				shift = 5'd6;
				end

		33'b1_0000_0001_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : 	
		begin						// 24'h010000
				sub_diff = fra_sub << 7;
				shift = 5'd7;
				end

		33'b1_0000_0000_1xxx_xxxx_xxxx_xxxx_xxxx_xxxx : 	
		begin						// 24'h008000
				sub_diff = fra_sub << 8;
				shift = 5'd8;
				end

		33'b1_0000_0000_01xx_xxxx_xxxx_xxxx_xxxx_xxxx : 	
		begin						// 24'h004000
				sub_diff = fra_sub << 9;
				shift = 5'd9;
				end

		33'b1_0000_0000_001x_xxxx_xxxx_xxxx_xxxx_xxxx : 	
		begin						// 24'h002000
				sub_diff = fra_sub << 10;
				shift = 5'd10;
				end

		33'b1_0000_0000_0001_xxxx_xxxx_xxxx_xxxx_xxxx : 	
		begin						// 24'h001000
				sub_diff = fra_sub << 11;
				shift = 5'd11;
				end

		33'b1_0000_0000_0000_1xxx_xxxx_xxxx_xxxx_xxxx : 	
		begin						// 24'h000800
				sub_diff = fra_sub << 12;
				shift = 5'd12;
				end

		33'b1_0000_0000_0000_01xx_xxxx_xxxx_xxxx_xxxx : 	
		begin						// 24'h000400
				sub_diff = fra_sub << 13;
				shift = 5'd13;
				end

		33'b1_0000_0000_0000_001x_xxxx_xxxx_xxxx_xxxx : 	
		begin						// 24'h000200
				sub_diff = fra_sub << 14;
				shift = 5'd14;
				end

		33'b1_0000_0000_0000_0001_xxxx_xxxx_xxxx_xxxx : 	
		begin						// 24'h000100
				sub_diff = fra_sub << 15;
				shift = 5'd15;
				end

		33'b1_0000_0000_0000_0000_1xxx_xxxx_xxxx_xxxx : 	
		begin						// 24'h000080
				sub_diff = fra_sub << 16;
				shift = 5'd16;
				end

		33'b1_0000_0000_0000_0000_01xx_xxxx_xxxx_xxxx : 	
		begin						// 24'h000040
				sub_diff = fra_sub << 17;
					shift = 5'd17;
			end

		33'b1_0000_0000_0000_0000_001x_xxxx_xxxx_xxxx : 	
		begin						// 24'h000020
				sub_diff = fra_sub << 18;
				shift = 5'd18;
				end

		33'b1_0000_0000_0000_0000_0001_xxxx_xxxx_xxxx : 	
		begin						// 24'h000010
				sub_diff = fra_sub << 19;
				shift = 5'd19;
			end

		33'b1_0000_0000_0000_0000_0000_1xxx_xxxx_xxxx :	
		begin						// 24'h000008
				sub_diff = fra_sub << 20;
				shift = 5'd20;
			end

		33'b1_0000_0000_0000_0000_0000_01xx_xxxx_xxxx : 	
		begin						// 24'h000004
				sub_diff = fra_sub << 21;
				shift = 5'd21;
				end

		33'b1_0000_0000_0000_0000_0000_001x_xxxx_xxxx : 	
		begin						// 24'h000002
				sub_diff = fra_sub << 22;
				shift = 5'd22;
				end

		33'b1_0000_0000_0000_0000_0000_0001_xxxx_xxxx : 	
		begin						// 24'h000001
				sub_diff = fra_sub << 23;
				shift = 5'd23;
				end

		33'b1_0000_0000_0000_0000_0000_0000_xxxx_xxxx : 	
		begin						// 24'h000000
				sub_diff = fra_sub << 24;
					shift = 5'd24;
			end
		default : 	begin
						sub_diff = (~fra_sub) + 1'b1;
						shift = 5'd0;
					end

	endcase
end
assign exp_sub = exp1 - shift;

endmodule