// control.v 控制单元模块
module control(
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,
    output reg        branch,
    output reg        mem_read,
    output reg        mem_to_reg,
    output reg [3:0]  alu_op,    // 扩展到4位
    output reg        mem_write,
    output reg        alu_src,
    output reg        reg_write,
    output reg [2:0]  imm_type,
    // 新增信号
    output reg        jump,        // 跳转信号
    output reg        jalr,        // JALR指令信号  
    output reg [1:0]  mem_size,    // 内存访问大小：00=byte, 01=half, 10=word
    output reg        mem_unsigned // 无符号加载
);

always @(*) begin
    // 默认值
    branch     = 0;
    mem_read   = 0;
    mem_to_reg = 0;
    alu_op     = 4'b0000;
    mem_write  = 0;
    alu_src    = 0;
    reg_write  = 0;
    imm_type   = 3'b000;
    jump       = 0;
    jalr       = 0;
    mem_size   = 2'b10;  // 默认字访问
    mem_unsigned = 0;

    case (opcode)
        7'b0110011: begin // R型指令
            alu_src    = 0;
            reg_write  = 1;
            mem_to_reg = 0;
            imm_type   = 3'b000;
            
            // 根据funct3和funct7确定ALU操作
            case (funct3)
                3'b000: alu_op = (funct7 == 7'b0100000) ? 4'b0001 : 4'b0000; // SUB : ADD
                3'b001: alu_op = 4'b0101; // SLL
                3'b010: alu_op = 4'b1000; // SLT
                3'b011: alu_op = 4'b1001; // SLTU
                3'b100: alu_op = 4'b0100; // XOR
                3'b101: alu_op = (funct7 == 7'b0100000) ? 4'b0111 : 4'b0110; // SRA : SRL
                3'b110: alu_op = 4'b0011; // OR
                3'b111: alu_op = 4'b0010; // AND
                default: alu_op = 4'b0000;
            endcase
        end
        7'b0010011: begin // I型指令（addi, ori, slli等）
            alu_src    = 1;
            reg_write  = 1;
            mem_to_reg = 0;
            mem_read   = 0;
            imm_type   = 3'b001; // I型
            
            // 根据funct3确定ALU操作
            case (funct3)
                3'b000: alu_op = 4'b0000; // addi
                3'b001: alu_op = 4'b0101; // slli
                3'b010: alu_op = 4'b1000; // slti
                3'b011: alu_op = 4'b1001; // sltiu
                3'b100: alu_op = 4'b0100; // xori
                3'b101: alu_op = (funct7 == 7'b0100000) ? 4'b0111 : 4'b0110; // srai : srli
                3'b110: alu_op = 4'b0011; // ori
                3'b111: alu_op = 4'b0010; // andi
                default: alu_op = 4'b0000;
            endcase
        end
        7'b0000011: begin // 加载指令 (lb, lh, lw, lbu, lhu)
            alu_src    = 1;
            reg_write  = 1;
            mem_to_reg = 1;
            mem_read   = 1;
            alu_op     = 4'b0000; // 地址计算
            imm_type   = 3'b001; // I型
            
            case (funct3)
                3'b000: begin mem_size = 2'b00; mem_unsigned = 0; end // lb
                3'b001: begin mem_size = 2'b01; mem_unsigned = 0; end // lh
                3'b010: begin mem_size = 2'b10; mem_unsigned = 0; end // lw
                3'b100: begin mem_size = 2'b00; mem_unsigned = 1; end // lbu
                3'b101: begin mem_size = 2'b01; mem_unsigned = 1; end // lhu
            endcase
        end
        7'b0100011: begin // 存储指令 (sb, sh, sw)
            alu_src    = 1;
            mem_write  = 1;
            alu_op     = 4'b0000; // 地址计算
            imm_type   = 3'b010; // S型
            
            case (funct3)
                3'b000: mem_size = 2'b00; // sb
                3'b001: mem_size = 2'b01; // sh
                3'b010: mem_size = 2'b10; // sw
            endcase
        end
        7'b1100011: begin // 分支指令 (beq, bne, blt, bge, bltu, bgeu)
            branch     = 1;
            imm_type   = 3'b011; // B型
            case (funct3)
                3'b000: alu_op = 4'b1010; // beq
                3'b001: alu_op = 4'b1011; // bne  
                3'b100: alu_op = 4'b1100; // blt
                3'b101: alu_op = 4'b1101; // bge
                3'b110: alu_op = 4'b1110; // bltu
                3'b111: alu_op = 4'b1111; // bgeu
                default: alu_op = 4'b1010; // 默认为beq
            endcase
        end
        7'b0110111: begin // LUI
            reg_write  = 1;
            alu_src    = 1;
            alu_op     = 4'b0000; // 直接传递立即数
            imm_type   = 3'b100; // U型
        end
        7'b0010111: begin // AUIPC
            reg_write  = 1;
            alu_src    = 1;
            alu_op     = 4'b0000; // PC + imm
            imm_type   = 3'b100; // U型
        end
        7'b1101111: begin // JAL
            reg_write  = 1;
            jump       = 1;
            imm_type   = 3'b101; // J型
        end
        7'b1100111: begin // JALR
            reg_write  = 1;
            alu_src    = 1;
            jalr       = 1;
            alu_op     = 4'b0000; // rs1 + imm
            imm_type   = 3'b001; // I型
        end
        7'b0001111: begin // FENCE
            // FENCE指令在简单实现中可以是NOP
        end
        default: ;
    endcase
end

endmodule