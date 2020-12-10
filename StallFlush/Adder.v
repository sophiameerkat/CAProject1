module Adder
(
	addr_i,
	ins_i,
	addr_o
);

input [31:0] addr_i;
input [31:0] ins_i;
output [31:0] addr_o;

reg [11:0] imm;
reg [31:0] addr_oReg;
assign addr_o = addr_oReg;

always@* begin
	//[31:25] = imm[12, 10:5] [11:7] = imm[4:1, 11]
	imm = {ins_i[31], ins_i[7], ins_i[30:25], ins_i[11:8]};
	imm = imm << 1;
	addr_oReg = addr_i + imm;
end

endmodule