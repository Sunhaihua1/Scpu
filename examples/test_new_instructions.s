# RV32I 新指令测试程序
# 测试LUI, AUIPC, JAL, JALR, LB, LH, LBU, LHU, SB, SH指令

# 1. 测试LUI指令
lui x1, 0x12345        # x1 = 0x12345000

# 2. 测试AUIPC指令  
auipc x2, 0x1000       # x2 = PC + 0x1000000

# 3. 测试存储指令
addi x3, x0, 0x5A      # x3 = 0x5A (90)
sb x3, 0(x0)           # 存储字节到地址0

addi x4, x0, 0x1234    # x4 = 0x1234 (4660)
sh x4, 4(x0)           # 存储半字到地址4

# 4. 测试加载指令
lb x5, 0(x0)           # 有符号字节加载: x5 = 0x5A
lbu x6, 0(x0)          # 无符号字节加载: x6 = 0x5A

lh x7, 4(x0)           # 有符号半字加载: x7 = 0x1234  
lhu x8, 4(x0)          # 无符号半字加载: x8 = 0x1234

# 5. 测试JAL指令
jal x9, skip_section   # 跳转并保存返回地址
addi x10, x0, 999      # 这条指令应该被跳过

skip_section:
addi x11, x0, 42       # 跳转后执行这条

# 6. 测试JALR指令
addi x12, x9, 4        # 计算返回地址+4
jalr x13, x12, 0       # 跳转到返回地址+4
addi x14, x0, 888      # 这条指令应该被跳过

addi x15, x0, 123      # 最终执行这条

# 7. 测试FENCE指令
fence

# 8. 测试完成，无限循环
loop:
beq x0, x0, loop       # 无限循环
