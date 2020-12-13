module Sign_Extend(data_i, data_o);

//Ports
input [31:0] data_i; //it is now the whole instruction
output [31:0] data_o;

//need to be modified?
assign data_o = { {20{data_i[11]}}, data_i[11:0]};
endmodule