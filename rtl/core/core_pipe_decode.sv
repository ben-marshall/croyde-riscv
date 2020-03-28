
//
// Module: core_pipe_decode
//
//  Pipeline decode / operand gather stage.
//
module core_pipe_decode (

input  wire                 g_clk       , // Global clock
input  wire                 g_resetn    , // Global active low sync reset.

input  wire                 s1_i16bit   , // 16 bit instruction?
input  wire                 s1_i32bit   , // 32 bit instruction?
input  wire [  FD_IBUF_R:0] s1_instr    , // Instruction to be decoded
input  wire [         XL:0] s1_pc       , // Program Counter
input  wire [         XL:0] s1_npc      , // Next Program Counter
input  wire [   FD_ERR_R:0] s1_ferr     , // Fetch bus error?
output wire                 s1_eat_2    , // Decode eats 2 bytes
output wire                 s1_eat_4    , // Decode eats 4 bytes

input  wire                 s1_flush    , // Stage 1 flush

output wire [ REG_ADDR_R:0] s1_rs1_addr , // RS1 Address
input  wire [         XL:0] s1_rs1_data , // RS1 Read Data (Forwarded)
output wire [ REG_ADDR_R:0] s1_rs2_addr , // RS2 Address
input  wire [         XL:0] s1_rs2_data , // RS2 Read Data (Forwarded)

`ifdef RVFI
output reg  [ REG_ADDR_R:0] s2_rs1_a    ,
output reg  [         XL:0] s2_rs1_d    ,
output reg  [ REG_ADDR_R:0] s2_rs2_a    ,
output reg  [         XL:0] s2_rs2_d    ,
`endif

output wire                 s2_valid    , // Decode instr ready for execute
input  wire                 s2_ready    , // Execute ready for new instr.
output reg  [         XL:0] s2_pc       , // Execute stage PC
output wire [         XL:0] s2_npc      , // Decode stage PC
output reg  [         XL:0] s2_opr_a    , // EX stage operand a
output reg  [         XL:0] s2_opr_b    , //    "       "     b
output reg  [         XL:0] s2_opr_c    , //    "       "     c
output reg  [ REG_ADDR_R:0] s2_rd       , // EX stage destination reg address.
output reg  [   ALU_OP_R:0] s2_alu_op   , // ALU operation
output reg  [   LSU_OP_R:0] s2_lsu_op   , // LSU operation
output reg  [   MDU_OP_R:0] s2_mdu_op   , // Mul/Div Operation
output reg  [   CSR_OP_R:0] s2_csr_op   , // CSR operation
output reg  [   CFU_OP_R:0] s2_cfu_op   , // Control flow unit operation
output reg                  s2_op_w     , // Is the operation on a word?
output reg  [         31:0] s2_instr      // Encoded instruction for trace.

);

// Common parameters and width definitions.
`include "core_common.svh"

// Generated decoder
`include "core_pipe_decode.svh"

//
// Pipeline stage progression.
// ------------------------------------------------------------

//
// TODO: Stalls to delay eating of 16/32 bit instructions.
assign s1_eat_2     = s1_i16bit && s2_ready;
assign s1_eat_4     = s1_i32bit && s2_ready;

//
// Next pipeline stage value selection
// ------------------------------------------------------------

wire [         XL:0] n_s2_opr_a     ;
wire [         XL:0] n_s2_opr_b     ;
wire [         XL:0] n_s2_opr_c     ;
wire [ REG_ADDR_R:0] n_s2_rd        ;

wire [         XL:0] opr_b_imm      ;
wire [         XL:0] opr_c_imm      ;

wire [         31:0] imm32_i        ;
wire [         11:0] imm_csr_addr   ;
wire [          4:0] imm_csr_mask   ;
wire [         31:0] imm32_s        ;
wire [         31:0] imm32_b        ;
wire [         31:0] imm32_u        ;
wire [         31:0] imm32_j        ;
wire [         31:0] imm_addi16sp   ;
wire [         31:0] imm_addi4spn   ;
wire [         31:0] imm_c_lsw      ;
wire [         31:0] imm_c_addi     ;
wire [         31:0] imm_c_lui      ;
wire [         31:0] imm_c_shamt    ;
wire [         31:0] imm_c_lwsp     ;
wire [         31:0] imm_c_swsp     ;
wire [         31:0] imm_c_j        ;
wire [         31:0] imm_c_bz       ;

