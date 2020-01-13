
//
// Module: core_pipe_decode
//
//  Pipeline decode / operand gather stage.
//
module core_pipe_decode (

input  wire                 g_clk       , // Global clock
input  wire                 g_resetn    , // Global active low sync reset.

input  wire                 s1_16bit    , // 16 bit instruction?
input  wire                 s1_32bit    , // 32 bit instruction?
input  wire [  FD_IBUF_R:0] s1_instr    , // Instruction to be decoded
input  wire [         XL:0] s1_pc       , // Program Counter
input  wire [         XL:0] s1_npc      , // Next Program Counter
input  wire [   FD_ERR_R:0] s1_ferr     , // Fetch bus error?
output wire                 s2_eat_2    , // Decode eats 2 bytes
output wire                 s2_eat_4    , // Decode eats 4 bytes

output wire [ REG_ADDR_R:0] s2_rs1_addr , // RS1 Address
input  wire [         XL:0] s2_rs1_data , // RS1 Read Data (Forwarded)
output wire [ REG_ADDR_R:0] s2_rs2_addr , // RS2 Address
input  wire [         XL:0] s2_rs2_data , // RS2 Read Data (Forwarded)

output reg  [         XL:0] s2_opr_a    ,
output reg  [         XL:0] s2_opr_b    ,
output reg  [         XL:0] s2_opr_c    ,
output reg  [ REG_ADDR_R:0] s2_rd        

);

// Common parameters and width definitions.
`include "core_common.vh"

// Generated decoder
`include "core_pipe_decode.vh"

//
// Next pipeline stage value selection
// ------------------------------------------------------------

wire [         XL:0] n_s2_opr_a     ;
wire [         XL:0] n_s2_opr_b     ;
wire [         XL:0] n_s2_opr_c     ;
wire [ REG_ADDR_R:0] n_s2_rd        ;

wire [         XL:0] opr_b_imm      ;
wire [         XL:0] opr_c_imm      ;

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

wire sel_opr_a_pc  = 
    dec_jal       || dec_c_jal     || dec_c_j       || dec_auipc     ;

wire sel_opr_b_rs2 =
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

wire sel_opr_b_imm =
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

wire sel_opr_c_imm =
    dec_beq       || dec_bne       || dec_c_beqz    || dec_c_bnez    ||
    dec_blt       || dec_bge       || dec_bltu      || dec_bgeu      ||
    dec_csrrw     || dec_csrrs     || dec_csrrc     || dec_csrrwi    ||
    dec_csrrsi    || dec_csrrci    ;

wire sel_opr_c_npc =
    dec_jalr      || dec_jal       || dec_c_jal     || dec_fence_i   ;

wire sel_opr_c_rs2 =
    dec_sb        || dec_sh        || dec_sw        || dec_c_sw      ||
    dec_sd        || dec_c_lwsp    || dec_c_swsp    ;


assign n_s2_opr_a =
    {64{sel_opr_a_rs1}} & s2_rs1_data |
    {64{sel_opr_a_pc }} & s1_pc       ;

assign n_s2_opr_b =
    {64{sel_opr_b_rs2}} & s2_rs2_data |
    {64{sel_opr_b_imm}} & opr_b_imm   ;

assign n_s2_opr_c =
    {64{sel_opr_c_rs2}} & s2_rs2_data |
    {64{sel_opr_c_imm}} & opr_c_imm   |
    {64{sel_opr_c_npc}} & s1_npc      ;

assign n_s2_rd    = dec_rd;

assign s2_eat_2 = s1_16bit;
assign s2_eat_4 = s1_32bit;


endmodule

