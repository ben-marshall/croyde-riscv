
//
// Module: core_pipe_exec
//
//  Top level for the execute stage of the pipeline.
//
module core_pipe_exec #(
parameter F_ZKB  = 1, // Turn on Bitmanip-borrowed crypto instructions
parameter F_ZKG  = 1, // Turn on CLMUL/CLMULH
parameter F_ZKNE = 1, // Turn on NIST AES encrypt
parameter F_ZKND = 1, // Turn on NIST AES decrypt
parameter F_ZKNH = 1, // Turn on NIST SHA2 instructions
parameter F_ZKSED= 1, // Turn on ShangMi SM4 instructions
parameter F_ZKSH = 1  // Turn on ShangMi SM3 instructions
)(

input  wire                 g_clk           , // Global clock
input  wire                 g_clk_mul       , // Multiplier clock
output wire                 g_clk_mul_req   , // Multiplier clock request
input  wire                 g_resetn        , // Global active low sync reset.

output wire                 s2_cf_valid     , // Control flow change?
input  wire                 s2_cf_ack       , // Control flow acknwoledged
output wire [         XL:0] s2_cf_target    , // Control flow destination

input  wire                 s2_flush        , // Flush pipestage contents
input  wire                 s2_cancel       , // Stop S2 instrs doing stuff.
input  wire [         XL:0] csr_mepc        , // return address for mret

input  wire                 mprv_m          , // access mem as if Machine mode.
input  wire                 mprv_u          , // access mem as if User    mode.

input  wire                 wfi_sleep       , // Core asleep due to WFI?

output wire                 s2_ready        , // EX ready for new instruction
input  wire                 s2_valid        , // Decode -> EX instr valid.

input  wire [ REG_ADDR_R:0] s2_rs1_addr     , // RS1 address.
input  wire [ REG_ADDR_R:0] s2_rs2_addr     , // RS2 address.
input  wire [ REG_ADDR_R:0] s2_rd           , // Destination reg address.
input  wire [         XL:0] s2_rs1_data     , // RS1 value.
input  wire [         XL:0] s2_rs2_data     , // RS2 value.
input  wire [         XL:0] s2_imm          , // Immediate value
input  wire [         XL:0] s2_pc           , // Current program counter.
input  wire [         XL:0] s2_npc          , // Next    program counter.
input  wire [         31:0] s2_instr        , // Current instruction word.
input  wire                 s2_trap         , // Raise a trap
input  wire [          6:0] s2_trap_cause   , // Trap cause

input  wire [         XL:0] s2_alu_lhs      , // ALU left  operand
input  wire [         XL:0] s2_alu_rhs      , // ALU right operand
input  wire [          5:0] s2_alu_shamt    , // ALU Shift amount
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
input  wire                 s2_alu_xorn     , // 
input  wire                 s2_alu_andn     , // 
input  wire                 s2_alu_orn      , // 
input  wire                 s2_alu_ror      , //
input  wire                 s2_alu_rol      , //
input  wire                 s2_alu_pack     , //
input  wire                 s2_alu_packh    , //
input  wire                 s2_alu_packu    , //
input  wire                 s2_alu_grev     , //
input  wire                 s2_alu_gorc     , //
input  wire                 s2_alu_xpermn   , //
input  wire                 s2_alu_xpermb   , //
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
input  wire                 s2_cfu_wfi      , //

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
input  wire                 s2_mdu_clmul    , //
input  wire                 s2_mdu_clmulh   , //
input  wire                 s2_mdu_div      , //
input  wire                 s2_mdu_divu     , //
input  wire                 s2_mdu_rem      , //
input  wire                 s2_mdu_remu     , //
input  wire                 s2_mdu_mulw     , //
input  wire                 s2_mdu_divw     , //
input  wire                 s2_mdu_divuw    , //
input  wire                 s2_mdu_remw     , //
input  wire                 s2_mdu_remuw    , //

input  wire                 s2_cry_aeses    , // Crypto extension operations.
input  wire                 s2_cry_aesesm   ,
input  wire                 s2_cry_aesds    ,
input  wire                 s2_cry_aesdsm   ,
input  wire                 s2_cry_aesks1   ,
input  wire                 s2_cry_aesks2   ,
input  wire                 s2_cry_aesimix  ,
input  wire                 s2_cry_sha256sig0,
input  wire                 s2_cry_sha256sig1,
input  wire                 s2_cry_sha256sum0,
input  wire                 s2_cry_sha256sum1,
input  wire                 s2_cry_sha512sig0,
input  wire                 s2_cry_sha512sig1,
input  wire                 s2_cry_sha512sum0,
input  wire                 s2_cry_sha512sum1,
input  wire                 s2_cry_sm4_ed    ,
input  wire                 s2_cry_sm4_ks    ,
input  wire                 s2_cry_sm3_p0    ,
input  wire                 s2_cry_sm3_p1    ,

input  wire                 s2_csr_set      , // CSR Operation
input  wire                 s2_csr_clr      , //
input  wire                 s2_csr_rd       , //
input  wire                 s2_csr_wr       , //
input  wire [         11:0] s2_csr_addr     , // CSR Access address.

input  wire                 s2_wb_alu       , // Writeback ALU result
input  wire                 s2_wb_csr       , // Writeback CSR result
input  wire                 s2_wb_mdu       , // Writeback MDU result
input  wire                 s2_wb_lsu       , // Writeback LSU Loaded data
input  wire                 s2_wb_cry       , // Writeback crypto result.
input  wire                 s2_wb_npc       , // Writeback next PC value

output wire                 s3_valid        , // New instruction ready
input  wire                 s3_ready        , // WB ready for new instruciton.
output reg                  s3_full         , // WB has an instr in it.
output reg  [         XL:0] s3_pc           , // Writeback stage PC
output reg  [         31:0] s3_instr        , // Writeback stage instr word
output reg  [         XL:0] s3_wdata        , // Writeback stage instr word
output reg  [ REG_ADDR_R:0] s3_rd           , // Writeback stage instr word
output reg  [   LSU_OP_R:0] s3_lsu_op       , // Writeback LSU op
output reg  [   CSR_OP_R:0] s3_csr_op       , // Writeback CSR op
output reg  [         11:0] s3_csr_addr     , // CSR Address
output reg  [   CFU_OP_R:0] s3_cfu_op       , // Writeback CFU op
output reg  [    WB_OP_R:0] s3_wb_op        , // Writeback Data source.
output reg                  s3_trap         , // Raise a trap

`ifdef RVFI
output reg  [ REG_ADDR_R:0] s3_rs1_addr     ,
output reg  [ REG_ADDR_R:0] s3_rs2_addr     ,
output reg  [         XL:0] s3_rs1_rdata    ,
output reg  [         XL:0] s3_rs2_rdata    ,
output reg                  s3_dmem_valid   ,
output reg  [ MEM_ADDR_R:0] s3_dmem_addr    ,
output reg  [ MEM_STRB_R:0] s3_dmem_strb    ,
output reg  [ MEM_DATA_R:0] s3_dmem_wdata   ,
`endif

output wire                 dmem_req        , // Memory request
output wire                 dmem_rtype      , // Memory request type.
output wire [ MEM_ADDR_R:0] dmem_addr       , // Memory request address
output wire                 dmem_wen        , // Memory request write enable
output wire [ MEM_STRB_R:0] dmem_strb       , // Memory request write strobe
output wire [ MEM_DATA_R:0] dmem_wdata      , // Memory write data.
output wire [  MEM_PRV_R:0] dmem_prv        , // Memory privilidge level.
input  wire                 dmem_gnt        , // Memory response valid
input  wire                 dmem_err        , // Memory response error
input  wire [ MEM_DATA_R:0] dmem_rdata        // Memory response read data

);

