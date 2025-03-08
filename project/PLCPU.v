`include "ctrl_encode_def.v"
module PLCPU(
    input      clk,            // clock
    input      reset,          // reset
    input [31:0]  inst_in,     // instruction
    input [31:0]  Data_in,     // data from data memory
    output [31:0] PC_out,     // PC address
    output [31:0] Addr_out,   // ALU output
    output [31:0] Data_out,   // data to data memory
    output    mem_w,          // output: memory write signal
    output    mem_r           // output: memory read signal
);
    wire stall;
    wire flush;

    wire [1:0] ForwardA, ForwardB;
    wire        RegWrite;    // control signal to register write
    wire [5:0]  EXTOp;      // control signal to signed extension
    wire [4:0]  ALUOp;       // ALU opertion
    wire [4:0]  NPCOp;       // next PC operation
    wire [1:0]  WDSel;       // (register) write data selection
    wire        branch_taken; // branch taken signal
   
    wire        ALUSrc;      // ALU source for B
    wire        Zero;        // ALU ouput zero

    wire [31:0] NPC;         // next PC

    wire [4:0]  rs1;          // rs
    wire [4:0]  rs2;          // rt
    wire [4:0]  rd;          // rd
    wire [6:0]  Op;          // opcode
    wire [6:0]  Funct7;       // funct7
    wire [2:0]  Funct3;       // funct3
    wire [11:0] Imm12;       // 12-bit immediate
    wire [31:0] Imm32;       // 32-bit immediate
    wire [19:0] IMM;         // 20-bit immediate (address)
    wire [4:0]  A3;          // register address for write
    reg [31:0] WD;           // register write data
    reg [31:0] memdata_wr;    // memory write data
    wire [31:0] RD1,RD2;         // register data specified by rs
    wire [31:0] A;            //operator for ALU A
    wire [31:0] B;           // operator for ALU B

	wire [4:0] iimm_shamt;
	wire [11:0] iimm,simm,bimm;
	wire [19:0] uimm,jimm;
	wire [31:0] immout;
	
	//EX wires
	wire [4:0] EX_rd;
    wire [4:0] EX_rs1;
    wire [4:0] EX_rs2;
    wire [31:0] EX_immout;
    wire [31:0] EX_RD1;
    wire [31:0] EX_RD2;
    wire        EX_RegWrite;//RFWr
    wire        EX_MemWrite;//DMWr
    wire        EX_MemRead;//DMRe
    wire [4:0] EX_ALUOp;
    wire [4:0] EX_NPCOp;
    wire       EX_ALUSrc;
    wire [1:0] EX_WDSel;
    wire [31:0] EX_pc;
	
	//MEM wires
	wire [4:0] MEM_rd;
	wire [4:0] MEM_rs2;
	wire [31:0] MEM_RD2;
	wire [31:0] MEM_aluout;
	wire        MEM_RegWrite;
	wire        MEM_MemWrite;
	wire        MEM_MemRead;
	wire [1:0] MEM_WDSel;

    assign mem_w = MEM_MemWrite;
    assign mem_r = MEM_MemRead;
    
    //WB wires
    wire [4:0] WB_rd;
    wire [31:0] WB_aluout;
    wire [31:0] WB_MemData;
    wire        WB_RegWrite;
    wire [1:0]  WB_WDSel;
	wire [31:0] WB_pc;
	
    wire[31:0] aluout;
    assign Addr_out = MEM_aluout;
	assign Data_out = memdata_wr;
	
	wire [31:0] instr;
	
	assign iimm_shamt=instr[24:20];
	assign iimm=instr[31:20];
	assign simm={instr[31:25],instr[11:7]};
	assign bimm={instr[31],instr[7],instr[30:25],instr[11:8]};
	assign uimm=instr[31:12];
	assign jimm={instr[31],instr[19:12],instr[20],instr[30:21]};
   
    assign Op = instr[6:0];  // instruction
    assign Funct7 = instr[31:25]; // funct7
    assign Funct3 = instr[14:12]; // funct3
    assign rs1 = instr[19:15];  // rs1
    assign rs2 = instr[24:20];  // rs2
    assign rd = instr[11:7];  // rd
    assign Imm12 = instr[31:20];// 12-bit immediate
    assign IMM = instr[31:12];  // 20-bit immediate
    
      
    wire ID_MemWrite; // MemWrite from ctrl in ID
    wire ID_MemRead; // MemRead from ctrl in ID

   // instantiation of control unit
	ctrl U_ctrl(
	    .Op(Op), .Funct7(Funct7), .Funct3(Funct3), .Zero(Zero), 
		.RegWrite(RegWrite), .MemWrite(ID_MemWrite), .MemRead(ID_MemRead),
		.EXTOp(EXTOp), .ALUOp(ALUOp), .NPCOp(NPCOp), 
		.ALUSrc(ALUSrc), .WDSel(WDSel), .branch_taken(branch_taken)
	);
 // instantiation of pc unit
	PC U_PC(.clk(~clk), .rst(reset), .stall(stall), .NPC(NPC), .PC(PC_out) );
	NPC U_NPC(.PC(PC_out), .NPCOp(EX_NPCOp),
	          .IMM(EX_immout), .aluout(aluout), .stall(stall), .NPC(NPC));
	EXT U_EXT(
		.iimm(iimm), .simm(simm), .bimm(bimm), .uimm(uimm), .jimm(jimm),
		.EXTOp(EXTOp), .immout(immout)
	);
	RF U_RF(
		.clk(clk), .rst(reset),
		.RFWr(WB_RegWrite), 
		.A1(rs1), .A2(rs2), .A3(WB_rd), 
		.WD(WD), 
		.RD1(RD1), .RD2(RD2)
	);
// instantiation of alu unit
	alu U_alu(.A(A), .B(B), .ALUOp(EX_ALUOp), .C(aluout), .Zero(Zero));
	
//please connnect the CPU by yourself


//WD MUX
always @(*)
begin
	case(WB_WDSel)
		`WDSel_FromALU: WD<=WB_aluout;
		`WDSel_FromMEM: WD<=WB_MemData;
		`WDSel_FromPC:  WD<=WB_pc+4;  //WB_pc��ǰ�漸����δ��4����Jָ��ԭʼ��ַ
	endcase
