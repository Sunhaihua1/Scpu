# RISC-V CPU 项目

本项目包含一个基于 Verilog 的 RISC-V CPU 设计，实现了**单周期CPU**和**四阶段流水线CPU**两种架构。支持完整的 RV32I 指令集，包括高级流水线优化功能如数据前递、Load-Use hazard 检测、分支跳转处理等。

## 🚀 项目特色

- ✅ **完整的四阶段流水线CPU**（IF/ID/EX/WB）
- ✅ **全面的RV32I指令集支持**（算术、逻辑、内存、分支、跳转指令）
- ✅ **高级流水线优化**：数据前递、Load-Use hazard检测与停顿
- ✅ **JAL/JALR跳转指令**完整实现
- ✅ **综合边界测试**：算术溢出、内存边界、分支跳转等
- ✅ **详细仿真测试**：包含完整的测试用例和验证

## 📁 目录结构

```
Scpu/
├── src/                    # Verilog 源码
│   ├── basic/              # 基础模块
│   │   ├── cpu.v          # 单周期CPU顶层模块
│   │   ├── imem.v         # 指令存储器（包含完整测试程序）
│   │   ├── dmem.v         # 数据存储器
│   │   ├── regfile.v      # 寄存器堆
│   │   ├── alu.v          # 算术逻辑单元
│   │   ├── control.v      # 控制单元
│   │   ├── decoder.v      # 指令译码器
│   │   └── pc.v           # 程序计数器
│   └── pipeline/           # 流水线模块
│       ├── pipeline_cpu.v     # 四阶段流水线CPU顶层
│       ├── pipeline_regs.v    # 流水线寄存器
│       ├── forwarding_unit.v  # 数据前递单元
│       └── hazard_unit.v      # 冒险检测单元
├── testbench/             # 测试平台
│   ├── cpu_tb.v          # 单周期CPU测试
│   ├── pipeline_tb.v     # 流水线CPU测试
│   └── ...               # 其他专项测试
├── output/               # 仿真输出文件
├── docs/                 # 项目文档
├── examples/             # 示例程序
├── Makefile             # 自动化构建脚本
└── README.md            # 项目说明
```

## 🎯 快速开始

### 1. 安装依赖

