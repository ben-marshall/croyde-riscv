
# Instruction Listing

*The canonical list of instructions the core implements and their
operand assignments inside the pipeline.*

---

## Control flow change instructions

Mnemonic  | ALU LHS | ALU RHS | ALU Op | CFU OP | WB Op | s2 wdata | s2 trap
----------|---------|---------|--------|--------|-------|----------|--------
beq       | rs1     | rs2     | SUB    | BEQ    |       |          |
bne       | rs1     | rs2     | SUB    | BNE    |       |          |
c.beqz    | rs1     | rs2     | SUB    | BEQ    |       |          |
c.bnez    | rs1     | rs2     | SUB    | BNE    |       |          |
blt       | rs1     | rs2     | SUB    | BLT    |       |          |
bge       | rs1     | rs2     | SUB    | BGE    |       |          |
bltu      | rs1     | rs2     | SUB    | BLTU   |       |          |
bgeu      | rs1     | rs2     | SUB    | BGEU   |       |          |
jalr      |         |         |        | JAL    | wdata | npn      |
jal       |         |         |        | JAL    | wdata | npc      |
c.jalr    |         |         |        | JALR   | wdata | npc      |
c.j       |         |         |        | J      |       |          |
c.jr      |         |         |        | J      |       |          |
ecall     |         |         |        | ECALL  |       |          | 1
ebreak    |         |         |        | EBREAK |       |          | 1
mret      |         |         |        | MRET   |       |          |
wfi       |         |         |        | WFI    |       |          |


## ALU instructions

Mnemonic  | ALU LHS | ALU RHS | ALU Op | WB Op | s2 wdata 
----------|---------|---------|--------|-------|----------
c.mv      | rs1     | 0       | OR     | wdata | alu out  
c.li      |   0     | imm     | OR     | wdata | alu out  
c.lui     |   0     | imm     | OR     | wdata | alu out  
lui       | 0       | imm     | OR     | wdata | alu out  
auipc     | PC      | imm     | ADD    | wdata | alu out  
addi      | rs1     | imm     | ADD    | wdata | alu out  
c.addi4spn| rs1     | imm     | ADD    | wdata | alu out  
c.addi    | rs1     | imm     | ADD    | wdata | alu out  
c.addiw   | rs1     | imm     | ADD    | wdata | alu out  
slli      | rs1     | imm     | SLL    | wdata | alu out  
c.slli    | rs1     | imm     | SLL    | wdata | alu out  
slti      | rs1     | imm     | SLT    | wdata | alu out  
sltiu     | rs1     | imm     | SLTU   | wdata | alu out  
xori      | rs1     | imm     | XOR    | wdata | alu out  
srli      | rs1     | imm     | SRL    | wdata | alu out  
srai      | rs1     | imm     | SRA    | wdata | alu out  
ori       | rs1     | imm     | OR     | wdata | alu out  
andi      | rs1     | imm     | AND    | wdata | alu out  
addiw     | rs1     | imm     | ADD    | wdata | alu out  
slliw     | rs1     | imm     | SLL    | wdata | alu out  
srliw     | rs1     | imm     | SRL    | wdata | alu out  
sraiw     | rs1     | imm     | SRA    | wdata | alu out  
c.srli    | rs1     | imm     | SRL    | wdata | alu out  
c.srai    | rs1     | imm     | SRA    | wdata | alu out  
c.andi    | rs1     | imm     | AND    | wdata | alu out  
c.add     | rs1     | rs2     | ADD    | wdata | alu out  
add       | rs1     | rs2     | ADD    | wdata | alu out  
sub       | rs1     | rs2     | SUB    | wdata | alu out  
sll       | rs1     | rs2     | SLL    | wdata | alu out  
slt       | rs1     | rs2     | SLT    | wdata | alu out  
sltu      | rs1     | rs2     | SLTU   | wdata | alu out  
xor       | rs1     | rs2     | XOR    | wdata | alu out  
srl       | rs1     | rs2     | SRL    | wdata | alu out  
sra       | rs1     | rs2     | SRA    | wdata | alu out  
or        | rs1     | rs2     | OR     | wdata | alu out  
and       | rs1     | rs2     | AND    | wdata | alu out  
addw      | rs1     | rs2     | ADD    | wdata | alu out  
subw      | rs1     | rs2     | SUB    | wdata | alu out  
sllw      | rs1     | rs2     | SLL    | wdata | alu out  
srlw      | rs1     | rs2     | SRL    | wdata | alu out  
sraw      | rs1     | rs2     | SRA    | wdata | alu out  
c.sub     | rs1     | rs2     | SUB    | wdata | alu out  
c.xor     | rs1     | rs2     | XOR    | wdata | alu out  
c.or      | rs1     | rs2     | OR     | wdata | alu out  
c.and     | rs1     | rs2     | AND    | wdata | alu out  
c.subw    | rs1     | rs2     | SUB    | wdata | alu out  
c.addw    | rs1     | rs2     | ADD    | wdata | alu out  
fence     |         |         | NOP    | wdata | alu out  


