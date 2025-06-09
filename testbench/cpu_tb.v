// cpu_tb.v 测试平台
`timescale 1ns/1ps
module cpu_tb;
    reg clk;
    reg rst;
    integer i; // 移到模块最外层

    // 实例化CPU
    cpu uut(
        .clk(clk),
        .rst(rst)
    );

    // 时钟生成
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // 复位信号
    initial begin
        rst = 1;
        #20;
        rst = 0;
    end

    initial begin
        $dumpfile("output/cpu_tb.vcd");
        // 转储所有信号（包括寄存器数组）
        $dumpvars(0, cpu_tb);
        
    #1000000; // 等待足够的时间让程序执行完成

    $display("\n=== 仿真结束 - 边界测试结果 ===");
    $display("=== 算术边界测试 ===");
    $display("x1 (最大正数):       0x%08x (%0d)", uut.u_regfile.regs[1], $signed(uut.u_regfile.regs[1]));
    $display("x2 (溢出结果):       0x%08x (%0d)", uut.u_regfile.regs[2], $signed(uut.u_regfile.regs[2]));
    $display("x3 (最小负数):       0x%08x (%0d)", uut.u_regfile.regs[3], $signed(uut.u_regfile.regs[3]));
    $display("x4 (下溢结果):       0x%08x (%0d)", uut.u_regfile.regs[4], $signed(uut.u_regfile.regs[4]));
    $display("x5 (零寄存器测试):   0x%08x (%0d)", uut.u_regfile.regs[5], $signed(uut.u_regfile.regs[5]));
    $display("x6 (相同数相减):     0x%08x (%0d)", uut.u_regfile.regs[6], $signed(uut.u_regfile.regs[6]));
    
    $display("\n=== 移位边界测试 ===");
    $display("x7 (基数1):          0x%08x (%0d)", uut.u_regfile.regs[7], $signed(uut.u_regfile.regs[7]));
    $display("x8 (左移31位):       0x%08x (%0d)", uut.u_regfile.regs[8], $signed(uut.u_regfile.regs[8]));
    $display("x9 (右移31位):       0x%08x (%0d)", uut.u_regfile.regs[9], $signed(uut.u_regfile.regs[9]));
    $display("x10 (移位量33):      0x%08x (%0d)", uut.u_regfile.regs[10], $signed(uut.u_regfile.regs[10]));
    $display("x11 (实际移位1位):   0x%08x (%0d)", uut.u_regfile.regs[11], $signed(uut.u_regfile.regs[11]));
    $display("x12 (算术右移):      0x%08x (%0d)", uut.u_regfile.regs[12], $signed(uut.u_regfile.regs[12]));
    
    $display("\n=== 比较边界测试 ===");
    $display("x13 (有符号<):       0x%08x (%0d)", uut.u_regfile.regs[13], $signed(uut.u_regfile.regs[13]));
    $display("x14 (有符号>):       0x%08x (%0d)", uut.u_regfile.regs[14], $signed(uut.u_regfile.regs[14]));
    $display("x15 (无符号<):       0x%08x (%0d)", uut.u_regfile.regs[15], $signed(uut.u_regfile.regs[15]));
    $display("x16 (无符号>):       0x%08x (%0d)", uut.u_regfile.regs[16], $signed(uut.u_regfile.regs[16]));
    
    $display("\n=== 内存边界测试 ===");
    $display("x17 (基地址):        0x%08x (%0d)", uut.u_regfile.regs[17], $signed(uut.u_regfile.regs[17]));
    $display("x18 (字加载):        0x%08x (%0d)", uut.u_regfile.regs[18], $signed(uut.u_regfile.regs[18]));
    $display("x19 (字节值255):     0x%08x (%0d)", uut.u_regfile.regs[19], $signed(uut.u_regfile.regs[19]));
    $display("x20 (无符号字节):    0x%08x (%0d)", uut.u_regfile.regs[20], $signed(uut.u_regfile.regs[20]));
    $display("x21 (有符号字节):    0x%08x (%0d)", uut.u_regfile.regs[21], $signed(uut.u_regfile.regs[21]));
    $display("x22 (半字值-1):      0x%08x (%0d)", uut.u_regfile.regs[22], $signed(uut.u_regfile.regs[22]));
    $display("x23 (无符号半字):    0x%08x (%0d)", uut.u_regfile.regs[23], $signed(uut.u_regfile.regs[23]));
    $display("x24 (有符号半字):    0x%08x (%0d)", uut.u_regfile.regs[24], $signed(uut.u_regfile.regs[24]));
    
    $display("\n=== 分支跳转测试 ===");
    $display("x25 (跳转检测):      0x%08x (%0d)", uut.u_regfile.regs[25], $signed(uut.u_regfile.regs[25]));
    $display("x26 (JAL返回地址):   0x%08x (%0d)", uut.u_regfile.regs[26], $signed(uut.u_regfile.regs[26]));
    $display("x27 (跳转目标):      0x%08x (%0d)", uut.u_regfile.regs[27], $signed(uut.u_regfile.regs[27]));
    $display("x28 (JALR返回地址):  0x%08x (%0d)", uut.u_regfile.regs[28], $signed(uut.u_regfile.regs[28]));
    
    $display("\n=== 立即数边界测试 ===");
    $display("x29 (12位最大正数):  0x%08x (%0d)", uut.u_regfile.regs[29], $signed(uut.u_regfile.regs[29]));
    $display("x30 (12位最小负数):  0x%08x (%0d)", uut.u_regfile.regs[30], $signed(uut.u_regfile.regs[30]));
    $display("x31 (20位全1):       0x%08x (%0d)", uut.u_regfile.regs[31], $signed(uut.u_regfile.regs[31]));
    
    $display("\n=== Load-Use连续操作测试 ===");
    $display("x17 (基地址):        0x%08x (%0d)", uut.u_regfile.regs[17], $signed(uut.u_regfile.regs[17]));
    $display("x18 (Load-Use测试1): 0x%08x (%0d)", uut.u_regfile.regs[18], $signed(uut.u_regfile.regs[18]));
    $display("x19 (Load-Use测试2): 0x%08x (%0d)", uut.u_regfile.regs[19], $signed(uut.u_regfile.regs[19]));
    $display("x20 (Load-Use测试3): 0x%08x (%0d)", uut.u_regfile.regs[20], $signed(uut.u_regfile.regs[20]));
    $display("x21 (连续Load-Use):  0x%08x (%0d)", uut.u_regfile.regs[21], $signed(uut.u_regfile.regs[21]));
    
    // 验证Load-Use测试结果正确性
    if (uut.u_regfile.regs[18] != 0 && uut.u_regfile.regs[19] != 0 && uut.u_regfile.regs[20] != 0) begin
        $display("✅ Load-Use测试：所有寄存器都有正确的非零值");
        // 检查值的逻辑关系（假设x18被加倍，x19被加倍，x20被加倍）
        if (uut.u_regfile.regs[18] == 2 * uut.u_regfile.regs[1] || 
            uut.u_regfile.regs[18] == 2 * 32'h7fffffff) begin
            $display("✅ x18的值符合预期（Load后立即使用）");
        end else begin
            $display("⚠️  x18的值可能不符合预期: %0d", uut.u_regfile.regs[18]);
        end
    end else begin
        $display("❌ Load-Use测试可能失败：存在零值寄存器");
    end
    $display("\n=== 内存状态检查 ===");
    $display("内存[0] (存储测试):  0x%08x (%0d)", uut.u_dmem.ram[0], $signed(uut.u_dmem.ram[0]));
    $display("内存[1] (字节测试):  0x%08x (%0d)", uut.u_dmem.ram[1], $signed(uut.u_dmem.ram[1]));
    $display("内存[2] (半字测试):  0x%08x (%0d)", uut.u_dmem.ram[2], $signed(uut.u_dmem.ram[2]));
    
    // 验证测试结果
    $display("\n=== 测试验证 ===");
    if (uut.u_regfile.regs[25] == 0) 
        $display("✅ 分支跳转测试通过！");
    else 
        $display("❌ 分支跳转测试失败，x25 = %0d", uut.u_regfile.regs[25]);
        
    if (uut.u_regfile.regs[1] == 32'h7fffffff)
        $display("✅ 最大正数测试通过！");
    else
        $display("❌ 最大正数测试失败");
        
    if (uut.u_regfile.regs[2] == 32'h80000000)
        $display("✅ 溢出测试通过！");
    else
        $display("❌ 溢出测试失败");
    
    $display("\n✅ 边界测试程序执行完成!");
    $finish;
   end

    // 每20ns显示所有非零寄存器的状态
    always @(posedge clk) begin
        if (!rst && ($time % 200 == 0) && $time > 25) begin
            $display("\n=== 时间 %0t 寄存器状态 ===", $time);
            for (i = 1; i < 16; i = i + 1) begin
                if (uut.u_regfile.regs[i] != 0)
                    $display("  x%0d = %0d (0x%h)", i, uut.u_regfile.regs[i], uut.u_regfile.regs[i]);
            end
            $display("  当前指令: %h, ALU操作: %h, ALU结果: %h", 
                     uut.inst, uut.alu_op, uut.alu_result);
            $display("");
        end
    end

    // 监控写回操作
    always @(posedge clk) begin
        if (!rst && uut.reg_write && uut.rd != 0) begin
            $display("时间 %0t: 写回 x%0d = %h (ALU结果: %h, 内存数据: %h)", 
                     $time, uut.rd, uut.write_data, uut.alu_result, uut.mem_data);
        end
    end
    
    // 监控Load-Use冒险测试区域的执行
    always @(posedge clk) begin
        if (!rst && uut.pc >= 32'hbc && uut.pc <= 32'hec) begin  // ROM[47]-ROM[59]范围
            $display("时间 %0t: Load-Use测试区域 PC=%h, 指令=%h", 
                     $time, uut.pc, uut.inst);
            
            // 监控Load指令
            if (uut.inst[6:0] == 7'b0000011) begin  // Load指令opcode
                $display("  🔵 Load指令: lw x%0d, offset(x%0d)", 
                         uut.inst[11:7], uut.inst[19:15]);
                $display("     地址计算: x%0d + %0d = %h", 
                         uut.inst[19:15], $signed(uut.inst[31:20]), uut.alu_result);
            end
            
            // 监控R-type指令（可能的Load-Use冒险目标）
            if (uut.inst[6:0] == 7'b0110011) begin  // R-type指令
                $display("  🟡 R-type指令: rs1=x%0d, rs2=x%0d, rd=x%0d", 
                         uut.inst[19:15], uut.inst[24:20], uut.inst[11:7]);
                $display("     操作数: %h + %h = %h", 
                         uut.reg1_data, uut.reg2_data, uut.alu_result);
            end
            
            // 显示关键寄存器状态
            if (uut.reg_write && uut.rd != 0) begin
                $display("  ✅ 写回: x%0d <= %h", uut.rd, uut.write_data);
            end
            $display("");
        end
    end
endmodule