end

// MUX Gate 
    reg [31:0] alu_in1;  
    reg [31:0] alu_in2;  


    
    always @(*) 
        memdata_wr <= MEM_RD2;//from MEM
        
    assign A = alu_in1;
    assign B = (EX_ALUSrc) ? EX_immout : alu_in2;//whether from EXT

//-----pipe registers--------------

    //IF_ID: [31:0] PC [31:0]instr
    wire [63:0] IF_ID_in;
    assign IF_ID_in[31:0] = PC_out;//original addr of the current ins in ID, not PC+4
    assign IF_ID_in[63:32] = inst_in;

    wire [63:0] IF_ID_out;
    assign instr = IF_ID_out[63:32];
    pl_reg #(.WIDTH(64))
    IF_ID
    (.clk(~clk), .rst(reset), 
    .in(IF_ID_in), .out(IF_ID_out));

    always @(*) begin
      $write("IF_ID_out:%h", IF_ID_out);
    end

    //ID_EX
    wire [193:0] ID_EX_in;
    assign ID_EX_in[31:0] = IF_ID_out[31:0];//PC
    assign ID_EX_in[36:32] = rd;
    assign ID_EX_in[41:37] = rs1;
    assign ID_EX_in[46:42] = rs2;
    assign ID_EX_in[78:47] = immout;
    assign ID_EX_in[110:79] = RD1;
    assign ID_EX_in[142:111] = RD2;
    assign ID_EX_in[143] = RegWrite;//RFWr
    assign ID_EX_in[144] = ID_MemWrite;//DMWr
    assign ID_EX_in[149:145] = ALUOp;
    assign ID_EX_in[154:150] = NPCOp;
    assign ID_EX_in[155] = ALUSrc;
    assign ID_EX_in[158:156] = 3'b000;  //nop, reserved for mem access
    assign ID_EX_in[160:159] = WDSel;
    assign ID_EX_in[161] = ID_MemRead;
    assign ID_EX_in[193:162] = IF_ID_out[63:32];

    wire [193:0] ID_EX_out;
    //wire [31:0] EX_inst;
    assign EX_rd = ID_EX_out[36:32];
    assign EX_rs1 = ID_EX_out[41:37];
    assign EX_rs2 = ID_EX_out[46:42];
    assign EX_immout = ID_EX_out[78:47];
    assign EX_RD1 = ID_EX_out[110:79];
    assign EX_RD2 = ID_EX_out[142:111];
    assign EX_RegWrite = ID_EX_out[143];//RFWr
    assign EX_MemWrite = ID_EX_out[144];//DMWr
    assign EX_ALUOp = ID_EX_out[149:145];
    assign EX_NPCOp = {ID_EX_out[154:151], ID_EX_out[150] & Zero};
    assign EX_ALUSrc = ID_EX_out[155];
    assign EX_DMType = ID_EX_out[158:156];
    assign EX_WDSel = ID_EX_out[160:159];
    assign EX_MemRead = ID_EX_out[161];
    assign EX_pc = ID_EX_out[31:0];
    //assign EX_inst = ID_EX_out[193:162];
    pl_reg #(.WIDTH(194))
    ID_EX
    (.clk(~clk), .rst(reset | flush), 
    .in(ID_EX_in), .out(ID_EX_out));
    always @(*) begin
      $write("ID_EX_out:%h", ID_EX_out);
    end
    
    //EX_MEM
    wire [145:0] EX_MEM_in;
    assign EX_MEM_in[31:0] = ID_EX_out[31:0];//PC
    assign EX_MEM_in[36:32] = EX_rd;//rd
    assign EX_MEM_in[68:37] = alu_in2;//RD2 updated!!!
    assign EX_MEM_in[100:69] = aluout;
    assign EX_MEM_in[101] = EX_RegWrite;
    assign EX_MEM_in[102] = EX_MemWrite;
    assign EX_MEM_in[105:103] = EX_DMType;
    assign EX_MEM_in[107:106] = EX_WDSel;
    assign EX_MEM_in[112:108] = EX_rs2;
    assign EX_MEM_in[113] = EX_MemRead;
    assign EX_MEM_in[145:114] = ID_EX_out[193:162];

    wire [145:0] EX_MEM_out;
    assign MEM_rd = EX_MEM_out[36:32];
    assign MEM_RD2 = EX_MEM_out[68:37];
    assign MEM_aluout = EX_MEM_out[100:69];
    assign MEM_RegWrite = EX_MEM_out[101];
    assign MEM_MemWrite = EX_MEM_out[102];
    assign MEM_DMType = EX_MEM_out[105:103];
    assign MEM_WDSel = EX_MEM_out[107:106];
    assign MEM_rs2 = EX_MEM_out[112:108];
    assign MEM_MemRead = EX_MEM_out[113];  
    //assign MEM_inst = EX_MEM_out[145:114];  
 
    pl_reg #(.WIDTH(146))
    EX_MEM
    (.clk(~clk), .rst(reset), 
    .in(EX_MEM_in), .out(EX_MEM_out));
    

    //MEM_WB
    wire [135:0] MEM_WB_in;
    wire [31:0] WB_inst;
    assign MEM_WB_in[31:0] = EX_MEM_out[31:0]; //PC
    assign MEM_WB_in[36:32] = MEM_rd;
    assign MEM_WB_in[68:37] = MEM_aluout;
    assign MEM_WB_in[100:69] = Data_in;  //data from dmem
    assign MEM_WB_in[101] = MEM_RegWrite;
    assign MEM_WB_in[103:102] = MEM_WDSel;
    assign MEM_WB_in[135:104] = EX_MEM_out[145:114];
 
    wire [135:0] MEM_WB_out;
    assign WB_pc = MEM_WB_out[31:0];
    assign WB_rd = MEM_WB_out[36:32];
    assign WB_aluout = MEM_WB_out[68:37];
    assign WB_MemData = MEM_WB_out[100:69];
    assign WB_RegWrite = MEM_WB_out[101];
    assign WB_WDSel = MEM_WB_out[103:102];
    assign WB_inst = MEM_WB_out[135:104];

    pl_reg #(.WIDTH(136))
    MEM_WB
    (.clk(~clk), .rst(reset), 
    .in(MEM_WB_in), .out(MEM_WB_out));


