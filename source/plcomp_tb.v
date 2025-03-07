`timescale 1ns/1ns 
module plcomp_tb();
  reg   clk, rstn;
  integer i=0;  //for debug

  // instantiation of plcomp
  plcomp plcomp(clk, rstn);
  
  initial begin
    // input instructions for simulation
    $readmemh("rv32_pl_sim.dat", plcomp.U_imem.RAM); //( 21 ins-25cycles )
    clk = 0;
    rstn = 1;
    #50 ;
    rstn = 0;
  end
  
  always begin
    #(5) clk = ~clk;
  end

  always @(posedge clk) begin   //for debug
       i=i+1;
       if (clk) $write("\n cycle=%d, IF_PC=%h, IF_ins=%h, ", i, plcomp.PC, plcomp.instr );
       if (plcomp.U_PLCPU.U_RF.RFWr && plcomp.U_PLCPU.U_RF.A3) $write("x%d = %h  ", plcomp.U_PLCPU.U_RF.A3, plcomp.U_PLCPU.U_RF.WD) ;
  end
      
endmodule
