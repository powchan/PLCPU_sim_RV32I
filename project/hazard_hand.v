// Hazard Detection Unit
module Hazard_Detect(
    input [4:0] ID_EX_rs1,
    input [4:0] ID_EX_rs2,
    input [4:0] EX_MEM_rd,
    input [4:0] MEM_WB_rd,
    input EX_MEM_RegWrite,
    input MEM_WB_RegWrite,
    input branch_taken,  // 新增：分支指令是否跳转
    output reg stall,
    output reg flush     // 新增：流水线刷新信号
);

always @(*) begin
    // 数据冒险检测（覆盖EX和MEM阶段）
    if ((EX_MEM_RegWrite && (EX_MEM_rd != 0) && 
         ((EX_MEM_rd == ID_EX_rs1) || (EX_MEM_rd == ID_EX_rs2))) ||
        (MEM_WB_RegWrite && (MEM_WB_rd != 0) && 
         ((MEM_WB_rd == ID_EX_rs1) || (MEM_WB_rd == ID_EX_rs2)))) begin
        stall = 1'b1;
        flush = 1'b0;
    end
    // 控制冒险检测保持不变
    else if (branch_taken) begin
        stall = 1'b0;
        flush = 1'b1;
    end
    else begin
        stall = 1'b0;
        flush = 1'b0;
    end
end

endmodule

module Forwarding(
    input [4:0] ID_EX_rs1,    // ID/EX阶段的rs1
    input [4:0] ID_EX_rs2,    // ID/EX阶段的rs2
    input [4:0] EX_MEM_rd,    // EX/MEM阶段的rd
    input [4:0] MEM_WB_rd,    // MEM/WB阶段的rd
    input EX_MEM_RegWrite,    // EX/MEM阶段的寄存器写使能
    input MEM_WB_RegWrite,    // MEM/WB阶段的寄存器写使能
    output reg [1:0] ForwardA, // ALU输入A的前递选择
    output reg [1:0] ForwardB  // ALU输入B的前递选择
);

// ForwardA控制逻辑
always @(*) begin
    ForwardA = 2'b00; // 默认值：无前递
    
    // 优先级1：EX/MEM阶段前递（最近的计算结果）
    if (EX_MEM_RegWrite && (EX_MEM_rd != 0) && (EX_MEM_rd == ID_EX_rs1)) begin
        ForwardA = 2'b10; // 选择EX/MEM阶段的ALU结果
    end 
    // 优先级2：MEM/WB阶段前递（较早的结果）
    else if (MEM_WB_RegWrite && (MEM_WB_rd != 0) && (MEM_WB_rd == ID_EX_rs1)) begin
        ForwardA = 2'b01; // 选择MEM/WB阶段的写回数据
    end
end

// ForwardB控制逻辑（与ForwardA对称）
always @(*) begin
    ForwardB = 2'b00; // 默认值：无前递
    
    if (EX_MEM_RegWrite && (EX_MEM_rd != 0) && (EX_MEM_rd == ID_EX_rs2)) begin
        ForwardB = 2'b10; 
    end 
    else if (MEM_WB_RegWrite && (MEM_WB_rd != 0) && (MEM_WB_rd == ID_EX_rs2)) begin
        ForwardB = 2'b01;
    end
end

endmodule