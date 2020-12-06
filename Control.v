module Control(Op_i, ALUOp_o, ALUSrc_o, RegWrite_o);

//Ports
input [6:0] Op_i;
output [1:0] ALUOp_o;
output ALUSrc_o;
output RegWrite_o;

//Regsiters
reg [1:0] ALUOp_o;
reg ALUSrc_o;
reg RegWrite_o;

always @(*) begin
	case(Op_i)
		7'b0110011: //R type
			begin
			ALUOp_o = 2'b10;
			ALUSrc_o = 1'b0;
			RegWrite_o = 1'b1;
			end
		7'b0010011: // I type
			begin
			ALUOp_o = 2'b00;
			ALUSrc_o = 1'b1;
			RegWrite_o = 1'b1;
			end
	endcase
end
endmodule
