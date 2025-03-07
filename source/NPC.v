`include "ctrl_encode_def.v"

module NPC(PC, NPCOp, IMM, aluout, NPC);  // next pc module
   input  [31:0] PC;        // pc
   input  [4:0]  NPCOp;     // next pc operation
   input  [31:0] IMM;       // immediate
   input [31:0] aluout;
   input stall;
   output reg [31:0] NPC;   // next pc
   
   wire [31:0] PCPLUS4;
   assign PCPLUS4 = PC + 4; // pc + 4
  
   always @(*) begin
        if (stall) begin
            NPC = PC;  // 暂停时保持当前PC
        end
        case (NPCOp)
            `NPC_PLUS4:  NPC = PCPLUS4;
            `NPC_BRANCH: NPC = PC+IMM;    //B type, NPC computes addr
            `NPC_JUMP:   NPC = PC+IMM;    //J type, NPC computes 
            `NPC_JALR:   NPC = aluout;
            default:     NPC = PCPLUS4;
        endcase
    end // end always
   
endmodule
