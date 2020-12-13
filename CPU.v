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
//Adder
wire [31:0] SignExtensionOut;
//HazarDetectionUnit
wire MemRead_ID_EXtoEX_MEM;
assign RegisterReadAddr1 = Instruction[19:15];
assign RegisterReadAddr2 = Instruction[24:20];
wire [4:0] RD_ID_EXtoEX_MEM;
wire NoOpSignal; //to Control & ID/EX
wire StallSignal;
//Control
assign Opcode = Instruction[6:0];
wire RegWrite;
wire MemtoReg;
wire MemRead;
wire MemWrite;
wire ALUOp;
wire ALUSrc;
wire Branch;
//Registers
wire [4:0] RDaddr_MEM_WBtoRegs;
wire [31:0] RDdata_MEM_WBtoRegs;
wire RegWrite_MEM_WBtoRegs;
wire [31:0] RS1data_RegstoID_EX;
wire [31:0] RS2data_RegstoID_EX;
//Sign_Extend
wire [31:0] SignExtensionIn;
assign SignExtensionIn = Instruction;
//ID_branch
wire Zero_ID_zerotoID_branch;
wire BranchTaken;

Adder Adder(
    .addr_i     (IF_ID_PC_o),
    .imm_i      (SignExtensionOut),
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

Control Control(
    .Op_i       (Opcode),
    .RegWrite_o (RegWrite), 
    .MemReg_o   (MemtoReg), 
    .MemRead_o  (MemRead), 
    .MemWrite_o (MemWrite), 
    .ALUOp_o    (ALUOp),
    .ALUSrc_o   (ALUSrc),
    .Branch_o (Branch)
);

Registers Registers(
    .clk_i      (clk_i),
    .RS1addr_i   (RegisterReadAddr1),
    .RS2addr_i   (RegisterReadAddr2),
    .RDaddr_i   (RDaddr_MEM_WBtoRegs), 
    .RDdata_i   (RDdata_MEM_WBtoRegs),
    .RegWrite_i (RegWrite_MEM_WBtoRegs), 
    .RS1data_o   (RS1data_RegstoID_EX), 
    .RS2data_o   (RS2data_RegstoID_EX) 
);

Sign_Extend Sign_Extend(
    .data_i     (SignExtensionIn),
    .data_o     (SignExtensionOut)
);

ID_branch ID_branch(
    .branchSignal_i     (Branch),
    .zero_i     (Zero_ID_zerotoID_branch),
    .branchTaken_o      (BranchTaken)
);

ID_zero ID_zero(
    .data1_i    (RS1data_RegstoID_EX),
    .data2_i    (RS2data_RegstoID_EX), 
    .zero_o     (Zero_ID_zerotoID_branch)
);

//Wires for ID/EX Stage
wire [4:0] RS1_IF_IDtoID_EX;
wire [4:0] RS2_IF_IDtoID_EX;
wire [4:0] RD_IF_IDtoID_EX;
wire [9:0] Funct_IF_IDtoID_EX;
assign Funct_IF_IDtoID_EX = {Instruction[31;25], Instruction[14:12]};
wire RegWrite_ID_EXtoEX_MEM;
wire MemtoReg_ID_EXtoEX_MEM;
wire MemRead_ID_EXtoEX_MEM;
wire MemWrite_ID_EXtoEX_MEM;
wire ALUOp_ID_EXtoALUControl;
wire ALUSrc_ID_EXtoMUX;
wire [31:0] RS1data_ID_EXtoMUX;
wire [31:0] RS2data_ID_EXtoMUX;
wire [9:0] Funct_ID_EXtoALUControl;
wire [4:0] RS1_ID_EXtoFU;
wire [4:0] RS2_ID_EXtoFU;
wire [31:0] imm_ID_EXtoMUX;

ID_EX ID_EX(
    .clk_i  (clk_i),
    //signals
    RegWrite_i      (RegWrite),
    MemtoReg_i  (MemtoReg),
    MemRead_i   (MemRead),
    MemWrite_i     (MemWrite),
    ALUOp_i     (ALUOp),
    ALUSrc_i    (ALUSrc),
    NoOp_i      (NoOpSignal),
    //register data
    reg1Data_i  (RS1data_RegstoID_EX),
    reg2Data_i  (RS2data_RegstoID_EX),
    //regID
    rs1_i   (RS1_IF_IDtoID_EX),
    rs2_i   (RS2_IF_IDtoID_EX),
    rd_i    (RD_IF_IDtoID_EX),
    //others
    funct_i     (Funct_IF_IDtoID_EX),
    imm_i   (SignExtensionOut),

    RegWrite_o  (RegWrite_ID_EXtoEX_MEM),
    MemtoReg_o  (MemtoReg_ID_EXtoEX_MEM),
    MemRead_o   (MemRead_ID_EXtoEX_MEM),
    MemWrite_o  (MemWrite_ID_EXtoEX_MEM),
    ALUOp_o     (ALUOp_ID_EXtoALUControl),
    ALUSrc_o    (ALUSrc_ID_EXtoMUX),
    reg1Data_o  (RS1data_ID_EXtoMUX),
    reg2Data_o  (RS2data_ID_EXtoMUX),
    rs1_o   (RS1_ID_EXtoFU),
    rs2_o   (RS2_ID_EXtoFU),
    rd_o    (RD_ID_EXtoEX_MEM),
    funct_o  (Funct_ID_EXtoALUControl),
    imm_o   (imm_ID_EXtoMUX)
);


/* Below haven't finish yet */






// Wires
wire [31:0] ReadData2;
wire [9:0] Function;
wire [2:0] ALUControl;
wire [31:0] ALUResult;
wire ZeroSignal;

assign funct3 = Instruction[14:12];
assign Function = {Instruction[31:25], Instruction[14:12]};
assign RegisterWriteAddr = Instruction[11:7];

MUX32 MUX_ALUSrc(
    .data1_i    (RegisterReadData2),
    .data2_i    (SignExtensionOut),
    .select_i   (ALUSrc),
    .data_o     (ReadData2)
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

