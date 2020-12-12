module EX_MEM(clk_i, RegWrite_i, MemReg_i, MemRead_i, MemWrite_i, ALUResult_i, RegWrite_o, MemReg_o, MemRead_o, MemWrite_o, rs2_data_i, rd_addr_i, rd_addr_o, ALUResult_o, MemData_o);

//Ports
input clk_i;
input RegWrite_i, MemReg_i, MemRead_i, MemWrite_i;
input [31:0] ALUResult_i, rs2_data_i, rd_addr_i;

output RegWrite_o, MemReg_o, MemRead_o, MemWrite_o;
output [31:0] rd_addr_o, ALUResult_o, MemData_o;

//Registers
reg RegWrite_o, MemReg_o, MemRead_o, MemWrite_o;
reg [31:0] rd_addr_o, ALUResult_o, MemData_o;

initial begin
	RegWrite_o = 0;
	MemReg_o = 0;
	MemRead_o = 0;
	MemWrite_o = 0;
	rd_addr_o = 0;
	MemAddr_o = 0;
	MemData_o = 0;
end

always @(posedge clk_i) begin
	RegWrite_o = RegWrite_i;
	MemReg_o = MemReg_i;
	MemRead_o = MemRead_i;
	MemWrite_o = MemWrite_i;
	rd_addr_o = rd_addr_i;
	ALUResult_o = ALUResult_i;
	MemData_o = rs2_data_i;
end