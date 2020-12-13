module MEM_WB(clk_i, RegWrite_i, MemReg_i, rd_addr_i, RegWrite_o, MemReg_o, data1_i, data2_i, data1_o, data2_o, rd_addr_o);

//Ports
input clk_i;
input RegWrite_i, MemReg_i;
input [5:0] rd_addr_i;
input [31:0] data1_i, data2_i;

output RegWrite_o, MemReg_o;
output [5:0] rd_addr_o;
output [31:0] data1_o, data2_o;

//Registers
reg RegWrite_o, MemReg_o;
reg [5:0] rd_addr_i;
reg [31:0] data1_o, data2_o;

initial begin
	RegWrite_o = 0;
	MemReg_o = 0;
	rd_addr_o = 0;
	data1_o = 0;
	data2_o = 0;
end

always @(posedge clk_i) begin
	RegWrite_o = RegWrite_i;
	MemReg_o = MemReg_i;
	rd_addr_o = rd_addr_i;
	data1_o = data1_i;
	data2_o = data2_i;
end
endmodule
