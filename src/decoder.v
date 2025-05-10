// decoder.v 指令译码器模块
module decoder(
    input wire [31:0] inst,
    input wire [2:0] imm_type,
    output wire [4:0] rs1,
    output wire [4:0] rs2,
    output wire [4:0] rd,
    output wire [2:0] alu_op,
    output reg [31:0] imm,
    output wire branch
    // 可根据需要添加更多输出
);
    // 这里只做简单字段分解，实际可扩展
    assign rs1 = inst[19:15];
    assign rs2 = inst[24:20];
    assign rd  = inst[11:7];
    assign alu_op = inst[14:12];
    assign branch = (inst[6:0] == 7'b1100011); // BEQ
    always @(*) begin
        case (imm_type)
            3'b001: imm = {{20{inst[31]}}, inst[31:20]}; // I型
            3'b010: imm = {{20{inst[31]}}, inst[31:25], inst[11:7]}; // S型
            3'b011: imm = {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0}; // B型
            default: imm = 32'b0;
        endcase
    end
endmodule 