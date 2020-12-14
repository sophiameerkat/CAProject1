module IF_ID (clk, start_i, start_o, PC_i, PC_o, IF_stall, IF_flush, instruction_i, instruction_o);

//Ports
input clk;
input start_i;
input [31:0] PC_i;
input [31:0] instruction_i;
input IF_stall, IF_flush;
output start_o;
output [31:0] PC_o;
output [31:0] instruction_o;

//Registers
reg start_o;
reg [31:0] PC_o;
reg [31:0] instruction_o;

always @(posedge clk) begin
	if(start_i == 1) begin
		start_o = start_i;
		if(IF_flush) begin
			PC_o = 32'b0;
			instruction_o = 32'b0;
		end

		else if(IF_stall) begin
			//do nothing
		end

		else begin
			PC_o = PC_i;
			instruction_o = instruction_i;
		end
	end
end
endmodule