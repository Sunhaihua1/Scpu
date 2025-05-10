# RISC-V CPU 项目

本项目包含一个基于 Verilog 的 RISC-V 单周期 CPU 设计，并支持扩展为四阶段流水线 CPU。适合学习、实验和进一步扩展。

## 目录结构

```
Scpu/
├── src/           # Verilog 源码
│   ├── cpu.v      # 单周期CPU顶层模块
│   ├── regfile.v  # 寄存器堆
│   ├── pc.v       # 程序计数器
│   ├── imem.v     # 指令存储器
│   ├── dmem.v     # 数据存储器
│   ├── alu.v      # 算术逻辑单元
│   ├── decoder.v  # 指令译码器
│   ├── control.v  # 控制单元
│   └── ...        # 其他模块/流水线相关模块
├── testbench/
│   └── cpu_tb.v   # 测试平台
├── cpu_tb.vcd     # 仿真波形文件（运行后生成）
├── cpu_tb.vvp     # 仿真可执行文件（编译后生成）
└── README.md      # 项目说明
```

## 快速开始

### 1. 安装依赖

建议使用 [Icarus Verilog](https://iverilog.fandom.com/wiki/Main_Page) 进行仿真：

#### Linux (Arch/Manjaro)
```sh
sudo pacman -S iverilog gtkwave
```

#### Mac (Homebrew)
```sh
brew install icarus-verilog gtkwave
```

#### Ubuntu/Debian
```sh
sudo apt-get install iverilog gtkwave
```

### 2. 编译与仿真

```sh
# 进入项目目录
cd /path/to/Scpu

# 编译
iverilog -o cpu_tb.vvp src/*.v testbench/cpu_tb.v

# 运行仿真
vvp cpu_tb.vvp

# 查看波形
gtkwave cpu_tb.vcd
```

### 3. 查看寄存器/信号
- 可在 testbench/cpu_tb.v 里用 `$monitor` 或 `$display` 打印寄存器内容。
- 用 gtkwave 打开波形文件，能看到所有信号和寄存器变化。

## 支持的指令

目前已支持部分 RISC-V RV32I 指令：
- `add`, `sub`, `or`, `addi`
- `lw`, `sw`
- `beq`

你可以在 `src/imem.v` 的 `initial` 块中写入机器码，测试不同指令。

## 扩展建议

- **流水线CPU**：可参考四阶段流水线架构（IF/ID/EX/MEM），将单周期CPU升级为流水线CPU。
- **指令支持**：可扩展更多RISC-V指令（如sll, slt, jal, jalr等）。
- **冒险处理**：实现数据冒险转发、分支预测等高级功能。
- **异常处理**：支持非法指令、越界访问等异常检测。

## 参考资料
- [RISC-V 指令集手册](https://riscv.org/technical/specifications/)
- [Icarus Verilog 官方文档](https://iverilog.fandom.com/wiki/Main_Page)
- [GTKWave 波形查看器](http://gtkwave.sourceforge.net/)

---

如有问题或建议，欢迎提issue或联系作者！
