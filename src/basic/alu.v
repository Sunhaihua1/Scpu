// alu.v 算术逻辑单元模块
module alu(
    input wire [3:0] op,  // 扩展到4位以支持更多操作
    input wire [31:0] a,
    input wire [31:0] b,
    output reg [31:0] result,
    output wire zero
);
    always @(*) begin
        case(op)
            4'b0000: result = a + b;                    // ADD
            4'b0001: result = a - b;                    // SUB
            4'b0010: result = a & b;                    // AND
            4'b0011: result = a | b;                    // OR
            4'b0100: result = a ^ b;                    // XOR
            4'b0101: result = a << b[4:0];              // SLL (shift left logical)
            4'b0110: result = a >> b[4:0];              // SRL (shift right logical)
            4'b0111: result = $signed(a) >>> b[4:0];    // SRA (shift right arithmetic)
            4'b1000: result = ($signed(a) < $signed(b)) ? 32'b1 : 32'b0;  // SLT
            4'b1001: result = (a < b) ? 32'b1 : 32'b0;  // SLTU
            4'b1010: result = (a == b) ? 32'b1 : 32'b0; // BEQ比较
            4'b1011: result = (a != b) ? 32'b1 : 32'b0; // BNE比较  
            4'b1100: result = ($signed(a) < $signed(b)) ? 32'b1 : 32'b0;  // BLT
            4'b1101: result = ($signed(a) >= $signed(b)) ? 32'b1 : 32'b0; // BGE
            4'b1110: result = (a < b) ? 32'b1 : 32'b0;  // BLTU
            4'b1111: result = (a >= b) ? 32'b1 : 32'b0; // BGEU
            default: result = 32'b0;
        endcase
    end
    assign zero = !result[0];
endmodule 