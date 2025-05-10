// regfile.v 寄存器堆模块
module regfile(
    input wire clk,
    input wire rst,
    input wire [4:0] rs1,
    input wire [4:0] rs2,
    input wire [4:0] rd,
    input wire we,
    input wire [31:0] wdata,
    output wire [31:0] rdata1,
    output wire [31:0] rdata2
);
    reg [31:0] regs [0:31];
    integer i; // 移到模块最外层
    // 读操作
    assign rdata1 = (rs1 != 0) ? regs[rs1] : 32'b0;
    assign rdata2 = (rs2 != 0) ? regs[rs2] : 32'b0;
    // 写操作
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1)
                regs[i] <= 32'b0;
        end else if (we && rd != 0) begin
            regs[rd] <= wdata;
        end
    end
endmodule 