//
// Operand A

wire sel_opr_a_rs1 = 
    dec_beq       || dec_bne       || dec_c_beqz    || dec_c_bnez    ||
    dec_blt       || dec_bge       || dec_bltu      || dec_bgeu      ||
    dec_jalr      || dec_auipc     || dec_addi      || dec_c_addi4spn||
    dec_c_addi    || dec_slli      || dec_c_mv      || dec_c_add     ||
    dec_c_slli    || dec_slti      || dec_sltiu     || dec_xori      ||
    dec_srli      || dec_srai      || dec_ori       || dec_andi      ||
    dec_add       || dec_sub       || dec_sll       || dec_slt       ||
    dec_sltu      || dec_xor       || dec_srl       || dec_sra       ||
    dec_or        || dec_and       || dec_addiw     || dec_slliw     ||
    dec_srliw     || dec_sraiw     || dec_addw      || dec_subw      ||
    dec_sllw      || dec_srlw      || dec_sraw      || dec_c_srli    ||
    dec_c_srai    || dec_c_andi    || dec_c_sub     || dec_c_xor     ||
    dec_c_or      || dec_c_and     || dec_c_subw    || dec_c_addw    ||
    dec_lb        || dec_lh        || dec_lw        || dec_c_lw      ||
    dec_ld        || dec_lbu       || dec_lhu       || dec_lwu       ||
    dec_sb        || dec_sh        || dec_sw        || dec_c_sw      ||
    dec_sd        || dec_c_lwsp    || dec_c_swsp    || dec_mul       ||
    dec_mulh      || dec_mulhsu    || dec_mulhu     || dec_div       ||
    dec_divu      || dec_rem       || dec_remu      || dec_mulw      ||
    dec_divw      || dec_divuw     || dec_remw      || dec_remuw     ||
    dec_csrrw     || dec_csrrs     || dec_csrrc     || dec_csrrwi    ||
    dec_csrrsi    || dec_csrrci    ;

wire sel_opr_a_pc   =
    dec_jal       || dec_c_jal     || dec_c_j       || dec_auipc     ;

//
// Operand B

wire sel_opr_b_rs2  =
    dec_beq       || dec_bne       || dec_c_beqz    || dec_c_bnez    ||
    dec_blt       || dec_bge       || dec_bltu      || dec_bgeu      ||
    dec_c_add     || dec_add       || dec_sub       || dec_sll       ||
    dec_slt       || dec_sltu      || dec_xor       || dec_srl       ||
    dec_sra       || dec_or        || dec_and       || dec_addw      ||
    dec_subw      || dec_sllw      || dec_srlw      || dec_sraw      ||
    dec_c_sub     || dec_c_xor     || dec_c_or      || dec_c_and     ||
    dec_c_subw    || dec_c_addw    || dec_mul       || dec_mulh      ||
    dec_mulhsu    || dec_mulhu     || dec_div       || dec_divu      ||
    dec_rem       || dec_remu      || dec_mulw      || dec_divw      ||
    dec_divuw     || dec_remw      || dec_remuw     || dec_csrrw     ||
    dec_csrrs     || dec_csrrc     ;

