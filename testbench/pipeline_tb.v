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
        $dumpfile("output/pipeline_tb.vcd");
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
        repeat(50) begin
            #10;
            display_pipeline_state;
        end

        $display("\n=== 寄存器最终状态 ===");
        display_registers;
        
        $display("\n=== 仿真结束 - 四阶段流水线CPU边界测试结果 ===");
        $display("=== 算术边界测试 ===");
        $display("x1 (最大正数):       0x%08x (%0d)", cpu.regfile_module.regs[1], $signed(cpu.regfile_module.regs[1]));
        $display("x2 (溢出结果):       0x%08x (%0d)", cpu.regfile_module.regs[2], $signed(cpu.regfile_module.regs[2]));
        $display("x3 (最小负数):       0x%08x (%0d)", cpu.regfile_module.regs[3], $signed(cpu.regfile_module.regs[3]));
        $display("x4 (下溢结果):       0x%08x (%0d)", cpu.regfile_module.regs[4], $signed(cpu.regfile_module.regs[4]));
        $display("x5 (零寄存器测试):   0x%08x (%0d)", cpu.regfile_module.regs[5], $signed(cpu.regfile_module.regs[5]));
        $display("x6 (相同数相减):     0x%08x (%0d)", cpu.regfile_module.regs[6], $signed(cpu.regfile_module.regs[6]));
        
        $display("\n=== 移位边界测试 ===");
        $display("x7 (基数1):          0x%08x (%0d)", cpu.regfile_module.regs[7], $signed(cpu.regfile_module.regs[7]));
        $display("x8 (左移31位):       0x%08x (%0d)", cpu.regfile_module.regs[8], $signed(cpu.regfile_module.regs[8]));
        $display("x9 (右移31位):       0x%08x (%0d)", cpu.regfile_module.regs[9], $signed(cpu.regfile_module.regs[9]));
        $display("x10 (移位量33):      0x%08x (%0d)", cpu.regfile_module.regs[10], $signed(cpu.regfile_module.regs[10]));
        $display("x11 (实际移位1位):   0x%08x (%0d)", cpu.regfile_module.regs[11], $signed(cpu.regfile_module.regs[11]));
        $display("x12 (算术右移):      0x%08x (%0d)", cpu.regfile_module.regs[12], $signed(cpu.regfile_module.regs[12]));
        
        $display("\n=== 比较边界测试 ===");
        $display("x13 (有符号<):       0x%08x (%0d)", cpu.regfile_module.regs[13], $signed(cpu.regfile_module.regs[13]));
        $display("x14 (有符号>):       0x%08x (%0d)", cpu.regfile_module.regs[14], $signed(cpu.regfile_module.regs[14]));
        $display("x15 (无符号<):       0x%08x (%0d)", cpu.regfile_module.regs[15], $signed(cpu.regfile_module.regs[15]));
        $display("x16 (无符号>):       0x%08x (%0d)", cpu.regfile_module.regs[16], $signed(cpu.regfile_module.regs[16]));
        
        $display("\n=== 内存边界测试 ===");
        $display("x17 (基地址):        0x%08x (%0d)", cpu.regfile_module.regs[17], $signed(cpu.regfile_module.regs[17]));
        $display("x18 (字加载):        0x%08x (%0d)", cpu.regfile_module.regs[18], $signed(cpu.regfile_module.regs[18]));
        $display("x19 (字节值255):     0x%08x (%0d)", cpu.regfile_module.regs[19], $signed(cpu.regfile_module.regs[19]));
        $display("x20 (无符号字节):    0x%08x (%0d)", cpu.regfile_module.regs[20], $signed(cpu.regfile_module.regs[20]));
        $display("x21 (有符号字节):    0x%08x (%0d)", cpu.regfile_module.regs[21], $signed(cpu.regfile_module.regs[21]));
        $display("x22 (半字值-1):      0x%08x (%0d)", cpu.regfile_module.regs[22], $signed(cpu.regfile_module.regs[22]));
        $display("x23 (无符号半字):    0x%08x (%0d)", cpu.regfile_module.regs[23], $signed(cpu.regfile_module.regs[23]));
        $display("x24 (有符号半字):    0x%08x (%0d)", cpu.regfile_module.regs[24], $signed(cpu.regfile_module.regs[24]));
        
        $display("\n=== 分支跳转测试 ===");
        $display("x25 (跳转检测):      0x%08x (%0d)", cpu.regfile_module.regs[25], $signed(cpu.regfile_module.regs[25]));
        $display("x26 (JAL返回地址):   0x%08x (%0d)", cpu.regfile_module.regs[26], $signed(cpu.regfile_module.regs[26]));
        $display("x27 (跳转目标):      0x%08x (%0d)", cpu.regfile_module.regs[27], $signed(cpu.regfile_module.regs[27]));
        $display("x28 (JALR返回地址):  0x%08x (%0d)", cpu.regfile_module.regs[28], $signed(cpu.regfile_module.regs[28]));
        
        $display("\n=== 立即数边界测试 ===");
        $display("x29 (12位最大正数):  0x%08x (%0d)", cpu.regfile_module.regs[29], $signed(cpu.regfile_module.regs[29]));
        $display("x30 (12位最小负数):  0x%08x (%0d)", cpu.regfile_module.regs[30], $signed(cpu.regfile_module.regs[30]));
        $display("x31 (20位全1):       0x%08x (%0d)", cpu.regfile_module.regs[31], $signed(cpu.regfile_module.regs[31]));
        
        $display("\n=== 内存状态检查 ===");
        $display("内存[0] (存储测试):  0x%08x (%0d)", cpu.dmem_module.ram[0], $signed(cpu.dmem_module.ram[0]));
        $display("内存[1] (字节测试):  0x%08x (%0d)", cpu.dmem_module.ram[1], $signed(cpu.dmem_module.ram[1]));
        $display("内存[2] (半字测试):  0x%08x (%0d)", cpu.dmem_module.ram[2], $signed(cpu.dmem_module.ram[2]));
        
        // 验证关键测试结果
        $display("\n=== 测试结果验证 ===");
        if (cpu.regfile_module.regs[25] == 0) 
            $display("✅ 分支跳转测试通过！");
        else 
            $display("❌ 分支跳转测试失败，x25 = %0d", cpu.regfile_module.regs[25]);
            
        if (cpu.regfile_module.regs[1] == 32'h7fffffff)
            $display("✅ 最大正数测试通过！");
        else
            $display("❌ 最大正数测试失败");
            
        if (cpu.regfile_module.regs[2] == 32'h80000000)
            $display("✅ 溢出测试通过！");
        else
            $display("❌ 溢出测试失败");

        // Load-Use冒险测试验证
        $display("\n=== Load-Use冒险测试验证 ===");
        $display("x18 (Load-Use测试1):  0x%08x (%0d)", cpu.regfile_module.regs[18], $signed(cpu.regfile_module.regs[18]));
        $display("x19 (Load-Use测试2):  0x%08x (%0d)", cpu.regfile_module.regs[19], $signed(cpu.regfile_module.regs[19]));
        $display("x20 (Load-Use测试3):  0x%08x (%0d)", cpu.regfile_module.regs[20], $signed(cpu.regfile_module.regs[20]));
        $display("x21 (连续Load-Use):   0x%08x (%0d)", cpu.regfile_module.regs[21], $signed(cpu.regfile_module.regs[21]));
        
        // 验证Load-Use测试结果
        if (cpu.regfile_module.regs[18] != 0 && cpu.regfile_module.regs[19] != 0)
            $display("✅ Load-Use冒险处理正确！");
        else
            $display("❌ Load-Use冒险处理可能有问题");

        $display("\n✅ 四阶段流水线CPU边界测试完成!");
        $finish;
    end

    // 超时保护
    initial begin
        #2000;  // 增加超时时间
        $display("\n⚠️  测试超时，强制结束");
        $display("\n=== 超时时寄存器状态 ===");
        $display("x29 (12位最大正数):  0x%08x (%0d)", cpu.regfile_module.regs[29], $signed(cpu.regfile_module.regs[29]));
        $display("x30 (12位最小负数):  0x%08x (%0d)", cpu.regfile_module.regs[30], $signed(cpu.regfile_module.regs[30]));
        $display("x31 (20位全1):       0x%08x (%0d)", cpu.regfile_module.regs[31], $signed(cpu.regfile_module.regs[31]));
        $finish;
    end

    // Load-Use冒险专门测试监控
    always @(posedge clk) begin
        // 监控ROM[48]-ROM[55]的Load-Use冒险测试区域
        if (pc_ex >= 32'hc4 && pc_ex <= 32'hdc) begin  // ROM[49]-ROM[55]对应地址范围
            $display("\n=== Load-Use冒险测试监控 (时间: %0t) ===", $time);
            // 从ID阶段获取opcode来判断指令类型
            $display("PC_EX: %h, PC_ID: %h", pc_ex, pc_id);
            $display("指令类型: %s", 
                (cpu.mem_read_ex) ? "LOAD" : 
                (instr_id[6:0] == 7'b0110011) ? "R-TYPE" : 
                (instr_id[6:0] == 7'b0010011) ? "I-TYPE" : "OTHER");
            $display("mem_read_ex: %b, rd_ex: %0d, rs1_id: %0d, rs2_id: %0d", 
                cpu.mem_read_ex, cpu.rd_ex, cpu.rs1_id, cpu.rs2_id);
            
            if (stall) begin
                $display("🔴 检测到Load-Use冒险停顿！");
                $display("   - 停顿原因: Load指令目标寄存器x%0d被下一条指令使用", cpu.rd_ex);
                $display("   - ID阶段指令需要: rs1=x%0d, rs2=x%0d", cpu.rs1_id, cpu.rs2_id);
                $display("   - Load指令: %h", cpu.instr_if);
                $display("   - 下一条指令: %h", instr_id);
            end else begin
                $display("🟢 正常执行，无Load-Use冒险");
            end
            $display("流水线状态: stall=%b, flush=%b", stall, cpu.flush);
        end
    end

    // 分支跳转调试
    always @(posedge clk) begin
        if (cpu.branch_taken) begin
            $display("*** 分支跳转检测到 ***");
            $display("时间: %0t, PC_EX: %h", $time, pc_ex);
            $display("下一个PC: %h", cpu.pc_next_if);
        end
        if (pc_if >= 32'h90) begin
            $display("*** 高地址执行 (时间: %0t) ***", $time);
            $display("PC_IF: %h, PC_ID: %h, PC_EX: %h", pc_if, pc_id, pc_ex);
            $display("指令: %h", cpu.instr_if);
        end
    end

    // BLTU指令调试
    always @(posedge clk) begin
        if (pc_ex >= 32'h88 && pc_ex <= 32'h98) begin
            $display("*** PC=%h调试 ***", pc_ex);
            $display("分支: %b, funct3: %b", cpu.branch_ex, cpu.funct3_ex);
            $display("ALU输入A: %h (%0d)", cpu.alu_input_a, cpu.alu_input_a);
            $display("ALU输入B: %h (%0d)", cpu.alu_input_b, cpu.alu_input_b);
            $display("ALU结果: %h, 分支条件: %b", cpu.alu_result_ex, cpu.branch_condition);
            $display("分支跳转: %b", cpu.branch_taken);
        end
    end

endmodule
