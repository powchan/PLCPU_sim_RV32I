// data memory
`include "ctrl_encode_def.v"
module dm(clk, DMWr, DMRe, addr, din, dout);
   input          clk;
   input          DMWr;
   input          DMRe;
   input  [31:0]  addr;
   input  [31:0]  din;
   output reg [31:0]  dout;
   
   reg [31:0] dmem[127:0];
   
   always @(posedge clk)
      if (DMWr) begin
          dmem[addr[8:2]] <= din;
          $write(" memaddr = %h, memdata = %h \n", addr[31:0], din);
      end
   
   //load
   always @(*)
      if (DMRe) begin
         dout <= dmem[addr[8:2]];
      end
   
endmodule    
