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
        `ALUOp_lui: begin C = B; flush = 1'b0; end
        `ALUOp_add: begin C = A + B; flush = 1'b0; end
        `ALUOp_sub: begin C = A - B; flush = 1'b0; end  //and beq
        `ALUOp_xor: begin C = A ^ B; flush = 1'b0; end
        `ALUOp_or: begin C = A | B; flush = 1'b0; end
        `ALUOp_and: begin C = A & B; flush = 1'b0; end
        `ALUOp_sll: begin C = A << B; flush = 1'b0; end
        `ALUOp_srl: begin C = A >> B; flush = 1'b0; end
        `ALUOp_sra: begin C = A >>> B; flush = 1'b0; end
        `ALUOp_slt: begin C = ($signed(A) < $signed(B)) ? 32'b1 : 32'b0; flush = 1'b0; end
        `ALUOp_sltu: begin C = ($unsigned(A) < $unsigned(B)) ? 32'b1 : 32'b0; flush = 1'b0; end
        `ALUOp_beq: begin C = {28'h0000000, 3'b000, (A != B)}; flush = (A == B); end
        `ALUOp_bne: begin C = {28'h0000000, 3'b000, (A == B)}; flush = (A != B); end
        `ALUOp_blt: begin C = {28'h0000000, 3'b000, (A >= B)}; flush = (A < B); end
        `ALUOp_bge: begin C = {28'h0000000, 3'b000, (A < B)}; flush = (A >= B); end
        `ALUOp_bltu: begin C = {28'h0000000, 3'b000, ($unsigned(A) >= $unsigned(B))}; flush = ($unsigned(A) < $unsigned(B)); end
        `ALUOp_bgeu: begin C = {28'h0000000, 3'b000, ($unsigned(A) < $unsigned(B))}; flush = ($unsigned(A) > $unsigned(B)); end
        `ALUOp_j: begin C = A; flush = 1'b1; end
        default: begin C = A; flush = 1'b0; end
      endcase
   end 
   
   assign Zero = (C == 32'b0);  

endmodule
    