// Common parameters and width definitions.
`include "core_common.svh"

//
// Events
// ------------------------------------------------------------

// New instruction will arrive on the next cycle.
wire    e_new_instr     = s2_valid && s2_ready;

// New instruction passed to next stage
wire    e_pipe_progress = e_new_instr && n_s3_full;

// Instruction in writeback retired.
wire    e_iret          = e_new_instr &&   s3_full;


//
// ALU interfacing
// ------------------------------------------------------------

wire [XL:0] alu_add_out     ; // Result of adding opr_a and opr_b
wire        alu_cmp_eq      ; // Result of opr_a == opr_b
wire        alu_cmp_lt      ; // Result of opr_a <  opr_b
wire        alu_cmp_ltu     ; // Result of opr_a <  opr_b
wire [XL:0] alu_result      ; // Operation result

//
// MDU interfacing
// ------------------------------------------------------------

wire        mdu_valid   =
    s2_mdu_mul      || s2_mdu_mulh    || s2_mdu_mulhsu   || s2_mdu_mulhu ||
    s2_mdu_div      || s2_mdu_divu    || s2_mdu_rem      || s2_mdu_remu  ||
    s2_mdu_mulw     || s2_mdu_divw    || s2_mdu_divuw    || s2_mdu_remw  ||
    s2_mdu_remuw    || s2_mdu_clmul   || s2_mdu_clmulh ;

wire        mdu_mul     = s2_mdu_mulw || s2_mdu_mul     ;
wire        mdu_div     = s2_mdu_div  || s2_mdu_divw    ;
wire        mdu_divu    = s2_mdu_divu || s2_mdu_divuw   ;
wire        mdu_rem     = s2_mdu_rem  || s2_mdu_remw    ;
wire        mdu_remu    = s2_mdu_remu || s2_mdu_remuw   ;

wire        mdu_word    =
    s2_mdu_mulw     || s2_mdu_divw    || s2_mdu_divuw    || s2_mdu_remw  ||
    s2_mdu_remuw    ;

wire [XL:0] s2_mdu_lhs  = s2_alu_lhs;
wire [XL:0] s2_mdu_rhs  = s2_alu_rhs;

wire        mdu_ready   ;
wire [XL:0] mdu_result  ;

wire        mdu_flush   = e_new_instr && mdu_valid;

//
// CFU interfacing
// ------------------------------------------------------------

wire                 cfu_op_any      =
    s2_cfu_beq  || s2_cfu_bge  || s2_cfu_bgeu || s2_cfu_blt  || s2_cfu_bltu ||
    s2_cfu_bne  || s2_cfu_ebrk || s2_cfu_ecall|| s2_cfu_j    || s2_cfu_jal  ||
    s2_cfu_jalr || s2_cfu_mret || s2_cfu_wfi ;

wire                 cfu_valid       = !wfi_sleep && s2_valid && cfu_op_any;

wire                 cfu_new_instr   = e_new_instr;
wire [         XL:0] cfu_new_pc      ; // New program counter
wire [   CFU_OP_R:0] cfu_new_op      ; // New operation to perform in wb.
wire [         XL:0] cfu_rd_wdata    ; // Data for register writeback
wire                 cfu_rd_wen      ; // Writeback enable
wire                 cfu_trap_raise  ; // Raise a trap.
wire [          6:0] cfu_trap_cause  ; // Cause of the trap.
wire                 cfu_finished    ; // CFU instruction finished.


//
// LSU interfacing
// ------------------------------------------------------------

wire        lsu_valid       =  s2_valid && !s3_trap && !s2_cancel&&
                               !wfi_sleep &&
                              (s2_lsu_load || s2_lsu_store);
wire        lsu_ready       ;
wire        lsu_trap_addr   ;

wire [MEM_ADDR_R:0] lsu_addr = alu_add_out[MEM_ADDR_R:0];

wire        lsu_new_instr   = e_new_instr;

wire [LSU_OP_R:0] lsu_new_op;
assign  lsu_new_op[LSU_OP_LOAD  ] = s2_lsu_load ;
assign  lsu_new_op[LSU_OP_STORE ] = s2_lsu_store;
assign  lsu_new_op[LSU_OP_BYTE  ] = s2_lsu_byte ;
assign  lsu_new_op[LSU_OP_HALF  ] = s2_lsu_half ;
assign  lsu_new_op[LSU_OP_WORD  ] = s2_lsu_word ;
assign  lsu_new_op[LSU_OP_DOUBLE] = s2_lsu_dbl  ;
assign  lsu_new_op[LSU_OP_SEXT  ] = s2_lsu_sext ;

//
// Crypto extension interfacing.
// ------------------------------------------------------------

wire        cry_valid       =
    s2_cry_aesks1     || s2_cry_aesks2     || s2_cry_aesimix    ||
    s2_cry_aeses      || s2_cry_aesesm     || s2_cry_aesds      ||
    s2_cry_aesdsm     || s2_cry_sha256sig0 || s2_cry_sha256sig1 ||
    s2_cry_sha256sum0 || s2_cry_sha256sum1 || s2_cry_sha512sig0 ||
    s2_cry_sha512sig1 || s2_cry_sha512sum0 || s2_cry_sha512sum1 ;

wire        cry_ready       ;

wire [XL:0] cry_result      ;

//
// CSR interfacing
// ------------------------------------------------------------

wire [CSR_OP_R:0] csr_new_op;

assign  csr_new_op[CSR_OP_RD    ] = s2_csr_rd   ;
assign  csr_new_op[CSR_OP_WR    ] = s2_csr_wr   || s2_csr_set || s2_csr_clr;
assign  csr_new_op[CSR_OP_SET   ] = s2_csr_set  ;
assign  csr_new_op[CSR_OP_CLR   ] = s2_csr_clr  ;

wire    wdata_csr = |csr_new_op;


//
// Writeback data multiplexing
// ------------------------------------------------------------

assign               s2_ready    =
     s3_ready                           &&
    (cfu_op_any ? cfu_finished : 1'b1)  &&
    (lsu_valid  ? lsu_ready    : 1'b1)  &&
    (cry_valid  ? cry_ready    : 1'b1)  &&
    (mdu_valid  ? mdu_ready    : 1'b1)  ;

assign              s3_valid     =
     s2_valid                           &&
    (cfu_op_any ? cfu_finished : 1'b1)  &&
    (lsu_valid  ? lsu_ready    : 1'b1)  &&
    (cry_valid  ? cry_ready    : 1'b1)  &&
    (mdu_valid  ? mdu_ready    : 1'b1)  ;

wire                 n_s3_full   = s3_valid && s3_ready && !s2_flush;
wire [         XL:0] n_s3_pc     = s2_pc        ;
wire [         31:0] n_s3_instr  = s2_instr     ;

// RD bits used to carry trap cause code.
// lsu_trap_addr ? 4 -> LDALIGN.
wire [ REG_ADDR_R:0] n_s3_rd     = 
    s2_trap        ? s2_trap_cause [REG_ADDR_R:0]   :
    cfu_trap_raise ? cfu_trap_cause[REG_ADDR_R:0]   :
    lsu_trap_addr  ? 5'd4                           :
                     s2_rd                          ;

// Next load/store unit op.
wire [   LSU_OP_R:0] n_s3_lsu_op = lsu_new_op   ;

// Next control & status register op.
wire [   CSR_OP_R:0] n_s3_csr_op = n_s3_trap ? {CSR_OP_W{1'b0}} :csr_new_op ;

// Next control flow unit op.
wire [   CFU_OP_R:0] n_s3_cfu_op = cfu_new_op   ;

// Raise a trap in the WB stage?
wire                 n_s3_trap   = s2_trap || lsu_trap_addr || cfu_trap_raise;

wire [    WB_OP_R:0] n_s3_wb_op  =
    {WB_OP_W{s2_wb_alu}} & WB_OP_WDATA  |
    {WB_OP_W{s2_wb_mdu}} & WB_OP_WDATA  |
    {WB_OP_W{s2_wb_npc}} & WB_OP_WDATA  |
    {WB_OP_W{s2_wb_cry}} & WB_OP_WDATA  |
    {WB_OP_W{s2_wb_lsu}} & WB_OP_LSU    |
    {WB_OP_W{s2_wb_csr}} & WB_OP_CSR    ;

wire [         XL:0] n_s3_wdata  = 
    {XLEN{s2_wb_lsu}}   &   alu_add_out |
    {XLEN{s2_wb_alu}}   &   alu_result  |
    {XLEN{s2_wb_mdu}}   &   mdu_result  |
    {XLEN{s2_wb_npc}}   &   s2_npc      |
    {XLEN{s2_wb_cry}}   &   cry_result  |
    {XLEN{wdata_csr}}   &   s2_rs1_data ;

wire [         11:0] n_s3_csr_addr = s2_csr_addr;

always @(posedge g_clk) begin
    if(!g_resetn || s2_flush) begin
        s3_full     <= 1'b0;
        s3_trap     <= 1'b0;
    end else if(s3_valid && s3_ready) begin
        s3_full     <= n_s3_full        ;
        s3_pc       <= n_s3_pc          ;
        s3_csr_addr <= n_s3_csr_addr    ;
        s3_instr    <= n_s3_instr       ;
        s3_wdata    <= n_s3_wdata       ;
        s3_rd       <= n_s3_rd          ;
        s3_lsu_op   <= n_s3_lsu_op      ;
        s3_csr_op   <= n_s3_csr_op      ;
        s3_cfu_op   <= n_s3_cfu_op      ;
        s3_wb_op    <= n_s3_wb_op       ;
        s3_trap     <= n_s3_trap        ;
        `ifdef RVFI
        s3_rs1_addr <= s2_rs1_addr      ;
        s3_rs2_addr <= s2_rs2_addr      ;
        s3_rs1_rdata<= s2_rs1_data      ;
        s3_rs2_rdata<= s2_rs2_data      ;
        `endif
    end
end

//
// RVFI
// ------------------------------------------------------------

`ifdef RVFI

