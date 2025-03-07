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
    // 数据冒险检测
    if (EX_MEM_RegWrite && 
        ((EX_MEM_rd == ID_EX_rs1) || (EX_MEM_rd == ID_EX_rs2))) begin
        stall = 1'b1;
        flush = 1'b0;
    end
    // 控制冒险检测
    else if (branch_taken) begin
        stall = 1'b0;
        flush = 1'b1;  // 刷新错误取指的指令
    end
    else begin
        stall = 1'b0;
        flush = 1'b0;
    end
end

endmodule

// Forwarding Unit
module Forwarding(
    input [4:0] ID_EX_rs1,    // ID阶段的rs1
    input [4:0] ID_EX_rs2,    // ID阶段的rs2
    input [4:0] EX_MEM_rd,    // EX/MEM阶段的rd
    input [4:0] MEM_WB_rd,    // MEM/WB阶段的rd
    input EX_MEM_RegWrite,    // EX/MEM阶段的RegWrite信号
    input MEM_WB_RegWrite,    // MEM/WB阶段的RegWrite信号
    output reg [1:0] ForwardA, // 前递选择信号A
    output reg [1:0] ForwardB  // 前递选择信号B
);

always @(*) begin
    // ForwardA逻辑
    if (EX_MEM_RegWrite && (EX_MEM_rd != 0) && (EX_MEM_rd == ID_EX_rs1)) begin
        ForwardA = 2'b10; // 前递EX/MEM阶段的结果
    end
    else if (MEM_WB_RegWrite && (MEM_WB_rd != 0) && (MEM_WB_rd == ID_EX_rs1)) begin
        ForwardA = 2'b01; // 前递MEM/WB阶段的结果
    end
    else begin
        ForwardA = 2'b00; // 不进行前递
    end

    // ForwardB逻辑
    if (EX_MEM_RegWrite && (EX_MEM_rd != 0) && (EX_MEM_rd == ID_EX_rs2)) begin
        ForwardB = 2'b10; // 前递EX/MEM阶段的结果
    end
    else if (MEM_WB_RegWrite && (MEM_WB_rd != 0) && (MEM_WB_rd == ID_EX_rs2)) begin
        ForwardB = 2'b01; // 前递MEM/WB阶段的结果
    end
    else begin
        ForwardB = 2'b00; // 不进行前递
    end
end

endmodule