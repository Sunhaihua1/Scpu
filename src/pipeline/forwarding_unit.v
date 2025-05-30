// forwarding_unit.v - 数据前递单元

module forwarding_unit(
    input wire [4:0] rs1_ex,
    input wire [4:0] rs2_ex,
    input wire [4:0] rs1_id,
    input wire [4:0] rs2_id,
    input wire [4:0] rd_ex,
    input wire [4:0] rd_wb,
    input wire reg_write_ex,
    input wire reg_write_wb,
    output reg [1:0] forward_a,
    output reg [1:0] forward_b,
    output reg [1:0] forward_id_a,
    output reg [1:0] forward_id_b
);
    always @(*) begin
        // 默认值：不前递
        forward_a = 2'b00;
        forward_b = 2'b00;
        forward_id_a = 2'b00;
        forward_id_b = 2'b00;
        
        // EX阶段前递：WB阶段前递到EX阶段
        if (reg_write_wb && (rd_wb != 5'b0) && (rd_wb == rs1_ex))
            forward_a = 2'b01;
        if (reg_write_wb && (rd_wb != 5'b0) && (rd_wb == rs2_ex))
            forward_b = 2'b01;
            
        // ID阶段前递：EX阶段前递到ID阶段  
        if (reg_write_ex && (rd_ex != 5'b0) && (rd_ex == rs1_id))
            forward_id_a = 2'b01;
        if (reg_write_ex && (rd_ex != 5'b0) && (rd_ex == rs2_id))
            forward_id_b = 2'b01;
            
        // ID阶段前递：WB阶段前递到ID阶段 (当EX阶段不产生冲突时)
        if (reg_write_wb && (rd_wb != 5'b0) && (rd_wb == rs1_id) && 
            !(reg_write_ex && (rd_ex != 5'b0) && (rd_ex == rs1_id)))
            forward_id_a = 2'b10;
        if (reg_write_wb && (rd_wb != 5'b0) && (rd_wb == rs2_id) && 
            !(reg_write_ex && (rd_ex != 5'b0) && (rd_ex == rs2_id)))
            forward_id_b = 2'b10;
    end
endmodule