//
// Catch memory transaction requests.
always @(posedge g_clk) begin
    if(!g_resetn) begin

    end else if(dmem_req && dmem_gnt) begin
        s3_dmem_valid <= 1'b1       ;
        s3_dmem_addr  <= dmem_addr  ;
        s3_dmem_strb  <= dmem_strb  ;
        s3_dmem_wdata <= dmem_wdata ;
    end

end

`endif


//
// Submodule instances
// ------------------------------------------------------------

//
// ALU

core_pipe_exec_alu i_core_pipe_exec_alu (
.opr_a      (s2_alu_lhs     ), // Input operand A
.opr_b      (s2_alu_rhs     ), // Input operand B
.shamt      (s2_alu_shamt   ), // Shift amount.
.word       (s2_alu_word    ), // Operate on low 32-bits of XL.
.op_add     (s2_alu_add     ), // Select output of adder
.op_sub     (s2_alu_sub     ), // Subtract opr_a from opr_b else add
.op_xor     (s2_alu_xor     ), // Select XOR operation result
.op_or      (s2_alu_or      ), // Select OR
.op_and     (s2_alu_and     ), //        AND
.op_slt     (s2_alu_slt     ), // Set less than
.op_sltu    (s2_alu_sltu    ), //                Unsigned
.op_srl     (s2_alu_srl     ), // Shift right logical
.op_sll     (s2_alu_sll     ), // Shift left logical
.op_sra     (s2_alu_sra     ), // Shift right arithmetic
.op_xorn    (s2_alu_xorn    ), // 
.op_andn    (s2_alu_andn    ), // 
.op_orn     (s2_alu_orn     ), // 
.op_ror     (s2_alu_ror     ), //
.op_rol     (s2_alu_rol     ), //
.op_pack    (s2_alu_pack    ), //
.op_packh   (s2_alu_packh   ), //
.op_packu   (s2_alu_packu   ), //
.op_grev    (s2_alu_grev    ), //
.op_gorc    (s2_alu_gorc    ), //
.op_xpermn  (s2_alu_xpermn  ), //
.op_xpermb  (s2_alu_xpermb  ), //
.add_out    (alu_add_out    ), // Result of adding opr_a and opr_b
.cmp_eq     (alu_cmp_eq     ), // Result of opr_a == opr_b
.cmp_lt     (alu_cmp_lt     ), // Result of opr_a <  opr_b
.cmp_ltu    (alu_cmp_ltu    ), // Result of opr_a <  opr_b
.result     (alu_result     )  // Operation result
);


riscv_crypto_fu #(
.XLEN          (        64), // Must be one of: 32, 64.
.SAES_ENC_EN   (F_ZKNE    ), // Enable AES encrypt instructions
.SAES_DEC_EN   (F_ZKND    ), // Enable AES decrypt instructions
.SAES64_SBOXES (        4 ), // saes64 sbox instances. Valid values: 8,4
.SSHA256_EN    (F_ZKNH    ), // Enable the ssha256.* instructions.
.SSHA512_EN    (F_ZKNH    ), // Enable the ssha256.* instructions.
.SSM3_EN       (F_ZKSH    ), // Enable the ssm3.* instructions.
.SSM4_EN       (F_ZKSED   ), // Enable the ssm4.* instructions.
.LOGIC_GATING  (        0 )  // Gate sub-module inputs to save toggling
) i_core_pipe_exec_crypto (
.g_clk           (g_clk             ), // Global clock
.g_resetn        (g_resetn          ), // Synchronous active low reset.
.valid           (cry_valid         ), // Inputs valid.
.rs1             (s2_rs1_data       ), // Source register 1
.rs2             (s2_rs2_data       ), // Source register 2
.imm             (s2_rs2_addr[3:0]  ), // enc_rcon for aes64.
.op_saes64_ks1   (s2_cry_aesks1     ), // RV64 AES Encrypt KeySchedule 1
.op_saes64_ks2   (s2_cry_aesks2     ), // RV64 AES Encrypt KeySchedule 2
.op_saes64_imix  (s2_cry_aesimix    ), // RV64 AES Decrypt KeySchedule Mix
.op_saes64_encs  (s2_cry_aeses      ), // RV64 AES Encrypt SBox
.op_saes64_encsm (s2_cry_aesesm     ), // RV64 AES Encrypt SBox + MixCols
.op_saes64_decs  (s2_cry_aesds      ), // RV64 AES Decrypt SBox
.op_saes64_decsm (s2_cry_aesdsm     ), // RV64 AES Decrypt SBox + MixCols
.op_ssha256_sig0 (s2_cry_sha256sig0 ), //      SHA256 Sigma 0
.op_ssha256_sig1 (s2_cry_sha256sig1 ), //      SHA256 Sigma 1
.op_ssha256_sum0 (s2_cry_sha256sum0 ), //      SHA256 Sum 0
.op_ssha256_sum1 (s2_cry_sha256sum1 ), //      SHA256 Sum 1
.op_ssha512_sig0 (s2_cry_sha512sig0 ), // RV64 SHA512 Sigma 0
.op_ssha512_sig1 (s2_cry_sha512sig1 ), // RV64 SHA512 Sigma 1
.op_ssha512_sum0 (s2_cry_sha512sum0 ), // RV64 SHA512 Sum 0
.op_ssha512_sum1 (s2_cry_sha512sum1 ), // RV64 SHA512 Sum 1
.op_ssm3_p0      (s2_cry_sm3_p0     ), //      SSM3 P0
.op_ssm3_p1      (s2_cry_sm3_p1     ), //      SSM3 P1
.op_ssm4_ks      (s2_cry_sm4_ks     ), //      SSM4 KeySchedule
.op_ssm4_ed      (s2_cry_sm4_ed     ), //      SSM4 Encrypt/Decrypt
.ready           (cry_ready         ), // Outputs ready.
.rd              (cry_result        )
);

//
// MDU

core_pipe_exec_mdu i_core_pipe_exec_mdu(
.g_clk      (g_clk_mul      ) , // Clock
.g_clk_req  (g_clk_mul_req  ) , // Clock request
.g_resetn   (g_resetn       ) , // Active low synchronous reset.
.flush      (mdu_flush      ) , // Flush and stop any execution.
.valid      (mdu_valid      ) , // Inputs are valid.
.op_word    (mdu_word       ) , // word-wise operation on 32-bit data.
.op_mul     (mdu_mul        ) , //
.op_mulh    (s2_mdu_mulh    ) , //
.op_mulhu   (s2_mdu_mulhu   ) , //
.op_mulhsu  (s2_mdu_mulhsu  ) , //
.op_clmul   (s2_mdu_clmul   ) , //
.op_clmulh  (s2_mdu_clmulh  ) , //
.op_div     (mdu_div        ) , //
.op_divu    (mdu_divu       ) , //
.op_rem     (mdu_rem        ) , //
.op_remu    (mdu_remu       ) , //
.rs1        (s2_mdu_lhs     ) , // Source register 1
.rs2        (s2_mdu_rhs     ) , // Source register 2
.ready      (mdu_ready      ) , // Finished computing
.rd         (mdu_result     )   // Result
);

//
// LSU

core_pipe_exec_lsu #(
.MEM_ADDR_W     (MEM_ADDR_W     )
) i_core_pipe_exec_lsu (
.g_clk      (g_clk          ), // Global clock enable.
.g_resetn   (g_resetn       ), // Global synchronous reset
.new_instr  (lsu_new_instr  ), // New instruciton next cycle
.valid      (lsu_valid      ), // Inputs are valid
.addr       (lsu_addr       ), // Address of the access.
.wdata      (s2_rs2_data    ), // Data being written (if any)
.load       (s2_lsu_load    ), //
.store      (s2_lsu_store   ), //
.d_double   (s2_lsu_dbl     ), //
.d_word     (s2_lsu_word    ), //
.d_half     (s2_lsu_half    ), //
.d_byte     (s2_lsu_byte    ), //
.sext       (s2_lsu_sext    ), // Sign extend read data
.mprv_m     (mprv_m         ), // Access memory as if in Machine mode.
.mprv_u     (mprv_u         ), // Access memory as if in User    mode.
.ready      (lsu_ready      ), // Read data ready
.trap_addr  (lsu_trap_addr  ), // Address alignment error
.dmem_req   (dmem_req       ), // Memory request
.dmem_rtype (dmem_rtype     ), // Memory request type.
.dmem_addr  (dmem_addr      ), // Memory request address
.dmem_wen   (dmem_wen       ), // Memory request write enable
.dmem_strb  (dmem_strb      ), // Memory request write strobe
.dmem_wdata (dmem_wdata     ), // Memory write data.
.dmem_prv   (dmem_prv       ), // Memory privilidge level.
.dmem_gnt   (dmem_gnt       ), // Memory response valid
.dmem_err   (dmem_err       ), // Memory response error
.dmem_rdata (dmem_rdata     )  // Memory response read data
);


//
// CFU

core_pipe_exec_cfu #(
.MEM_ADDR_W     (MEM_ADDR_W )
) i_core_pipe_exec_cfu (
.g_clk      (g_clk          ),
.g_resetn   (g_resetn       ),
.new_instr  (cfu_new_instr  ), // Being fed a new instruction.
.csr_mepc   (csr_mepc       ),
.cmp_eq     (alu_cmp_eq     ),
.cmp_lt     (alu_cmp_lt     ),
.cmp_ltu    (alu_cmp_ltu    ),
.valid      (cfu_valid      ),
.pc         (s2_pc          ), // Current program counter
.npc        (s2_npc         ), // Next natural program counter
.rs1        (s2_alu_lhs     ), // Source register 1
.offset     (s2_imm         ), // Branch offset
.cfu_beq    (s2_cfu_beq     ), // Control flow operation.
.cfu_bge    (s2_cfu_bge     ), //
.cfu_bgeu   (s2_cfu_bgeu    ), //
.cfu_blt    (s2_cfu_blt     ), //
.cfu_bltu   (s2_cfu_bltu    ), //
.cfu_bne    (s2_cfu_bne     ), //
.cfu_ebrk   (s2_cfu_ebrk    ), //
.cfu_ecall  (s2_cfu_ecall   ), //
.cfu_j      (s2_cfu_j       ), //
.cfu_jal    (s2_cfu_jal     ), //
.cfu_jalr   (s2_cfu_jalr    ), //
.cfu_mret   (s2_cfu_mret    ), //
.cfu_wfi    (s2_cfu_wfi     ), //
.cf_valid   (s2_cf_valid    ), // Control flow change?
.cf_ack     (s2_cf_ack      ), // Control flow acknwoledged
.cf_target  (s2_cf_target   ), // Control flow destination
.new_pc     (cfu_new_pc     ), // New program counter
.new_op     (cfu_new_op     ), // New operation to perform in wb.
.rd_wdata   (cfu_rd_wdata   ), // Data for register writeback
.rd_wen     (cfu_rd_wen     ), // Writeback enable
.trap_raise (cfu_trap_raise ), // Raise a trap.
.trap_cause (cfu_trap_cause ), // Cause of the trap.
.finished   (cfu_finished   )  // CFU instruction finished.
);

endmodule
