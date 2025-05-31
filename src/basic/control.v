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
    output reg [2:0]  imm_type
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
        7'b0000011: begin // lw
            alu_src    = 1;
            reg_write  = 1;
            mem_to_reg = 1;
            mem_read   = 1;
            alu_op     = 4'b0000; // add for address calculation
            imm_type   = 3'b001; // I型
        end
        7'b0100011: begin // sw
            alu_src    = 1;
            mem_write  = 1;
            alu_op     = 4'b0000; // add
            imm_type   = 3'b010; // S型
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
        default: ;
    endcase
end

endmodule 