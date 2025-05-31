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
    wire [3:0]  alu_op;    // 扩展到4位
    wire        mem_read, mem_write;
    wire [31:0] imm;
    wire branch;
    wire [2:0] imm_type;
    wire [31:0] next_pc;
    wire zero;
    
    // 新增控制信号
    wire jump, jalr;
    wire [1:0] mem_size;
    wire mem_unsigned;
    
    // PC计算逻辑
    wire [31:0] pc_plus4 = pc + 4;
    wire [31:0] pc_branch = pc + imm;
    wire [31:0] pc_jump = pc + imm;  // JAL
    wire [31:0] pc_jalr = (alu_result & ~1); // JALR: (rs1+imm) & ~1
    
    // 分支条件判断逻辑
    reg branch_condition;
    always @(*) begin
        case (funct3)
            3'b000: branch_condition = alu_result[0];  // BEQ: ALU输出1时跳转
            3'b001: branch_condition = alu_result[0];  // BNE: ALU输出1时跳转
            3'b100: branch_condition = alu_result[0];  // BLT: 小于时跳转
            3'b101: branch_condition = alu_result[0];  // BGE: 大于等于时跳转
            3'b110: branch_condition = alu_result[0];  // BLTU: 无符号小于时跳转
            3'b111: branch_condition = alu_result[0];  // BGEU: 无符号大于等于时跳转
            default: branch_condition = 1'b0;
        endcase
    end
    wire branch_taken = branch && branch_condition;
    
    assign next_pc = jump ? pc_jump :
                    jalr ? pc_jalr :
                    branch_taken ? pc_branch :
                    pc_plus4;

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
        .pc_write(1'b1),  // 单周期CPU总是允许PC更新
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
        .imm_type(imm_type),
        .jump(jump),
        .jalr(jalr),
        .mem_size(mem_size),
        .mem_unsigned(mem_unsigned)
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
    wire [31:0] alu_a = (opcode == 7'b0010111) ? pc : reg1_data; // AUIPC使用PC
    wire [31:0] alu_b = alu_src ? imm : reg2_data;
    alu u_alu(
        .op(alu_op),
        .a(alu_a),
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
        .mem_write(mem_write),
        .mem_size(mem_size),
        .mem_unsigned(mem_unsigned)
    );
    // 写回数据选择 - 支持JAL/JALR的PC+4写回
    wire [31:0] pc_plus4_writeback = pc + 4;
    assign write_data = (jump || jalr) ? pc_plus4_writeback :
                       mem_to_reg ? mem_data : alu_result;
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