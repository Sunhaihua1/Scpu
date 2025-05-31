#!/usr/bin/env python3
"""
RISC-V 汇编代码转ROM数据工具
将RISC-V汇编指令转换为Verilog ROM初始化格式
"""

import re
import sys
import os

class RISCVAssembler:
    def __init__(self):
        # RISC-V指令编码表
        self.opcodes = {
            # R型指令
            'add':   {'opcode': 0b0110011, 'funct3': 0b000, 'funct7': 0b0000000},
            'sub':   {'opcode': 0b0110011, 'funct3': 0b000, 'funct7': 0b0100000},
            'and':   {'opcode': 0b0110011, 'funct3': 0b111, 'funct7': 0b0000000},
            'or':    {'opcode': 0b0110011, 'funct3': 0b110, 'funct7': 0b0000000},
            'xor':   {'opcode': 0b0110011, 'funct3': 0b100, 'funct7': 0b0000000},
            'sll':   {'opcode': 0b0110011, 'funct3': 0b001, 'funct7': 0b0000000},
            'srl':   {'opcode': 0b0110011, 'funct3': 0b101, 'funct7': 0b0000000},
            'sra':   {'opcode': 0b0110011, 'funct3': 0b101, 'funct7': 0b0100000},
            'slt':   {'opcode': 0b0110011, 'funct3': 0b010, 'funct7': 0b0000000},
            'sltu':  {'opcode': 0b0110011, 'funct3': 0b011, 'funct7': 0b0000000},
            
            # I型指令
            'addi':  {'opcode': 0b0010011, 'funct3': 0b000},
            'andi':  {'opcode': 0b0010011, 'funct3': 0b111},
            'ori':   {'opcode': 0b0010011, 'funct3': 0b110},
            'xori':  {'opcode': 0b0010011, 'funct3': 0b100},
            'slli':  {'opcode': 0b0010011, 'funct3': 0b001},
            'srli':  {'opcode': 0b0010011, 'funct3': 0b101},
            'srai':  {'opcode': 0b0010011, 'funct3': 0b101},
            'slti':  {'opcode': 0b0010011, 'funct3': 0b010},
            'sltiu': {'opcode': 0b0010011, 'funct3': 0b011},
            'lw':    {'opcode': 0b0000011, 'funct3': 0b010},
            'lb':    {'opcode': 0b0000011, 'funct3': 0b000},
            'lh':    {'opcode': 0b0000011, 'funct3': 0b001},
            'lbu':   {'opcode': 0b0000011, 'funct3': 0b100},
            'lhu':   {'opcode': 0b0000011, 'funct3': 0b101},
            'jalr':  {'opcode': 0b1100111, 'funct3': 0b000},
            
            # S型指令
            'sw':    {'opcode': 0b0100011, 'funct3': 0b010},
            'sb':    {'opcode': 0b0100011, 'funct3': 0b000},
            'sh':    {'opcode': 0b0100011, 'funct3': 0b001},
            
            # B型指令
            'beq':   {'opcode': 0b1100011, 'funct3': 0b000},
            'bne':   {'opcode': 0b1100011, 'funct3': 0b001},
            'blt':   {'opcode': 0b1100011, 'funct3': 0b100},
            'bge':   {'opcode': 0b1100011, 'funct3': 0b101},
            'bltu':  {'opcode': 0b1100011, 'funct3': 0b110},
            'bgeu':  {'opcode': 0b1100011, 'funct3': 0b111},
            
            # U型指令
            'lui':   {'opcode': 0b0110111},
            'auipc': {'opcode': 0b0010111},
            
            # J型指令
            'jal':   {'opcode': 0b1101111},
            
            # 其他指令
            'fence': {'opcode': 0b0001111, 'funct3': 0b000},
        }
        
        # 寄存器别名映射
        self.registers = {
            'x0': 0, 'zero': 0,
            'x1': 1, 'ra': 1,
            'x2': 2, 'sp': 2,
            'x3': 3, 'gp': 3,
            'x4': 4, 'tp': 4,
            'x5': 5, 't0': 5,
            'x6': 6, 't1': 6,
            'x7': 7, 't2': 7,
            'x8': 8, 's0': 8, 'fp': 8,
            'x9': 9, 's1': 9,
            'x10': 10, 'a0': 10,
            'x11': 11, 'a1': 11,
            'x12': 12, 'a2': 12,
            'x13': 13, 'a3': 13,
            'x14': 14, 'a4': 14,
            'x15': 15, 'a5': 15,
            'x16': 16, 'a6': 16,
            'x17': 17, 'a7': 17,
            'x18': 18, 's2': 18,
            'x19': 19, 's3': 19,
            'x20': 20, 's4': 20,
            'x21': 21, 's5': 21,
            'x22': 22, 's6': 22,
            'x23': 23, 's7': 23,
            'x24': 24, 's8': 24,
            'x25': 25, 's9': 25,
            'x26': 26, 's10': 26,
            'x27': 27, 's11': 27,
            'x28': 28, 't3': 28,
            'x29': 29, 't4': 29,
            'x30': 30, 't5': 30,
            'x31': 31, 't6': 31,
        }
        
        self.labels = {}  # 标签到地址的映射
        
    def parse_register(self, reg_str):
        """解析寄存器名"""
        reg_str = reg_str.strip().rstrip(',')
        if reg_str in self.registers:
            return self.registers[reg_str]
        raise ValueError(f"Unknown register: {reg_str}")
    
    def parse_immediate(self, imm_str):
        """解析立即数"""
        imm_str = imm_str.strip().rstrip(',')
        if imm_str.startswith('0x'):
            return int(imm_str, 16)
        elif imm_str.startswith('0b'):
            return int(imm_str, 2)
        else:
            return int(imm_str)
    
    def parse_memory_operand(self, operand):
        """解析内存操作数，如 4(x10) -> (offset=4, base=x10)"""
        match = re.match(r'(-?\d+)\((\w+)\)', operand.strip())
        if match:
            offset = int(match.group(1))
            base_reg = self.parse_register(match.group(2))
            return offset, base_reg
        raise ValueError(f"Invalid memory operand: {operand}")
    
    def encode_r_type(self, instr, rd, rs1, rs2):
        """编码R型指令"""
        info = self.opcodes[instr]
        opcode = info['opcode']
        funct3 = info['funct3']
        funct7 = info['funct7']
        
        instruction = (funct7 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode
        return instruction & 0xFFFFFFFF
    
    def encode_i_type(self, instr, rd, rs1, imm):
        """编码I型指令"""
        info = self.opcodes[instr]
        opcode = info['opcode']
        funct3 = info['funct3']
        
        # 处理移位指令的特殊情况
        if instr in ['srai']:
            imm = imm | (0b0100000 << 5)  # 设置第30位
        
        # 立即数符号扩展到12位
        imm = imm & 0xFFF
        
        instruction = (imm << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode
        return instruction & 0xFFFFFFFF
    
    def encode_s_type(self, instr, rs1, rs2, imm):
        """编码S型指令"""
        info = self.opcodes[instr]
        opcode = info['opcode']
        funct3 = info['funct3']
        
        # 立即数分割：[11:5]和[4:0]
        imm_11_5 = (imm >> 5) & 0x7F
        imm_4_0 = imm & 0x1F
        
        instruction = (imm_11_5 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (imm_4_0 << 7) | opcode
        return instruction & 0xFFFFFFFF
    
    def encode_b_type(self, instr, rs1, rs2, imm):
        """编码B型指令"""
        info = self.opcodes[instr]
        opcode = info['opcode']
        funct3 = info['funct3']
        
        # B型立即数编码：[12|10:5|4:1|11]
        imm_12 = (imm >> 12) & 1
        imm_11 = (imm >> 11) & 1
        imm_10_5 = (imm >> 5) & 0x3F
        imm_4_1 = (imm >> 1) & 0xF
        
        instruction = (imm_12 << 31) | (imm_10_5 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (imm_4_1 << 8) | (imm_11 << 7) | opcode
        return instruction & 0xFFFFFFFF
    
    def encode_u_type(self, instr, rd, imm):
        """编码U型指令 (LUI, AUIPC)"""
        info = self.opcodes[instr]
        opcode = info['opcode']
        
        # U型立即数：对于LUI，立即数直接作为高20位
        # 对于输入如0x80000，应该直接放在指令的[31:12]位置
        imm_31_12 = imm & 0xFFFFF  # 取低20位作为指令的高20位字段
        
        instruction = (imm_31_12 << 12) | (rd << 7) | opcode
        return instruction & 0xFFFFFFFF
    
    def encode_j_type(self, instr, rd, imm):
        """编码J型指令 (JAL)"""
        info = self.opcodes[instr]
        opcode = info['opcode']
        
        # J型立即数编码：[20|10:1|11|19:12]
        imm_20 = (imm >> 20) & 1
        imm_10_1 = (imm >> 1) & 0x3FF
        imm_11 = (imm >> 11) & 1
        imm_19_12 = (imm >> 12) & 0xFF
        
        instruction = (imm_20 << 31) | (imm_19_12 << 12) | (imm_11 << 20) | (imm_10_1 << 21) | (rd << 7) | opcode
        return instruction & 0xFFFFFFFF
    
    def first_pass(self, lines):
        """第一遍扫描：收集标签"""
        address = 0
        for line in lines:
            line = line.strip()
            if not line or line.startswith('//') or line.startswith('#'):
                continue
            
            # 移除注释 (支持 // 和 # 两种注释)
            if '//' in line:
                line = line[:line.index('//')].strip()
            if '#' in line:
                line = line[:line.index('#')].strip()
            
            if not line:
                continue
            
            # 检查标签
            if ':' in line:
                parts = line.split(':', 1)
                label = parts[0].strip()
                self.labels[label] = address
                line = parts[1].strip() if len(parts) > 1 else ''
            
            # 如果还有指令，地址递增
            if line and not line.startswith('//') and not line.startswith('#'):
                address += 4
    
    def assemble_instruction(self, line, address):
        """汇编单条指令"""
        # 移除注释 (支持 // 和 # 两种注释)
        if '//' in line:
            line = line[:line.index('//')].strip()
        if '#' in line:
            line = line[:line.index('#')].strip()
        
        if not line:
            return None
        
        parts = line.replace(',', ' ').split()
        if not parts:
            return None
        
        instr = parts[0].lower()
        
        if instr not in self.opcodes:
            raise ValueError(f"Unknown instruction: {instr}")
        
        # R型指令: add x1, x2, x3
        if instr in ['add', 'sub', 'and', 'or', 'xor', 'sll', 'srl', 'sra', 'slt', 'sltu']:
            if len(parts) != 4:
                raise ValueError(f"R-type instruction {instr} requires 3 operands")
            rd = self.parse_register(parts[1])
            rs1 = self.parse_register(parts[2])
            rs2 = self.parse_register(parts[3])
            return self.encode_r_type(instr, rd, rs1, rs2)
        
        # I型指令: addi x1, x2, 100
        elif instr in ['addi', 'andi', 'ori', 'xori', 'slli', 'srli', 'srai', 'slti', 'sltiu']:
            if len(parts) != 4:
                raise ValueError(f"I-type instruction {instr} requires 3 operands")
            rd = self.parse_register(parts[1])
            rs1 = self.parse_register(parts[2])
            imm = self.parse_immediate(parts[3])
            return self.encode_i_type(instr, rd, rs1, imm)
        
        # 加载指令: lw x1, 4(x2), lb x1, 4(x2), etc.
        elif instr in ['lw', 'lb', 'lh', 'lbu', 'lhu']:
            if len(parts) != 3:
                raise ValueError(f"{instr} instruction requires 2 operands")
            rd = self.parse_register(parts[1])
            offset, rs1 = self.parse_memory_operand(parts[2])
            return self.encode_i_type(instr, rd, rs1, offset)
        
        # 存储指令: sw x1, 4(x2), sb x1, 4(x2), etc.
        elif instr in ['sw', 'sb', 'sh']:
            if len(parts) != 3:
                raise ValueError(f"{instr} instruction requires 2 operands")
            rs2 = self.parse_register(parts[1])
            offset, rs1 = self.parse_memory_operand(parts[2])
            return self.encode_s_type(instr, rs1, rs2, offset)
        
        # JALR指令: jalr x1, x2, 100
        elif instr == 'jalr':
            if len(parts) != 4:
                raise ValueError(f"jalr instruction requires 3 operands")
            rd = self.parse_register(parts[1])
            rs1 = self.parse_register(parts[2])
            imm = self.parse_immediate(parts[3])
            return self.encode_i_type(instr, rd, rs1, imm)
        
        # B型指令: beq x1, x2, label
        elif instr in ['beq', 'bne', 'blt', 'bge', 'bltu', 'bgeu']:
            if len(parts) != 4:
                raise ValueError(f"B-type instruction {instr} requires 3 operands")
            rs1 = self.parse_register(parts[1])
            rs2 = self.parse_register(parts[2])
            target = parts[3]
            
            # 计算分支偏移
            if target in self.labels:
                target_addr = self.labels[target]
                offset = target_addr - address
            else:
                offset = self.parse_immediate(target)
            
            return self.encode_b_type(instr, rs1, rs2, offset)
        
        # U型指令: lui x1, 0x12345 或 auipc x1, 0x12345
        elif instr in ['lui', 'auipc']:
            if len(parts) != 3:
                raise ValueError(f"U-type instruction {instr} requires 2 operands")
            rd = self.parse_register(parts[1])
            imm = self.parse_immediate(parts[2])
            return self.encode_u_type(instr, rd, imm)
        
        # J型指令: jal x1, label
        elif instr == 'jal':
            if len(parts) != 3:
                raise ValueError(f"jal instruction requires 2 operands")
            rd = self.parse_register(parts[1])
            target = parts[2]
            
            # 计算跳转偏移
            if target in self.labels:
                target_addr = self.labels[target]
                offset = target_addr - address
            else:
                offset = self.parse_immediate(target)
            
            return self.encode_j_type(instr, rd, offset)
        
        # FENCE指令: fence
        elif instr == 'fence':
            # FENCE指令在简单实现中可以是NOP (addi x0, x0, 0)
            return 0x00000013
        
        else:
            raise ValueError(f"Unsupported instruction: {instr}")
    
    def assemble(self, assembly_text):
        """汇编整个程序"""
        lines = assembly_text.strip().split('\n')
        
        # 第一遍：收集标签
        self.first_pass(lines)
        
        # 第二遍：生成指令
        instructions = []
        address = 0
        
        for line in lines:
            original_line = line.strip()
            
            # 跳过空行和注释
            if not original_line or original_line.startswith('//') or original_line.startswith('#'):
                continue
            
            # 移除注释 (支持 // 和 # 两种注释)
            line = original_line
            if '//' in line:
                line = line[:line.index('//')].strip()
            if '#' in line:
                line = line[:line.index('#')].strip()
            
            if not line:
                continue
            
            # 处理标签
            if ':' in line:
                parts = line.split(':', 1)
                line = parts[1].strip() if len(parts) > 1 else ''
            
            if line and not line.startswith('//') and not line.startswith('#'):
                try:
                    machine_code = self.assemble_instruction(line, address)
                    if machine_code is not None:
                        instructions.append((address // 4, machine_code, original_line))
                        address += 4
                except Exception as e:
                    print(f"Error assembling line '{original_line}': {e}")
                    sys.exit(1)
        
        return instructions

def generate_verilog_rom(instructions, module_name="generated_imem"):
    """生成Verilog ROM模块"""
    verilog_code = f"""// {module_name}.v - 自动生成的指令存储器
module {module_name}(
    input wire [31:0] addr,
    output wire [31:0] inst
);
    // 简单的ROM实现
    reg [31:0] rom [0:255];
    assign inst = rom[addr[9:2]];
    
    integer i;
    
    initial begin
"""
    
    # 添加指令
    for index, machine_code, original_line in instructions:
        verilog_code += f"        rom[{index}] = 32'h{machine_code:08x}; // {original_line}\n"
    
    # 添加NOP指令填充
    max_index = max(instr[0] for instr in instructions) if instructions else 0
    verilog_code += f"""        
        // 剩余位置初始化为NOP
        for (i = {max_index + 1}; i < 256; i = i + 1) begin
            rom[i] = 32'h00000013; // addi x0, x0, 0 (NOP)
        end
    end
endmodule
"""
    
    return verilog_code

def main():
    if len(sys.argv) != 2:
        print("用法: python3 asm_to_rom.py <assembly_file>")
        print("示例: python3 asm_to_rom.py fibonacci.s")
        sys.exit(1)
    
    asm_file = sys.argv[1]
    
    if not os.path.exists(asm_file):
        print(f"错误: 文件 {asm_file} 不存在")
        sys.exit(1)
    
    with open(asm_file, 'r', encoding='utf-8') as f:
        assembly_text = f.read()
    
    assembler = RISCVAssembler()
    try:
        instructions = assembler.assemble(assembly_text)
        
        # 生成Verilog代码
        base_name = os.path.splitext(os.path.basename(asm_file))[0]
        verilog_code = generate_verilog_rom(instructions, f"{base_name}_imem")
        
        # 输出到文件
        output_file = f"{base_name}_imem.v"
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(verilog_code)
        
        print(f"✅ 汇编完成!")
        print(f"   输入: {asm_file}")
        print(f"   输出: {output_file}")
        print(f"   指令数: {len(instructions)}")
        
        # 显示指令列表
        print("\n生成的指令:")
        for index, machine_code, original_line in instructions:
            print(f"  rom[{index:2d}] = 32'h{machine_code:08x}; // {original_line}")
            
    except Exception as e:
        print(f"❌ 汇编失败: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
