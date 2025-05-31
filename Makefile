# Makefile for RISC-V CPU 仿真

# 输出目录
OUTPUT_DIR=output

# 基本模块路径
BASIC_SRC=src/basic/alu.v src/basic/control.v src/basic/decoder.v src/basic/dmem.v src/basic/imem.v src/basic/pc.v src/basic/regfile.v

# 单周期CPU
SINGLE_SRC=$(BASIC_SRC) src/basic/cpu.v
SINGLE_TB=testbench/cpu_tb.v
SINGLE_VVP=$(OUTPUT_DIR)/cpu_tb.vvp
SINGLE_VCD=$(OUTPUT_DIR)/cpu_tb.vcd

# 四阶段流水线CPU
PIPELINE_SRC=$(BASIC_SRC) src/pipeline/pipeline_cpu.v src/pipeline/pipeline_regs.v src/pipeline/forwarding_unit.v src/pipeline/hazard_unit.v
PIPELINE_TB=testbench/pipeline_tb.v
PIPELINE_VVP=$(OUTPUT_DIR)/pipeline_tb.vvp
PIPELINE_VCD=$(OUTPUT_DIR)/pipeline_tb.vcd

# 斐波那契测试
FIBONACCI_SRC=$(BASIC_SRC) src/basic/cpu_fibonacci.v src/basic/fibonacci_imem.v
FIBONACCI_TB=testbench/fibonacci_tb.v
FIBONACCI_VVP=$(OUTPUT_DIR)/fibonacci_tb.vvp
FIBONACCI_VCD=$(OUTPUT_DIR)/fibonacci_tb.vcd

# 流水线斐波那契测试
PIPELINE_FIBONACCI_SRC=$(BASIC_SRC) src/pipeline/pipeline_cpu_fibonacci.v src/pipeline/pipeline_regs.v src/pipeline/forwarding_unit.v src/pipeline/hazard_unit.v src/basic/fibonacci_imem.v
PIPELINE_FIBONACCI_TB=testbench/pipeline_fibonacci_tb.v
PIPELINE_FIBONACCI_VVP=$(OUTPUT_DIR)/pipeline_fibonacci_tb.vvp
PIPELINE_FIBONACCI_VCD=$(OUTPUT_DIR)/pipeline_fibonacci_tb.vcd

# 基本指令测试
TEST_BASIC_SRC=$(BASIC_SRC) src/basic/cpu_test_basic.v test_basic_imem.v
TEST_BASIC_TB=testbench/test_basic_tb.v
TEST_BASIC_VVP=$(OUTPUT_DIR)/test_basic_tb.vvp
TEST_BASIC_VCD=$(OUTPUT_DIR)/test_basic_tb.vcd

# 流水线基本指令测试
PIPELINE_TEST_BASIC_SRC=$(BASIC_SRC) src/pipeline/pipeline_cpu.v src/pipeline/pipeline_regs.v src/pipeline/forwarding_unit.v src/pipeline/hazard_unit.v test_basic_imem.v
PIPELINE_TEST_BASIC_TB=testbench/pipeline_tb.v
PIPELINE_TEST_BASIC_VVP=$(OUTPUT_DIR)/pipeline_test_basic_tb.vvp
PIPELINE_TEST_BASIC_VCD=$(OUTPUT_DIR)/pipeline_test_basic_tb.vcd

# 默认目标：单周期CPU
all: run

# 确保输出目录存在
$(OUTPUT_DIR):
	mkdir -p $(OUTPUT_DIR)

# 单周期CPU编译
$(SINGLE_VVP): $(SINGLE_SRC) $(SINGLE_TB) | $(OUTPUT_DIR)
	iverilog -o $(SINGLE_VVP) $(SINGLE_SRC) $(SINGLE_TB)

# 四阶段流水线CPU编译
$(PIPELINE_VVP): $(PIPELINE_SRC) $(PIPELINE_TB) | $(OUTPUT_DIR)
	iverilog -o $(PIPELINE_VVP) $(PIPELINE_SRC) $(PIPELINE_TB)

# 斐波那契测试编译
$(FIBONACCI_VVP): $(FIBONACCI_SRC) $(FIBONACCI_TB) | $(OUTPUT_DIR)
	iverilog -o $(FIBONACCI_VVP) $(FIBONACCI_SRC) $(FIBONACCI_TB)

