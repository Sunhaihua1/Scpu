// decoder.v 指令译码器模块
module decoder(
    input wire [31:0] inst,
    input wire [2:0] imm_type,
    output wire [4:0] rs1,
    output wire [4:0] rs2,
    output wire [4:0] rd,
    output reg [31:0] imm
);
//      funct7  rs2  rs1  funct3  rd  opcode7 
// bits 5       5    5    3       5   7
    // 这里只做简单字段分解，实际可扩展
    assign rs1 = inst[19:15];
    assign rs2 = inst[24:20];
    assign rd  = inst[11:7];
    always @(*) begin
        case (imm_type)
            3'b001: imm = {{20{inst[31]}}, inst[31:20]}; // I型
            3'b010: imm = {{20{inst[31]}}, inst[31:25], inst[11:7]}; // S型
            3'b011: imm = {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0}; // B型
            3'b100: imm = {inst[31:12], 12'b0}; // U型 (LUI, AUIPC)
            3'b101: imm = {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0}; // J型 (JAL)
            default: imm = 32'b0;
        endcase
    end
endmodule