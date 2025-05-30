// pipeline_cpu_fibonacci.v - 使用斐波那契指令存储器的四阶段流水线CPU
module pipeline_cpu_fibonacci(
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
    wire [3:0] alu_op_id;
    
    // EX阶段信号
    wire [31:0] pc_ex, read_data1_ex, read_data2_ex, imm_ex;
    wire [4:0] rs1_ex, rs2_ex, rd_ex;
    wire [3:0] alu_op_ex;
    wire branch_ex, mem_read_ex, mem_to_reg_ex, mem_write_ex, alu_src_ex, reg_write_ex;
    wire [31:0] alu_input_a, alu_input_b, alu_result_ex, mem_data_ex;
    wire zero_ex, branch_taken;
    wire [31:0] pc_branch_ex;
    
    // WB阶段信号
    wire [31:0] alu_result_wb, mem_data_wb, write_data_wb;
    wire [4:0] rd_wb;
    wire reg_write_wb, mem_to_reg_wb;
    
    // 冒险检测和数据前递
    wire stall, flush;
    wire [1:0] forward_a, forward_b, forward_id_a, forward_id_b;
    wire if_id_write_en;
    
    assign if_id_write_en = ~stall;

    // ========== IF阶段 ==========
    assign pc_plus4_if = pc_if + 4;
    assign pc_next_if = branch_taken ? pc_branch_ex : pc_plus4_if;
    // 修正分支判断逻辑
    assign branch_taken = branch_ex & ((alu_op_ex == 4'b1010) ? zero_ex :        // BEQ: 当结果为0时跳转
                                     (alu_op_ex == 4'b1011) ? !zero_ex :       // BNE: 当结果不为0时跳转  
                                     (alu_result_ex != 0));                    // 其他分支：当ALU结果为1时跳转

    pc pc_module(
        .clk(clk),
        .rst(reset),
        .pc_write(pc_write),
        .next_pc(pc_next_if),
        .pc(pc_if)
    );

    // 使用斐波那契指令存储器
    fibonacci_imem imem_module(
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
        .imm_type(imm_type_id)
    );

    decoder decoder_module(
        .inst(instr_id),
        .imm_type(imm_type_id),
        .rs1(rs1_id),
        .rs2(rs2_id),
        .rd(rd_id),
        .imm(imm_id)
    );

    // 数据前递到ID阶段
    wire [31:0] read_data1_forwarded, read_data2_forwarded;
    assign read_data1_forwarded = (forward_id_a == 2'b01) ? alu_result_ex : 
                                  (forward_id_a == 2'b10) ? write_data_wb : read_data1_id;
    assign read_data2_forwarded = (forward_id_b == 2'b01) ? alu_result_ex : 
                                  (forward_id_b == 2'b10) ? write_data_wb : read_data2_id;

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

    // ========== ID/EX流水线寄存器 ==========
    id_ex_reg id_ex_register(
        .clk(clk),
        .reset(reset),
        .flush(flush),
        .pc_id(pc_id),
        .read_data1_id(read_data1_forwarded),
        .read_data2_id(read_data2_forwarded),
        .imm_id(imm_id),
        .rs1_id(rs1_id),
        .rs2_id(rs2_id),
        .rd_id(rd_id),
        .alu_op_id(alu_op_id),
        .branch_id(branch_id),
        .mem_read_id(mem_read_id),
        .mem_to_reg_id(mem_to_reg_id),
        .mem_write_id(mem_write_id),
        .alu_src_id(alu_src_id),
        .reg_write_id(reg_write_id),
        .pc_ex(pc_ex),
        .read_data1_ex(read_data1_ex),
        .read_data2_ex(read_data2_ex),
        .imm_ex(imm_ex),
        .rs1_ex(rs1_ex),
        .rs2_ex(rs2_ex),
        .rd_ex(rd_ex),
        .alu_op_ex(alu_op_ex),
        .branch_ex(branch_ex),
        .mem_read_ex(mem_read_ex),
        .mem_to_reg_ex(mem_to_reg_ex),
        .mem_write_ex(mem_write_ex),
        .alu_src_ex(alu_src_ex),
        .reg_write_ex(reg_write_ex)
    );

    // ========== EX阶段 ==========
    assign pc_branch_ex = pc_ex + imm_ex;
    
    // 数据前递选择
    assign alu_input_a = (forward_a == 2'b01) ? alu_result_wb : 
                         (forward_a == 2'b10) ? write_data_wb : read_data1_ex;
    assign alu_input_b = alu_src_ex ? imm_ex : 
                         ((forward_b == 2'b01) ? alu_result_wb : 
                          (forward_b == 2'b10) ? write_data_wb : read_data2_ex);

    alu alu_module(
        .op(alu_op_ex),
        .a(alu_input_a),
        .b(alu_input_b),
        .result(alu_result_ex),
        .zero(zero_ex)
    );

    dmem dmem_module(
        .clk(clk),
        .addr(alu_result_ex),
        .wdata((forward_b == 2'b01) ? alu_result_wb : 
               (forward_b == 2'b10) ? write_data_wb : read_data2_ex),
        .rdata(mem_data_ex),
        .mem_read(mem_read_ex),
        .mem_write(mem_write_ex)
    );

    // ========== EX/WB流水线寄存器 ==========
    ex_wb_reg ex_wb_register(
        .clk(clk),
        .reset(reset),
        .alu_result_ex(alu_result_ex),
        .mem_data_ex(mem_data_ex),
        .rd_ex(rd_ex),
        .reg_write_ex(reg_write_ex),
        .mem_to_reg_ex(mem_to_reg_ex),
        .alu_result_wb(alu_result_wb),
        .mem_data_wb(mem_data_wb),
        .rd_wb(rd_wb),
        .reg_write_wb(reg_write_wb),
        .mem_to_reg_wb(mem_to_reg_wb)
    );

    // ========== WB阶段 ==========
    assign write_data_wb = mem_to_reg_wb ? mem_data_wb : alu_result_wb;

    // ========== 冒险检测和数据前递 ==========
    hazard_unit hazard_unit_module(
        .rs1_id(rs1_id),
        .rs2_id(rs2_id),
        .rd_ex(rd_ex),
        .mem_read_ex(mem_read_ex),
        .pc_write(pc_write),
        .if_id_write(if_id_write_en),
        .stall(stall),
        .flush(flush)
    );

    forwarding_unit forwarding_unit_module(
        .rs1_ex(rs1_ex),
        .rs2_ex(rs2_ex),
        .rs1_id(rs1_id),  
        .rs2_id(rs2_id),
        .rd_wb(rd_wb),
        .rd_ex(rd_ex),
        .reg_write_wb(reg_write_wb),
        .reg_write_ex(reg_write_ex),
        .forward_a(forward_a),
        .forward_b(forward_b),
        .forward_id_a(forward_id_a),
        .forward_id_b(forward_id_b)
    );

endmodule
