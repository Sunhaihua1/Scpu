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
            4'b1010: result = a - b;                    // BEQ比较 (保持兼容)
            // 可扩展更多操作
            default: result = 32'b0;
        endcase
    end
    assign zero = (result == 32'b0);
endmodule 