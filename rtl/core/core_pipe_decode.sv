
//
// Module: core_pipe_decode
//
//  Pipeline decode / operand gather stage.
//
module core_pipe_decode (

input  wire                 g_clk           , // Global clock
input  wire                 g_resetn        , // Global active low sync reset.

input  wire                 s1_i16bit       , // 16 bit instruction?
input  wire                 s1_i32bit       , // 32 bit instruction?
input  wire [  FD_IBUF_R:0] s1_instr        , // Instruction to be decoded
input  wire [   FD_ERR_R:0] s1_ferr         , // Fetch bus error?
output wire                 s1_eat_2        , // Decode eats 2 bytes
output wire                 s1_eat_4        , // Decode eats 4 bytes

input  wire                 s2_flush        , // Stage 2 flush

input  wire                 cf_valid        , // Control flow change?
input  wire                 cf_ack          , // Control flow acknwoledged
input  wire [         XL:0] cf_target       , // Control flow destination

output wire [ REG_ADDR_R:0] s1_rs1_addr     , // RS1 Address
input  wire [         XL:0] s1_rs1_data     , // RS1 Read Data (Forwarded)
output wire [ REG_ADDR_R:0] s1_rs2_addr     , // RS2 Address
input  wire [         XL:0] s1_rs2_data     , // RS2 Read Data (Forwarded)

input  wire                 s2_ready        , // EX ready for new instruction
output wire                 s2_valid        , // Decode -> EX instr valid.

output wire [ REG_ADDR_R:0] s2_rs1_addr     , // RS1 address.
output wire [ REG_ADDR_R:0] s2_rs2_addr     , // RS2 address.
output wire [ REG_ADDR_R:0] s2_rd           , // Destination reg address.
output wire [         XL:0] s2_rs1_data     , // RS1 value.
output wire [         XL:0] s2_rs2_data     , // RS2 value.
output wire [         XL:0] s2_imm          , // Immediate value
output reg  [         XL:0] s2_pc           , // Current program counter.
output wire [         XL:0] s2_npc          , // Next    program counter.
output wire [         31:0] s2_instr        , // Current instruction word.
output wire                 s2_trap         , // Raise a trap

output wire [         XL:0] s2_alu_lhs      , // ALU left  operand
output wire [         XL:0] s2_alu_rhs      , // ALU right operand
output wire                 s2_alu_add      , // ALU Operation to perform.
output wire                 s2_alu_and      , // 
output wire                 s2_alu_or       , // 
output wire                 s2_alu_sll      , // 
output wire                 s2_alu_srl      , // 
output wire                 s2_alu_slt      , // 
output wire                 s2_alu_sltu     , // 
output wire                 s2_alu_sra      , // 
output wire                 s2_alu_sub      , // 
output wire                 s2_alu_xor      , // 
output wire                 s2_alu_word     , // Word result only.

output wire                 s2_cfu_beq      , // Control flow operation.
output wire                 s2_cfu_bge      , //
output wire                 s2_cfu_bgeu     , //
output wire                 s2_cfu_blt      , //
output wire                 s2_cfu_bltu     , //
output wire                 s2_cfu_bne      , //
output wire                 s2_cfu_ebrk     , //
output wire                 s2_cfu_ecall    , //
output wire                 s2_cfu_j        , //
output wire                 s2_cfu_jal      , //
output wire                 s2_cfu_jalr     , //
output wire                 s2_cfu_mret     , //

output wire                 s2_lsu_load     , // LSU Load
output wire                 s2_lsu_store    , // "   Store
output wire                 s2_lsu_byte     , // Byte width
output wire                 s2_lsu_half     , // Halfword width
output wire                 s2_lsu_word     , // Word width
output wire                 s2_lsu_dbl      , // Doubleword widt
output wire                 s2_lsu_sext     , // Sign extend loaded value.

output wire                 s2_mdu_mul      , // MDU Operation
output wire                 s2_mdu_mulh     , //
output wire                 s2_mdu_mulhsu   , //
output wire                 s2_mdu_mulhu    , //
output wire                 s2_mdu_div      , //
output wire                 s2_mdu_divu     , //
output wire                 s2_mdu_rem      , //
output wire                 s2_mdu_remu     , //
output wire                 s2_mdu_mulw     , //
output wire                 s2_mdu_divw     , //
output wire                 s2_mdu_divuw    , //
output wire                 s2_mdu_remw     , //
output wire                 s2_mdu_remuw    , //

output wire                 s2_csr_set      , // CSR Operation
output wire                 s2_csr_clr      , //
output wire                 s2_csr_rd       , //
output wire                 s2_csr_wr       , //
output wire [         11:0] s2_csr_addr     , // CSR Access address.

output wire                 s2_wb_alu       , // Writeback ALU result
output wire                 s2_wb_csr       , // Writeback CSR result
output wire                 s2_wb_mdu       , // Writeback MDU result
output wire                 s2_wb_lsu       , // Writeback LSU Loaded data
output wire                 s2_wb_npc         // Writeback next PC value

);