Hazard_Detect U_Hazard_Detect(
    .ID_EX_rs1(EX_rs1),
    .ID_EX_rs2(EX_rs2),
    .EX_MEM_rd(MEM_rd),
    .EX_MEM_RegWrite(MEM_RegWrite),
    .EX_MEM_MemRead(EX_MEM_MemRead), // 确保连接
    .branch_taken(branch_taken),
    .stall(stall),
    .flush(flush)
);

Forwarding U_Forwarding(
    .ID_EX_rs1(EX_rs1),
    .ID_EX_rs2(EX_rs2),
    .EX_MEM_rd(MEM_rd),
    .MEM_WB_rd(WB_rd),
    .EX_MEM_RegWrite(MEM_RegWrite),
    .MEM_WB_RegWrite(WB_RegWrite),
    .ForwardA(ForwardA),
    .ForwardB(ForwardB)
);
    always @(*) 
begin
    case(ForwardA)
        2'b00: alu_in1 <= EX_RD1; // 正常情况，无需前递
        2'b01: // 从MEM/WB阶段前递
            case(WB_WDSel)
                `WDSel_FromALU: alu_in1 <= WB_aluout; // ALU指令的结果
                `WDSel_FromMEM: alu_in1 <= WB_MemData; // 加载指令的数据
                `WDSel_FromPC:  alu_in1 <= WB_pc + 4;  // 跳转指令的PC+4
                default:        alu_in1 <= 32'b0;      // 默认值（可选）
            endcase
        2'b10: alu_in1 <= MEM_aluout; // 从EX/MEM阶段前递，通常为ALU结果
        default: alu_in1 <= 32'b0;    // 默认值（可选）
    endcase

    case(ForwardB)
        2'b00: alu_in2 <= EX_RD2; // 正常情况，无需前递
        2'b01: // 从MEM/WB阶段前递
            case(WB_WDSel)
                `WDSel_FromALU: alu_in2 <= WB_aluout; // ALU指令的结果
                `WDSel_FromMEM: alu_in2 <= WB_MemData; // 加载指令的数据
                `WDSel_FromPC:  alu_in2 <= WB_pc + 4;  // 跳转指令的PC+4
                default:        alu_in2 <= 32'b0;      // 默认值（可选）
            endcase
        2'b10: alu_in2 <= MEM_aluout; // 从EX/MEM阶段前递，通常为ALU结果
        default: alu_in2 <= 32'b0;    // 默认值（可选）
    endcase
end
endmodule
