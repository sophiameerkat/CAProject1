module MEM_WB(clk_i, start_i, RegWrite_i, MemReg_i, rd_addr_i, RegWrite_o, MemReg_o, data1_i, data2_i, data1_o, data2_o, rd_addr_o);

//Ports
input clk_i;
input start_i;
input RegWrite_i, MemReg_i;
input [4:0] rd_addr_i;
input [31:0] data1_i, data2_i;

output RegWrite_o, MemReg_o;
output [4:0] rd_addr_o;
output [31:0] data1_o, data2_o;

//Registers
reg RegWrite_o, MemReg_o;
reg [4:0] rd_addr_o;
reg [31:0] data1_o, data2_o;
reg [31:0] qq;
reg regw, memr;
reg [4:0] rda;

/*initial begin
	{ RegWrite_o, MemReg_o, rd_addr_o, data1_o, data2_o } <= 0;
end
*/
always@(*) begin
	qq = data1_i;
	regw = RegWrite_i;
	memr = MemReg_i;
	rda = rd_addr_i;
end

always @(posedge clk_i) begin
	if(start_i == 1) begin
		RegWrite_o <= regw;
		MemReg_o <= memr;
		rd_addr_o <= rda;
		data1_o <= qq;
		data2_o <= data2_i;
	end
end
endmodule
