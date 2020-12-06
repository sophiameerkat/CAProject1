module MUX32(data1_i, data2_i, select_i, data_o);

//Ports
input [31:0] data1_i;
input [31:0] data2_i;
input select_i;
output [31:0] data_o;

//Registers 
reg [31:0] data_o;

always@(data1_i or data2_i or select_i) begin
	if (select_i == 0)
		begin
		data_o = data1_i;
		end
	else
		begin
		data_o = data2_i;
		end
end

endmodule