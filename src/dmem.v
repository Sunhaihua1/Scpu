// dmem.v 数据存储器模块
module dmem(
    input wire clk,
    input wire [31:0] addr,
    input wire [31:0] wdata,
    output wire [31:0] rdata,
    input wire mem_read,
    input wire mem_write
);
    reg [31:0] ram [0:255];
    // 读操作
    assign rdata = (mem_read) ? ram[addr[9:2]] : 32'b0;
    // 写操作
    always @(posedge clk) begin
        if (mem_write)
            ram[addr[9:2]] <= wdata;
    end
endmodule 