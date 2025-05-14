// cpu.v 顶层模块
module cpu(
    input wire clk,
    input wire rst
    // 可以根据需要添加外部端口
);
    // 内部信号定义
    wire [31:0] pc;
    wire [31:0] inst;
    wire [31:0] alu_result;
    wire [31:0] reg1_data, reg2_data;
    wire [31:0] mem_data;
    wire [31:0] write_data;
    wire [4:0]  rs1, rs2, rd;
    wire        reg_write_en;
    wire [2:0]  alu_op;
    wire        mem_read, mem_write;
    wire [31:0] imm;
    wire branch;
    wire [2:0] imm_type;
    wire [31:0] next_pc;
    wire zero;
    assign next_pc = (branch && zero) ? (pc + imm) : (pc + 4);

    // 解析指令字段
    wire [6:0] opcode = inst[6:0];
    wire [2:0] funct3 = inst[14:12];
    wire [6:0] funct7 = inst[31:25];
    // 控制信号
    wire mem_to_reg, alu_src, reg_write;

    // 实例化各个子模块
    pc u_pc(
        .clk(clk),
        .rst(rst),
        .next_pc(next_pc),
        .pc(pc)
    );
    imem u_imem(
        .addr(pc),
        .inst(inst)
    );
    control u_control(
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
    decoder u_decoder(
        .inst(inst),
        .imm_type(imm_type),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .imm(imm)
    );
    // ALU第二输入选择
    wire [31:0] alu_b = alu_src ? imm : reg2_data;
    alu u_alu(
        .op(alu_op),
        .a(reg1_data),
        .b(alu_b),
        .result(alu_result),
        .zero(zero)
    );
    dmem u_dmem(
        .clk(clk),
        .addr(alu_result),
        .wdata(reg2_data),
        .rdata(mem_data),
        .mem_read(mem_read),
        .mem_write(mem_write)
    );
    // 写回数据选择
    assign write_data = mem_to_reg ? mem_data : alu_result;
    // regfile写使能
    regfile u_regfile(
        .clk(clk),
        .rst(rst),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .we(reg_write),
        .wdata(write_data),
        .rdata1(reg1_data),
        .rdata2(reg2_data)
    );
endmodule 