module CPU
(
    clk_i, 
    rst_i,
    start_i
);

// Ports
input               clk_i;
input               rst_i;
input               start_i;

// Wires
wire [31:0] Instruction;
wire [1:0] ALUOp;
wire [6:0] Opcode;
wire ALUSrc;
wire RegWrite;
wire [31:0] PCNext;
wire [31:0] PCCurrent;
wire [4:0] RegisterReadAddr1;
wire [4:0] RegisterReadAddr2;
wire [4:0] RegisterWriteAddr;
wire [31:0] RegisterReadData1;
wire [31:0] RegisterReadData2;
wire [31:0] RegisterWriteData;
wire [31:0] ReadData2;
wire [9:0] Function;
wire [2:0] ALUControl;
wire [11:0] SignExtensionIn;
wire [31:0] SignExtensionOut;
wire [31:0] ALUResult;
wire ZeroSignal;

assign Opcode = Instruction[6:0];
assign funct3 = Instruction[14:12];
assign RegisterReadAddr1 = Instruction[19:15];
assign RegisterReadAddr2 = Instruction[24:20];
assign SignExtensionIn = Instruction[31:20];
assign Function = {Instruction[31:25], Instruction[14:12]};
assign RegisterWriteAddr = Instruction[11:7];

Control Control(
    .Op_i       (Opcode),
    .ALUOp_o    (ALUOp),
    .ALUSrc_o   (ALUSrc),
    .RegWrite_o (RegWrite)
);


Adder Add_PC(
    .data1_in   (PCCurrent),
    .data2_in   (32'd4),
    .data_o     (PCNext)
);

PC PC(
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .start_i    (start_i),
    .pc_i       (PCNext),
    .pc_o       (PCCurrent)
);

Instruction_Memory Instruction_Memory(
    .addr_i     (PCCurrent), 
    .instr_o    (Instruction)
);

Registers Registers(
    .clk_i      (clk_i),
    .RS1addr_i   (RegisterReadAddr1),
    .RS2addr_i   (RegisterReadAddr2),
    .RDaddr_i   (RegisterWriteAddr), 
    .RDdata_i   (ALUResult),
    .RegWrite_i (RegWrite), 
    .RS1data_o   (RegisterReadData1), 
    .RS2data_o   (RegisterReadData2) 
);

MUX32 MUX_ALUSrc(
    .data1_i    (RegisterReadData2),
    .data2_i    (SignExtensionOut),
    .select_i   (ALUSrc),
    .data_o     (ReadData2)
);

Sign_Extend Sign_Extend(
    .data_i     (SignExtensionIn),
    .data_o     (SignExtensionOut)
);
  
ALU ALU(
    .data1_i    (RegisterReadData1),
    .data2_i    (ReadData2),
    .ALUCtrl_i  (ALUControl),
    .data_o     (ALUResult),
    .Zero_o     (ZeroSignal)
);

ALU_Control ALU_Control(
    .funct_i    (Function),
    .ALUOp_i    (ALUOp),
    .ALUCtrl_o  (ALUControl)
);

endmodule

