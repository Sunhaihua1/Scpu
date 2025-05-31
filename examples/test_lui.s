# 简单的LUI指令测试
_start:
    lui x1, 0x80000      # x1 应该 = 0x80000000
    lui x2, 0x7ffff      # x2 应该 = 0x7ffff000  
    lui x3, 1            # x3 应该 = 0x00001000
    addi x4, x0, 0       # x4 = 0 (NOP等效)
    beq x0, x0, _start   # 无限循环
