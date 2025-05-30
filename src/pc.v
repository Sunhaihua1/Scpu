// pc.v 程序计数器模块
module pc(
    input wire clk,
    input wire rst,
    input wire pc_write,  // PC写使能信号
    input wire [31:0] next_pc,
    output reg [31:0] pc
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            pc <= 32'b0;
        else if (pc_write)  // 只有在允许写入时才更新PC
            pc <= next_pc;
    end
endmodule 