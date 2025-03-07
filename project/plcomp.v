`include "ctrl_encode_def.v"
module plcomp(clk, rstn);
  input             clk, rstn;
   
   wire [31:0]    instr;
   wire [31:0]    PC;
   wire           MemWrite;
   wire           MemRead;
   wire [31:0]    dm_addr, dm_din, dm_dout;
   wire [2:0] DMType;
   
   wire reset;
   assign reset = rstn;
   
   // instantiation of pipeline CPU   
   PLCPU U_PLCPU(
         .clk(clk),                 // input:  cpu clock
         .reset(reset),                 // input:  reset
         .inst_in(instr),             // input:  instruction from im
         .Data_in(dm_dout),        // input:  data to cpu  
         .mem_w(MemWrite),       // output: memory write signal
         .mem_r(MemRead),       // output: memory read signal
         .PC_out(PC),                   // output: PC to im
         .Addr_out(dm_addr),          // output: address from cpu to memory
         .Data_out(dm_din)        // output: data from cpu to memory
         );
   
   dm  U_DM(
         .clk(clk),           // input:  cpu clock
         .DMWr(MemWrite),     // input:  ram write
         .DMRe(MemRead),      // input:  ram read
         .addr(dm_addr),      // input:  ram address
         .din(dm_din),         // input:  data to ram
         .dout(dm_dout)       // output: data from ram
         );
         
  // instantiation of intruction memory (used for simulation)
   im    U_imem ( 
      .addr(PC[31:2]),     // input:  rom address
      .dout(instr)        // output: instruction
   );
   
  
endmodule





















