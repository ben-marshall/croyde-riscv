
# Instruction Listing

*The canonical list of instructions the core implements and their
operand assignments inside the pipeline.*

---

Mnemonic  | `opr_a` | `opr_b` | `opr_c` | ALU Op | CFU OP |
----------|---------|---------|---------|--------|--------|------------------
beq       | rs1     | rs2     | imm     | SUB    | BEQ    |
bne       | rs1     | rs2     | imm     | SUB    | BNE    |
c.beqz    | rs1     | rs2     | imm     | SUB    | BEQ    |
c.bnez    | rs1     | rs2     | imm     | SUB    | BNE    |
blt       | rs1     | rs2     | imm     | SUB    | BLT    |
bge       | rs1     | rs2     | imm     | SUB    | BGE    |
bltu      | rs1     | rs2     | imm     | SUB    | BLTU   |
bgeu      | rs1     | rs2     | imm     | SUB    | BGEU   |
jalr      | rs1     | imm     | npc     | ADD    | JAL    |
jal       | PC      | imm     | npc     | ADD    | JAL    |
c.j       | PC      | imm     |         | ADD    | J      |
c.jr      | rs1     | 0       |         | ADD    | J      |
c.jalr    | rs1     | imm     | npc     | ADD    | JALR   |
ecall     |         |         |         | NOP    | ECALL  |
ebreak    |         |         |         | NOP    | EBREAK |
mret      | rs1     |         |         | NOP    | MRET   |
wfi       |         |         |         | NOP    | NOP    |
fence.i   | npc     |         | npc     | NOP    | NOP    |

Mnemonic  | `opr_a` | `opr_b` | `opr_c` | ALU Op |
----------|---------|---------|---------|--------|---------------------------
lui       | 0       | imm     |         | OR     |
auipc     | PC      | imm     |         | ADD    |
addi      | rs1     | imm     |         | ADD    |
c.addi4spn| rs1     | imm     |         | ADD    |
c.addi    | rs1     | imm     |         | ADD    |
slli      | rs1     | imm     |         | SLL    |
c.mv      | 0       | rs1     |         | OR     |
c.add     | rs1     | rs2     |         | ADD    |
c.slli    | rs1     | imm     |         | SLL    |
slti      | rs1     | imm     |         | SLT    |
sltiu     | rs1     | imm     |         | SLTU   |
xori      | rs1     | imm     |         | XOR    |
srli      | rs1     | imm     |         | SLR    |
srai      | rs1     | imm     |         | SRA    |
ori       | rs1     | imm     |         | OR     |
andi      | rs1     | imm     |         | AND    |
add       | rs1     | rs2     |         | ADD    |
sub       | rs1     | rs2     |         | SUB    |
sll       | rs1     | rs2     |         | SLL    |
slt       | rs1     | rs2     |         | SLT    |
sltu      | rs1     | rs2     |         | SLTU   |
xor       | rs1     | rs2     |         | XOR    |
srl       | rs1     | rs2     |         | SLR    |
sra       | rs1     | rs2     |         | SRA    |
or        | rs1     | rs2     |         | OR     |
and       | rs1     | rs2     |         | AND    |
addiw     | rs1     | imm     |         | ADD    |
slliw     | rs1     | imm     |         | SLL    |
srliw     | rs1     | imm     |         | SLR    |
sraiw     | rs1     | imm     |         | SRA    |
addw      | rs1     | rs2     |         | ADD    |
subw      | rs1     | rs2     |         | SUB    |
sllw      | rs1     | rs2     |         | SLL    |
srlw      | rs1     | rs2     |         | SLR    |
sraw      | rs1     | rs2     |         | SRA    |
c.li      |   0     | imm     |         | OR     |
c.lui     |   0     | imm     |         | OR     |
c.srli    | rs1     | imm     |         | SLR    |
c.srai    | rs1     | imm     |         | SRA    |
c.andi    | rs1     | imm     |         | AND    |
c.sub     | rs1     | rs2     |         | SUB    |
c.xor     | rs1     | rs2     |         | XOR    |
c.or      | rs1     | rs2     |         | OR     |
c.and     | rs1     | rs2     |         | AND    |
c.subw    | rs1     | rs2     |         | SUB    |
c.addw    | rs1     | rs2     |         | ADD    |
fence     |         |         |         | NOP    |

Mnemonic  | `opr_a` | `opr_b` | `opr_c` | ALU Op |
----------|---------|---------|---------|--------|--------------------------
lb        | rs1     | imm     |         | ADD    |
lh        | rs1     | imm     |         | ADD    |
lw        | rs1     | imm     |         | ADD    |
c.lw      | rs1     | imm     |         | ADD    |
ld        | rs1     | imm     |         | ADD    |
lbu       | rs1     | imm     |         | ADD    |
lhu       | rs1     | imm     |         | ADD    |
lwu       | rs1     | imm     |         | ADD    |
sb        | rs1     | imm     | rs2     | ADD    |
sh        | rs1     | imm     | rs2     | ADD    |
sw        | rs1     | imm     | rs2     | ADD    |
c.sw      | rs1     | imm     | rs2     | ADD    |
sd        | rs1     | imm     | rs2     | ADD    |
c.lwsp    | rs1     | imm     | rs2     | ADD    |
c.swsp    | rs1     | imm     | rs2     | ADD    |

Mnemonic  | `opr_a` | `opr_b` | `opr_c` | MDU Op |
----------|---------|---------|---------|--------|--------------------------
mul       | rs1     | rs2     |         | MUL    |
mulh      | rs1     | rs2     |         | MULH   |
mulhsu    | rs1     | rs2     |         | MULHSU |
mulhu     | rs1     | rs2     |         | MULHU  |
div       | rs1     | rs2     |         | DIV    |
divu      | rs1     | rs2     |         | DIVU   |
rem       | rs1     | rs2     |         | REM    |
remu      | rs1     | rs2     |         | REMU   |
mulw      | rs1     | rs2     |         | MUL    |
divw      | rs1     | rs2     |         | DIV    |
divuw     | rs1     | rs2     |         | DIVU   |
remw      | rs1     | rs2     |         | REM    |
remuw     | rs1     | rs2     |         | REMU   |

Mnemonic  | `opr_a` | `opr_b` | `opr_c` | CSR OP |
----------|---------|---------|---------|--------|---------------------------
csrrw     | rs1     | rs2     | csr     |
csrrs     | rs1     | rs2     | csr     |
csrrc     | rs1     | rs2     | csr     |
csrrwi    | rs1     | imm     | csr     |
csrrsi    | rs1     | imm     | csr     |
csrrci    | rs1     | imm     | csr     |

