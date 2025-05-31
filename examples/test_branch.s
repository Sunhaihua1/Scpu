# 简单分支测试
_start:
    addi x1, x0, 5       # x1 = 5
    addi x2, x0, 3       # x2 = 3
    
    # 测试BEQ - 不相等，不应跳转
    beq x1, x2, error    # 5 != 3，不跳转
    addi x3, x0, 1       # x3 = 1 (应该执行)
    
    # 测试BNE - 不相等，应该跳转
    bne x1, x2, next1    # 5 != 3，应该跳转
    addi x25, x0, 999    # 不应执行
    
next1:
    # 测试BLT - 3 < 5，应该跳转
    blt x2, x1, next2    # 3 < 5，应该跳转
    addi x25, x0, 998    # 不应执行
    
next2:
    # 测试BGE - 5 >= 3，应该跳转
    bge x1, x2, next3    # 5 >= 3，应该跳转
    addi x25, x0, 997    # 不应执行
    
next3:
    addi x4, x0, 100     # x4 = 100 (测试完成标记)
    beq x0, x0, next3    # 无限循环
    
error:
    addi x25, x0, 1000   # 错误标记
