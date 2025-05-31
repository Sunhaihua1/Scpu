// pipeline_fibonacci_tb.v - 流水线CPU斐波那契测试台
`timescale 1ns / 1ps

module pipeline_fibonacci_tb;
    reg clk, reset;
    
    // 实例化流水线CPU，使用斐波那契指令存储器
    pipeline_cpu_fibonacci cpu_pipeline(
        .clk(clk),
        .reset(reset)
    );

    // 生成时钟信号
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns周期
    end
    
    // 主测试流程
    initial begin
        $dumpfile("output/pipeline_fibonacci_tb.vcd");
        $dumpvars(0, pipeline_fibonacci_tb);
        
        // 初始化
        reset = 1;
        #20;
        reset = 0;
        
        $display("=== 流水线CPU斐波那契数列计算测试开始 ===");
        $display("程序将计算前10个斐波那契数：");
        $display("fib(0)=1, fib(1)=1, fib(2)=2, fib(3)=3, fib(4)=5, ...");
        $display("");
        $display("开始执行计算...");
        
        // 等待计算完成（检测死循环状态）
        wait_for_completion();
        
        // 显示计算结果
        display_fibonacci_results();
        
        $display("");
        $display("=== 流水线CPU斐波那契数列计算测试完成 ===");
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
            while (stable_count < 20) begin
                #10;
                if (cpu_pipeline.pc_module.pc == prev_pc && prev_pc == 100) begin // rom[25] = 地址100
                    stable_count = stable_count + 1;
                end else begin
                    stable_count = 0;
                end
                prev_pc = cpu_pipeline.pc_module.pc;
                
                // 防止无限等待
                if ($time > 20000) begin
                    $display("⚠️  计算时间过长，强制停止");
                    stable_count = 20; // 退出循环
                end
            end
            
            $display("计算完成！流水线程序已到达结束状态。");
        end
    endtask

    // 显示斐波那契计算结果
    task display_fibonacci_results;
        integer i;
        reg [31:0] reg_result, mem_result;
        integer error_count;
        reg [31:0] expected_fibs [0:9];
        begin
            // 期望的斐波那契数列值
            expected_fibs[0] = 1;  expected_fibs[1] = 1;  expected_fibs[2] = 2;
            expected_fibs[3] = 3;  expected_fibs[4] = 5;  expected_fibs[5] = 8;
            expected_fibs[6] = 13; expected_fibs[7] = 21; expected_fibs[8] = 34;
            expected_fibs[9] = 55;
            
            error_count = 0;
            
            $display("");
            $display("=== 流水线CPU斐波那契数列计算结果 ===");
            $display("从寄存器读取结果：");
            for (i = 0; i < 10; i = i + 1) begin
                reg_result = cpu_pipeline.regfile_module.regs[15 + i];
                $display("fib(%0d) = %0d (寄存器x%0d)", i, reg_result, 15 + i);
            end
            
            $display("");
            $display("从内存读取结果验证：");
            for (i = 0; i < 10; i = i + 1) begin
                mem_result = cpu_pipeline.dmem_module.ram[i];
                $display("fib(%0d) = %0d (内存地址%0d)", i, mem_result, i * 4);
            end
            
            $display("");
            $display("=== 结果验证 ===");
            for (i = 0; i < 10; i = i + 1) begin
                reg_result = cpu_pipeline.regfile_module.regs[15 + i];
                if (reg_result == expected_fibs[i]) begin
                    $display("✅ fib(%0d): %0d", i, reg_result);
                end else begin
                    $display("❌ fib(%0d): 期望=%0d, 实际=%0d", i, expected_fibs[i], reg_result);
                    error_count = error_count + 1;
                end
            end
            
            $display("");
            if (error_count == 0) begin
                $display("🎉 所有斐波那契数计算正确！");
            end else begin
                $display("⚠️  发现%0d个错误", error_count);
            end
        end
    endtask

endmodule