// Common parameters and width definitions.
`include "core_common.svh"

// Generated decoder
`include "core_pipe_decode.svh"

//
// Pipeline stage progression.
// ------------------------------------------------------------

assign s1_eat_2     = s1_i16bit && s2_ready;
assign s1_eat_4     = s1_i32bit && s2_ready;

assign s2_valid     = s1_i16bit || s1_i32bit;
assign s2_instr     = {s1_i32bit ? s1_instr[31:16] : 16'b0, s1_instr[15:0]};

//
// Program Counter Tracking
// ------------------------------------------------------------

// Inital address of the program counter post reset.
parameter   PC_RESET_ADDRESS      = 64'h10000000;

wire        e_cf_change = cf_valid && cf_ack;

assign      s2_npc      = s2_pc + {61'b0, s1_i32bit, s1_i16bit, 1'b0};

always @(posedge g_clk) begin
    if(!g_resetn) begin
        s2_pc <= PC_RESET_ADDRESS;
    end else if(e_cf_change) begin
        s2_pc <= cf_target;
    end else if(s1_eat_2 || s1_eat_4) begin
        s2_pc <= s2_npc;
    end
end

//
// Immediate Decoding
// ------------------------------------------------------------

wire [         31:0] imm32_i        ;
wire [         11:0] imm_csr_addr   ;
wire [          4:0] imm_csr_mask   ;
wire [         31:0] imm32_s        ;
wire [         31:0] imm32_b        ;
wire [         31:0] imm32_u        ;
wire [         31:0] imm32_j        ;
wire [         31:0] imm_addi16sp   ;
wire [         31:0] imm_addi4spn   ;
wire [         31:0] imm_c_addi     ;
wire [         31:0] imm_c_lui      ;
wire [         31:0] imm_c_lsw      ;
wire [         31:0] imm_c_lwsp     ;
wire [         31:0] imm_c_swsp     ;
wire [         31:0] imm_c_lsd      ;
wire [         31:0] imm_c_ldsp     ;
wire [         31:0] imm_c_sdsp     ;
wire [         31:0] imm_c_j        ;
wire [         31:0] imm_c_bz       ;

wire  cf_offset_cbeq_imm    = dec_c_beqz || dec_c_bnez;

wire  cfu_op_conditonal     =
    dec_beq     || dec_c_beqz   || dec_bge      || dec_bgeu   || dec_blt  ||
    dec_bltu    || dec_bne      || dec_c_bnez   ;

wire    [XL:0]  sext_imm32_u = {{32{imm32_u[31]}}, imm32_u};
wire    [XL:0]  sext_imm32_i = {{32{imm32_i[31]}}, imm32_i};
wire    [XL:0]  sext_imm32_s = {{32{imm32_s[31]}}, imm32_s};
wire    [XL:0]  sext_imm32_j = {{32{imm32_j[31]}}, imm32_j};

wire    major_op_load        = s1_instr[6:0] == 7'b0000011;
wire    major_op_store       = s1_instr[6:0] == 7'b0100011;
wire    major_op_branch      = s1_instr[6:0] == 7'b1100011;
wire    major_op_imm         = s1_instr[6:0] == 7'b0010011;

wire    use_imm_sext_imm32_u = dec_lui      || dec_auipc        ;

wire    use_imm_sext_imm32_i = dec_jalr     || major_op_load    ||
                               major_op_imm || dec_addiw        ;

wire    use_imm_shamt        = dec_slli     || dec_srli         ||
                               dec_slliw    || dec_srliw        ||
                               dec_srai     || dec_sraiw        ||
                               dec_c_slli   || dec_c_srli       ||
                               dec_c_srai   ;

wire    use_imm_c_addi      = dec_c_addi    || dec_c_addiw      ||
                              dec_c_li      || dec_c_andi       ;

wire    use_imm_c_lsw       = dec_c_lw      || dec_c_sw         ;

wire    use_imm_c_lsd       = dec_c_ld      || dec_c_sd         ;

wire    use_imm_c_j         = dec_c_j                           ;

wire    [ 5:0] imm_c_shamt  = {s1_instr[12],s1_instr[6:2]};
wire    [XL:0] imm_shamt    = {58'b0, s1_i16bit ? imm_c_shamt : {1'b0,dec_shamtw}};

