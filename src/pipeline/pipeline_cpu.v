// pipeline_cpu.v - 四阶段流水线CPU
module pipeline_cpu(
    input wire clk,
    input wire reset
);

    // IF阶段信号
    wire [31:0] pc_if, pc_plus4_if, pc_next_if;
    wire [31:0] instr_if;
    wire pc_write;
    
    // ID阶段信号  
    wire [31:0] pc_id, instr_id;
    wire [31:0] read_data1_id, read_data2_id, imm_id;
    wire [4:0] rs1_id, rs2_id, rd_id;
    wire [6:0] opcode_id, funct7_id;
    wire [2:0] funct3_id, imm_type_id;
    wire branch_id, mem_read_id, mem_to_reg_id, mem_write_id, alu_src_id, reg_write_id;
    wire jump_id, jalr_id;
    wire [1:0] mem_size_id;
    wire mem_unsigned_id;
    wire [3:0] alu_op_id;
    
    // EX阶段信号
    wire [31:0] pc_ex, read_data1_ex, read_data2_ex, imm_ex;
    wire [4:0] rs1_ex, rs2_ex, rd_ex;
    wire [2:0] funct3_ex;
    wire [3:0] alu_op_ex;
    wire branch_ex, mem_read_ex, mem_to_reg_ex, mem_write_ex, alu_src_ex, reg_write_ex;
    wire jump_ex, jalr_ex;
    wire [1:0] mem_size_ex;
    wire mem_unsigned_ex;
    wire [31:0] alu_input_a, alu_input_b, alu_result_ex, mem_data_ex;
    wire zero_ex, branch_taken;
    wire [31:0] pc_branch_ex, pc_jump_ex, pc_jalr_ex;
    
    // WB阶段信号
    wire [31:0] alu_result_wb, mem_data_wb, write_data_wb, pc_wb;
    wire [4:0] rd_wb;
    wire reg_write_wb, mem_to_reg_wb, jump_wb, jalr_wb;
    
    // 冒险检测和数据前递
    wire stall, flush;
    wire [1:0] forward_a, forward_b, forward_id_a, forward_id_b;
    wire if_id_write_en;
    
    // 分支条件判断
    reg branch_condition;
    
    assign if_id_write_en = ~stall;

    // ========== IF阶段 ==========
    assign pc_plus4_if = pc_if + 4;
    
    // 跳转目标计算
    assign pc_jump_ex = pc_ex + imm_ex;  // JAL
    assign pc_jalr_ex = (alu_result_ex & ~1); // JALR: (rs1+imm) & ~1
    
    // PC选择逻辑
    assign pc_next_if = jump_ex ? pc_jump_ex :
                       jalr_ex ? pc_jalr_ex :
                       branch_taken ? pc_branch_ex : 
                       pc_plus4_if;

    // 分支条件判断逻辑
    always @(*) begin
        case (funct3_ex)
            3'b000: branch_condition = alu_result_ex[0];  // BEQ: ALU输出1时跳转
            3'b001: branch_condition = alu_result_ex[0];  // BNE: ALU输出1时跳转
            3'b100: branch_condition = alu_result_ex[0];  // BLT: 小于时跳转
            3'b101: branch_condition = alu_result_ex[0];  // BGE: 大于等于时跳转
            3'b110: branch_condition = alu_result_ex[0];  // BLTU: 无符号小于时跳转
            3'b111: branch_condition = alu_result_ex[0];  // BGEU: 无符号大于等于时跳转
            default: branch_condition = 1'b0;
        endcase
    end
    assign branch_taken = branch_ex && branch_condition;

    pc pc_module(
        .clk(clk),
        .rst(reset),
        .pc_write(pc_write),
        .next_pc(pc_next_if),
        .pc(pc_if)
    );

    imem imem_module(
        .addr(pc_if),
        .inst(instr_if)
    );

    // ========== IF/ID流水线寄存器 ==========
    if_id_reg if_id_register(
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .flush(flush || branch_taken),
        .pc_if(pc_if),
        .instr_if(instr_if),
        .pc_id(pc_id),
        .instr_id(instr_id)
    );

    // ========== ID阶段 ==========
    // 指令字段解析
    assign opcode_id = instr_id[6:0];
    assign funct3_id = instr_id[14:12];
    assign funct7_id = instr_id[31:25];
    assign rs1_id = instr_id[19:15];
    assign rs2_id = instr_id[24:20];
    assign rd_id = instr_id[11:7];

    control control_module(
        .opcode(opcode_id),
        .funct3(funct3_id),
        .funct7(funct7_id),
        .branch(branch_id),
        .mem_read(mem_read_id),
        .mem_to_reg(mem_to_reg_id),
        .alu_op(alu_op_id),
        .mem_write(mem_write_id),
        .alu_src(alu_src_id),
        .reg_write(reg_write_id),
        .imm_type(imm_type_id),
        .jump(jump_id),
        .jalr(jalr_id),
        .mem_size(mem_size_id),
        .mem_unsigned(mem_unsigned_id)
    );

    decoder decoder_module(
        .inst(instr_id),
        .imm_type(imm_type_id),
        .rs1(rs1_id),
        .rs2(rs2_id),
        .rd(rd_id),
        .imm(imm_id)
    );

    regfile regfile_module(
        .clk(clk),
        .rst(reset),
        .rs1(rs1_id),
        .rs2(rs2_id),
        .rd(rd_wb),
        .we(reg_write_wb),
        .wdata(write_data_wb),
        .rdata1(read_data1_id),
        .rdata2(read_data2_id)
    );

    // ID阶段前递选择
    wire [31:0] read_data1_forwarded, read_data2_forwarded;
    assign read_data1_forwarded = (forward_id_a == 2'b01) ? alu_result_ex :
                                  (forward_id_a == 2'b10) ? write_data_wb :
                                  read_data1_id;
    assign read_data2_forwarded = (forward_id_b == 2'b01) ? alu_result_ex :
                                  (forward_id_b == 2'b10) ? write_data_wb :
                                  read_data2_id;

    // ========== ID/EX流水线寄存器 ==========
    id_ex_reg id_ex_register(
        .clk(clk),
        .reset(reset),
        .flush(jump_ex || jalr_ex),
        .pc_id(pc_id),
        .read_data1_id(read_data1_forwarded),
        .read_data2_id(read_data2_forwarded),
        .imm_id(imm_id),
        .rs1_id(rs1_id),
        .rs2_id(rs2_id),
        .rd_id(rd_id),
        .funct3_id(funct3_id),
        .branch_id(branch_id),
        .mem_read_id(mem_read_id),
        .mem_to_reg_id(mem_to_reg_id),
        .alu_op_id(alu_op_id),
        .mem_write_id(mem_write_id),
        .alu_src_id(alu_src_id),
        .reg_write_id(reg_write_id),
        .jump_id(jump_id),
        .jalr_id(jalr_id),
        .mem_size_id(mem_size_id),
        .mem_unsigned_id(mem_unsigned_id),
        .pc_ex(pc_ex),
        .read_data1_ex(read_data1_ex),
        .read_data2_ex(read_data2_ex),
        .imm_ex(imm_ex),
        .rs1_ex(rs1_ex),
        .rs2_ex(rs2_ex),
        .rd_ex(rd_ex),
        .funct3_ex(funct3_ex),
        .branch_ex(branch_ex),
        .mem_read_ex(mem_read_ex),
        .mem_to_reg_ex(mem_to_reg_ex),
        .alu_op_ex(alu_op_ex),
        .mem_write_ex(mem_write_ex),
        .alu_src_ex(alu_src_ex),
        .reg_write_ex(reg_write_ex),
        .jump_ex(jump_ex),
        .jalr_ex(jalr_ex),
        .mem_size_ex(mem_size_ex),
        .mem_unsigned_ex(mem_unsigned_ex)
    );

    // ========== EX阶段 ==========
    // 数据前递
    forwarding_unit forward_unit(
        .rs1_ex(rs1_ex),
        .rs2_ex(rs2_ex),
        .rs1_id(rs1_id),
        .rs2_id(rs2_id),
        .rd_ex(rd_ex),
        .rd_wb(rd_wb),
        .reg_write_ex(reg_write_ex),
        .reg_write_wb(reg_write_wb),
        .forward_a(forward_a),
        .forward_b(forward_b),
        .forward_id_a(forward_id_a),
        .forward_id_b(forward_id_b)
    );

    // ALU输入选择 - 支持AUIPC
    wire [31:0] alu_a = (opcode_id == 7'b0010111) ? pc_ex : 
                       (forward_a == 2'b01) ? write_data_wb : read_data1_ex;
    assign alu_input_a = alu_a;
    assign alu_input_b = alu_src_ex ? imm_ex : 
                        (forward_b == 2'b01) ? write_data_wb : read_data2_ex;

    alu alu_module(
        .op(alu_op_ex),
        .a(alu_input_a),
        .b(alu_input_b),
        .result(alu_result_ex),
        .zero(zero_ex)
    );

    // 分支目标地址计算
    assign pc_branch_ex = pc_ex + imm_ex;

    // 数据存储器(在EX阶段完成)
    dmem dmem_module(
        .clk(clk),
        .addr(alu_result_ex),
        .wdata(forward_b == 2'b01 ? write_data_wb : read_data2_ex),
        .rdata(mem_data_ex),
        .mem_read(mem_read_ex),
        .mem_write(mem_write_ex),
        .mem_size(mem_size_ex),
        .mem_unsigned(mem_unsigned_ex)
    );

    // ========== EX/WB流水线寄存器 ==========
    ex_wb_reg ex_wb_register(
        .clk(clk),
        .reset(reset),
        .alu_result_ex(alu_result_ex),
        .mem_data_ex(mem_data_ex),
        .pc_ex(pc_ex),
        .rd_ex(rd_ex),
        .reg_write_ex(reg_write_ex),
        .mem_to_reg_ex(mem_to_reg_ex),
        .jump_ex(jump_ex),
        .jalr_ex(jalr_ex),
        .alu_result_wb(alu_result_wb),
        .mem_data_wb(mem_data_wb),
        .pc_wb(pc_wb),
        .rd_wb(rd_wb),
        .reg_write_wb(reg_write_wb),
        .mem_to_reg_wb(mem_to_reg_wb),
        .jump_wb(jump_wb),
        .jalr_wb(jalr_wb)
    );

    // ========== WB阶段 ==========
    // 支持JAL/JALR的PC+4写回
    wire [31:0] pc_plus4_writeback = pc_wb + 4;
    assign write_data_wb = (jump_wb || jalr_wb) ? pc_plus4_writeback :
                          mem_to_reg_wb ? mem_data_wb : alu_result_wb;

    // ========== 冒险检测单元 ==========
    hazard_unit hazard_unit(
        .mem_read_ex(mem_read_ex),
        .rd_ex(rd_ex),
        .rs1_id(rs1_id),
        .rs2_id(rs2_id),
        .pc_write(pc_write),
        .if_id_write(if_id_write_en),
        .stall(stall),
        .flush(flush)
    );

endmodule
