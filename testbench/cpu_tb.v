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
        $dumpfile("cpu_tb.vcd");
        // 转储所有信号（包括寄存器数组）
        $dumpvars(0, cpu_tb);
        
        // // 显式添加寄存器监控（用于终端显示）
        // $monitor("时间: %0t | PC: %h | 指令: %h | x1: %h | x2: %h | x3: %h | x4: %h | x5: %h | x6: %h", 
        //          $time, uut.pc, uut.inst, 
        //          uut.u_regfile.regs[1], uut.u_regfile.regs[2], 
        //          uut.u_regfile.regs[3], uut.u_regfile.regs[4],
        //          uut.u_regfile.regs[5], uut.u_regfile.regs[6]);

        #300;  // 增加仿真时间以执行更多指令
        
        // 显示最终结果
        $display("\n=== 仿真结束 - 所有R型指令测试结果 ===");
        $display("x1 (初始值 5):     %0d", uut.u_regfile.regs[1]);
        $display("x2 (初始值 2):     %0d", uut.u_regfile.regs[2]);
        $display("x3 (ADD 5+2):      %0d", uut.u_regfile.regs[3]);
        $display("x4 (SUB 2-5):      %0d", uut.u_regfile.regs[4]);
        $display("x5 (OR 5|2):       %0d", uut.u_regfile.regs[5]);
        $display("x6 (AND 5&2):      %0d", uut.u_regfile.regs[6]);
        $display("x7 (XOR 5^2):      %0d", uut.u_regfile.regs[7]);
        $display("x8 (SLL 5<<2):     %0d", uut.u_regfile.regs[8]);
        $display("x9 (SRL 5>>2):     %0d", uut.u_regfile.regs[9]);
        $display("x10 (SRA 5>>>2):   %0d", uut.u_regfile.regs[10]);
        $display("x11 (SLT 5<2):     %0d", uut.u_regfile.regs[11]);
        $display("x12 (SLTU 5<2):    %0d", uut.u_regfile.regs[12]);
        $display("x13 (LW from mem): %0d", uut.u_regfile.regs[13]);
        $display("x14 (分支结果):    %0d", uut.u_regfile.regs[14]);
        $display("\n✅ 所有R型指令测试完成!");
        
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
endmodule 