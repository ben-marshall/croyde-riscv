
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
input  wire [         XL:0] csr_rdata   , // CSR read data
input  wire                 csr_error   , // CSR access error.

input  wire [         XL:0] csr_mepc    , // Current MEPC  value
input  wire [         XL:0] csr_mtvec   , // Current MTVEC value

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

// New instruction will arrive on the next cycle.
wire    e_new_instr = s2_valid && s2_ready;

// Control flow change occured this cycle.
wire    e_cf_change = s2_cf_valid && s2_cf_ack;


//
// ALU Interfacing
// ------------------------------------------------------------

wire [    XL:0] alu_opr_a   = s2_opr_a                   ;
wire [    XL:0] alu_opr_b   = s2_opr_b                   ;

wire            alu_word    = s2_op_w && !lsu_valid      ;

wire            alu_op_nop  = s2_alu_op == ALU_OP_NOP    ;
wire            alu_op_add  = s2_alu_op == ALU_OP_ADD    ;
wire            alu_op_sub  = s2_alu_op == ALU_OP_SUB    ;
wire            alu_op_xor  = s2_alu_op == ALU_OP_XOR    ;
wire            alu_op_or   = s2_alu_op == ALU_OP_OR     ;
wire            alu_op_and  = s2_alu_op == ALU_OP_AND    ;
wire            alu_op_slt  = s2_alu_op == ALU_OP_SLT    ;
wire            alu_op_sltu = s2_alu_op == ALU_OP_SLTU   ;
wire            alu_op_srl  = s2_alu_op == ALU_OP_SRL    ;
wire            alu_op_sll  = s2_alu_op == ALU_OP_SLL    ;
wire            alu_op_sra  = s2_alu_op == ALU_OP_SRA    ;

wire            alu_cmp_eq  ;
wire            alu_cmp_lt  ;

wire [    XL:0] alu_add_out ;
wire [    XL:0] alu_result  ;

wire            alu_gpr_wen = !alu_op_nop && cfu_op_nop;

// ALU only ever takes one cycle.
wire            op_done_alu = 1'b1;

//
// Load Store Unit Interfacing.
// ------------------------------------------------------------

wire        lsu_done            = 1'b0                      ;

wire        lsu_nop             =  s2_lsu_op == 0           ;

wire        lsu_valid           = s2_valid && |s2_lsu_op && !lsu_done;
wire [XL:0] lsu_addr            = alu_add_out               ;
wire [XL:0] lsu_wdata           =  s2_opr_c                 ;
wire        lsu_load            = !s2_lsu_op[  4]           ;
wire        lsu_store           =  s2_lsu_op[  4]           ;
wire        lsu_double          =  s2_lsu_op[3:1] == 3'd4   ;
wire        lsu_word            =  s2_lsu_op[3:1] == 3'd3   ;
wire        lsu_half            =  s2_lsu_op[3:1] == 3'd2   ;
wire        lsu_byte            =  s2_lsu_op[3:1] == 3'd1   ;
wire        lsu_sext            =  s2_lsu_op[  0]           ;

wire        lsu_ready           ; // Read data ready
wire        lsu_trap_bus        ; // Bus error
wire        lsu_trap_addr       ; // Address alignment error
wire [XL:0] lsu_rdata           ; // Read data

wire        lsu_gpr_wen         = lsu_ready && lsu_load;
wire [XL:0] lsu_gpr_wdata       = lsu_rdata ;

wire        op_done_lsu         =
    lsu_nop || lsu_done || (lsu_valid && lsu_ready);

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
wire    cfu_op_always_done  = cfu_op_j      || cfu_op_jal   || cfu_op_mret  ||
                              cfu_op_ebreak || cfu_op_ecall ;

// Conditional control flow changes.
wire    cfu_conditional     = cfu_op_beq    || cfu_op_bne   || cfu_op_blt   ||
                              cfu_op_bltu   || cfu_op_bge   || cfu_op_bgeu  ;

wire    cfu_op_blt_taken    = cfu_op_blt    &&  alu_cmp_lt;
wire    cfu_op_bltu_taken   = cfu_op_bltu   &&  alu_cmp_lt;
wire    cfu_op_bge_taken    = cfu_op_bge    && !alu_cmp_lt;
wire    cfu_op_bgeu_taken   = cfu_op_bgeu   && !alu_cmp_lt;

wire [XL:0] cfu_bcmp_taret  = s2_pc + s2_opr_c;

// Is a conditional branch taken?
wire    cfu_cond_taken      =
    cfu_op_beq &&  alu_cmp_eq   ||
    cfu_op_bne && !alu_cmp_eq   ||
    cfu_op_blt_taken            ||
    cfu_op_bltu_taken           ||
    cfu_op_bge_taken            ||
    cfu_op_bgeu_taken           ;

wire    cfu_not_taken       = cfu_conditional && !cfu_cond_taken;

// Jump directly to the EPC register
wire    cfu_goto_mepc       = cfu_op_mret                           ;

// Jump directly to the MTVEC CSR register
wire    cfu_goto_mtvec      = cfu_op_ecall  || cfu_op_ebreak        ;

// Has the CFU finished executing it's given instruction.
wire    op_done_cfu         = cfu_op_nop    || cfu_op_always_done   ||
                              cfu_cond_taken&& (e_cf_change || cf_done)||
                              cfu_not_taken ;

// Does the CFU need to write anything back to the GPRs?
// - Only on a jump and link instruction.
wire        cfu_gpr_wen     = cfu_op_jal;
wire [XL:0] cfu_gpr_wdata   = s2_opr_c  ;

//
// Exception condition raising
// ------------------------------------------------------------

