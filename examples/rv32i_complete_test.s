# 完整RV32I指令集测试程序
# 测试所有RV32I指令的功能

# 初始化寄存器
addi x1, x0, 5      # x1 = 5
addi x2, x0, 2      # x2 = 2
addi x3, x0, -4     # x3 = -4

# === R型指令测试 ===
add  x4, x1, x2     # x4 = 5 + 2 = 7
sub  x5, x1, x2     # x5 = 5 - 2 = 3
and  x6, x1, x2     # x6 = 5 & 2 = 0
or   x7, x1, x2     # x7 = 5 | 2 = 7
xor  x8, x1, x2     # x8 = 5 ^ 2 = 7
sll  x9, x1, x2     # x9 = 5 << 2 = 20
srl  x10, x1, x2    # x10 = 5 >> 2 = 1
sra  x11, x3, x2    # x11 = -4 >>> 2 = -1
slt  x12, x1, x2    # x12 = (5 < 2) = 0
sltu x13, x1, x2    # x13 = (5 < 2) = 0

# === I型指令测试 ===
addi  x14, x1, 10   # x14 = 5 + 10 = 15
andi  x15, x1, 3    # x15 = 5 & 3 = 1
ori   x16, x1, 8    # x16 = 5 | 8 = 13
xori  x17, x1, 7    # x17 = 5 ^ 7 = 2
slli  x18, x1, 3    # x18 = 5 << 3 = 40
srli  x19, x1, 1    # x19 = 5 >> 1 = 2
srai  x20, x3, 1    # x20 = -4 >>> 1 = -2
slti  x21, x1, 10   # x21 = (5 < 10) = 1
sltiu x22, x1, 10   # x22 = (5 < 10) = 1

# === U型指令测试 ===
lui   x23, 0x12345  # x23 = 0x12345000
auipc x24, 0x1000   # x24 = PC + 0x1000000

# === 内存访问指令测试 ===
# 先存储一些测试数据
addi x25, x0, 0x12345678  # 测试数据1
sw   x25, 0(x0)          # 存储到地址0

addi x26, x0, 0x9ABC     # 测试数据2 (16位)
sh   x26, 4(x0)          # 存储半字到地址4

addi x27, x0, 0x5A       # 测试数据3 (8位)
sb   x27, 6(x0)          # 存储字节到地址6

# 加载测试
lw   x28, 0(x0)          # 加载字
lh   x29, 4(x0)          # 加载半字(有符号)
lhu  x30, 4(x0)          # 加载半字(无符号)
lb   x31, 6(x0)          # 加载字节(有符号)
lbu  x1, 6(x0)           # 加载字节(无符号)

# === 跳转指令测试 ===
jal  x2, test_label      # 跳转并链接
addi x3, x0, 999         # 这条不应该执行

test_label:
addi x4, x0, 42          # 跳转目标

# JALR测试
addi x5, x0, return_addr # 计算返回地址
jalr x6, x5, 0           # 跳转到return_addr
addi x7, x0, 888         # 这条不应该执行

return_addr:
addi x8, x0, 123         # 返回目标

# === 分支指令测试 ===
beq  x1, x1, branch1     # 相等分支
addi x9, x0, 777         # 不应该执行

branch1:
bne  x1, x2, branch2     # 不等分支
addi x10, x0, 666        # 不应该执行

branch2:
blt  x2, x1, branch3     # 小于分支 (2 < 5)
addi x11, x0, 555        # 不应该执行

branch3:
bge  x1, x2, branch4     # 大于等于分支 (5 >= 2)
addi x12, x0, 444        # 不应该执行

branch4:
bltu x2, x1, branch5     # 无符号小于分支
addi x13, x0, 333        # 不应该执行

branch5:
bgeu x1, x2, end         # 无符号大于等于分支
addi x14, x0, 222        # 不应该执行

end:
# 内存屏障指令
fence

# 程序结束 - 无限循环
beq x0, x0, end
