lui x1, 0x12345
auipc x2, 0x1000
addi x3, x0, 0x5A
sb x3, 0(x0)
addi x4, x0, 0x1234
sh x4, 4(x0)
lb x5, 0(x0)
lbu x6, 0(x0)
lh x7, 4(x0)
lhu x8, 4(x0)
jal x9, skip_section
addi x10, x0, 999
skip_section:
addi x11, x0, 42
addi x12, x9, 4
jalr x13, x12, 0
addi x14, x0, 888
addi x15, x0, 123
fence
loop:
beq x0, x0, loop
