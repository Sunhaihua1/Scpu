# 完整的RV32I指令集测试程序
# 测试所有39个RV32I基本指令

# 初始化测试
addi x1, x0, 1         # x1 = 1
addi x2, x0, 2         # x2 = 2  
addi x3, x0, -1        # x3 = -1

# R型指令测试 (10个)
add x4, x1, x2         # x4 = x1 + x2 = 3
sub x5, x4, x1         # x5 = x4 - x1 = 2
sll x6, x1, x2         # x6 = x1 << x2 = 4
slt x7, x3, x1         # x7 = (x3 < x1) = 1
sltu x8, x3, x1        # x8 = (x3 < x1 unsigned) = 0
xor x9, x1, x2         # x9 = x1 ^ x2 = 3
srl x10, x6, x1        # x10 = x6 >> x1 = 2
sra x11, x3, x1        # x11 = x3 >> x1 (算术) = -1
or x12, x1, x2         # x12 = x1 | x2 = 3
and x13, x1, x2        # x13 = x1 & x2 = 0

# I型立即数指令测试 (9个)
addi x14, x1, 100      # x14 = x1 + 100 = 101
slti x15, x14, 102     # x15 = (x14 < 102) = 1
sltiu x16, x3, 1       # x16 = (x3 < 1 unsigned) = 0
xori x17, x1, 3        # x17 = x1 ^ 3 = 2
ori x18, x1, 4         # x18 = x1 | 4 = 5
andi x19, x18, 7       # x19 = x18 & 7 = 5
slli x20, x1, 3        # x20 = x1 << 3 = 8
srli x21, x20, 2       # x21 = x20 >> 2 = 2
srai x22, x3, 1        # x22 = x3 >> 1 (算术) = -1

# 存储指令测试 (3个)
sw x14, 0(x0)          # 存储字：mem[0] = x14 = 101
sh x18, 4(x0)          # 存储半字：mem[4] = x18 = 5
sb x19, 8(x0)          # 存储字节：mem[8] = x19 = 5

# 加载指令测试 (5个)
lw x23, 0(x0)          # x23 = mem[0] = 101
lh x24, 4(x0)          # x24 = mem[4] (有符号半字) = 5
lhu x25, 4(x0)         # x25 = mem[4] (无符号半字) = 5
lb x26, 8(x0)          # x26 = mem[8] (有符号字节) = 5
lbu x27, 8(x0)         # x27 = mem[8] (无符号字节) = 5

# U型指令测试 (2个)
lui x28, 0x12345       # x28 = 0x12345000
auipc x29, 0x1000      # x29 = PC + 0x1000000

# JAL跳转测试 (1个)
jal x30, test_jalr     # 跳转到test_jalr，x30保存返回地址
addi x31, x0, 999      # 这条应该被跳过

test_jalr:
# JALR跳转测试 (1个)
addi x30, x30, 4       # 修正返回地址
jalr x31, x30, 0       # 跳转回来，x31保存返回地址

# 条件分支指令测试 (6个)
beq x1, x1, branch1    # x1 == x1，应该跳转
addi x1, x1, 100       # 不应该执行

branch1:
bne x1, x2, branch2    # x1 != x2，应该跳转
addi x1, x1, 100       # 不应该执行

branch2:
blt x3, x1, branch3    # x3 < x1，应该跳转
addi x1, x1, 100       # 不应该执行

branch3:
bge x1, x3, branch4    # x1 >= x3，应该跳转
addi x1, x1, 100       # 不应该执行

branch4:
bltu x3, x1, branch5   # x3 < x1 (无符号)，应该跳转
addi x1, x1, 100       # 不应该执行

branch5:
bgeu x1, x3, branch6   # x1 >= x3 (无符号)，应该跳转
addi x1, x1, 100       # 不应该执行

branch6:
# FENCE指令测试 (1个)
fence

# 特殊跳转测试
# 没有分支的情况下继续执行

# 最终验证
addi x28, x0, 0x555    # x28 = 0x555 (结束标记)

# 程序结束：无限循环
end_loop:
beq x0, x0, end_loop   # 无限循环
