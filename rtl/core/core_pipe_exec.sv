
//
// Module: core_pipe_exec
//
//  Top level for the execute stage of the pipeline.
//
module core_pipe_exec (

input  wire                 g_clk       , // Global clock
input  wire                 g_resetn    , // Global active low sync reset.

output wire                 cf_valid    , // Control flow change?
output wire                 cf_ack      , // Control flow change acknwoledged
output wire [         XL:0] cf_target   , // Control flow change destination
output wire [ CF_CAUSE_R:0] cf_cause      // Control flow change cause

input  wire [         XL:0] s2_rs1_data     , // RS1 value
input  wire [         XL:0] s2_rs2_data     , // RS2 value
input  wire [ REG_ADDR_R:0] s2_rd           , // Destination reg address.
input  wire [         XL:0] s2_imm          , // Immediate value
input  wire [         XL:0] s2_pc           , // Current program counter.
input  wire [         XL:0] s2_npc          , // Next    program counter.
input  wire [         31:0] s2_instr        , // Current instruction word.
input  wire                 s2_trap         , // Raise a trap

input  wire                 s2_alu_lhs      , // ALU left  operand
input  wire                 s2_alu_rhs      , // ALU right operand
input  wire                 s2_alu_add      , // ALU Operation to perform.
input  wire                 s2_alu_and      , // 
input  wire                 s2_alu_or       , // 
input  wire                 s2_alu_sll      , // 
input  wire                 s2_alu_srl      , // 
input  wire                 s2_alu_slt      , // 
input  wire                 s2_alu_sltu     , // 
input  wire                 s2_alu_sra      , // 
input  wire                 s2_alu_sub      , // 
input  wire                 s2_alu_xor      , // 
input  wire                 s2_alu_word     , // Word result only.

input  wire                 s2_cfu_beq      , // Control flow operation.
input  wire                 s2_cfu_bge      , //
input  wire                 s2_cfu_bgeu     , //
input  wire                 s2_cfu_blt      , //
input  wire                 s2_cfu_bltu     , //
input  wire                 s2_cfu_bne      , //
input  wire                 s2_cfu_ebrk     , //
input  wire                 s2_cfu_ecall    , //
input  wire                 s2_cfu_j        , //
input  wire                 s2_cfu_jal      , //
input  wire                 s2_cfu_jalr     , //
input  wire                 s2_cfu_mret     , //

input  wire                 s2_lsu_load     , // LSU Load
input  wire                 s2_lsu_store    , // "   Store
input  wire                 s2_lsu_byte     , // Byte width
input  wire                 s2_lsu_half     , // Halfword width
input  wire                 s2_lsu_word     , // Word width
input  wire                 s2_lsu_dbl      , // Doubleword widt
input  wire                 s2_lsu_sext     , // Sign extend loaded value.

input  wire                 s2_mdu_mul      , // MDU Operation
input  wire                 s2_mdu_mulh     , //
input  wire                 s2_mdu_mulhsu   , //
input  wire                 s2_mdu_mulhu    , //
input  wire                 s2_mdu_div      , //
input  wire                 s2_mdu_divu     , //
input  wire                 s2_mdu_rem      , //
input  wire                 s2_mdu_remu     , //
input  wire                 s2_mdu_mul      , //
input  wire                 s2_mdu_div      , //
input  wire                 s2_mdu_divu     , //
input  wire                 s2_mdu_rem      , //
input  wire                 s2_mdu_remu     , //

input  wire                 s2_csr_set      , // CSR Operation
input  wire                 s2_csr_clr      , //
input  wire                 s2_csr_rd       , //
input  wire                 s2_csr_wr       , //

input  wire                 s2_wb_alu       , // Writeback ALU result
input  wire                 s2_wb_csr       , // Writeback CSR result
input  wire                 s2_wb_mdu       , // Writeback MDU result
input  wire                 s2_wb_lsu       , // Writeback LSU Loaded data
input  wire                 s2_wb_npc       , // Writeback next PC value

output reg  [         XL:0] s3_pc           , // Writeback stage PC
output reg  [         31:0] s3_instr        , // Writeback stage instr word
output reg  [         XL:0] s3_wdata        , // Writeback stage instr word
output reg  [ REG_ADDR_R:0] s3_rd           , // Writeback stage instr word
output reg  [   LSU_OP_R:0] s3_lsu_op       , // Writeback LSU op
output reg  [   CSR_OP_R:0] s3_csr_op       , // Writeback CSR op
output reg  [   CFU_OP_R:0] s3_cfu_op       , // Writeback CFU op
output reg  [    WB_OP_R:0] s3_wb_op        , // Writeback Data source.
output reg                  s3_trap           // Raise a trap

);

// Common parameters and width definitions.
`include "core_common.svh"

//
// Events
// ------------------------------------------------------------

// New instruction will arrive on the next cycle.
wire    e_new_instr = s2_valid && s2_ready;

// Old instruction retired.
wire    e_iret      = e_new_instr && s2_full;



endmodule
