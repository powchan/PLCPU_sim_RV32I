`include "ctrl_encode_def.v"

module alu(A, B, ALUOp, C, Zero, flush);
   input  signed [31:0] A, B;
   input         [4:0]  ALUOp;
   output signed [31:0] C;
   output Zero;  //condition flag: set if condition is true for B-type instruction
   output reg flush; //branch flag: set if branch is taken
   
   reg [31:0] C;
   integer    i;
   
   initial flush = 1'b0;
   always @( * ) begin
      case ( ALUOp )
        `ALUOp_lui:C=B;
        `ALUOp_add:C=A+B;
        `ALUOp_sub:C=A-B;  //and beq
        `ALUOp_xor:C=A^B;
        `ALUOp_or:C=A|B;
        `ALUOp_and:C=A&B;
        `ALUOp_sll:C=A<<B;
        `ALUOp_srl:C=A>>B;
        `ALUOp_sra:C=A>>>B;
        `ALUOp_slt:C=($signed(A) < $signed(B)) ? 32'b1 : 32'b0;
        `ALUOp_sltu:C=($unsigned(A) < $unsigned(B)) ? 32'b1 : 32'b0;
      `ALUOp_beq: begin C={28'h0000000,3'b000,(A!=B)}; flush=(A==B); end
      `ALUOp_bne: begin C={28'h0000000,3'b000,(A==B)}; flush=(A!=B); end
      `ALUOp_blt: begin C={28'h0000000,3'b000,(A>=B)}; flush=(A<B); end
      `ALUOp_bge: begin C={28'h0000000,3'b000,(A<B)}; flush=(A>=B); end
      `ALUOp_bltu: begin C={28'h0000000,3'b000,($unsigned(A)>=$unsigned(B))}; flush=($unsigned(A)<$unsigned(B)); end
      `ALUOp_bgeu: begin C={28'h0000000,3'b000,($unsigned(A)<$unsigned(B))}; flush=($unsigned(A)>=$unsigned(B)); end
        default: C=A;
      endcase
   end 
   
   assign Zero = (C == 32'b0);  

endmodule
    
