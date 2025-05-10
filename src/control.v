// control.v 控制单元模块
module control(
    input wire [31:0] inst,
    output reg reg_write_en,
    output reg mem_read,
    output reg mem_write,
    output reg [2:0] alu_op,
    output reg [2:0] imm_type
    // 可根据需要添加更多控制信号
);
    wire [6:0] opcode = inst[6:0];
    wire [2:0] funct3 = inst[14:12];
    wire [6:0] funct7 = inst[31:25];
    always @(*) begin
        // 默认值
        reg_write_en = 0;
        mem_read = 0;
        mem_write = 0;
        alu_op = 3'b000;
        imm_type = 0;
        case (opcode)
            7'b0110011: begin // R型指令
                reg_write_en = 1;
                case ({funct7, funct3})
                    {7'b0000000, 3'b000}: alu_op = 3'b000; // ADD
                    {7'b0100000, 3'b000}: alu_op = 3'b001; // SUB
                    {7'b0000000, 3'b110}: alu_op = 3'b010; // OR
                    default: alu_op = 3'b000;
                endcase
                imm_type = 0;
            end
            7'b0000011: begin // LW
                reg_write_en = 1;
                mem_read = 1;
                alu_op = 3'b000; // ADD for address
                imm_type = 3'b001; // I型立即数
            end
            7'b0100011: begin // SW
                mem_write = 1;
                alu_op = 3'b000; // ADD for address
                imm_type = 3'b010; // S型立即数
            end
            7'b1100011: begin // BEQ
                alu_op = 3'b011; // BEQ比较
                imm_type = 3'b011; // B型立即数
            end
            default: begin
                // 保持默认
            end
        endcase
    end
endmodule 