# 流水线斐波那契测试编译
$(PIPELINE_FIBONACCI_VVP): $(PIPELINE_FIBONACCI_SRC) $(PIPELINE_FIBONACCI_TB) | $(OUTPUT_DIR)
	iverilog -o $(PIPELINE_FIBONACCI_VVP) $(PIPELINE_FIBONACCI_SRC) $(PIPELINE_FIBONACCI_TB)

# 基本指令测试编译
$(TEST_BASIC_VVP): $(TEST_BASIC_SRC) $(TEST_BASIC_TB) | $(OUTPUT_DIR)
	iverilog -o $(TEST_BASIC_VVP) $(TEST_BASIC_SRC) $(TEST_BASIC_TB)

# 流水线基本指令测试编译
$(PIPELINE_TEST_BASIC_VVP): $(PIPELINE_TEST_BASIC_SRC) $(PIPELINE_TEST_BASIC_TB) | $(OUTPUT_DIR)
	iverilog -o $(PIPELINE_TEST_BASIC_VVP) $(PIPELINE_TEST_BASIC_SRC) $(PIPELINE_TEST_BASIC_TB)

# VCD文件生成规则
$(SINGLE_VCD): $(SINGLE_VVP)
	vvp $(SINGLE_VVP)

$(PIPELINE_VCD): $(PIPELINE_VVP)
	vvp $(PIPELINE_VVP)

$(FIBONACCI_VCD): $(FIBONACCI_VVP)
	vvp $(FIBONACCI_VVP)

$(PIPELINE_FIBONACCI_VCD): $(PIPELINE_FIBONACCI_VVP)
	vvp $(PIPELINE_FIBONACCI_VVP)

$(TEST_BASIC_VCD): $(TEST_BASIC_VVP)
	vvp $(TEST_BASIC_VVP)

$(PIPELINE_TEST_BASIC_VCD): $(PIPELINE_TEST_BASIC_VVP)
	vvp $(PIPELINE_TEST_BASIC_VVP)

# 运行单周期CPU仿真
run: $(SINGLE_VVP)
	vvp $(SINGLE_VVP)

# 运行四阶段流水线CPU仿真
run-pipeline: $(PIPELINE_VVP)
	vvp $(PIPELINE_VVP)

# 运行斐波那契测试
fibonacci: $(FIBONACCI_VVP)
	vvp $(FIBONACCI_VVP)

# 运行流水线斐波那契测试
fibonacci-pipeline: $(PIPELINE_FIBONACCI_VVP)
	vvp $(PIPELINE_FIBONACCI_VVP)

# 同时运行两种仿真
run-all: run run-pipeline

# 查看单周期波形
wave: $(SINGLE_VCD)
	gtkwave $(SINGLE_VCD) &

# 查看四阶段流水线波形
wave-pipeline: $(PIPELINE_VCD)
	gtkwave $(PIPELINE_VCD) &

# 查看斐波那契测试波形
wave-fibonacci: $(FIBONACCI_VCD)
	gtkwave $(FIBONACCI_VCD) &

# 查看流水线斐波那契测试波形
wave-fibonacci-pipeline: $(PIPELINE_FIBONACCI_VCD)
	gtkwave $(PIPELINE_FIBONACCI_VCD) &

# 清理生成文件
clean:
	rm -rf $(OUTPUT_DIR)
	rm -f *.vvp *.vcd  # 清理可能存在的旧文件

# 仅清理output目录内容，保留目录
clean-output:
	rm -f $(OUTPUT_DIR)/*

# 帮助信息
help:
	@echo "可用目标："
	@echo "  run                    - 运行单周期CPU仿真"
	@echo "  run-pipeline           - 运行四阶段流水线CPU仿真"
	@echo "  fibonacci              - 运行单周期CPU斐波那契测试"
	@echo "  fibonacci-pipeline     - 运行流水线CPU斐波那契测试"
	@echo "  run-all                - 运行两种CPU仿真"
	@echo "  wave                   - 查看单周期CPU波形"
	@echo "  wave-pipeline          - 查看四阶段流水线CPU波形"
	@echo "  wave-fibonacci         - 查看斐波那契测试波形"
	@echo "  wave-fibonacci-pipeline- 查看流水线斐波那契测试波形"
	@echo "  clean                  - 清理所有生成文件"
	@echo "  clean-output           - 仅清理output目录内容"
	@echo "  help                   - 显示此帮助信息"
	@echo ""
	@echo "所有生成的文件都会放在 $(OUTPUT_DIR)/ 目录中"

.PHONY: all run run-pipeline run-all wave wave-pipeline clean clean-output help 