// pipeline_regs.v - 流水线寄存器模块

// IF/ID流水线寄存器
module if_id_reg(
    input wire clk,
    input wire reset,
    input wire stall,
    input wire flush,
    input wire [31:0] pc_if,
    input wire [31:0] instr_if,
    output reg [31:0] pc_id,
    output reg [31:0] instr_id
);
    always @(posedge clk) begin
        if (reset || flush) begin
            pc_id <= 32'b0;
            instr_id <= 32'b0;
        end else if (!stall) begin
            pc_id <= pc_if;
            instr_id <= instr_if;
        end
    end
endmodule

// ID/EX流水线寄存器
module id_ex_reg(
    input wire clk,
    input wire reset,
    input wire flush,
    input wire [31:0] pc_id,
    input wire [31:0] read_data1_id,
    input wire [31:0] read_data2_id,
    input wire [31:0] imm_id,
    input wire [4:0] rs1_id,
    input wire [4:0] rs2_id,
    input wire [4:0] rd_id,
    input wire [2:0] funct3_id,
    input wire branch_id,
    input wire mem_read_id,
    input wire mem_to_reg_id,
    input wire [3:0] alu_op_id,
    input wire mem_write_id,
    input wire alu_src_id,
    input wire reg_write_id,
    input wire jump_id,
    input wire jalr_id,
    input wire [1:0] mem_size_id,
    input wire mem_unsigned_id,
    output reg [31:0] pc_ex,
    output reg [31:0] read_data1_ex,
    output reg [31:0] read_data2_ex,
    output reg [31:0] imm_ex,
    output reg [4:0] rs1_ex,
    output reg [4:0] rs2_ex,
    output reg [4:0] rd_ex,
    output reg [2:0] funct3_ex,
    output reg branch_ex,
    output reg mem_read_ex,
    output reg mem_to_reg_ex,
    output reg [3:0] alu_op_ex,
    output reg mem_write_ex,
    output reg alu_src_ex,
    output reg reg_write_ex,
    output reg jump_ex,
    output reg jalr_ex,
    output reg [1:0] mem_size_ex,
    output reg mem_unsigned_ex
);
    always @(posedge clk) begin
        if (reset || flush) begin
            pc_ex <= 32'b0;
            read_data1_ex <= 32'b0;
            read_data2_ex <= 32'b0;
            imm_ex <= 32'b0;
            rs1_ex <= 5'b0;
            rs2_ex <= 5'b0;
            rd_ex <= 5'b0;
            funct3_ex <= 3'b0;
            branch_ex <= 1'b0;
            mem_read_ex <= 1'b0;
            mem_to_reg_ex <= 1'b0;
            alu_op_ex <= 4'b0;
            mem_write_ex <= 1'b0;
            alu_src_ex <= 1'b0;
            reg_write_ex <= 1'b0;
            jump_ex <= 1'b0;
            jalr_ex <= 1'b0;
            mem_size_ex <= 2'b0;
            mem_unsigned_ex <= 1'b0;
        end else begin
            pc_ex <= pc_id;
            read_data1_ex <= read_data1_id;
            read_data2_ex <= read_data2_id;
            imm_ex <= imm_id;
            rs1_ex <= rs1_id;
            rs2_ex <= rs2_id;
            rd_ex <= rd_id;
            funct3_ex <= funct3_id;
            branch_ex <= branch_id;
            mem_read_ex <= mem_read_id;
            mem_to_reg_ex <= mem_to_reg_id;
            alu_op_ex <= alu_op_id;
            mem_write_ex <= mem_write_id;
            alu_src_ex <= alu_src_id;
            reg_write_ex <= reg_write_id;
            jump_ex <= jump_id;
            jalr_ex <= jalr_id;
            mem_size_ex <= mem_size_id;
            mem_unsigned_ex <= mem_unsigned_id;
        end
    end
endmodule

// EX/WB流水线寄存器
module ex_wb_reg(
    input wire clk,
    input wire reset,
    input wire [31:0] alu_result_ex,
    input wire [31:0] mem_data_ex,
    input wire [31:0] pc_ex,
    input wire [4:0] rd_ex,
    input wire reg_write_ex,
    input wire mem_to_reg_ex,
    input wire jump_ex,
    input wire jalr_ex,
    output reg [31:0] alu_result_wb,
    output reg [31:0] mem_data_wb,
    output reg [31:0] pc_wb,
    output reg [4:0] rd_wb,
    output reg reg_write_wb,
    output reg mem_to_reg_wb,
    output reg jump_wb,
    output reg jalr_wb
);
    always @(posedge clk) begin
        if (reset) begin
            alu_result_wb <= 32'b0;
            mem_data_wb <= 32'b0;
            pc_wb <= 32'b0;
            rd_wb <= 5'b0;
            reg_write_wb <= 1'b0;
            mem_to_reg_wb <= 1'b0;
            jump_wb <= 1'b0;
            jalr_wb <= 1'b0;
        end else begin
            alu_result_wb <= alu_result_ex;
            mem_data_wb <= mem_data_ex;
            pc_wb <= pc_ex;
            rd_wb <= rd_ex;
            reg_write_wb <= reg_write_ex;
            mem_to_reg_wb <= mem_to_reg_ex;
            jump_wb <= jump_ex;
            jalr_wb <= jalr_ex;
        end
    end
endmodule