## Load/Store instructions

Mnemonic  | ALU LHS | ALU RHS | ALU Op | lsu op | wb op 
----------|---------|---------|--------|--------|-------
lb        | rs1     | imm     | ADD    | l b    | lsu   
lh        | rs1     | imm     | ADD    | l h    | lsu   
lw        | rs1     | imm     | ADD    | l w    | lsu   
c.lw      | rs1     | imm     | ADD    | l w    | lsu   
ld        | rs1     | imm     | ADD    | l d    | lsu   
c.ld      | rs1     | imm     | ADD    | l d    | lsu   
lbu       | rs1     | imm     | ADD    | l b u  | lsu   
lhu       | rs1     | imm     | ADD    | l h u  | lsu   
lwu       | rs1     | imm     | ADD    | l w u  | lsu   
c.lwsp    | rs1     | imm     | ADD    | l w    | lsu   
c.ldsp    | rs1     | imm     | ADD    | l d    | lsu   
sb        | rs1     | imm     | ADD    | s b    | lsu   
sh        | rs1     | imm     | ADD    | s h    | lsu   
sw        | rs1     | imm     | ADD    | s w    | lsu   
c.sw      | rs1     | imm     | ADD    | s w    | lsu   
sd        | rs1     | imm     | ADD    | s d    | lsu   
c.sd      | rs1     | imm     | ADD    | s d    | lsu   
c.swsp    | rs1     | imm     | ADD    | s w    | lsu   
c.sdsp    | rs1     | imm     | ADD    | s d    | lsu   

## M-Extension - Multiply / Divide

Mnemonic  | MDU LHS | MDU LHS | MDU Op | wb op   | wdata
----------|---------|---------|--------|---------|------
mul       | rs1     | rs2     | MUL    | mdu out | mdu  
mulh      | rs1     | rs2     | MULH   | mdu out | mdu  
mulhsu    | rs1     | rs2     | MULHSU | mdu out | mdu  
mulhu     | rs1     | rs2     | MULHU  | mdu out | mdu  
div       | rs1     | rs2     | DIV    | mdu out | mdu  
divu      | rs1     | rs2     | DIVU   | mdu out | mdu  
rem       | rs1     | rs2     | REM    | mdu out | mdu  
remu      | rs1     | rs2     | REMU   | mdu out | mdu  
mulw      | rs1     | rs2     | MUL    | mdu out | mdu  
divw      | rs1     | rs2     | DIV    | mdu out | mdu  
divuw     | rs1     | rs2     | DIVU   | mdu out | mdu  
remw      | rs1     | rs2     | REM    | mdu out | mdu  
remuw     | rs1     | rs2     | REMU   | mdu out | mdu  

## CSR Instructions

Mnemonic  | CSR OP | wb op | wdata
----------|--------|-------|-----------
csrrw     | rw     | csr   | rs1
csrrs     | rs     | csr   | rs1
csrrc     | rc     | csr   | rs1
csrrwi    | rw     | csr   | rs1
csrrsi    | rs     | csr   | rs1
csrrci    | rc     | csr   | rs1

