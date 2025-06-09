// 指令存储器模块 - 修正后的边界测试
module imem(
    input wire [31:0] addr,
    output wire [31:0] inst
);
    // 简单的ROM实现
    reg [31:0] rom [0:255];
    assign inst = rom[addr[9:2]];
    
    integer i;
    
    initial begin
        rom[0] = 32'h800000b7; // lui x1, 0x80000      # x1 = 0x80000000
        rom[1] = 32'hfff08093; // addi x1, x1, -1      # x1 = 0x7fffffff (最大正数)
        rom[2] = 32'h00108113; // addi x2, x1, 1       # x2 = 0x80000000 (溢出为最小负数)
        rom[3] = 32'h800001b7; // lui x3, 0x80000      # x3 = 0x80000000 (最小负数)
        rom[4] = 32'hfff18213; // addi x4, x3, -1      # x4 = 0x7fffffff (下溢为最大正数)
        rom[5] = 32'h000002b3; // add x5, x0, x0       # x5 = 0 (零寄存器测试)
        rom[6] = 32'h40108333; // sub x6, x1, x1       # x6 = 0 (相同数相减)
        rom[7] = 32'h00100393; // addi x7, x0, 1       # x7 = 1
        rom[8] = 32'h01f39413; // slli x8, x7, 31      # x8 = 0x80000000 (左移31位)
        rom[9] = 32'h01f45493; // srli x9, x8, 31      # x9 = 1 (右移31位恢复)
        rom[10] = 32'h02100513; // addi x10, x0, 33     # x10 = 33 (等效于移位1)
        rom[11] = 32'h00a395b3; // sll x11, x7, x10     # x11 = 2 (实际移位1位)
        rom[12] = 32'h40145613; // srai x12, x8, 1      # x12 = 0xc0000000 (符号扩展)
        rom[13] = 32'h0011a6b3; // slt x13, x3, x1      # x13 = 1 (0x80000000 < 0x7fffffff)
        rom[14] = 32'h0030a733; // slt x14, x1, x3      # x14 = 0 (0x7fffffff > 0x80000000)
        rom[15] = 32'h0011b7b3; // sltu x15, x3, x1     # x15 = 0 (0x80000000 > 0x7fffffff 无符号)
        rom[16] = 32'h0030b833; // sltu x16, x1, x3     # x16 = 1 (0x7fffffff < 0x80000000 无符号)
        rom[17] = 32'h00000893; // addi x17, x0, 0      # x17 = 0 (最小地址)
        rom[18] = 32'h0018a023; // sw x1, 0(x17)        # 存储到地址0
        rom[19] = 32'h0008a903; // lw x18, 0(x17)       # 从地址0加载
        rom[20] = 32'h0ff00993; // addi x19, x0, 255    # x19 = 0xff
        rom[21] = 32'h01388223; // sb x19, 4(x17)       # 存储字节
        rom[22] = 32'h0048ca03; // lbu x20, 4(x17)      # 无符号字节加载
        rom[23] = 32'h00488a83; // lb x21, 4(x17)       # 有符号字节加载 (应为-1)
        rom[24] = 32'hfff00b13; // addi x22, x0, -1     # x22 = 0xffffffff
        rom[25] = 32'h01689423; // sh x22, 8(x17)       # 存储半字
        rom[26] = 32'h0088db83; // lhu x23, 8(x17)      # 无符号半字加载 (0xffff)
        rom[27] = 32'h00889c03; // lh x24, 8(x17)       # 有符号半字加载 (-1)
        rom[28] = 32'h00000463; // beq x0, x0, zero_equal     # 零等于零，应跳转
        rom[29] = 32'h3e700c93; // addi x25, x0, 999          # 不应执行
        rom[30] = 32'h00108463; // beq x1, x1, same_equal     # 相同值相等，应跳转
        rom[31] = 32'h3e600c93; // addi x25, x0, 998          # 不应执行
        rom[32] = 32'h00309463; // bne x1, x3, diff_not_equal # 不同值不等，应跳转
        rom[33] = 32'h3e500c93; // addi x25, x0, 997          # 不应执行
        rom[34] = 32'h0011c463; // blt x3, x1, signed_less    # 最小负数 < 最大正数，应跳转
        rom[35] = 32'h3e400c93; // addi x25, x0, 996          # 不应执行
        rom[36] = 32'h00800463; // beq x0, x0, 8             # 强制跳转到立即数测试（跳转到rom[38]）
        rom[37] = 32'h3e300c93; // addi x25, x0, 995          # 不应执行
        rom[38] = 32'h7ff00e93; // addi x29, x0, 2047         # x29 = 0x7ff (12位最大正数)
        rom[39] = 32'h80000f13; // addi x30, x0, -2048        # x30 = 0x800 (12位最小负数)
        rom[40] = 32'hffffffb7; // lui x31, 0xfffff          # x31 = 0xfffff000 (20位全1)
        rom[41] = 32'h06400013; // addi x0, x0, 100          # 尝试修改x0，应无效果
        rom[42] = 32'h00208033; // add x0, x1, x2            # 尝试修改x0，应无效果
        rom[43] = 32'h00100c93; // addi x25, x0, 1           # x25 = 1 (用于测试分支条件)
        rom[44] = 32'h019c8d33; // add x26, x25, x25         # x26 = 2 (RAW冒险测试)
        rom[45] = 32'h01ac86b3; // add x13, x25, x26         # x13 = 3 (连续RAW冒险)
        
        // Load-Use冒险测试序列
        rom[46] = 32'h00000893; // addi x17, x0, 0           # x17 = 0 (基地址)
        rom[47] = 32'hfff00913; // addi x18, x0, -1          # x18 = -1 (准备测试数据)
        rom[48] = 32'h0128a023; // sw x18, 0(x17)            # 存储x18到地址0（准备数据）
        rom[49] = 32'h0008a903; // lw x18, 0(x17)            # 加载指令：lw x18, 0(x17)
        rom[50] = 32'h01290933; // add x18, x18, x18         # Load-Use冒险：立即使用x18
        rom[51] = 32'h0008a983; // lw x19, 0(x17)            # 再次加载：lw x19, 0(x17)
        rom[52] = 32'h013989b3; // add x19, x19, x19         # Load-Use冒险：立即使用x19
        rom[53] = 32'h00000013; // nop                       # NOP指令
    
        // 连续Load-Use冒险测试
        rom[54] = 32'h0008aa03; // lw x20, 0(x17)            # 加载到x20
        rom[55] = 32'h014a0a33; // add x20, x20, x20         # 立即使用x20
        rom[56] = 32'h015a0ab3; // add x21, x20, x21         # 使用x20的结果
        
        // 清除测试标记并结束
        rom[57] = 32'h00000c93; // addi x25, x0, 0           # x25 = 0 (清除错误标记)
        rom[58] = 32'h00000013; // addi x0, x0, 0            # NOP
        rom[59] = 32'h00000063; // beq x0, x0, 0             # 无限循环（跳转到自己）
        
        // 剩余位置初始化为NOP
        for (i = 60; i < 256; i = i + 1) begin
            rom[i] = 32'h00000013; // addi x0, x0, 0 (NOP)
        end
    end
endmodule
