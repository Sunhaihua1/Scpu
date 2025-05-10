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
    assign next_pc = (branch && alu_result) ? (pc + imm) : (pc + 4);
    // ... 其他信号

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
    decoder u_decoder(
        .inst(inst),
        .imm_type(imm_type),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .alu_op(alu_op),
        .imm(imm),
        .branch(branch)
    );
    regfile u_regfile(
        .clk(clk),
        .rst(rst),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .we(reg_write_en),
        .wdata(write_data),
        .rdata1(reg1_data),
        .rdata2(reg2_data)
    );
    alu u_alu(
        .op(alu_op),
        .a(reg1_data),
        .b(reg2_data),
        .result(alu_result)
    );
    dmem u_dmem(
        .clk(clk),
        .addr(alu_result),
        .wdata(reg2_data),
        .rdata(mem_data),
        .mem_read(mem_read),
        .mem_write(mem_write)
    );
    control u_control(
        .inst(inst),
        .reg_write_en(reg_write_en),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .alu_op(alu_op),
        .imm_type(imm_type)
    );
    // 写回数据选择
    assign write_data = mem_read ? mem_data : alu_result;
    // 分支跳转逻辑（示例，假设pc模块支持外部next_pc）
    // wire [31:0] next_pc = (branch && alu_result) ? (pc + imm) : (pc + 4);
    // ... 其他逻辑
endmodule 