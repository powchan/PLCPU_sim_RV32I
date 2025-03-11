module pl_reg #(parameter WIDTH = 32)(
    input clk, rst, flush, stall,
    input [WIDTH-1:0] in,
    output reg [WIDTH-1:0] out
    );
    
    always@(posedge clk, posedge rst)
      begin
          if(rst)
              out <= 0;
          else if(flush)
              out <= 0;
          else if (!stall)
              out <= in;
      end
    
endmodule
