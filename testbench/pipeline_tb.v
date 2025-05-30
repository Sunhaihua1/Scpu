// pipeline_tb.v - 四阶段流水线CPU测试台
`timescale 1ns / 1ps

module pipeline_tb;
    reg clk;
    reg reset;

    // 实例化四阶段流水线CPU
    pipeline_cpu cpu(
        .clk(clk),
        .reset(reset)
    );

    // 时钟生成
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // 监控信号
    wire [31:0] pc_if = cpu.pc_if;
    wire [31:0] pc_id = cpu.pc_id;
    wire [31:0] pc_ex = cpu.pc_ex;
    wire [31:0] instr_id = cpu.instr_id;
    wire [31:0] alu_result_ex = cpu.alu_result_ex;
    wire [4:0] rs1_ex = cpu.rs1_ex;
    wire [4:0] rs2_ex = cpu.rs2_ex;
    wire [4:0] rd_ex = cpu.rd_ex;
    wire [4:0] rd_wb = cpu.rd_wb;
    wire reg_write_wb = cpu.reg_write_wb;
    wire [1:0] forward_a = cpu.forward_a;
    wire [1:0] forward_b = cpu.forward_b;
    wire stall = cpu.stall;
    wire branch_taken = cpu.branch_taken;
    wire [31:0] write_data_wb = cpu.write_data_wb;

    // 生成VCD文件
    initial begin
        $dumpfile("pipeline_tb.vcd");
        $dumpvars(0, pipeline_tb);
    end

    // 测试任务：显示流水线状态
    task display_pipeline_state;
        begin
            $display("--- 四阶段流水线状态 (时间=%0t) ---", $time);
            $display("IF: PC=%h, Instr=%h", pc_if, cpu.instr_if);
            $display("ID: PC=%h, Instr=%h", pc_id, instr_id);
            $display("EX: PC=%h, ALU=%0d, rs1=%2d, rs2=%2d, rd=%2d", pc_ex, alu_result_ex, rs1_ex, rs2_ex, rd_ex);
            $display("WB: Data=%0d, rd=%2d, reg_write=%b", write_data_wb, rd_wb, reg_write_wb);
            if (stall)
                $display("*** 检测到流水线停顿 ***");
            if (forward_a != 2'b00 || forward_b != 2'b00)
                $display("*** 数据前递：A=%b, B=%b ***", forward_a, forward_b);
            if (branch_taken)
                $display("*** 分支跳转到：%h ***", cpu.pc_branch_ex);
            $display("");
        end
    endtask

    // 测试任务：显示寄存器内容
    task display_registers;
        integer i;
        begin
            for (i = 0; i < 16; i = i + 1) begin
                $display("x%0d = %0d", i, cpu.regfile_module.regs[i]);
            end
        end
    endtask

    // 主测试序列
    initial begin
        $display("=== 四阶段流水线CPU测试开始 ===");
        
        // 复位
        reset = 1;
        #10;
        reset = 0;
        #10;

        // 监控流水线执行
        $monitor("时间=%0t, PC_IF=%h, PC_ID=%h, PC_EX=%h, Instr_ID=%h, ALU_Result=%0d, rs1=%2d, rs2=%2d, rd=%2d, reg_write=%b, 前递A=%b, 前递B=%b", 
                 $time, pc_if, pc_id, pc_ex, instr_id, alu_result_ex, rs1_ex, rs2_ex, rd_ex, reg_write_wb, forward_a, forward_b);

        // 运行一段时间观察流水线状态
        repeat(20) begin
            #10;
            display_pipeline_state;
        end

        $display("\n=== 中期检查 (时间150ns) ===");
        display_registers;

        // 继续运行
        repeat(20) begin
            #10;
            display_pipeline_state;
        end

        $display("\n=== 寄存器最终状态 ===");
        display_registers;
        
        $display("\n=== 仿真结束 - 四阶段流水线CPU测试结果 ===");
        $display("x1 (初始值 5):     %0d", cpu.regfile_module.regs[1]);
        $display("x2 (初始值 2):     %0d", cpu.regfile_module.regs[2]);
        $display("x3 (ADD 5+2):      %0d", cpu.regfile_module.regs[3]);
        $display("x4 (SUB 2-5):      %0d", cpu.regfile_module.regs[4]);
        $display("x5 (OR 5|2):       %0d", cpu.regfile_module.regs[5]);
        $display("x6 (AND 5&2):      %0d", cpu.regfile_module.regs[6]);
        $display("x7 (XOR 5^2):      %0d", cpu.regfile_module.regs[7]);
        $display("x8 (SLL 5<<2):     %0d", cpu.regfile_module.regs[8]);
        $display("x9 (SRL 5>>2):     %0d", cpu.regfile_module.regs[9]);
        $display("x10 (SRA 5>>>2):   %0d", cpu.regfile_module.regs[10]);
        $display("x11 (SLT 5<2):     %0d", cpu.regfile_module.regs[11]);
        $display("x12 (SLTU 5<2):    %0d", cpu.regfile_module.regs[12]);
        $display("x13 (LW from mem): %0d", cpu.regfile_module.regs[13]);
        $display("x14 (分支结果):    %0d", cpu.regfile_module.regs[14]);

        $display("\n✅ 四阶段流水线CPU测试完成!");
        $finish;
    end

    // 超时保护
    initial begin
        #500;
        $display("\n⚠️  测试超时，强制结束");
        $finish;
    end

endmodule
