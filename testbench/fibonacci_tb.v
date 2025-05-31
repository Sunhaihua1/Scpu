// fibonacci_tb.v - 斐波那契数列计算测试平台
`timescale 1ns / 1ps

module fibonacci_tb;
    reg clk;
    reg reset;

    // 斐波那契数列专用CPU实例 (使用单周期CPU)
    cpu_fibonacci cpu_fib(
        .clk(clk),
        .rst(reset)
    );

    // 时钟生成
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // 生成VCD文件
    initial begin
        $dumpfile("output/fibonacci_tb.vcd");
        $dumpvars(0, fibonacci_tb);
    end

    // 主测试序列
    initial begin
        $display("=== 斐波那契数列计算测试开始 ===");
        $display("程序将计算前10个斐波那契数：");
        $display("fib(0)=1, fib(1)=1, fib(2)=2, fib(3)=3, fib(4)=5, ...");
        $display("");
        
        // 复位
        reset = 1;
        #10;
        reset = 0;

        // 监控程序执行
        $display("开始执行计算...");
        
        // 等待计算完成（当程序到达死循环时停止）
        wait_for_completion();
        
        // 显示计算结果
        display_fibonacci_results();
        
        $display("\n=== 斐波那契数列计算测试完成 ===");
        $finish;
    end

    // 等待计算完成的任务
    task wait_for_completion;
        reg [31:0] prev_pc;
        integer stable_count;
        begin
            stable_count = 0;
            prev_pc = 32'hffffffff;
            
            // 检测PC是否稳定在某个值（死循环）
            while (stable_count < 10) begin
                #10;
                if (cpu_fib.u_pc.pc == prev_pc && prev_pc == 104) begin // rom[26] = 地址104的死循环
                    stable_count = stable_count + 1;
                end else begin
                    stable_count = 0;
                end
                prev_pc = cpu_fib.u_pc.pc;
                
                // 防止无限等待
                if ($time > 10000) begin
                    $display("⚠️  计算时间过长，强制停止");
                    stable_count = 10; // 退出循环
                end
            end
            
            $display("计算完成！程序已到达结束状态。");
        end
    endtask

    // 显示斐波那契计算结果
    task display_fibonacci_results;
        begin
            $display("\n=== 斐波那契数列计算结果 ===");
            $display("从寄存器读取结果：");
            $display("fib(0) = %0d (寄存器x15)", cpu_fib.u_regfile.regs[15]);
            $display("fib(1) = %0d (寄存器x16)", cpu_fib.u_regfile.regs[16]);
            $display("fib(2) = %0d (寄存器x17)", cpu_fib.u_regfile.regs[17]);
            $display("fib(3) = %0d (寄存器x18)", cpu_fib.u_regfile.regs[18]);
            $display("fib(4) = %0d (寄存器x19)", cpu_fib.u_regfile.regs[19]);
            $display("fib(5) = %0d (寄存器x20)", cpu_fib.u_regfile.regs[20]);
            $display("fib(6) = %0d (寄存器x21)", cpu_fib.u_regfile.regs[21]);
            $display("fib(7) = %0d (寄存器x22)", cpu_fib.u_regfile.regs[22]);
            $display("fib(8) = %0d (寄存器x23)", cpu_fib.u_regfile.regs[23]);
            $display("fib(9) = %0d (寄存器x24)", cpu_fib.u_regfile.regs[24]);
            
            $display("\n从内存读取结果验证：");
            $display("fib(0) = %0d (内存地址0)", cpu_fib.u_dmem.ram[0]);
            $display("fib(1) = %0d (内存地址4)", cpu_fib.u_dmem.ram[1]);
            $display("fib(2) = %0d (内存地址8)", cpu_fib.u_dmem.ram[2]);
            $display("fib(3) = %0d (内存地址12)", cpu_fib.u_dmem.ram[3]);
            $display("fib(4) = %0d (内存地址16)", cpu_fib.u_dmem.ram[4]);
            $display("fib(5) = %0d (内存地址20)", cpu_fib.u_dmem.ram[5]);
            $display("fib(6) = %0d (内存地址24)", cpu_fib.u_dmem.ram[6]);
            $display("fib(7) = %0d (内存地址28)", cpu_fib.u_dmem.ram[7]);
            $display("fib(8) = %0d (内存地址32)", cpu_fib.u_dmem.ram[8]);
            $display("fib(9) = %0d (内存地址36)", cpu_fib.u_dmem.ram[9]);
            
            // 验证结果正确性
            verify_fibonacci_results();
        end
    endtask

    // 验证斐波那契数列结果
    task verify_fibonacci_results;
        reg [31:0] expected_fib [0:9];
        integer i;
        integer errors;
        begin
            // 期望的斐波那契数列
            expected_fib[0] = 1;   // fib(0)
            expected_fib[1] = 1;   // fib(1) 
            expected_fib[2] = 2;   // fib(2)
            expected_fib[3] = 3;   // fib(3)
            expected_fib[4] = 5;   // fib(4)
            expected_fib[5] = 8;   // fib(5)
            expected_fib[6] = 13;  // fib(6)
            expected_fib[7] = 21;  // fib(7)
            expected_fib[8] = 34;  // fib(8)
            expected_fib[9] = 55;  // fib(9)
            
            $display("\n=== 结果验证 ===");
            errors = 0;
            
            for (i = 0; i < 10; i = i + 1) begin
                if (cpu_fib.u_dmem.ram[i] != expected_fib[i]) begin
                    $display("❌ fib(%0d): 期望=%0d, 实际=%0d", 
                             i, expected_fib[i], cpu_fib.u_dmem.ram[i]);
                    errors = errors + 1;
                end else begin
                    $display("✅ fib(%0d): %0d", i, cpu_fib.u_dmem.ram[i]);
                end
            end
            
            if (errors == 0) begin
                $display("\n🎉 所有斐波那契数计算正确！");
            end else begin
                $display("\n⚠️  发现%0d个错误", errors);
            end
        end
    endtask

    // 监控关键指令执行
    always @(posedge clk) begin
        if (!reset) begin
            // 监控BGE指令
            if (cpu_fib.u_pc.pc == 28) begin  // rom[7] - 循环开始的bge指令
                $display("时间 %0t: BGE检查 x10=%0d >= x11=%0d ? branch_taken=%b, alu_result=0x%08x", 
                         $time, cpu_fib.u_regfile.regs[10], 
                         cpu_fib.u_regfile.regs[11],
                         cpu_fib.branch_taken,
                         cpu_fib.alu_result);
            end
            
            if (cpu_fib.u_pc.pc == 32) begin  // rom[8] - 加法指令
                $display("时间 %0t: 计算 fib(%0d), F(n-2)=%0d + F(n-1)=%0d", 
                         $time, cpu_fib.u_regfile.regs[10], 
                         cpu_fib.u_regfile.regs[15], cpu_fib.u_regfile.regs[16]);
            end
            
            // 监控存储操作
            if (cpu_fib.u_control.mem_write && cpu_fib.u_regfile.regs[10] <= 9) begin
                $display("时间 %0t: 存储 fib(%0d) = %0d 到地址 %0d", 
                         $time, cpu_fib.u_regfile.regs[10], 
                         cpu_fib.u_regfile.regs[17], 
                         cpu_fib.u_regfile.regs[13]);
            end
            
            // 监控加载操作
            if (cpu_fib.u_pc.pc >= 64 && cpu_fib.u_pc.pc <= 100) begin
                $display("时间 %0t: 执行加载指令 PC=%0d, inst=0x%08x", 
                         $time, cpu_fib.u_pc.pc, cpu_fib.inst);
            end
            
            // 监控PC变化
            if (cpu_fib.u_pc.pc == 60) begin  // 应该跳转到的结束部分
                $display("时间 %0t: 到达结束部分 PC=%0d", $time, cpu_fib.u_pc.pc);
            end
        end
    end

endmodule
