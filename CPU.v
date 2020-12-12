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
wire [31:0] Instruction_pre;

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
    .instr_o    (Instruction_pre)
);

//Wires for IF_ID Stage
wire [31:0] IF_ID_PC_o, Instruction;
wire IFStall, IFFlush;

IF_ID IF_ID(
    .clk    (clk_i),
    .PC_i   (PCCurrent),
    .PC_o   (IF_ID_PC_o),
    .IF_stall   (IFStall),
    .IF_flush   (IFFlush),
    .instruction_i  (Instruction_pre),
    .Instruction_o  (Instruction)
)

//Wires for ID Stage
wire [31:0] imm_to_Adder;
wire MemRead_ID_EXtoEX_MEM;
wire [4:0] RD_ID_EXtoEX_MEM;
wire NoOpSignal; //to Control & ID/EX
wire StallSignal;

Adder Adder(
    .addr_i     (IF_ID_PC_o),
    .imm_i      (imm_to_Adder),
    .addr_o     (PCBranch)
);

HazardDetectionUnit HazardDetectionUnit(
    .MemReadSignal_i    (MemRead_ID_EXtoEX_MEM),
    .RS1_i  (RegisterReadAddr1),
    .RS2_i  (RegisterReadAddr2),
    .RD_i   (RD_ID_EXtoEX_MEM),
    .noOpSignal_o   (NoOpSignal),
    .stallSignal_o  (StallSignal),　
    .PCWriteSignal_o    (PCWrite)
);

/* Below haven't finish yet */

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

