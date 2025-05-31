# 测试边界条件和错误处理的RV32I程序

.text
.globl _start

_start:
    # ========== 1. 算术边界测试 ==========
    
    # 测试加法溢出
    lui x1, 0x7ffff      # x1 = 0x7ffff000 (接近最大正数)
    addi x1, x1, 0x7ff   # x1 = 0x7fffffff (最大正数)
    addi x2, x1, 1       # x2 = 0x80000000 (溢出为最小负数)
    
    # 测试减法下溢
    lui x3, 0x80000      # x3 = 0x80000000 (最小负数)
    addi x4, x3, -1      # x4 = 0x7fffffff (下溢为最大正数)
    
    # 测试零操作
    add x5, x0, x0       # x5 = 0 (零寄存器测试)
    sub x6, x1, x1       # x6 = 0 (相同数相减)
    
    # ========== 2. 移位边界测试 ==========
    
    # 测试最大移位量
    addi x7, x0, 1       # x7 = 1
    slli x8, x7, 31      # x8 = 0x80000000 (左移31位)
    srli x9, x8, 31      # x9 = 1 (右移31位恢复)
    
    # 测试移位量截断（只取低5位）
    addi x10, x0, 33     # x10 = 33 (等效于移位1)
    sll x11, x7, x10     # x11 = 2 (实际移位1位)
    
    # 算术右移负数
    srai x12, x8, 1      # x12 = 0xc0000000 (符号扩展)
    
    # ========== 3. 比较边界测试 ==========
    
    # 有符号比较边界
    slt x13, x3, x1      # x13 = 1 (0x80000000 < 0x7fffffff)
    slt x14, x1, x3      # x14 = 0 (0x7fffffff > 0x80000000)
    
    # 无符号比较边界  
    sltu x15, x3, x1     # x15 = 0 (0x80000000 > 0x7fffffff 无符号)
    sltu x16, x1, x3     # x16 = 1 (0x7fffffff < 0x80000000 无符号)
    
    # ========== 4. 内存边界测试 ==========
    
    # 测试内存边界地址
    addi x17, x0, 0      # x17 = 0 (最小地址)
    sw x1, 0(x17)        # 存储到地址0
    lw x18, 0(x17)       # 从地址0加载
    
    # 测试字节存储/加载的边界
    addi x19, x0, 255    # x19 = 0xff
    sb x19, 4(x17)       # 存储字节
    lbu x20, 4(x17)      # 无符号字节加载
    lb x21, 4(x17)       # 有符号字节加载 (应为-1)
    
    # 测试半字边界
    addi x22, x0, -1     # x22 = 0xffffffff
    sh x22, 8(x17)       # 存储半字
    lhu x23, 8(x17)      # 无符号半字加载 (0xffff)
    lh x24, 8(x17)       # 有符号半字加载 (-1)
    
    # ========== 5. 分支边界测试 ==========
    
    # 测试零标志的边界情况
    beq x0, x0, zero_equal     # 零等于零，应跳转
    addi x25, x0, 999          # 不应执行
    
zero_equal:
    # 测试相等边界
    beq x1, x1, same_equal     # 相同值相等，应跳转  
    addi x25, x0, 998          # 不应执行
    
same_equal:
    # 测试不等边界
    bne x1, x3, diff_not_equal # 不同值不等，应跳转
    addi x25, x0, 997          # 不应执行
    
diff_not_equal:
    # 测试有符号比较边界
    blt x3, x1, signed_less    # 最小负数 < 最大正数，应跳转
    addi x25, x0, 996          # 不应执行
    
signed_less:
    # 测试无符号比较边界  
    bltu x1, x3, unsigned_less # 最大正数 < 最小负数（无符号），应跳转
    addi x25, x0, 995          # 不应执行
    
unsigned_less:
    # ========== 6. 跳转边界测试 ==========
    
    # 测试JAL最大偏移
    jal x26, max_jump          # 保存返回地址并跳转
    addi x25, x0, 994          # 不应执行
    
max_jump:
    # 测试JALR间接跳转
    addi x27, x0, return_point # x27 = return_point地址
    jalr x28, x27, 0           # 间接跳转并保存返回地址
    addi x25, x0, 993          # 不应执行
    
return_point:
    # ========== 7. 立即数边界测试 ==========
    
    # 测试最大正立即数
    addi x29, x0, 2047         # x29 = 0x7ff (12位最大正数)
    
    # 测试最大负立即数  
    addi x30, x0, -2048        # x30 = 0x800 (12位最小负数)
    
    # 测试LUI边界
    lui x31, 0xfffff          # x31 = 0xfffff000 (20位全1)
    
    # ========== 8. 特殊情况测试 ==========
    
    # 测试写入x0的情况（应被忽略）
    addi x0, x0, 100          # 尝试修改x0，应无效果
    add x0, x1, x2            # 尝试修改x0，应无效果
    
    # 测试连续相关指令
    addi x1, x0, 1            # x1 = 1
    add x2, x1, x1            # x2 = 2 (RAW冒险测试)
    add x3, x2, x1            # x3 = 3 (连续RAW冒险)
    
    # ========== 结束标记 ==========
    # 无限循环用于仿真结束检测
end_loop:
    beq x0, x0, end_loop      # 无限循环
    
    # 永不到达的指令
    addi x25, x0, 0           # 错误标记
