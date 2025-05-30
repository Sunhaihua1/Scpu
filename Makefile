# Makefile for RISC-V CPU 仿真

SRC=src/*.v
TB=testbench/cpu_tb.v
VVP=cpu_tb.vvp
VCD=cpu_tb.vcd

all: run

# 编译
$(VVP): $(SRC) $(TB)
	iverilog -o $(VVP) $(SRC) $(TB)

# 运行仿真，生成波形
run: $(VVP)
	vvp $(VVP)

# 查看波形
wave: $(VCD)
	gtkwave $(VCD) &

# 清理生成文件
clean:
	rm -f $(VVP) $(VCD)

.PHONY: all run wave clean 