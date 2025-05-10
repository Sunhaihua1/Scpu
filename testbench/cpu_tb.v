// cpu_tb.v 测试平台
`timescale 1ns/1ps
module cpu_tb;
    reg clk;
    reg rst;

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

    // 仿真时间
    initial begin
        $dumpfile("cpu_tb.vcd");
        $dumpvars(0, cpu_tb);
        #200;
        $finish;
    end
endmodule 