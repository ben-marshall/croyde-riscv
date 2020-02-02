
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



endmodule
