
//
// Module: core_pipe_exec_cfu
//
//  Control flow unit. Responsible for branching etc.
//
module core_pipe_exec_cfu (

input  wire                 g_clk       ,
input  wire                 g_resetn    ,

input  wire                 new_instr   , // Being fed a new instruction.

input  wire                 cmp_eq      ,
input  wire                 cmp_lt      ,
input  wire                 cmp_ltu     ,

input  wire                 valid       , // Inputs are valid.

input  wire [        XL:0]  pc          , // Current program counter
input  wire [        XL:0]  npc         , // Next natural program counter
input  wire [        XL:0]  rs1         , // Source register 1
input  wire [        XL:0]  offset      , // Branch offset

input  wire                 cfu_beq     , // Control flow operation.
input  wire                 cfu_bge     , //
input  wire                 cfu_bgeu    , //
input  wire                 cfu_blt     , //
input  wire                 cfu_bltu    , //
input  wire                 cfu_bne     , //
input  wire                 cfu_ebrk    , //
input  wire                 cfu_ecall   , //
input  wire                 cfu_j       , //
input  wire                 cfu_jal     , //
input  wire                 cfu_jalr    , //
input  wire                 cfu_mret    , //

output wire                 cf_valid    , // Control flow change?
input  wire                 cf_ack      , // Control flow acknwoledged
output wire [         XL:0] cf_target   , // Control flow destination

output wire [         XL:0] new_pc      , // New program counter
output wire [   CFU_OP_R:0] new_op      , // New operation to perform in wb.
output wire [         XL:0] rd_wdata    , // Data for register writeback
output wire                 rd_wen      , // Writeback enable
output wire                 trap_raise  , // Raise a trap.
output wire [          6:0] trap_cause  , // Cause of the trap.
output wire                 finished      // CFU instruction finished.

);

// Common parameters and width definitions.
`include "core_common.svh"

//
// MISC Useful signals
// ------------------------------------------------------------

wire    branch_conditional  = cfu_beq   || cfu_bge  || cfu_bgeu ||
                              cfu_blt   || cfu_bltu || cfu_bne  ;

wire    branch_always       = cfu_j     || cfu_jal  || cfu_jalr ||
                              cfu_mret  || cfu_ebrk || cfu_ecall;

//
// Compute branch target address
// ------------------------------------------------------------

wire    [XL:0]  target_lhs  = cfu_jalr   ? rs1   : pc;

wire    [XL:0]  target_addr = target_lhs + offset;

//
// Raise a trap?
// ------------------------------------------------------------

wire    target_misaligned   = target_addr[0] && !cfu_jalr;

assign  trap_raise          = cfu_ebrk  || cfu_ecall || target_misaligned;

assign  trap_cause          = cfu_ecall ? TRAP_ECALLM   :
                              cfu_ebrk  ? TRAP_BREAKPT  :
                                          TRAP_IALIGN   ;

//
// Did we take the branch?
// ------------------------------------------------------------

wire    branch_taken        =
    branch_always                   ||
    cfu_beq  &&  cmp_eq             ||
    cfu_bge  && (cmp_eq || !cmp_lt )||
    cfu_bgeu && (cmp_eq || !cmp_ltu)||
    cfu_blt  &&             cmp_lt  ||
    cfu_bltu &&             cmp_ltu ||
    cfu_bne  && !cmp_eq             ;

wire    branch_ignore       = branch_conditional && !branch_taken;

assign  new_pc              = branch_taken ? target_addr : npc;

assign  new_op              = trap_raise    ? CFU_OP_TRAP   :
                              cfu_mret      ? CFU_OP_MRET   :
                              branch_taken  ? CFU_OP_TAKEN  :
                              branch_ignore ? CFU_OP_IGNORE :
                                              CFU_OP_NOP    ;

assign  rd_wen              = !trap_raise && (cfu_jal || cfu_jalr);

assign  rd_wdata            = npc                           ;

//
// Control flow change bus handling
// ------------------------------------------------------------

reg       cf_change_done;
wire    n_cf_change_done = (cf_valid && cf_ack) || cf_change_done;

assign  finished    = n_cf_change_done || trap_raise || branch_ignore;

assign  cf_target   = target_addr;

assign  cf_valid    = branch_taken && !cf_change_done && valid;

always @(posedge g_clk) begin
    if(!g_resetn || new_instr) begin
        cf_change_done <= 1'b0;
    end else if(cf_valid && cf_ack) begin
        cf_change_done <= n_cf_change_done;
    end
end

endmodule
