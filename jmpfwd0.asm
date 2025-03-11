#测试2：J和B指令都是在EX级进行条件判断和目标地址计算，不是提前分支。
# 待验证：能否正确处理转发：MEM-->EX, WB-->EX, WB-->MEM
main:	addi x5, x0, 1		#0x0: 00100293,  x5 = 1
		addi x6, x0, 2		#0x4: 00200313,  x6 = 2
		add  x7, x5, x6	#EX rs1 from WB, rs2 from MEM, x7 = 3, 0x8: 006283b3
		add  x8, x7, x6	#EX rs1 from MEM, rs2 from WB, x8 = 5, 0xc: 00638433
		sw	 x8, 0(x0)		#MEM write data from WB's arith op, mem[0] = 5, 0x10: 00802023
		lw	 x9, 0(x0)		#0x14: 00002483,  x9 = 5
		sw	 x9, 4(x0)		
#stall 1 cycle in ID, then MEM write data from WB's load, mem[4] = 5, 0x18: 00902223
		lw   x10, 4(x0)	#0x1c: 00402503,  x10= 5
		addi x5, x0, 3		#0x20: 00300293,  x5 = 3
		addi x6, x0, 3		#0x24: 00300313,  x6 = 3
		addi x0, x0, 0		#0x28: 00000013
		beq  x5, x6, br1 	# 0x2c: 00628663, x6 from forward WB-ex
		addi  x10, x0, 10	#should flush, 0x30: 00a00513
br2:	    jal	 x0,  end	#should flush, 0x34: 0100006f

br1: 	addi x11, x0, 0x34	#0x38: 03400593 , x11= 0x34
        addi x0, x0, 0		#0x3c: 00000013
        jalr x0, x11, 0		#jalr x0, br2, 0x40: 00058067
	addi x0, x0, 0
end:	    addi x5, x5, 0x100  # 0x48, x5 = 0x103