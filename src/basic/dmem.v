// dmem.v 数据存储器模块
module dmem(
    input wire clk,
    input wire [31:0] addr,
    input wire [31:0] wdata,
    output reg [31:0] rdata,
    input wire mem_read,
    input wire mem_write,
    input wire [1:0] mem_size,    // 00=byte, 01=half, 10=word
    input wire mem_unsigned       // 无符号扩展
);
    reg [31:0] ram [0:255];
    
    // 读操作
    always @(*) begin
        if (mem_read) begin
            case (mem_size)
                2'b00: begin // 字节访问
                    case (addr[1:0])
                        2'b00: rdata = mem_unsigned ? {24'b0, ram[addr[9:2]][7:0]} : 
                                                     {{24{ram[addr[9:2]][7]}}, ram[addr[9:2]][7:0]};
                        2'b01: rdata = mem_unsigned ? {24'b0, ram[addr[9:2]][15:8]} : 
                                                     {{24{ram[addr[9:2]][15]}}, ram[addr[9:2]][15:8]};
                        2'b10: rdata = mem_unsigned ? {24'b0, ram[addr[9:2]][23:16]} : 
                                                     {{24{ram[addr[9:2]][23]}}, ram[addr[9:2]][23:16]};
                        2'b11: rdata = mem_unsigned ? {24'b0, ram[addr[9:2]][31:24]} : 
                                                     {{24{ram[addr[9:2]][31]}}, ram[addr[9:2]][31:24]};
                        default: rdata = 32'b0; // 默认情况
                    endcase
                end
                2'b01: begin // 半字访问
                    case (addr[1])
                        1'b0: rdata = mem_unsigned ? {16'b0, ram[addr[9:2]][15:0]} : 
                                                    {{16{ram[addr[9:2]][15]}}, ram[addr[9:2]][15:0]};
                        1'b1: rdata = mem_unsigned ? {16'b0, ram[addr[9:2]][31:16]} : 
                                                    {{16{ram[addr[9:2]][31]}}, ram[addr[9:2]][31:16]};
                        default: rdata = 32'b0; // 默认情况
                    endcase
                end
                2'b10: rdata = ram[addr[9:2]]; // 字访问
                default: rdata = 32'b0;
            endcase
        end else begin
            rdata = 32'b0;
        end
    end
    
    // 写操作 - 直接条件写入，最小化MUX
    always @(posedge clk) begin
        // 字写入
        if (mem_write && mem_size == 2'b10) begin
            ram[addr[9:2]] <= wdata;
        end
        // 半字写入
        else if (mem_write && mem_size == 2'b01) begin
            if (addr[1] == 1'b0) 
                ram[addr[9:2]][15:0] <= wdata[15:0];
            else
                ram[addr[9:2]][31:16] <= wdata[15:0];
        end
        // 字节写入
        else if (mem_write && mem_size == 2'b00) begin
            case (addr[1:0])
                2'b00: ram[addr[9:2]][7:0]   <= wdata[7:0];
                2'b01: ram[addr[9:2]][15:8]  <= wdata[7:0];
                2'b10: ram[addr[9:2]][23:16] <= wdata[7:0];
                2'b11: ram[addr[9:2]][31:24] <= wdata[7:0];
            endcase
        end
    end
endmodule