wire excep_csr_error        = csr_error && csr_en   ;

wire excep_cfu_bad_target   = 1'b0                  ;

wire excep_ecall            = cfu_op_ecall          ;

wire excep_ebreak           = cfu_op_ebreak         ;


wire cf_excep   = excep_csr_error || excep_cfu_bad_target   ||
                  excep_ecall     || excep_ebreak           ;

//
// Control flow bus
// ------------------------------------------------------------

// Control flow change completed for the current instruction. Used to
// stop accidentially triggering multiple CF changes to the same address.
reg       cf_done ;
wire    n_cf_done = e_new_instr ? 1'b0 : cf_done || e_cf_change;

always @(posedge g_clk) begin
    if(!g_resetn) begin
        cf_done <= 1'b0;
    end else begin
        cf_done <= n_cf_done;
    end
end

assign  s2_cf_valid         =
    (cf_excep || cfu_cond_taken || cfu_op_always_done) && !cf_done;

assign  s2_cf_target        = 
    cfu_goto_mepc       ?   csr_mepc        :
    cfu_conditional     ?   cfu_bcmp_taret  :
    cfu_op_always_done  ?   alu_add_out     :
                            csr_mtvec       ;

assign  s2_cf_cause         = 0     ;   // TODO

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
assign  csr_wdata   =  s2_opr_a                         ;

wire    op_done_csr = csr_op_nop || csr_en              ;

// Does the CSR FU need to write anything back to the GPRs?
wire        csr_gpr_wen     = csr_read_en && !csr_error ;
wire [XL:0] csr_gpr_wdata   = csr_rdata;

//
// Is the stage ready for a new instruction?
// ------------------------------------------------------------

assign  s2_ready    = op_done_csr && op_done_cfu &&
                      op_done_alu && op_done_lsu ;

//
// GPR Writeback
// ------------------------------------------------------------

// GPR Writeback completed for the current instruction. Used to
// stop accidentially triggering multiple writebacks for the same instruction
reg       rd_done ;
wire    n_rd_done = e_new_instr ? 1'b0 : rd_done || s2_rd_wen;

always @(posedge g_clk) begin
    if(!g_resetn) begin
        rd_done <= 1'b0;
    end else begin
        rd_done <= n_rd_done;
    end
end

assign s2_rd_addr   = s2_rd;

assign s2_rd_wen    = !rd_done && (
    cfu_gpr_wen || csr_gpr_wen || alu_gpr_wen || lsu_gpr_wen
);

assign s2_rd_wdata  = {XLEN{cfu_gpr_wen}} & cfu_gpr_wdata   |
                      {XLEN{csr_gpr_wen}} & csr_gpr_wdata   |
                      {XLEN{lsu_gpr_wen}} & lsu_gpr_wdata   |
                      {XLEN{alu_gpr_wen}} & alu_result      ;

//
// Submodule Instances
// ------------------------------------------------------------


//
// instance: core_pipe_exec_alu
//
//  Integer ALU module
//
core_pipe_exec_alu i_core_pipe_exec_alu (
.opr_a   (alu_opr_a   ), // Input operand A
.opr_b   (alu_opr_b   ), // Input operand B
.word    (alu_word    ), // Operate on low 32-bits of XL.
.op_add  (alu_op_add  ), // Select output of adder
.op_sub  (alu_op_sub  ), // Subtract opr_a from opr_b else add
.op_xor  (alu_op_xor  ), // Select XOR operation result
.op_or   (alu_op_or   ), // Select OR
.op_and  (alu_op_and  ), //        AND
.op_slt  (alu_op_slt  ), // Set less than
.op_sltu (alu_op_sltu ), //                Unsigned
.op_srl  (alu_op_srl  ), // Shift right logical
.op_sll  (alu_op_sll  ), // Shift left logical
.op_sra  (alu_op_sra  ), // Shift right arithmetic
.add_out (alu_add_out ), // Result of adding opr_a and opr_b
.cmp_eq  (alu_cmp_eq  ), // Does opr_a == opr_b
.cmp_lt  (alu_cmp_lt  ), // Does opr_a <  opr_b
.result  (alu_result  )  // Operation result
);


//
// instance: core_pipe_exec_lsu
//
//  Responsible for all data memory accesses
//
core_pipe_exec_lsu i_core_pipe_exec_lsu (
.g_clk      (g_clk        ), // Global clock enable.
.g_resetn   (g_resetn     ), // Global synchronous reset
.valid      (lsu_valid    ), // Inputs are valid
.addr       (lsu_addr     ), // Address.
.wdata      (lsu_wdata    ), // Data being written (if any)
.load       (lsu_load     ), //
.store      (lsu_store    ), //
.d_double   (lsu_double   ), //
.d_word     (lsu_word     ), //
.d_half     (lsu_half     ), //
.d_byte     (lsu_byte     ), //
.sext       (lsu_sext     ), // Sign extend read data
.ready      (lsu_ready    ), // Read data ready
.trap_bus   (lsu_trap_bus ), // Bus error
.trap_addr  (lsu_trap_addr), // Address alignment error
.rdata      (lsu_rdata    ), // Read data
.dmem_req   (dmem_req     ), // Memory request
.dmem_addr  (dmem_addr    ), // Memory request address
.dmem_wen   (dmem_wen     ), // Memory request write enable
.dmem_strb  (dmem_strb    ), // Memory request write strobe
.dmem_wdata (dmem_wdata   ), // Memory write data.
.dmem_gnt   (dmem_gnt     ), // Memory response valid
.dmem_err   (dmem_err     ), // Memory response error
.dmem_rdata (dmem_rdata   )  // Memory response read data
);

endmodule
