
# Instruction Listing

*The canonical list of instructions the core implements and their
operand assignments inside the pipeline.*

---

Mnemonic  | `opr_a` | `opr_b` | `opr_c` |
----------|---------|---------|---------|-----------------------------------
beq       | rs1     | rs2     | imm     |
bne       | rs1     | rs2     | imm     |
c.beqz    | rs1     | rs2     | imm     |
c.bnez    | rs1     | rs2     | imm     |
blt       | rs1     | rs2     | imm     |
bge       | rs1     | rs2     | imm     |
bltu      | rs1     | rs2     | imm     |
bgeu      | rs1     | rs2     | imm     |
jalr      | rs1     | imm     | npc     |
jal       | PC      | imm     | npc     |
c.jal     | PC      | imm     | npc     |
c.j       | PC      | imm     |         |
ecall     |         |         |         |
ebreak    |         |         |         |
mret      | rs1     |         |         |
wfi       |         |         |         |
fence.i   | npc     |         | npc     |

Mnemonic  | `opr_a` | `opr_b` | `opr_c` |
----------|---------|---------|---------|-----------------------------------
lui       | 0       | imm     |         |
auipc     | PC      | imm     |         |
addi      | rs1     | imm     |         |
c.addi4spn| rs1     | imm     |         |
c.addi    | rs1     | imm     |         |
slli      | rs1     | imm     |         |
c.mv      | rs1     | 0       |         |
c.add     | rs1     | rs2     |         |
c.slli    | rs1     | imm     |         |
slti      | rs1     | imm     |         |
sltiu     | rs1     | imm     |         |
xori      | rs1     | imm     |         |
srli      | rs1     | imm     |         |
srai      | rs1     | imm     |         |
ori       | rs1     | imm     |         |
andi      | rs1     | imm     |         |
add       | rs1     | rs2     |         |
sub       | rs1     | rs2     |         |
sll       | rs1     | rs2     |         |
slt       | rs1     | rs2     |         |
sltu      | rs1     | rs2     |         |
xor       | rs1     | rs2     |         |
srl       | rs1     | rs2     |         |
sra       | rs1     | rs2     |         |
or        | rs1     | rs2     |         |
and       | rs1     | rs2     |         |
addiw     | rs1     | imm     |         |
slliw     | rs1     | imm     |         |
srliw     | rs1     | imm     |         |
sraiw     | rs1     | imm     |         |
addw      | rs1     | rs2     |         |
subw      | rs1     | rs2     |         |
sllw      | rs1     | rs2     |         |
srlw      | rs1     | rs2     |         |
sraw      | rs1     | rs2     |         |
c.li      |   0     | imm     |         |
c.lui     |   0     | imm     |         |
c.srli    | rs1     | imm     |         |
c.srai    | rs1     | imm     |         |
c.andi    | rs1     | imm     |         |
c.sub     | rs1     | rs2     |         |
c.xor     | rs1     | rs2     |         |
c.or      | rs1     | rs2     |         |
c.and     | rs1     | rs2     |         |
c.subw    | rs1     | rs2     |         |
c.addw    | rs1     | rs2     |         |
fence     |         |         |         |

Mnemonic  | `opr_a` | `opr_b` | `opr_c` |
----------|---------|---------|---------|-----------------------------------
lb        | rs1     | imm     |         |
lh        | rs1     | imm     |         |
lw        | rs1     | imm     |         |
c.lw      | rs1     | imm     |         |
ld        | rs1     | imm     |         |
lbu       | rs1     | imm     |         |
lhu       | rs1     | imm     |         |
lwu       | rs1     | imm     |         |
sb        | rs1     | imm     | rs2     |
sh        | rs1     | imm     | rs2     |
sw        | rs1     | imm     | rs2     |
c.sw      | rs1     | imm     | rs2     |
sd        | rs1     | imm     | rs2     |
c.lwsp    | rs1     | imm     | rs2     |
c.swsp    | rs1     | imm     | rs2     |

Mnemonic  | `opr_a` | `opr_b` | `opr_c` |
----------|---------|---------|---------|-----------------------------------
mul       | rs1     | rs2     |         |
mulh      | rs1     | rs2     |         |
mulhsu    | rs1     | rs2     |         |
mulhu     | rs1     | rs2     |         |
div       | rs1     | rs2     |         |
divu      | rs1     | rs2     |         |
rem       | rs1     | rs2     |         |
remu      | rs1     | rs2     |         |
mulw      | rs1     | rs2     |         |
divw      | rs1     | rs2     |         |
divuw     | rs1     | rs2     |         |
remw      | rs1     | rs2     |         |
remuw     | rs1     | rs2     |         |

Mnemonic  | `opr_a` | `opr_b` | `opr_c` |
----------|---------|---------|---------|-----------------------------------
csrrw     | rs1     | rs2     | csr     |
csrrs     | rs1     | rs2     | csr     |
csrrc     | rs1     | rs2     | csr     |
csrrwi    | rs1     | imm     | csr     |
csrrsi    | rs1     | imm     | csr     |
csrrci    | rs1     | imm     | csr     |

