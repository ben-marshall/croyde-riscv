
//
// Module: core_pipe_exec
//
//  Top level for the execute stage of the pipeline.
//
module core_pipe_exec (

input  wire                 g_clk       , // Global clock
input  wire                 g_resetn    , // Global active low sync reset.

input  wire                 s2_valid    , // Decode instr ready for execute
output wire                 s2_ready    , // Execute ready for new instr.
input  wire [         XL:0] s2_pc       , // Execute stage PC
input  wire [         XL:0] s2_opr_a    , // EX stage operand a
input  wire [         XL:0] s2_opr_b    , //    "       "     b
input  wire [         XL:0] s2_opr_c    , //    "       "     c
input  wire [ REG_ADDR_R:0] s2_rd       , // EX stage destination reg address.
input  wire [   ALU_OP_R:0] s2_alu_op   , // ALU operation
input  wire [   LSU_OP_R:0] s2_lsu_op   , // LSU operation
input  wire [   MDU_OP_R:0] s2_mdu_op   , // Mul/Div Operation
input  wire [   CSR_OP_R:0] s2_csr_op   , // CSR operation
input  wire [   CFU_OP_R:0] s2_cfu_op   , // Control flow unit operation
input  wire                 s2_op_w     , // Is the operation on a word?
input  wire [         31:0] s2_instr    , // Encoded instruction for trace.

output wire                 s2_rd_wen   , // GPR write enable
output wire [ REG_ADDR_R:0] s2_rd_addr  , // GPR write address
output wire [         XL:0] s2_rd_wdata , // GPR write data

output wire                 csr_en      , // CSR Access Enable
output wire                 csr_wr      , // CSR Write Enable
output wire                 csr_wr_set  , // CSR Write - Set
output wire                 csr_wr_clr  , // CSR Write - Clear
output wire [         11:0] csr_addr    , // Address of the CSR to access.
output wire [         XL:0] csr_wdata   , // Data to be written to a CSR
output wire [         XL:0] csr_rdata   , // CSR read data

output wire                 s2_cf_valid , // EX Control flow change?
input  wire                 s2_cf_ack   , // EX Control flow acknwoledged
output wire [         XL:0] s2_cf_target, // EX Control flow destination
output wire [ CF_CAUSE_R:0] s2_cf_cause , // EX Control flow change cause

output wire                 dmem_req    , // Memory request
output wire [ MEM_ADDR_R:0] dmem_addr   , // Memory request address
output wire                 dmem_wen    , // Memory request write enable
output wire [ MEM_STRB_R:0] dmem_strb   , // Memory request write strobe
output wire [ MEM_DATA_R:0] dmem_wdata  , // Memory write data.
input  wire                 dmem_gnt    , // Memory response valid
input  wire                 dmem_err    , // Memory response error
input  wire [ MEM_DATA_R:0] dmem_rdata    // Memory response read data

);

// Common parameters and width definitions.
`include "core_common.vh"

//
// Events
// ------------------------------------------------------------

// New instruction arrived this cycle.
wire    e_new_instr = s2_valid && s2_ready;

// Control flow change occured this cycle.
wire    e_cf_change = s2_cf_valid && s2_cf_ack;

//
// CFU Interfacing
// ------------------------------------------------------------

wire    cfu_op_nop          = s2_cfu_op     == CFU_OP_NOP   ;

wire    cfu_op_j            = s2_cfu_op     == CFU_OP_J     ;
wire    cfu_op_jal          = s2_cfu_op     == CFU_OP_JAL   ;
wire    cfu_op_beq          = s2_cfu_op     == CFU_OP_BEQ   ;
wire    cfu_op_bne          = s2_cfu_op     == CFU_OP_BNE   ;
wire    cfu_op_blt          = s2_cfu_op     == CFU_OP_BLT   ;
wire    cfu_op_bltu         = s2_cfu_op     == CFU_OP_BLTU  ;
wire    cfu_op_bge          = s2_cfu_op     == CFU_OP_BGE   ;
wire    cfu_op_bgeu         = s2_cfu_op     == CFU_OP_BGEU  ;
wire    cfu_op_mret         = s2_cfu_op     == CFU_OP_MRET  ;
wire    cfu_op_ebreak       = s2_cfu_op     == CFU_OP_EBREAK;
wire    cfu_op_ecall        = s2_cfu_op     == CFU_OP_ECALL ;

// EX stage CFU doesn't need to do any blocking for these instructions.
wire    cfu_op_always_done  = cfu_op_j      || cfu_op_jal   ;

// Conditional control flow changes.
wire    cfu_conditional     = cfu_op_beq    || cfu_op_bne   || cfu_op_blt   ||
                              cfu_op_bltu   || cfu_op_bge   || cfu_op_bgeu  ;

// Jump directly to the EPC register
wire    cfu_goto_epc        = cfu_op_mret                           ;

// Jump directly to the MTVEC CSR register
wire    cfu_goto_mtvec      = cfu_op_ecall  || cfu_op_ebreak        ;

// Has the CFU finished executing it's given instruction.
wire    op_done_cfu         = cfu_op_nop    || cfu_op_always_done   ;

// Does the CFU need to write anything back to the GPRs?
wire        cfu_gpr_wen     = 1'b0;
wire [XL:0] cfu_gpr_wdata   = 64'b0;

//
// CSR Interfacing
// ------------------------------------------------------------

wire    csr_op_nop  = s2_csr_op == CSR_OP_NOP;

//
// CSR Interface bus assignments

assign  csr_en      = |s2_csr_op                        ;
assign  csr_wr      =  s2_csr_op[CSR_OP_WR ]            ;
assign  csr_wr_set  =  s2_csr_op[CSR_OP_SET] && csr_wr  ;
assign  csr_wr_clr  =  s2_csr_op[CSR_OP_CLR] && csr_wr  ;

// Enable writeback of a read CSR value?.
wire    csr_read_en =  s2_csr_op[CSR_OP_RD ]            ;

assign  csr_addr    =  s2_opr_c[11:0]                   ;
assign  csr_wdata   =  s2_opr_b                         ;

wire    op_done_csr = csr_op_nop || csr_en              ;

// Does the CSR FU need to write anything back to the GPRs?
wire        csr_gpr_wen     = 1'b0;
wire [XL:0] csr_gpr_wdata   = csr_rdata;

//
// Is the stage ready for a new instruction?
// ------------------------------------------------------------

assign  s2_ready    = op_done_csr && op_done_cfu;

//
// GPR Writeback
// ------------------------------------------------------------

assign s2_rd_addr   = s2_rd;

assign s2_rd_wen    = cfu_gpr_wen || csr_gpr_wen;

assign s2_rd_wdata  = {64{cfu_gpr_wen}} & cfu_gpr_wdata |
                      {64{csr_gpr_wen}} & csr_gpr_wdata ;

//
// Submodule Instances
// ------------------------------------------------------------


endmodule
