// alu.v 算术逻辑单元模块
module alu(
    input wire [2:0] op,
    input wire [31:0] a,
    input wire [31:0] b,
    output reg [31:0] result,
    output wire zero
);
    always @(*) begin
        case(op)
            3'b000: result = a + b; // 加法
            3'b001: result = a - b; // 减法
            3'b010: result = a | b; // OR
            3'b011: result = a - b; // beq 比较
            // 可扩展更多操作
            default: result = 32'b0;
        endcase
    end
    assign zero = (result == 32'b0);
endmodule 