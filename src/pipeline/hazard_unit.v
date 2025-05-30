// hazard_unit.v - 冒险检测单元

module hazard_unit(
    input wire mem_read_ex,
    input wire [4:0] rd_ex,
    input wire [4:0] rs1_id,
    input wire [4:0] rs2_id,
    output reg pc_write,
    output reg if_id_write,
    output reg stall,
    output reg flush
);
    always @(*) begin
        // 默认值
        pc_write = 1'b1;
        if_id_write = 1'b1;
        stall = 1'b0;
        flush = 1'b0;
        
        // 加载-使用冒险检测
        if (mem_read_ex && (rd_ex != 5'b0) && 
            ((rd_ex == rs1_id) || (rd_ex == rs2_id))) begin
            pc_write = 1'b0;
            if_id_write = 1'b0;
            stall = 1'b1;
            flush = 1'b1;
        end
    end
endmodule
