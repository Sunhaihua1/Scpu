// cpu_fibonacci.v - 使用斐波那契指令存储器的单周期CPU
module cpu_fibonacci(
    input wire clk,
    input wire reset
);

    // 内部信号定义
    wire [31:0] pc, next_pc, pc_plus4, pc_branch;
    wire [31:0] inst;
    wire [6:0] opcode;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire [4:0] rs1, rs2, rd;
    wire [31:0] imm;
    wire [31:0] read_data1, read_data2, write_data;
    wire [31:0] alu_input_b, alu_result;
    wire [31:0] mem_data;
    wire [3:0] alu_op;
    wire [2:0] imm_type;
    wire branch, mem_read, mem_to_reg, mem_write, alu_src, reg_write;
    wire zero, branch_taken;

    // 指令字段解析
    assign opcode = inst[6:0];
    assign funct3 = inst[14:12];
    assign funct7 = inst[31:25];
    assign rs1 = inst[19:15];
    assign rs2 = inst[24:20];
    assign rd = inst[11:7];

    // 分支控制
    assign pc_plus4 = pc + 4;
    assign pc_branch = pc + imm;
    // 对于BEQ/BNE，检查zero标志；对于其他分支指令，检查ALU结果
    assign branch_taken = branch & ((alu_op == 4'b1010) ? zero :        // BEQ: 当结果为0时跳转
                                   (alu_op == 4'b1011) ? !zero :       // BNE: 当结果不为0时跳转  
                                   (alu_result != 0));                 // 其他分支：当ALU结果为1时跳转
    assign next_pc = branch_taken ? pc_branch : pc_plus4;

    // ALU输入选择
    assign alu_input_b = alu_src ? imm : read_data2;

    // 写回数据选择
    assign write_data = mem_to_reg ? mem_data : alu_result;

    // 模块实例化
    pc pc_module(
        .clk(clk),
        .rst(reset),
        .pc_write(1'b1),
        .next_pc(next_pc),
        .pc(pc)
    );

    fibonacci_imem imem_module(
        .addr(pc),
        .inst(inst)
    );

    control control_module(
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .branch(branch),
        .mem_read(mem_read),
        .mem_to_reg(mem_to_reg),
        .alu_op(alu_op),
        .mem_write(mem_write),
        .alu_src(alu_src),
        .reg_write(reg_write),
        .imm_type(imm_type)
    );

    decoder decoder_module(
        .inst(inst),
        .imm_type(imm_type),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .imm(imm)
    );

    regfile regfile_module(
        .clk(clk),
        .rst(reset),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .we(reg_write),
        .wdata(write_data),
        .rdata1(read_data1),
        .rdata2(read_data2)
    );

    alu alu_module(
        .op(alu_op),
        .a(read_data1),
        .b(alu_input_b),
        .result(alu_result),
        .zero(zero)
    );

    dmem dmem_module(
        .clk(clk),
        .addr(alu_result),
        .wdata(read_data2),
        .rdata(mem_data),
        .mem_read(mem_read),
        .mem_write(mem_write)
    );

endmodule