建议使用 [Icarus Verilog](https://iverilog.fandom.com/wiki/Main_Page) 进行仿真：

#### Linux (Arch/Manjaro)

```bash
sudo pacman -S iverilog gtkwave
```

#### Mac (Homebrew)

```bash
brew install icarus-verilog gtkwave
```

#### Ubuntu/Debian

```bash
sudo apt-get install iverilog gtkwave
```

### 2. 使用 Makefile 进行编译与仿真

本项目提供了便捷的 Makefile，支持多种测试模式：

```bash
# 进入项目目录
cd /home/shh/coding/Scpu

# 运行单周期CPU测试
make run

# 运行四阶段流水线CPU测试（推荐）
make run-pipeline

# 运行斐波那契数列测试
make run-fibonacci

# 清理生成文件
make clean
```

### 3. 手动编译（可选）

```bash
# 编译流水线CPU
iverilog -o output/pipeline_tb.vvp src/basic/*.v src/pipeline/*.v testbench/pipeline_tb.v

# 运行仿真
vvp output/pipeline_tb.vvp

# 查看波形
gtkwave output/pipeline_tb.vcd
```

### 4. 查看测试结果

- 流水线CPU测试会显示详细的执行状态，包括：
  - 各阶段流水线状态
  - 数据前递检测
  - Load-Use hazard 停顿
  - 分支跳转处理
  - 寄存器最终状态验证

- 可使用 GTKWave 查看详细的信号波形：

```bash
gtkwave output/pipeline_tb.vcd
```

## 📋 支持的指令集

本项目完整支持 RISC-V RV32I 指令集：

### 算术运算指令
- **立即数运算**：`addi`, `slti`, `sltiu`, `xori`, `ori`, `andi`
- **寄存器运算**：`add`, `sub`, `sll`, `slt`, `sltu`, `xor`, `srl`, `sra`, `or`, `and`
- **移位运算**：`slli`, `srli`, `srai`

### 内存访问指令
- **加载指令**：`lb`, `lh`, `lw`, `lbu`, `lhu`
- **存储指令**：`sb`, `sh`, `sw`

### 分支跳转指令
- **条件分支**：`beq`, `bne`, `blt`, `bge`, `bltu`, `bgeu`
- **无条件跳转**：`jal`, `jalr`

### 立即数指令
- **上位立即数**：`lui`, `auipc`

## 🧪 测试覆盖

项目包含全面的测试用例：

### 边界条件测试
- ✅ **算术溢出测试**：32位有符号数的上下溢处理
- ✅ **移位边界测试**：移位量超过31位的处理
- ✅ **内存边界测试**：字节、半字、字的加载存储
- ✅ **比较操作测试**：有符号/无符号比较边界情况

### 流水线功能测试
- ✅ **数据前递**：EX-to-EX, MEM-to-EX 前递路径
- ✅ **Load-Use hazard**：自动检测与流水线停顿
- ✅ **分支跳转**：分支预测失败的流水线刷新
- ✅ **JAL指令**：跳转目标计算与PC+4保存

### 专项功能测试
- ✅ **斐波那契数列**：复杂程序执行验证
- ✅ **寄存器x0**：硬连线为0的验证
- ✅ **内存对齐**：非对齐访问处理

## 🔧 架构特色

### 四阶段流水线设计
- **IF (Instruction Fetch)**：指令获取
- **ID (Instruction Decode)**：指令译码与寄存器读取
- **EX (Execute)**：算术运算与地址计算
- **WB (Write Back)**：结果写回寄存器

### 高级优化功能
- **数据前递单元**：解决 RAW（Read After Write）数据冒险
- **冒险检测单元**：检测 Load-Use 冒险并插入气泡
- **分支处理**：支持条件分支的流水线刷新
- **JAL优化**：单周期跳转延迟，最小化性能损失

## 🚀 性能特点

- **CPI (Clock Per Instruction)**：理想情况下接近 1.0
- **冒险处理**：Load-Use 冒险导致 1 周期停顿
- **分支跳转**：分支失败导致 1-2 周期延迟
- **数据前递**：大部分 RAW 冒险零延迟解决

## 📈 扩展建议

### 性能优化
- **分支预测器**：减少分支跳转的性能损失
- **超标量执行**：同时执行多条指令
- **乱序执行**：指令重排以提高并行度
- **缓存系统**：指令缓存和数据缓存

### 指令集扩展
- **RV32M扩展**：乘法和除法指令
- **RV32F扩展**：单精度浮点运算
- **特权指令**：系统调用和中断处理
- **原子指令**：多核同步支持

### 系统级功能
- **异常处理**：非法指令、内存访问异常
- **中断控制器**：外部中断处理
- **虚拟内存**：MMU和地址转换
- **多核支持**：缓存一致性协议

## 📚 参考资料

- [RISC-V 指令集手册 v2.2](https://riscv.org/technical/specifications/)
- [Computer Architecture: A Quantitative Approach (Hennessy & Patterson)](https://www.elsevier.com/books/computer-architecture/hennessy/978-0-12-811905-1)
- [Digital Design and Computer Architecture (Harris & Harris)](https://www.elsevier.com/books/digital-design-and-computer-architecture/harris/978-0-12-800056-4)
- [Icarus Verilog 官方文档](https://iverilog.fandom.com/wiki/Main_Page)
- [GTKWave 波形查看器](http://gtkwave.sourceforge.net/)

## 🤝 贡献与支持

如有问题或建议，欢迎：
- 提交 Issue 报告 bug 或建议功能
- 提交 Pull Request 贡献代码
- 联系作者讨论技术问题
