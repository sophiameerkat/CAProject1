module Adder
(
	addr_i,
	imm_i,
	addr_o
);

input [31:0] addr_i;
input [31:0] imm_i;
output [31:0] addr_o;

reg [11:0] imm;
reg [31:0] addr_oReg;
assign addr_o = addr_oReg;

always@* begin
	imm = imm << 1;
	addr_oReg = addr_i + imm;
end

endmodule