wire sel_opr_b_imm  =
    dec_jalr      || dec_jal       || dec_c_jal     || dec_c_j       ||
    dec_lui       || dec_auipc     || dec_addi      || dec_c_addi4spn||
    dec_c_addi    || dec_slli      || dec_c_slli    || dec_slti      ||
    dec_sltiu     || dec_xori      || dec_srli      || dec_srai      ||
    dec_ori       || dec_andi      || dec_addiw     || dec_slliw     ||
    dec_srliw     || dec_sraiw     || dec_c_li      || dec_c_lui     ||
    dec_c_srli    || dec_c_srai    || dec_c_andi    || dec_lb        ||
    dec_lh        || dec_lw        || dec_c_lw      || dec_ld        ||
    dec_lbu       || dec_lhu       || dec_lwu       || dec_sb        ||
    dec_sh        || dec_sw        || dec_c_sw      || dec_sd        ||
    dec_c_lwsp    || dec_c_swsp    || dec_csrrwi    || dec_csrrsi    ||
    dec_csrrci    ; 

//
// Operand C

wire sel_opr_c_imm  =
    dec_beq       || dec_bne       || dec_c_beqz    || dec_c_bnez    ||
    dec_blt       || dec_bge       || dec_bltu      || dec_bgeu      ||
    dec_csrrw     || dec_csrrs     || dec_csrrc     || dec_csrrwi    ||
    dec_csrrsi    || dec_csrrci    || dec_auipc     ;

wire sel_opr_c_npc  =
    dec_jalr      || dec_jal       || dec_c_jal     || dec_fence_i   ;

wire sel_opr_c_rs2  =
    dec_sb        || dec_sh        || dec_sw        || dec_c_sw      ||
    dec_sd        || dec_c_lwsp    || dec_c_swsp    ;


assign n_s2_opr_a   =
    {64{sel_opr_a_rs1}} & s1_rs1_data |
    {64{sel_opr_a_pc }} & s1_pc       ;

assign n_s2_opr_b   =
    {64{sel_opr_b_rs2}} & s1_rs2_data |
    {64{sel_opr_b_imm}} & opr_b_imm   ;

assign n_s2_opr_c   =
    {64{sel_opr_c_rs2}} & s1_rs2_data |
    {64{sel_opr_c_imm}} & opr_c_imm   |
    {64{sel_opr_c_npc}} & s1_npc      ;

//
// Register operands
// TODO: decode 16-bit destination registers.
assign n_s2_rd      = dec_rd;

wire [REG_ADDR_R:0] dec_16bit_rs1 = 0; 
wire [REG_ADDR_R:0] dec_16bit_rs2 = 0;

assign s1_rs1_addr  = s1_i16bit ? dec_16bit_rs1 : dec_rs1 ;
assign s1_rs2_addr  = s1_i16bit ? dec_16bit_rs2 : dec_rs2 ;

//
// Is this decoded instruction explicitly operating on a word, rather than
// the full XLEN=64 bit register?
wire   n_s2_op_w    =
    dec_addiw     || dec_slliw     || dec_srliw     || dec_sraiw     ||
    dec_addw      || dec_subw      || dec_sllw      || dec_srlw      ||
    dec_sraw      || dec_c_subw    || dec_mulw      || dec_divw      ||
    dec_divuw     || dec_remw      || dec_remuw     || dec_c_addw    ;

//
// Operand immediate selection

