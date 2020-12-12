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

//Wires for IF Stage
wire [31:0] PCNext_pre, PCNext, PCCurrent, PCBranch;
wire PCWrite;
wire PC_signal;
wire [31:0] Instruction;

PC_Adder PC_Adder(
    .data1_in   (PCCurrent),
    .data2_in   (32'd4),
    .data_o     (PCNext)
);

PC_MUX PC_MUX(
    .branchTaken_i (PC_signal),
    .addrNotTaken_i (PCNext),
    .addrTaken_i (PCBranch),
    .addr_o (PCNext_pre)
)

PC PC(
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .start_i    (start_i),
    .PCWrite_i  (PCWrite),
    .pc_i       (PCNext_pre),
    .pc_o       (PCCurrent)
);

Instruction_Memory Instruction_Memory(
    .addr_i     (PCCurrent), 
    .instr_o    (Instruction)
);

//Wires for IF_ID Stage
wire [31:0] IF_ID_PC_o, IF_ID_Instruction_o;
wire IFStall, IFFlush;

IF_ID IF_ID(
    .clk    (clk_i),
    .PC_i   (PCCurrent),
    .PC_o   (IF_ID_PC_o),
    .IF_stall   (IFStall),
    .IF_flush   (IFFlush),
    .instruction_i  (instruction),
    .Instruction_o  (IF_ID_Instruction_o)
)

//Wires for ID Stage
wire [4:0] RegisterReadAddr1, RegisterReadAddr2, RegisterWriteAddr;
wire RegWrite;
wire [31:0] RegisterReadData1, RegisterReadData2, RegisterWriteData;
wire [6:0] Opcode;
wire [1:0] ALUOp;
wire NoOp_signal, RegWrite, MemtoReg, MemRead, MemWrite, ALUSrc, Branch;


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

Control Control(
    .Op_i       (Opcode),
    .No_Op_i    (NoOp_signal),
    .RegWrite_o (RegWrite), 
    .MemReg_o   (MemtoReg), 
    .MemRead_o  (MemRead), 
    .MemWrite_o (MemWrite), 
    .ALUOp_o    (ALUOp),
    .ALUSrc_o   (ALUSrc),
    .Branch_o (Branch)
);


/* Below haven't finish yet */

// Wires
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

