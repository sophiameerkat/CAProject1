module IF_ID (clk, PC_i, PC_o, IF_stall, IF_flush, instruction_i, instruction_o);

//Ports
input clk;
input [31:0] PC_i;
input IF_stall;
input IF_flush;
input [31:0] instruction_i;
output [31:0] PC_o;
output [31:0] instruction_o;

//Registers
reg [31:0] PC_o;
reg [31:0] instruction_o;


