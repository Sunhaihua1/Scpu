// imem.v 指令存储器模块
module imem(
    input wire [31:0] addr,
    output wire [31:0] inst
);
    // 简单的ROM实现
    reg [31:0] rom [0:255];
    assign inst = rom[addr[9:2]];
    initial begin
        rom[0] = 32'h00500093; // addi x1, x0, 5
        rom[1] = 32'h00a00113; // addi x2, x0, 10
        rom[2] = 32'h002081b3; // add  x3, x1, x2
        rom[3] = 32'h40110233; // sub  x4, x2, x1
        rom[4] = 32'h0020e2b3; // or   x5, x1, x2
        rom[5] = 32'h00302023; // sw   x3, 0(x0)
        rom[6] = 32'h00002303; // lw   x6, 0(x0)
        rom[7] = 32'h00330463; // beq  x6, x3, +8 (跳到rom[9])
        rom[8] = 32'h06300393; // addi x7, x0, 99 (跳过)
        rom[9] = 32'h02a00393; // addi x7, x0, 42 (label)
        rom[10] = 32'h00000063; // beq x0, x0, 0 
    end
endmodule 