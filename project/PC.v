module PC( clk, rst, NPC, PC, stall );
  input              clk;
  input              rst;
  input              stall;
  input       [31:0] NPC;
  output reg  [31:0] PC;

  always @(posedge clk, posedge rst) begin
    if (rst) begin
       PC <= 32'h0000_0000;
       end
    else if (stall) begin  
       end
    else begin
        PC <= NPC;
      end
  end
  
endmodule