assign opr_c_imm = 
    |n_csr_op            ? {52'b0, imm_csr_addr}        : 
    n_cfu_op_conditional ? {{32{imm32_b[31]}},imm32_b}  :
    dec_auipc            ? {{32{imm32_u[31]}},imm32_u}  :
    dec_lui              ? {{32{imm32_u[31]}},imm32_u}  :
                           0                            ;

wire    [XL:0]  sext_imm32_u = {{32{imm32_u[31]}}, imm32_u};
wire    [XL:0]  sext_imm32_i = {{32{imm32_i[31]}}, imm32_i};
wire    [XL:0]  sext_imm32_s = {{32{imm32_s[31]}}, imm32_s};
wire    [XL:0]  sext_imm32_j = {{32{imm32_j[31]}}, imm32_j};

wire    major_op_load        = s1_instr[6:0] == 7'b0000011;
wire    major_op_store       = s1_instr[6:0] == 7'b0100011;
wire    major_op_imm         = s1_instr[6:0] == 7'b0010011;

wire    use_imm_sext_imm32_u = dec_lui      || dec_auipc        ;

wire    use_imm_sext_imm32_i = dec_jalr     || major_op_load    ||
                               major_op_imm ;

assign opr_b_imm = 
    use_imm_sext_imm32_u    ? sext_imm32_u  :
    use_imm_sext_imm32_i    ? sext_imm32_i  :
    major_op_store          ? sext_imm32_s  :
    dec_jal                 ? sext_imm32_j  :
                              0             ;


//
// Uop decoding.
// ------------------------------------------------------------

//
// ALU Op code select

wire [ALU_OP_R:0] n_alu_op = 
    {ALU_OP_W{dec_beq       }} & ALU_OP_SUB     |
    {ALU_OP_W{dec_bne       }} & ALU_OP_SUB     |
    {ALU_OP_W{dec_c_beqz    }} & ALU_OP_SUB     |
    {ALU_OP_W{dec_c_bnez    }} & ALU_OP_SUB     |
    {ALU_OP_W{dec_blt       }} & ALU_OP_SUB     |
    {ALU_OP_W{dec_bge       }} & ALU_OP_SUB     |
    {ALU_OP_W{dec_bltu      }} & ALU_OP_SUB     |
    {ALU_OP_W{dec_bgeu      }} & ALU_OP_SUB     |
    {ALU_OP_W{dec_jalr      }} & ALU_OP_NOP     |
    {ALU_OP_W{dec_jal       }} & ALU_OP_NOP     |
    {ALU_OP_W{dec_c_jal     }} & ALU_OP_NOP     |
    {ALU_OP_W{dec_c_j       }} & ALU_OP_NOP     |
    {ALU_OP_W{dec_ecall     }} & ALU_OP_NOP     |
    {ALU_OP_W{dec_ebreak    }} & ALU_OP_NOP     |
    {ALU_OP_W{dec_mret      }} & ALU_OP_NOP     |
    {ALU_OP_W{dec_wfi       }} & ALU_OP_NOP     |
    {ALU_OP_W{dec_fence_i   }} & ALU_OP_NOP     |
    {ALU_OP_W{dec_lui       }} & ALU_OP_OR      |
    {ALU_OP_W{dec_auipc     }} & ALU_OP_ADD     |
    {ALU_OP_W{dec_addi      }} & ALU_OP_ADD     |
    {ALU_OP_W{dec_c_addi4spn}} & ALU_OP_ADD     |
    {ALU_OP_W{dec_c_addi    }} & ALU_OP_ADD     |
    {ALU_OP_W{dec_slli      }} & ALU_OP_SLL     |
    {ALU_OP_W{dec_c_mv      }} & ALU_OP_OR      |
    {ALU_OP_W{dec_c_add     }} & ALU_OP_ADD     |
    {ALU_OP_W{dec_c_slli    }} & ALU_OP_SLL     |
    {ALU_OP_W{dec_slti      }} & ALU_OP_SLT     |
    {ALU_OP_W{dec_sltiu     }} & ALU_OP_SLTU    |
    {ALU_OP_W{dec_xori      }} & ALU_OP_XOR     |
    {ALU_OP_W{dec_srli      }} & ALU_OP_SRL     |
    {ALU_OP_W{dec_srai      }} & ALU_OP_SRA     |
    {ALU_OP_W{dec_ori       }} & ALU_OP_OR      |
    {ALU_OP_W{dec_andi      }} & ALU_OP_AND     |
    {ALU_OP_W{dec_add       }} & ALU_OP_ADD     |
    {ALU_OP_W{dec_sub       }} & ALU_OP_SUB     |
    {ALU_OP_W{dec_sll       }} & ALU_OP_SLL     |
    {ALU_OP_W{dec_slt       }} & ALU_OP_SLT     |
    {ALU_OP_W{dec_sltu      }} & ALU_OP_SLTU    |
    {ALU_OP_W{dec_xor       }} & ALU_OP_XOR     |
    {ALU_OP_W{dec_srl       }} & ALU_OP_SRL     |
    {ALU_OP_W{dec_sra       }} & ALU_OP_SRA     |
    {ALU_OP_W{dec_or        }} & ALU_OP_OR      |
    {ALU_OP_W{dec_and       }} & ALU_OP_AND     |
    {ALU_OP_W{dec_addiw     }} & ALU_OP_ADD     |
    {ALU_OP_W{dec_slliw     }} & ALU_OP_SLL     |
    {ALU_OP_W{dec_srliw     }} & ALU_OP_SRL     |
    {ALU_OP_W{dec_sraiw     }} & ALU_OP_SRA     |
    {ALU_OP_W{dec_addw      }} & ALU_OP_ADD     |
    {ALU_OP_W{dec_subw      }} & ALU_OP_SUB     |
    {ALU_OP_W{dec_sllw      }} & ALU_OP_SLL     |
    {ALU_OP_W{dec_srlw      }} & ALU_OP_SRL     |
    {ALU_OP_W{dec_sraw      }} & ALU_OP_SRA     |
    {ALU_OP_W{dec_c_li      }} & ALU_OP_OR      |
    {ALU_OP_W{dec_c_lui     }} & ALU_OP_OR      |
    {ALU_OP_W{dec_c_srli    }} & ALU_OP_SRL     |
    {ALU_OP_W{dec_c_srai    }} & ALU_OP_SRA     |
    {ALU_OP_W{dec_c_andi    }} & ALU_OP_AND     |
    {ALU_OP_W{dec_c_sub     }} & ALU_OP_SUB     |
    {ALU_OP_W{dec_c_xor     }} & ALU_OP_XOR     |
    {ALU_OP_W{dec_c_or      }} & ALU_OP_OR      |
    {ALU_OP_W{dec_c_and     }} & ALU_OP_AND     |
    {ALU_OP_W{dec_c_subw    }} & ALU_OP_SUB     |
    {ALU_OP_W{dec_c_addw    }} & ALU_OP_ADD     |
    {ALU_OP_W{dec_fence     }} & ALU_OP_NOP     |
    {ALU_OP_W{dec_lb        }} & ALU_OP_ADD     |
    {ALU_OP_W{dec_lh        }} & ALU_OP_ADD     |
    {ALU_OP_W{dec_lw        }} & ALU_OP_ADD     |
    {ALU_OP_W{dec_c_lw      }} & ALU_OP_ADD     |
    {ALU_OP_W{dec_ld        }} & ALU_OP_ADD     |
    {ALU_OP_W{dec_lbu       }} & ALU_OP_ADD     |
    {ALU_OP_W{dec_lhu       }} & ALU_OP_ADD     |
    {ALU_OP_W{dec_lwu       }} & ALU_OP_ADD     |
    {ALU_OP_W{dec_sb        }} & ALU_OP_ADD     |
    {ALU_OP_W{dec_sh        }} & ALU_OP_ADD     |
    {ALU_OP_W{dec_sw        }} & ALU_OP_ADD     |
    {ALU_OP_W{dec_c_sw      }} & ALU_OP_ADD     |
    {ALU_OP_W{dec_sd        }} & ALU_OP_ADD     |
    {ALU_OP_W{dec_c_lwsp    }} & ALU_OP_ADD     |
    {ALU_OP_W{dec_c_swsp    }} & ALU_OP_ADD     ;

//
// MUL / DIV Opcode select

wire [MDU_OP_R:0] n_mdu_op = 
    {MDU_OP_W{dec_mul       }} & MDU_OP_MUL     |
    {MDU_OP_W{dec_mulh      }} & MDU_OP_MULH    |
    {MDU_OP_W{dec_mulhsu    }} & MDU_OP_MULHSU  |
    {MDU_OP_W{dec_mulhu     }} & MDU_OP_MULHU   |
    {MDU_OP_W{dec_div       }} & MDU_OP_DIV     |
    {MDU_OP_W{dec_divu      }} & MDU_OP_DIVU    |
    {MDU_OP_W{dec_rem       }} & MDU_OP_REM     |
    {MDU_OP_W{dec_remu      }} & MDU_OP_REMU    |
    {MDU_OP_W{dec_mulw      }} & MDU_OP_MUL     |
    {MDU_OP_W{dec_divw      }} & MDU_OP_DIV     |
    {MDU_OP_W{dec_divuw     }} & MDU_OP_DIVU    |
    {MDU_OP_W{dec_remw      }} & MDU_OP_REM     |
    {MDU_OP_W{dec_remuw     }} & MDU_OP_REMU    ;

//
// Load/Store opcode select

wire [LSU_OP_R:0] n_lsu_op =
    {LSU_OP_W{dec_lb        }} & LSU_OP_LB      |
    {LSU_OP_W{dec_lbu       }} & LSU_OP_LBU     |
    {LSU_OP_W{dec_lh        }} & LSU_OP_LH      |
    {LSU_OP_W{dec_lhu       }} & LSU_OP_LHU     |
    {LSU_OP_W{dec_lw        }} & LSU_OP_LW      |
    {LSU_OP_W{dec_lwu       }} & LSU_OP_LWU     |
    {LSU_OP_W{dec_ld        }} & LSU_OP_LD      |
    {LSU_OP_W{dec_sb        }} & LSU_OP_SB      |
    {LSU_OP_W{dec_sh        }} & LSU_OP_SH      |
    {LSU_OP_W{dec_sw        }} & LSU_OP_SW      |
    {LSU_OP_W{dec_sd        }} & LSU_OP_SD      ;

//
// CSR Opcode select

wire [CSR_OP_R:0] n_csr_op;

wire    rd_zero     = dec_rd    == 5'b0;
wire    rs1_zero    = dec_rs1   == 5'b0;

assign  n_csr_op[CSR_OP_RD ] = !rd_zero && (
    dec_csrrw  || dec_csrrc  || dec_csrrs  ||
    dec_csrrwi || dec_csrrci || dec_csrrsi
);

assign  n_csr_op[CSR_OP_WR ] = (
    dec_csrrw  || dec_csrrc  || dec_csrrs  ||
    dec_csrrwi || (dec_csrrci || dec_csrrsi) && |imm_csr_mask
);

assign  n_csr_op[CSR_OP_SET] = dec_csrrs || dec_csrrsi;
assign  n_csr_op[CSR_OP_CLR] = dec_csrrc || dec_csrrci;

//
//  CFU Opcode select
    
wire n_cfu_op_conditional = 
    dec_beq    || dec_bne    || dec_c_beqz || dec_c_bnez || dec_blt    ||
    dec_bge    || dec_bltu   || dec_bgeu   ;

wire [CFU_OP_R:0] n_cfu_op =
    {CFU_OP_W{dec_beq       }} & CFU_OP_BEQ     |
    {CFU_OP_W{dec_bne       }} & CFU_OP_BNE     |
    {CFU_OP_W{dec_c_beqz    }} & CFU_OP_BEQ     |
    {CFU_OP_W{dec_c_bnez    }} & CFU_OP_BNE     |
    {CFU_OP_W{dec_blt       }} & CFU_OP_BLT     |
    {CFU_OP_W{dec_bge       }} & CFU_OP_BGE     |
    {CFU_OP_W{dec_bltu      }} & CFU_OP_BLTU    |
    {CFU_OP_W{dec_bgeu      }} & CFU_OP_BGEU    |
    {CFU_OP_W{dec_jalr      }} & CFU_OP_JAL     |
    {CFU_OP_W{dec_jal       }} & CFU_OP_JAL     |
    {CFU_OP_W{dec_c_jal     }} & CFU_OP_JAL     |
    {CFU_OP_W{dec_c_j       }} & CFU_OP_J       |
    {CFU_OP_W{dec_ecall     }} & CFU_OP_ECALL   |
    {CFU_OP_W{dec_ebreak    }} & CFU_OP_EBREAK  |
    {CFU_OP_W{dec_mret      }} & CFU_OP_MRET    |
    {CFU_OP_W{dec_wfi       }} & CFU_OP_NOP     |
    {CFU_OP_W{dec_fence_i   }} & CFU_OP_NOP     ;

//
// Decode stage control flow change raising
// ------------------------------------------------------------

// Offset used when calculating jumps taken from the decode stage.
wire [XL:0] decode_cf_offset = 
    {64{dec_jalr || dec_jal  }} & {{32{imm32_j[31]}}, imm32_j} |
    {64{dec_c_j  || dec_c_jal}} & {{32{imm_c_j[31]}}, imm_c_j} ;

//
// Decode -> Execute stage registers
// ------------------------------------------------------------

assign      s2_valid    = ( s1_i16bit   || s1_i32bit  );

assign      s2_npc      = n_s2_pc;

wire [XL:0] n_s2_pc     = s1_pc;
wire [31:0] n_s2_instr  = {
    s1_i16bit ? 16'b0 : s1_instr[31:16], s1_instr[15:0]
};

wire        flush_pipe  = s1_flush;

always @(posedge g_clk) begin
    if(!g_resetn || flush_pipe) begin
        s2_pc       <= 0            ;
        s2_opr_a    <= 0            ;
        s2_opr_b    <= 0            ;
        s2_opr_c    <= 0            ;
        s2_rd       <= 0            ;
        s2_alu_op   <= 0            ;
        s2_lsu_op   <= 0            ;
        s2_mdu_op   <= 0            ;
        s2_csr_op   <= 0            ;
        s2_cfu_op   <= 0            ;
        s2_op_w     <= 0            ;
        s2_instr    <= 0            ;
    end else if(s2_valid && s2_ready) begin
        s2_pc       <= n_s2_pc      ;
        s2_opr_a    <= n_s2_opr_a   ;
        s2_opr_b    <= n_s2_opr_b   ;
        s2_opr_c    <= n_s2_opr_c   ;
        s2_rd       <= n_s2_rd      ;
        s2_alu_op   <= n_alu_op     ;
        s2_lsu_op   <= n_lsu_op     ;
        s2_mdu_op   <= n_mdu_op     ;
        s2_csr_op   <= n_csr_op     ;
        s2_cfu_op   <= n_cfu_op     ;
        s2_op_w     <= n_s2_op_w    ;
        s2_instr    <= n_s2_instr   ;
    end
end


//
// Submodule instances
// ------------------------------------------------------------

core_pipe_decode_immediates i_core_pipe_decode_immediates (
.instr        (s1_instr     ),   // Input encoded instruction.
.imm32_i      (imm32_i      ),
.imm_csr_addr (imm_csr_addr ),
.imm_csr_mask (imm_csr_mask ),
.imm32_s      (imm32_s      ),
.imm32_b      (imm32_b      ),
.imm32_u      (imm32_u      ),
.imm32_j      (imm32_j      ),
.imm_addi16sp (imm_addi16sp ),
.imm_addi4spn (imm_addi4spn ),
.imm_c_lsw    (imm_c_lsw    ),
.imm_c_addi   (imm_c_addi   ),
.imm_c_lui    (imm_c_lui    ),
.imm_c_shamt  (imm_c_shamt  ),
.imm_c_lwsp   (imm_c_lwsp   ),
.imm_c_swsp   (imm_c_swsp   ),
.imm_c_j      (imm_c_j      ),
.imm_c_bz     (imm_c_bz     ) 
);


//
// RVFI
// ------------------------------------------------------------

`ifdef RVFI
always @(posedge g_clk) begin
    if(!g_resetn || flush_pipe) begin
        s2_rs1_a <= 0;
        s2_rs1_d <= 0;
        s2_rs2_a <= 0;
        s2_rs2_d <= 0;
    end else if(s2_valid && s2_ready) begin
        s2_rs1_a <= s1_rs1_addr;
        s2_rs1_d <= s1_rs1_data;
        s2_rs2_a <= s1_rs2_addr;
        s2_rs2_d <= s1_rs2_data;
    end
end
`endif

endmodule