assign s2_imm =
    cf_offset_cbeq_imm      ? {{32{imm_c_bz[31]}}, imm_c_bz    } :
    cfu_op_conditonal       ? {{32{imm32_b[31]}} , imm32_b     } :
    use_imm_sext_imm32_u    ? sext_imm32_u  :
    use_imm_sext_imm32_i    ? sext_imm32_i  :
    major_op_store          ? sext_imm32_s  :
    use_imm_shamt           ? imm_shamt     :
    dec_c_lui               ? {{32{imm_c_lui[31]}}, imm_c_lui      } :
    dec_c_addi4spn          ? {{32{imm_addi4spn[31]}}, imm_addi4spn} :
    dec_c_addi16sp          ? {{32{imm_addi16sp[31]}}, imm_addi16sp} :
    use_imm_c_addi          ? {{32{imm_c_addi[31]}}, imm_c_addi} :
    use_imm_c_j             ? {{32{imm_c_j   [31]}}, imm_c_j   } :
    dec_c_lwsp              ? {32'b0, imm_c_lwsp} :
    dec_c_swsp              ? {32'b0, imm_c_swsp} :
    use_imm_c_lsw           ? {32'b0, imm_c_lsw } :
    dec_c_ldsp              ? {32'b0, imm_c_ldsp} :
    dec_c_sdsp              ? {32'b0, imm_c_sdsp} :
    use_imm_c_lsd           ? {32'b0, imm_c_lsd } :
    dec_jal                 ? sext_imm32_j  :
                              0             ;

assign s2_csr_addr          = s1_instr[31:20];

//
// Register Address Decoding
// -------------------------------------------------------------------------

// Source register 1, given a 16-bit instruction
wire [4:0] dec_rs1_16 = 
    {5{dec_c_add     }} & {s1_instr[11:7]      } |
    {5{dec_c_addi    }} & {s1_instr[11:7]      } |
    {5{dec_c_addiw   }} & {s1_instr[11:7]      } |
    {5{dec_c_jalr    }} & {s1_instr[11:7]      } |
    {5{dec_c_jr      }} & {s1_instr[11:7]      } |
    {5{dec_c_slli    }} & {s1_instr[11:7]      } |
    {5{dec_c_swsp    }} & {REG_SP            } |
    {5{dec_c_sdsp    }} & {REG_SP            } |
    {5{dec_c_addi16sp}} & {REG_SP            } |
    {5{dec_c_addi4spn}} & {REG_SP            } |
    {5{dec_c_lwsp    }} & {REG_SP            } |
    {5{dec_c_ldsp    }} & {REG_SP            } |
    {5{dec_c_and     }} & {2'b01, s1_instr[9:7]} |
    {5{dec_c_andi    }} & {2'b01, s1_instr[9:7]} |
    {5{dec_c_beqz    }} & {2'b01, s1_instr[9:7]} |
    {5{dec_c_bnez    }} & {2'b01, s1_instr[9:7]} |
    {5{dec_c_lw      }} & {2'b01, s1_instr[9:7]} |
    {5{dec_c_ld      }} & {2'b01, s1_instr[9:7]} |
    {5{dec_c_or      }} & {2'b01, s1_instr[9:7]} |
    {5{dec_c_srai    }} & {2'b01, s1_instr[9:7]} |
    {5{dec_c_srli    }} & {2'b01, s1_instr[9:7]} |
    {5{dec_c_sub     }} & {2'b01, s1_instr[9:7]} |
    {5{dec_c_addw    }} & {2'b01, s1_instr[9:7]} |
    {5{dec_c_subw    }} & {2'b01, s1_instr[9:7]} |
    {5{dec_c_sw      }} & {2'b01, s1_instr[9:7]} |
    {5{dec_c_sd      }} & {2'b01, s1_instr[9:7]} |
    {5{dec_c_xor     }} & {2'b01, s1_instr[9:7]} ;
    
// Source register 2, given a 16-bit instruction
wire [4:0] dec_rs2_16 = 
    {5{dec_c_beqz    }} & {       REG_ZERO   } |
    {5{dec_c_bnez    }} & {       REG_ZERO   } |
    {5{dec_c_add     }} & {       s1_instr[6:2]} |
    {5{dec_c_mv      }} & {       s1_instr[6:2]} |
    {5{dec_c_swsp    }} & {       s1_instr[6:2]} |
    {5{dec_c_sdsp    }} & {       s1_instr[6:2]} |
    {5{dec_c_and     }} & {2'b01, s1_instr[4:2]} |
    {5{dec_c_or      }} & {2'b01, s1_instr[4:2]} |
    {5{dec_c_sub     }} & {2'b01, s1_instr[4:2]} |
    {5{dec_c_addw    }} & {2'b01, s1_instr[4:2]} |
    {5{dec_c_subw    }} & {2'b01, s1_instr[4:2]} |
    {5{dec_c_sw      }} & {2'b01, s1_instr[4:2]} |
    {5{dec_c_sd      }} & {2'b01, s1_instr[4:2]} |
    {5{dec_c_xor     }} & {2'b01, s1_instr[4:2]} ;

// Destination register, given a 16-bit instruction
wire [4:0] dec_rd_16 = 
    {5{dec_c_addi16sp}} & {REG_SP} |
    {5{dec_c_addi4spn}} & {2'b01, s1_instr[4:2]} |
    {5{dec_c_and     }} & {2'b01, s1_instr[9:7]} |
    {5{dec_c_andi    }} & {2'b01, s1_instr[9:7]} |
    {5{dec_c_jalr    }} & {REG_RA} |
    {5{dec_c_add     }} & {s1_instr[11:7]} |
    {5{dec_c_addi    }} & {s1_instr[11:7]} |
    {5{dec_c_addiw   }} & {s1_instr[11:7]} |
    {5{dec_c_li      }} & {s1_instr[11:7]} |
    {5{dec_c_lui     }} & {s1_instr[11:7]} |
    {5{dec_c_lwsp    }} & {s1_instr[11:7]} |
    {5{dec_c_ldsp    }} & {s1_instr[11:7]} |
    {5{dec_c_mv      }} & {s1_instr[11:7]} |
    {5{dec_c_slli    }} & {s1_instr[11:7]} |
    {5{dec_c_lw      }} & {2'b01, s1_instr[4:2]} |
    {5{dec_c_ld      }} & {2'b01, s1_instr[4:2]} |
    {5{dec_c_or      }} & {2'b01, s1_instr[9:7]} |
    {5{dec_c_srai    }} & {2'b01, s1_instr[9:7]} |
    {5{dec_c_srli    }} & {2'b01, s1_instr[9:7]} |
    {5{dec_c_sub     }} & {2'b01, s1_instr[9:7]} |
    {5{dec_c_addw    }} & {2'b01, s1_instr[9:7]} |
    {5{dec_c_subw    }} & {2'b01, s1_instr[9:7]} |
    {5{dec_c_xor     }} & {2'b01, s1_instr[9:7]} ;

assign s1_rs1_addr  = s1_i16bit     ? dec_rs1_16 : dec_rs1 ;
assign s1_rs2_addr  = s1_i16bit     ? dec_rs2_16 : dec_rs2 ;

assign s2_rs1_addr  = s1_rs1_addr;
assign s2_rs2_addr  = s1_rs2_addr;

wire   zero_rd      = major_op_store || major_op_branch;

assign s2_rd        = s1_i16bit     ? dec_rd_16         :
                      zero_rd       ? {REG_ADDR_W{1'b0}}:
                                      dec_rd            ;

assign s2_rs1_data  = s1_rs1_data   ;
assign s2_rs2_data  = s1_rs2_data   ;


//
// Uop decoding.
// ------------------------------------------------------------

//
// ALU

wire    alu_rhs_imm = dec_addi          || dec_addiw        ||
                      dec_slli          || dec_slliw        ||
                      dec_srli          || dec_srliw        ||
                      dec_srai          || dec_sraiw        ||
                      dec_andi          || dec_ori          ||
                      dec_xori          || dec_lui          ||
                      dec_auipc         || dec_c_addi       ||
                      dec_c_addi4spn    || dec_c_addiw      ||
                      dec_c_addi16sp    || dec_c_andi       ||
                      dec_c_slli        || dec_c_srli       ||
                      dec_c_srai        || dec_c_li         ||
                      dec_c_lui         || dec_slti         ||
                      dec_sltiu         ;

assign  s2_alu_lhs  = dec_auipc     ? s2_pc  : s2_rs1_data  ;

assign  s2_alu_rhs  = alu_rhs_imm   ? s2_imm : s2_rs2_data  ;

assign  s2_alu_add  = dec_add           || dec_addi          ||
                      dec_addiw         || dec_addw          ||
                      dec_auipc         || dec_c_add         ||
                      dec_c_addi        || dec_c_addi4spn    ||
                      dec_c_addiw       || dec_c_addw        ||
                      dec_c_addi16sp    ;

assign  s2_alu_and  = dec_and           || dec_andi          ||
                      dec_c_and         || dec_c_andi        ;

assign  s2_alu_or   = dec_c_li          || dec_c_lui         ||
                      dec_c_mv          || dec_c_or          ||
                      dec_lui           || dec_or            ||
                      dec_ori           ;

assign  s2_alu_sll  = dec_c_slli        || dec_sll           ||
                      dec_slli          || dec_slliw         ||
                      dec_sllw          ;
                      
assign  s2_alu_slt  = dec_slti          || dec_slt           ;

assign  s2_alu_sltu = dec_sltiu         || dec_sltu          ;

assign  s2_alu_sra  = dec_c_srai        || dec_sra           ||
                      dec_srai          || dec_sraiw         ||
                      dec_sraw          ;

assign  s2_alu_srl  = dec_c_srli        || dec_srl           ||
                      dec_srli          || dec_srliw         ||
                      dec_srlw          ;

assign  s2_alu_sub  = dec_beq           || dec_c_beqz        ||
                      dec_bge           || dec_c_bnez        ||
                      dec_bgeu          || dec_c_sub         ||
                      dec_blt           || dec_c_subw        ||
                      dec_bltu          || dec_sub           ||
                      dec_bne           || dec_subw          ;

assign  s2_alu_xor  = dec_c_xor         || dec_xor           ||
                      dec_xori          ;

assign  s2_alu_word = dec_addiw         || dec_addw         ||
                      dec_slliw         || dec_sllw         ||
                      dec_srliw         || dec_srlw         ||
                      dec_sraiw         || dec_sraw         ||
                      dec_subw          || dec_c_subw       ||
                      dec_c_addiw       || dec_c_addw       ;

//
// CFU

assign  s2_cfu_beq  = dec_beq    || dec_c_beqz  ;
assign  s2_cfu_bge  = dec_bge                   ;
assign  s2_cfu_bgeu = dec_bgeu                  ;
assign  s2_cfu_blt  = dec_blt                   ;
assign  s2_cfu_bltu = dec_bltu                  ;
assign  s2_cfu_bne  = dec_bne    || dec_c_bnez  ;
assign  s2_cfu_ebrk = dec_ebreak                ;
assign  s2_cfu_ecall= dec_ecall                 ;
assign  s2_cfu_j    = dec_c_j                   ;
assign  s2_cfu_jal  = dec_jal                   ;
assign  s2_cfu_jalr = dec_jalr   || dec_c_jalr  || dec_c_jr;
assign  s2_cfu_mret = dec_mret                  ;

//
// LSU

assign  s2_lsu_load = dec_lb    || dec_lbu  || dec_lh   || dec_lhu      ||
                      dec_lw    || dec_lwu  || dec_ld   || dec_c_lwsp   ||
                      dec_c_lw  || dec_c_ldsp || dec_c_ld;

assign  s2_lsu_store= dec_sb        || dec_sh   || dec_sw     || dec_sd   || 
                      dec_c_swsp    || dec_c_sw || dec_c_sdsp || dec_c_sd ;

assign  s2_lsu_byte = dec_lb    || dec_lbu  || dec_sb;

assign  s2_lsu_half = dec_lh    || dec_lhu  || dec_sh;

assign  s2_lsu_word = dec_lw    || dec_lwu  || dec_sw   || dec_c_lwsp   ||
                      dec_c_swsp;

assign  s2_lsu_dbl  = dec_ld    || dec_sd   || dec_c_ldsp || dec_c_sdsp ;

assign  s2_lsu_sext = dec_lw    || dec_lh   || dec_lb   ;

//
// MDU

assign  s2_mdu_mul    = dec_mul   ;
assign  s2_mdu_mulh   = dec_mulh  ;
assign  s2_mdu_mulhsu = dec_mulhsu;
assign  s2_mdu_mulhu  = dec_mulhu ;
assign  s2_mdu_div    = dec_div   ;
assign  s2_mdu_divu   = dec_divu  ;
assign  s2_mdu_rem    = dec_rem   ;
assign  s2_mdu_remu   = dec_remu  ;
assign  s2_mdu_mulw   = dec_mulw  ;
assign  s2_mdu_divw   = dec_divw  ;
assign  s2_mdu_divuw  = dec_divuw ;
assign  s2_mdu_remw   = dec_remw  ;
assign  s2_mdu_remuw  = dec_remuw ;

//
// CSRs

assign  s2_csr_set    = dec_csrrsi || dec_csrrs ;
assign  s2_csr_clr    = dec_csrrsi || dec_csrrs ;
assign  s2_csr_rd     = dec_csrrsi || dec_csrrs || dec_csrrw || dec_csrrwi;
assign  s2_csr_wr     = dec_csrrsi || dec_csrrs || dec_csrrw || dec_csrrwi;

//
// Writeback data selection

assign  s2_wb_alu     = !s2_wb_npc && !cfu_op_conditonal && (
    s2_alu_add      || s2_alu_and      || s2_alu_or       || s2_alu_sll ||
    s2_alu_srl      || s2_alu_slt      || s2_alu_sltu     || s2_alu_sra ||
    s2_alu_sub      || s2_alu_xor      || s2_alu_word     );

assign  s2_wb_csr     = s2_csr_rd   ;

assign  s2_wb_mdu     = 
    s2_mdu_mul      || s2_mdu_mulh     || s2_mdu_mulhsu   || s2_mdu_mulhu ||
    s2_mdu_div      || s2_mdu_divu     || s2_mdu_rem      || s2_mdu_remu  ||
    s2_mdu_mulw     || s2_mdu_divw     || s2_mdu_divuw    || s2_mdu_remw  ||
    s2_mdu_remuw    ;

assign  s2_wb_lsu     = s2_lsu_load ;

assign  s2_wb_npc     = s2_cfu_jal  || s2_cfu_jalr;


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
.imm_c_lwsp   (imm_c_lwsp   ),
.imm_c_swsp   (imm_c_swsp   ),
.imm_c_lsd    (imm_c_lsd    ),
.imm_c_ldsp   (imm_c_ldsp   ),
.imm_c_sdsp   (imm_c_sdsp   ),
.imm_c_j      (imm_c_j      ),
.imm_c_bz     (imm_c_bz     ) 
);

endmodule

