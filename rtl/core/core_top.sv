
//
// Module: core_top 
//
//  The top level module of the core.
//
module core_top (

input  wire                 g_clk        , // global clock
input  wire                 g_resetn     , // global active low sync reset.

input  wire                 int_sw       , // software interrupt
input  wire                 int_ext      , // hardware interrupt
              
output wire                 imem_req     , // Memory request
output wire [ MEM_ADDR_R:0] imem_addr    , // Memory request address
output wire                 imem_wen     , // Memory request write enable
output wire [ MEM_STRB_R:0] imem_strb    , // Memory request write strobe
output wire [ MEM_DATA_R:0] imem_wdata   , // Memory write data.
input  wire                 imem_gnt     , // Memory response valid
input  wire                 imem_err     , // Memory response error
input  wire [ MEM_DATA_R:0] imem_rdata   , // Memory response read data

output wire                 dmem_req     , // Memory request
output wire [ MEM_ADDR_R:0] dmem_addr    , // Memory request address
output wire                 dmem_wen     , // Memory request write enable
output wire [ MEM_STRB_R:0] dmem_strb    , // Memory request write strobe
output wire [ MEM_DATA_R:0] dmem_wdata   , // Memory write data.
input  wire                 dmem_gnt     , // Memory response valid
input  wire                 dmem_err     , // Memory response error
input  wire [ MEM_DATA_R:0] dmem_rdata   , // Memory response read data

`ifdef RVFI
`RVFI_OUTPUTS                            , // Formal checker interface.
`endif

output wire                 trs_valid    , // Instruction trace valid
output wire [         31:0] trs_instr    , // Instruction trace data
output wire [         XL:0] trs_pc         // Instruction trace PC

);


// Common parameters and width definitions.
`include "core_common.svh"

// Inital address of the program counter post reset.
parameter   PC_RESET_ADDRESS= 'h10000000;

// Base address of the memory mapped IO region.
parameter   MMIO_BASE_ADDR  = 'h0000_0000_0001_0000;
parameter   MMIO_BASE_MASK  = 'h0000_0000_0001_FFFF;

//
// Control flow change busses
// ------------------------------------------------------------

// See also: DESIGNER_ASSERTION_CONTROL_FLOW_BUS
wire                 cf_valid    ; // Control flow change?
wire                 cf_ack      ; // Control flow change acknwoledged
wire [         XL:0] cf_target   ; // Control flow change destination

wire                 s2_cf_valid ; // Control flow change?
wire                 s2_cf_ack   = cf_ack;
wire [         XL:0] s2_cf_target; // Control flow destination

wire                 s3_cf_valid ; // Control flow change?
wire                 s3_cf_ack   = cf_ack;
wire [         XL:0] s3_cf_target; // Control flow destination

assign  cf_valid    = s2_cf_valid || s3_cf_valid;
assign  cf_target   = s3_cf_valid ? s3_cf_target : s2_cf_target;

wire                 int_pending ; // Int pending but not enabled
wire                 int_request ; // Int pending and enabled.
wire [ CF_CAUSE_R:0] int_cause   ; // Cause code for the interrupt.
wire [         XL:0] int_tvec    ; // Interrupt trap vector
wire                 int_ack     ; // Interrupt taken acknowledge

wire                 s2_flush    = s3_cf_valid && s3_cf_ack;
wire                 s2_cancel   = s3_cf_valid ;

//
// Inter-stage wiring
// ------------------------------------------------------------

wire                 s1_i16bit   ; // 16 bit instruction?
wire                 s1_i32bit   ; // 32 bit instruction?
wire [  FD_IBUF_R:0] s1_instr    ; // Instruction to be decoded
wire [   FD_ERR_R:0] s1_ferr     ; // Fetch bus error?
wire                 s1_eat_2    ; // Decode eats 2 bytes
wire                 s1_eat_4    ; // Decode eats 4 bytes

wire [ REG_ADDR_R:0] s1_rs1_addr ; // RS1 Address
wire [         XL:0] s1_rs1_data ; // RS1 Read Data (Forwarded)
wire [ REG_ADDR_R:0] s1_rs2_addr ; // RS2 Address
wire [         XL:0] s1_rs2_data ; // RS2 Read Data (Forwarded)

wire                 s2_ready       ; // EX ready for new instruction
wire                 s2_valid       ; // Decode -> EX instr valid.

wire [ REG_ADDR_R:0] s2_rs1_addr    ; // RS1 address.
wire [ REG_ADDR_R:0] s2_rs2_addr    ; // RS2 address.
wire [ REG_ADDR_R:0] s2_rd          ; // Destination reg address.
wire [         XL:0] s2_rs1_data    ; // RS1 value.
wire [         XL:0] s2_rs2_data    ; // RS2 value.
wire [         XL:0] s2_imm         ; // Immediate value
wire [         XL:0] s2_pc          ; // Current program counter.
wire [         XL:0] s2_npc         ; // Next    program counter.
wire [         31:0] s2_instr       ; // Current instruction word.
wire                 s2_trap        ; // Raise a trap
wire [          6:0] s2_trap_cause  ; // Cause of trap being raised.

wire [         XL:0] s2_alu_lhs     ; // ALU left  operand
wire [         XL:0] s2_alu_rhs     ; // ALU right operand
wire                 s2_alu_add     ; // ALU Operation to perform.
wire                 s2_alu_and     ; // 
wire                 s2_alu_or      ; // 
wire                 s2_alu_sll     ; // 
wire                 s2_alu_srl     ; // 
wire                 s2_alu_slt     ; // 
wire                 s2_alu_sltu    ; // 
wire                 s2_alu_sra     ; // 
wire                 s2_alu_sub     ; // 
wire                 s2_alu_xor     ; // 
wire                 s2_alu_word    ; // Word result only.

wire                 s2_cfu_beq     ; // Control flow operation.
wire                 s2_cfu_bge     ; //
wire                 s2_cfu_bgeu    ; //
wire                 s2_cfu_blt     ; //
wire                 s2_cfu_bltu    ; //
wire                 s2_cfu_bne     ; //
wire                 s2_cfu_ebrk    ; //
wire                 s2_cfu_ecall   ; //
wire                 s2_cfu_j       ; //
wire                 s2_cfu_jal     ; //
wire                 s2_cfu_jalr    ; //
wire                 s2_cfu_mret    ; // Machine trap return
wire                 s2_cfu_wfi     ; // Wait for interrupt

wire                 s2_lsu_load    ; // LSU Load
wire                 s2_lsu_store   ; // "   Store
wire                 s2_lsu_byte    ; // Byte width
wire                 s2_lsu_half    ; // Halfword width
wire                 s2_lsu_word    ; // Word width
wire                 s2_lsu_dbl     ; // Doubleword widt
wire                 s2_lsu_sext    ; // Sign extend loaded value.

wire                 s2_mdu_mul     ; // MDU Operation
wire                 s2_mdu_mulh    ; //
wire                 s2_mdu_mulhsu  ; //
wire                 s2_mdu_mulhu   ; //
wire                 s2_mdu_div     ; //
wire                 s2_mdu_divu    ; //
wire                 s2_mdu_rem     ; //
wire                 s2_mdu_remu    ; //
wire                 s2_mdu_mulw    ; //
wire                 s2_mdu_divw    ; //
wire                 s2_mdu_divuw   ; //
wire                 s2_mdu_remw    ; //
wire                 s2_mdu_remuw   ; //

wire                 s2_csr_set     ; // CSR Operation
wire                 s2_csr_clr     ; //
wire                 s2_csr_rd      ; //
wire                 s2_csr_wr      ; //
wire [         11:0] s2_csr_addr    ; // CSR access address

wire                 s2_wb_alu      ; // Writeback ALU result
wire                 s2_wb_csr      ; // Writeback CSR result
wire                 s2_wb_mdu      ; // Writeback MDU result
wire                 s2_wb_lsu      ; // Writeback LSU Loaded data
wire                 s2_wb_npc      ; // Writeback next PC value

wire                 s3_valid       ; // New instruction ready
wire                 s3_ready       ; // WB ready for new instruciton.
wire                 s3_full        ; // WB has an instr in it.
wire [         XL:0] s3_pc          ; // Writeback stage PC
wire [         31:0] s3_instr       ; // Writeback stage instr word
wire [         XL:0] s3_wdata       ; // Writeback stage instr word
wire [ REG_ADDR_R:0] s3_rd          ; // Writeback stage instr word
wire [   LSU_OP_R:0] s3_lsu_op      ; // Writeback LSU op
wire [   CSR_OP_R:0] s3_csr_op      ; // Writeback CSR op
wire [         11:0] s3_csr_addr    ; // CSR access address
wire [   CFU_OP_R:0] s3_cfu_op      ; // Writeback CFU op
wire [    WB_OP_R:0] s3_wb_op       ; // Writeback Data source.
wire                 s3_trap        ; // Raise a trap

`ifdef RVFI
wire [ REG_ADDR_R:0] s3_rs1_addr    ;
wire [ REG_ADDR_R:0] s3_rs2_addr    ;
wire [         XL:0] s3_rs1_rdata   ;
wire [         XL:0] s3_rs2_rdata   ;
wire                 s3_dmem_valid  ;
wire [ MEM_ADDR_R:0] s3_dmem_addr   ;
wire [ MEM_STRB_R:0] s3_dmem_strb   ;
wire [ MEM_DATA_R:0] s3_dmem_wdata  ;
`endif

wire                 s3_rd_wen      ; // Destination register write enable
wire [ REG_ADDR_R:0] s3_rd_addr     ; // Destination register write addr
wire [         XL:0] s3_rd_wdata    ; // Destination register write data.


wire                 csr_en      ; // CSR Access Enable
wire                 csr_wr      ; // CSR Write Enable
wire                 csr_wr_set  ; // CSR Write - Set
wire                 csr_wr_clr  ; // CSR Write - Clear
wire [         11:0] csr_addr    ; // Address of the CSR to access.
wire [         XL:0] csr_wdata   ; // Data to be written to a CSR
wire [         XL:0] csr_rdata   ; // CSR read data
wire                 csr_error   ; // CSR access error
               
wire [         XL:0] csr_mepc    ; // Current EPC.
wire [         XL:0] mtvec_base  ; // Current MTVEC base address.
wire [          1:0] mtvec_mode  ; // Current MTVEC direct/vector mode
               
wire                 exec_mret   ; // MRET instruction executed.
               
wire                 mstatus_mie ; // Global interrupt enable.
wire                 mie_meie    ; // External interrupt enable.
wire                 mie_mtie    ; // Timer interrupt enable.
wire                 mie_msie    ; // Software interrupt enable.
               
wire                 mip_meip    ; // External interrupt pending
wire                 mip_mtip    ; // Timer interrupt pending
wire                 mip_msip    ; // Software interrupt pending

wire                 instr_ret   ; // Instruction retired;
wire                 int_ti      ; // A timer interrupt has fired.
               
wire [         63:0] ctr_time    ; // The time counter value.
wire [         63:0] ctr_cycle   ; // The cycle counter value.
wire [         63:0] ctr_instret ; // The instret counter value.
               
wire                 inhibit_cy  ; // Stop cycle counter incrementing.
wire                 inhibit_tm  ; // Stop time counter incrementing.
wire                 inhibit_ir  ; // Stop instret incrementing.
               
wire                 trap_cpu    ; // A trap occured due to CPU
wire                 trap_int    ; // A trap occured due to interrupt
wire [ CF_CAUSE_R:0] trap_cause  ; // A trap occured due to interrupt
wire [         XL:0] trap_mtval  ; // Value associated with the trap.
wire [         XL:0] trap_pc     ; // PC value associated with the trap.

//
// Internal memory request, prior to external/MMIO filtering.
wire                 int_dmem_req  ; // Memory request
wire [ MEM_ADDR_R:0] int_dmem_addr ; // Memory request address
wire                 int_dmem_wen  ; // Memory request write enable
wire [ MEM_STRB_R:0] int_dmem_strb ; // Memory request write strobe
wire [ MEM_DATA_R:0] int_dmem_wdata; // Memory write data.
wire                 int_dmem_gnt  ; // Memory response valid
wire                 int_dmem_err  ; // Memory response error
wire [ MEM_DATA_R:0] int_dmem_rdata; // Memory response read data

wire                 mmio_req    ; // MMIO enable
wire                 mmio_wen    ; // MMIO write enable
wire [ MEM_ADDR_R:0] mmio_addr   ; // MMIO address
wire [ MEM_DATA_R:0] mmio_wdata  ; // MMIO write data
wire                 mmio_gnt    ; // MMIO grant
wire [ MEM_DATA_R:0] mmio_rdata  ; // MMIO read data
wire                 mmio_error  ; // MMIO error

//
// Pipeline forwarding
// ------------------------------------------------------------

wire [XL:0] gpr_rs1_data;
wire [XL:0] gpr_rs2_data;

// Writeback stage gpr writeback enable *used only for forwarding*.
// This signal is ignorant of whether a WB instruction *will* write back
// a GPR value. It only idicates if it *could*. This removes things
// like trap calculation and calcalation of a GPR write from the
// critical path.
wire        s3_fwd_rd_wen;

wire    fwd_rs1     = s3_fwd_rd_wen && |s3_rd_addr && s3_rd_addr==s1_rs1_addr;
wire    fwd_rs2     = s3_fwd_rd_wen && |s3_rd_addr && s3_rd_addr==s1_rs2_addr;

assign  s1_rs1_data = fwd_rs1 ? s3_rd_wdata : gpr_rs1_data;
assign  s1_rs2_data = fwd_rs2 ? s3_rd_wdata : gpr_rs2_data;

//
// Submodule instances.
// ------------------------------------------------------------


//
// Instance: core_pipe_fetch
//
//  Pipeline Fetch Stage
//
core_pipe_fetch #(
.PC_RESET_ADDRESS(PC_RESET_ADDRESS),
.MEM_ADDR_W      (MEM_ADDR_W      )
) i_core_pipe_fetch (
.g_clk        (g_clk        ), // Global clock
.g_resetn     (g_resetn     ), // Global active low sync reset.
.cf_valid     (cf_valid     ), // Control flow change?
.cf_ack       (cf_ack       ), // Control flow change acknwoledged
.cf_target    (cf_target    ), // Control flow change destination
.imem_req     (imem_req     ), // Memory request
.imem_addr    (imem_addr    ), // Memory request address
.imem_wen     (imem_wen     ), // Memory request write enable
.imem_strb    (imem_strb    ), // Memory request write strobe
.imem_wdata   (imem_wdata   ), // Memory write data.
.imem_gnt     (imem_gnt     ), // Memory response valid
.imem_err     (imem_err     ), // Memory response error
.imem_rdata   (imem_rdata   ), // Memory response read data
.s1_i16bit    (s1_i16bit    ), // 16 bit instruction?
.s1_i32bit    (s1_i32bit    ), // 32 bit instruction?
.s1_instr     (s1_instr     ), // Instruction to be decoded
.s1_ferr      (s1_ferr      ), // Fetch bus error?
.s1_eat_2     (s1_eat_2     ), // Decode eats 2 bytes
.s1_eat_4     (s1_eat_4     )  // Decode eats 4 bytes
);


//
// Module: core_pipe_decode
//
//  Pipeline decode / operand gather stage.
//
core_pipe_decode #(
.PC_RESET_ADDRESS(PC_RESET_ADDRESS),
.MEM_ADDR_W      (MEM_ADDR_W      )
) i_core_pipe_decode (
.g_clk           (g_clk           ), // Global clock
.g_resetn        (g_resetn        ), // Global active low sync reset.
.s1_i16bit       (s1_i16bit       ), // 16 bit instruction?
.s1_i32bit       (s1_i32bit       ), // 32 bit instruction?
.s1_instr        (s1_instr        ), // Instruction to be decoded
.s1_ferr         (s1_ferr         ), // Fetch bus error?
.s1_eat_2        (s1_eat_2        ), // Decode eats 2 bytes
.s1_eat_4        (s1_eat_4        ), // Decode eats 4 bytes
.s2_flush        (s2_flush        ), // Stage 1 flush
.cf_valid        (cf_valid        ), // Control flow change?
.cf_ack          (cf_ack          ), // Control flow acknwoledged
.cf_target       (cf_target       ), // Control flow destination
.s1_rs1_addr     (s1_rs1_addr     ), // RS1 Address
.s1_rs1_data     (s1_rs1_data     ), // RS1 Read Data (Forwarded)
.s1_rs2_addr     (s1_rs2_addr     ), // RS2 Address
.s1_rs2_data     (s1_rs2_data     ), // RS2 Read Data (Forwarded)
.s2_ready        (s2_ready        ), // EX ready for new instruction
.s2_valid        (s2_valid        ), // Decode -> EX instr valid.
.s2_rs1_addr     (s2_rs1_addr     ), // RS1 address.
.s2_rs2_addr     (s2_rs2_addr     ), // RS2 address.
.s2_rd           (s2_rd           ), // Destination reg address.
.s2_rs1_data     (s2_rs1_data     ), // RS1 value.
.s2_rs2_data     (s2_rs2_data     ), // RS2 value.
.s2_imm          (s2_imm          ), // Immediate value
.s2_pc           (s2_pc           ), // Current program counter.
.s2_npc          (s2_npc          ), // Next    program counter.
.s2_instr        (s2_instr        ), // Current instruction word.
.s2_trap         (s2_trap         ), // Raise a trap
.s2_trap_cause   (s2_trap_cause   ), // Cause of trap being raised.
.s2_alu_lhs      (s2_alu_lhs      ), // ALU left  operand
.s2_alu_rhs      (s2_alu_rhs      ), // ALU right operand
.s2_alu_add      (s2_alu_add      ), // ALU Operation to perform.
.s2_alu_and      (s2_alu_and      ), // 
.s2_alu_or       (s2_alu_or       ), // 
.s2_alu_sll      (s2_alu_sll      ), // 
.s2_alu_srl      (s2_alu_srl      ), // 
.s2_alu_slt      (s2_alu_slt      ), // 
.s2_alu_sltu     (s2_alu_sltu     ), // 
.s2_alu_sra      (s2_alu_sra      ), // 
.s2_alu_sub      (s2_alu_sub      ), // 
.s2_alu_xor      (s2_alu_xor      ), // 
.s2_alu_word     (s2_alu_word     ), // Word result only.
.s2_cfu_beq      (s2_cfu_beq      ), // Control flow operation.
.s2_cfu_bge      (s2_cfu_bge      ), //
.s2_cfu_bgeu     (s2_cfu_bgeu     ), //
.s2_cfu_blt      (s2_cfu_blt      ), //
.s2_cfu_bltu     (s2_cfu_bltu     ), //
.s2_cfu_bne      (s2_cfu_bne      ), //
.s2_cfu_ebrk     (s2_cfu_ebrk     ), //
.s2_cfu_ecall    (s2_cfu_ecall    ), //
.s2_cfu_j        (s2_cfu_j        ), //
.s2_cfu_jal      (s2_cfu_jal      ), //
.s2_cfu_jalr     (s2_cfu_jalr     ), //
.s2_cfu_mret     (s2_cfu_mret     ), //
.s2_cfu_wfi      (s2_cfu_wfi      ), //
.s2_lsu_load     (s2_lsu_load     ), // LSU Load
.s2_lsu_store    (s2_lsu_store    ), // "   Store
.s2_lsu_byte     (s2_lsu_byte     ), // Byte width
.s2_lsu_half     (s2_lsu_half     ), // Halfword width
.s2_lsu_word     (s2_lsu_word     ), // Word width
.s2_lsu_dbl      (s2_lsu_dbl      ), // Doubleword widt
.s2_lsu_sext     (s2_lsu_sext     ), // Sign extend loaded value.
.s2_mdu_mul      (s2_mdu_mul      ), // MDU Operation
.s2_mdu_mulh     (s2_mdu_mulh     ), //
.s2_mdu_mulhsu   (s2_mdu_mulhsu   ), //
.s2_mdu_mulhu    (s2_mdu_mulhu    ), //
.s2_mdu_div      (s2_mdu_div      ), //
.s2_mdu_divu     (s2_mdu_divu     ), //
.s2_mdu_rem      (s2_mdu_rem      ), //
.s2_mdu_remu     (s2_mdu_remu     ), //
.s2_mdu_mulw     (s2_mdu_mulw     ), //
.s2_mdu_divw     (s2_mdu_divw     ), //
.s2_mdu_divuw    (s2_mdu_divuw    ), //
.s2_mdu_remw     (s2_mdu_remw     ), //
.s2_mdu_remuw    (s2_mdu_remuw    ), //
.s2_csr_set      (s2_csr_set      ), // CSR Operation
.s2_csr_clr      (s2_csr_clr      ), //
.s2_csr_rd       (s2_csr_rd       ), //
.s2_csr_wr       (s2_csr_wr       ), //
.s2_csr_addr     (s2_csr_addr     ), // CSR Access address
.s2_wb_alu       (s2_wb_alu       ), // Writeback ALU result
.s2_wb_csr       (s2_wb_csr       ), // Writeback CSR result
.s2_wb_mdu       (s2_wb_mdu       ), // Writeback MDU result
.s2_wb_lsu       (s2_wb_lsu       ), // Writeback LSU Loaded data
.s2_wb_npc       (s2_wb_npc       )  // Writeback next PC value
);


//
// Module: core_pipe_exec
//
//  Top level for the execute stage of the pipeline.
//
core_pipe_exec #(
.MEM_ADDR_W     (MEM_ADDR_W     )
) i_core_pipe_exec(
.g_clk           (g_clk           ), // Global clock
.g_resetn        (g_resetn        ), // Global active low sync reset.
.s2_cf_valid     (s2_cf_valid     ), // Control flow change?
.s2_cf_ack       (s2_cf_ack       ), // Control flow acknwoledged
.s2_cf_target    (s2_cf_target    ), // Control flow destination
.s2_flush        (s2_flush        ), // Flush stage contents.
.s2_cancel       (s2_cancel       ), // Stage 1 flush
.csr_mepc        (csr_mepc        ), // MRET return address
.s2_ready        (s2_ready        ), // EX ready for new instruction
.s2_valid        (s2_valid        ), // Decode -> EX instr valid.
.s2_rs1_addr     (s2_rs1_addr     ), // RS1 address.
.s2_rs2_addr     (s2_rs2_addr     ), // RS2 address.
.s2_rd           (s2_rd           ), // Destination reg address.
.s2_rs1_data     (s2_rs1_data     ), // RS1 value.
.s2_rs2_data     (s2_rs2_data     ), // RS2 value.
.s2_imm          (s2_imm          ), // Immediate value
.s2_pc           (s2_pc           ), // Current program counter.
.s2_npc          (s2_npc          ), // Next    program counter.
.s2_instr        (s2_instr        ), // Current instruction word.
.s2_trap         (s2_trap         ), // Raise a trap
.s2_trap_cause   (s2_trap_cause   ), // Cause of trap being raised.
.s2_alu_lhs      (s2_alu_lhs      ), // ALU left  operand
.s2_alu_rhs      (s2_alu_rhs      ), // ALU right operand
.s2_alu_add      (s2_alu_add      ), // ALU Operation to perform.
.s2_alu_and      (s2_alu_and      ), // 
.s2_alu_or       (s2_alu_or       ), // 
.s2_alu_sll      (s2_alu_sll      ), // 
.s2_alu_srl      (s2_alu_srl      ), // 
.s2_alu_slt      (s2_alu_slt      ), // 
.s2_alu_sltu     (s2_alu_sltu     ), // 
.s2_alu_sra      (s2_alu_sra      ), // 
.s2_alu_sub      (s2_alu_sub      ), // 
.s2_alu_xor      (s2_alu_xor      ), // 
.s2_alu_word     (s2_alu_word     ), // Word result only.
.s2_cfu_beq      (s2_cfu_beq      ), // Control flow operation.
.s2_cfu_bge      (s2_cfu_bge      ), //
.s2_cfu_bgeu     (s2_cfu_bgeu     ), //
.s2_cfu_blt      (s2_cfu_blt      ), //
.s2_cfu_bltu     (s2_cfu_bltu     ), //
.s2_cfu_bne      (s2_cfu_bne      ), //
.s2_cfu_ebrk     (s2_cfu_ebrk     ), //
.s2_cfu_ecall    (s2_cfu_ecall    ), //
.s2_cfu_j        (s2_cfu_j        ), //
.s2_cfu_jal      (s2_cfu_jal      ), //
.s2_cfu_jalr     (s2_cfu_jalr     ), //
.s2_cfu_mret     (s2_cfu_mret     ), //
.s2_cfu_wfi      (s2_cfu_wfi      ), //
.s2_lsu_load     (s2_lsu_load     ), // LSU Load
.s2_lsu_store    (s2_lsu_store    ), // "   Store
.s2_lsu_byte     (s2_lsu_byte     ), // Byte width
.s2_lsu_half     (s2_lsu_half     ), // Halfword width
.s2_lsu_word     (s2_lsu_word     ), // Word width
.s2_lsu_dbl      (s2_lsu_dbl      ), // Doubleword widt
.s2_lsu_sext     (s2_lsu_sext     ), // Sign extend loaded value.
.s2_mdu_mul      (s2_mdu_mul      ), // MDU Operation
.s2_mdu_mulh     (s2_mdu_mulh     ), //
.s2_mdu_mulhsu   (s2_mdu_mulhsu   ), //
.s2_mdu_mulhu    (s2_mdu_mulhu    ), //
.s2_mdu_div      (s2_mdu_div      ), //
.s2_mdu_divu     (s2_mdu_divu     ), //
.s2_mdu_rem      (s2_mdu_rem      ), //
.s2_mdu_remu     (s2_mdu_remu     ), //
.s2_mdu_mulw     (s2_mdu_mulw     ), //
.s2_mdu_divw     (s2_mdu_divw     ), //
.s2_mdu_divuw    (s2_mdu_divuw    ), //
.s2_mdu_remw     (s2_mdu_remw     ), //
.s2_mdu_remuw    (s2_mdu_remuw    ), //
.s2_csr_set      (s2_csr_set      ), // CSR Operation
.s2_csr_clr      (s2_csr_clr      ), //
.s2_csr_rd       (s2_csr_rd       ), //
.s2_csr_wr       (s2_csr_wr       ), //
.s2_csr_addr     (s2_csr_addr     ), // CSR Access address
.s2_wb_alu       (s2_wb_alu       ), // Writeback ALU result
.s2_wb_csr       (s2_wb_csr       ), // Writeback CSR result
.s2_wb_mdu       (s2_wb_mdu       ), // Writeback MDU result
.s2_wb_lsu       (s2_wb_lsu       ), // Writeback LSU Loaded data
.s2_wb_npc       (s2_wb_npc       ), // Writeback next PC value
.s3_valid        (s3_valid        ), // New instruction ready
.s3_ready        (s3_ready        ), // WB ready for new instruciton.
.s3_full         (s3_full         ), // WB has an instr in it.
.s3_pc           (s3_pc           ), // Writeback stage PC
.s3_instr        (s3_instr        ), // Writeback stage instr word
.s3_wdata        (s3_wdata        ), // Writeback stage instr word
.s3_rd           (s3_rd           ), // Writeback stage instr word
.s3_lsu_op       (s3_lsu_op       ), // Writeback LSU op
.s3_csr_op       (s3_csr_op       ), // Writeback CSR op
.s3_csr_addr     (s3_csr_addr     ), // CSR Access address
.s3_cfu_op       (s3_cfu_op       ), // Writeback CFU op
.s3_wb_op        (s3_wb_op        ), // Writeback Data source.
.s3_trap         (s3_trap         ), // Raise a trap
`ifdef RVFI
.s3_rs1_addr     (s3_rs1_addr     ),
.s3_rs2_addr     (s3_rs2_addr     ),
.s3_rs1_rdata    (s3_rs1_rdata    ),
.s3_rs2_rdata    (s3_rs2_rdata    ),
.s3_dmem_valid   (s3_dmem_valid   ),
.s3_dmem_addr    (s3_dmem_addr    ),
.s3_dmem_strb    (s3_dmem_strb    ),
.s3_dmem_wdata   (s3_dmem_wdata   ),
`endif
.dmem_req        (int_dmem_req    ), // Memory request
.dmem_addr       (int_dmem_addr   ), // Memory request address
.dmem_wen        (int_dmem_wen    ), // Memory request write enable
.dmem_strb       (int_dmem_strb   ), // Memory request write strobe
.dmem_wdata      (int_dmem_wdata  ), // Memory write data.
.dmem_gnt        (int_dmem_gnt    ), // Memory response valid
.dmem_err        (int_dmem_err    ), // Memory response error
.dmem_rdata      (int_dmem_rdata  )  // Memory response read data
);



//
// module: core_pipe_wb
//
//  Writeback stage. Responsible for GPR writebacks, CSR accesses,
//  Load data processing, trap raising.
//
core_pipe_wb #(
.MEM_ADDR_W     (MEM_ADDR_W     )
) i_core_pipe_wb (
.g_clk           (g_clk           ), // Global clock
.g_resetn        (g_resetn        ), // Global active low sync reset.
.s3_cf_valid     (s3_cf_valid     ), // Control flow change?
.s3_cf_ack       (s3_cf_ack       ), // Control flow acknwoledged
.s3_cf_target    (s3_cf_target    ), // Control flow destination
.int_pending     (int_pending     ), // Pending but disabled.
.int_request     (int_request     ), // Pending and enabled, so taken.
.int_cause       (int_cause       ), // Cause code for the interrupt.
.int_tvec        (int_tvec        ), // Interrupt trap vector
.int_ack         (int_ack         ), // Interrupt taken acknowledge
.s3_valid        (s3_valid        ), // New instruction ready
.s3_ready        (s3_ready        ), // WB ready for new instruciton.
.s3_full         (s3_full         ), // WB has an instr in it.
.s3_pc           (s3_pc           ), // Writeback stage PC
.s3_n_pc         (s2_pc           ), // Writeback stage Next PC
.s3_instr        (s3_instr        ), // Writeback stage instr word
.s3_wdata        (s3_wdata        ), // Writeback stage instr word
.s3_rd           (s3_rd           ), // Writeback stage instr word
.s3_lsu_op       (s3_lsu_op       ), // Writeback LSU op
.s3_csr_op       (s3_csr_op       ), // Writeback CSR op
.s3_csr_addr     (s3_csr_addr     ), // CSR Access address
.s3_cfu_op       (s3_cfu_op       ), // Writeback CFU op
.s3_wb_op        (s3_wb_op        ), // Writeback Data source.
.s3_trap         (s3_trap         ), // Raise a trap
.s3_fwd_rd_wen   (s3_fwd_rd_wen   ), // RD write en for forwarding network.
.s3_rd_wen       (s3_rd_wen       ), // RD write enable
.s3_rd_addr      (s3_rd_addr      ), // RD write addr
.s3_rd_wdata     (s3_rd_wdata     ), // RD write data.
.csr_en          (csr_en          ), // CSR Access Enable
.csr_wr          (csr_wr          ), // CSR Write Enable
.csr_wr_set      (csr_wr_set      ), // CSR Write - Set
.csr_wr_clr      (csr_wr_clr      ), // CSR Write - Clear
.csr_addr        (csr_addr        ), // Address of the CSR to access.
.csr_wdata       (csr_wdata       ), // Data to be written to a CSR
.csr_rdata       (csr_rdata       ), // CSR read data
.csr_error       (csr_error       ), // CSR access error.
.mtvec_base      (mtvec_base      ), // Current MTVEC base address.
.trap_cpu        (trap_cpu        ), // A trap occured due to CPU
.trap_int        (trap_int        ), // A trap occured due to interrupt
.trap_cause      (trap_cause      ), // A trap occured due to interrupt
.trap_mtval      (trap_mtval      ), // Value associated with the trap.
.trap_pc         (trap_pc         ), // PC value associated with the trap.
.exec_mret       (exec_mret       ), // MRET instruction executed.
.instr_ret       (instr_ret       ), // INstruction retired
.dmem_req        (int_dmem_req    ), // Memory request
.dmem_addr       (int_dmem_addr   ), // Memory request address
.dmem_wen        (int_dmem_wen    ), // Memory request write enable
.dmem_strb       (int_dmem_strb   ), // Memory request write strobe
.dmem_wdata      (int_dmem_wdata  ), // Memory write data.
.dmem_gnt        (int_dmem_gnt    ), // Memory response valid
.dmem_err        (int_dmem_err    ), // Memory response error
.dmem_rdata      (int_dmem_rdata  ), // Memory response read data
`ifdef RVFI
.s3_rs1_addr     (s3_rs1_addr     ),
.s3_rs2_addr     (s3_rs2_addr     ),
.s3_rs1_rdata    (s3_rs1_rdata    ),
.s3_rs2_rdata    (s3_rs2_rdata    ),
.s3_dmem_valid   (s3_dmem_valid   ),
.s3_dmem_addr    (s3_dmem_addr    ),
.s3_dmem_strb    (s3_dmem_strb    ),
.s3_dmem_wdata   (s3_dmem_wdata   ),
`RVFI_CONN                         ,
`endif
.trs_valid       (trs_valid       ), // Instruction trace valid
.trs_instr       (trs_instr       ), // Instruction trace data
.trs_pc          (trs_pc          )  // Instruction trace PC
);



//
// instance: core_regfile
//
//  Core register file. 2 read, 1 write.
//
core_regfile i_core_regfile (
.g_clk    (g_clk       ),
.g_resetn (g_resetn    ),
.rs1_addr (s1_rs1_addr ),
.rs2_addr (s1_rs2_addr ),
.rs1_data (gpr_rs1_data),
.rs2_data (gpr_rs2_data),
.rd_wen   (s3_rd_wen   ),
.rd_addr  (s3_rd_addr  ),
.rd_wdata (s3_rd_wdata ) 
);


//
// module: i_core_csrs
//
//  Responsible for keeping control/status registers up to date.
//
core_csrs i_core_csrs (
.g_clk            (g_clk            ), // global clock
.g_resetn         (g_resetn         ), // synchronous reset
.csr_en           (csr_en           ), // CSR Access Enable
.csr_wr           (csr_wr           ), // CSR Write Enable
.csr_wr_set       (csr_wr_set       ), // CSR Write - Set
.csr_wr_clr       (csr_wr_clr       ), // CSR Write - Clear
.csr_addr         (csr_addr         ), // Address of the CSR to access.
.csr_wdata        (csr_wdata        ), // Data to be written to a CSR
.csr_rdata        (csr_rdata        ), // CSR read data
.csr_error        (csr_error        ), // CSR access error.
.csr_mepc         (csr_mepc         ), // Current EPC.
.mtvec_base       (mtvec_base       ), // Current MTVEC base address.
.mtvec_mode       (mtvec_mode       ), // Current MTVEC vector mode.
.exec_mret        (exec_mret        ), // MRET instruction executed.
.mstatus_mie      (mstatus_mie      ), // Global interrupt enable.
.mie_meie         (mie_meie         ), // External interrupt enable.
.mie_mtie         (mie_mtie         ), // Timer interrupt enable.
.mie_msie         (mie_msie         ), // Software interrupt enable.
.mip_meip         (mip_meip         ), // External interrupt pending
.mip_mtip         (mip_mtip         ), // Timer interrupt pending
.mip_msip         (mip_msip         ), // Software interrupt pending
.ctr_time         (ctr_time         ), // The time counter value.
.ctr_cycle        (ctr_cycle        ), // The cycle counter value.
.ctr_instret      (ctr_instret      ), // The instret counter value.
.inhibit_cy       (inhibit_cy       ), // Stop cycle counter incrementing.
.inhibit_tm       (inhibit_tm       ), // Stop time counter incrementing.
.inhibit_ir       (inhibit_ir       ), // Stop instret incrementing.
.trap_cpu         (trap_cpu         ), // A trap occured due to CPU
.trap_int         (trap_int         ), // A trap occured due to interrupt
.trap_cause       (trap_cause       ), // A trap occured due to interrupt
.trap_mtval       (trap_mtval       ), // Value associated with the trap.
.trap_pc          (trap_pc          )  // PC value associated with the trap.
);


//
// module: core_interrupts
//
//  Handles interrupt prioritisation and raising.
//
core_interrupts i_core_interrupts (
.g_clk        (g_clk            ), // global clock
.g_resetn     (g_resetn         ), // global active low sync reset.
.int_sw       (int_sw           ), // Software interrupt
.int_ext      (int_ext          ), // External interrupt
.int_ti       (int_ti           ), // Timer interrupt
.mtvec_base   (mtvec_base       ), // Current MTVEC base address.
.mtvec_mode   (mtvec_mode       ), // Current MTVEC vector mode.
.mstatus_mie  (mstatus_mie      ), // Global interrupt enable.
.mie_meie     (mie_meie         ), // External interrupt enable.
.mie_mtie     (mie_mtie         ), // Timer interrupt enable.
.mie_msie     (mie_msie         ), // Software interrupt enable.
.mip_meip     (mip_meip         ), // External interrupt pending
.mip_mtip     (mip_mtip         ), // Timer interrupt pending
.mip_msip     (mip_msip         ), // Software interrupt pending
.int_pending  (int_pending      ), // Pending but disabled.
.int_request  (int_request      ), // Pending and enabled, so taken.
.int_cause    (int_cause        ), // Cause code for the interrupt.
.int_tvec     (int_tvec         ), // Interrupt trap vector
.int_ack      (int_ack          )  // Interrupt taken acknowledge
);


//
// module: core_counters
//
//  Responsible for all performance counters and timers.
//
core_counters #(
.MMIO_BASE_ADDR(MMIO_BASE_ADDR),
.MMIO_BASE_MASK(MMIO_BASE_MASK),
.MEM_ADDR_W    (MEM_ADDR_W    )
) i_core_counters (
.g_clk           (g_clk           ), // global clock
.g_resetn        (g_resetn        ), // synchronous reset
.instr_ret       (instr_ret       ), // Instruction retired.
.timer_interrupt (int_ti          ), // Raise a timer interrupt
.ctr_time        (ctr_time        ), // The time counter value.
.ctr_cycle       (ctr_cycle       ), // The cycle counter value.
.ctr_instret     (ctr_instret     ), // The instret counter value.
.inhibit_cy      (inhibit_cy      ), // Stop cycle counter incrementing.
.inhibit_tm      (inhibit_tm      ), // Stop time counter incrementing.
.inhibit_ir      (inhibit_ir      ), // Stop instret incrementing.
.mmio_req        (mmio_req        ), // MMIO enable
.mmio_wen        (mmio_wen        ), // MMIO write enable
.mmio_addr       (mmio_addr       ), // MMIO address
.mmio_wdata      (mmio_wdata      ), // MMIO write data
.mmio_gnt        (mmio_gnt        ), // MMIO grant
.mmio_rdata      (mmio_rdata      ), // MMIO read data
.mmio_error      (mmio_error      )  // MMIO error
);


//
// module: core_mmio_mux
//
// Responsible for muxing the data memory bus between core internal
// and external accesses.
//
core_mmio_mux #(
.MMIO_BASE_ADDR(MMIO_BASE_ADDR),
.MMIO_BASE_MASK(MMIO_BASE_MASK),
.MEM_ADDR_W    (MEM_ADDR_W    )
) i_core_mmio_mux (
.g_clk           (g_clk           ), // Global clock
.g_resetn        (g_resetn        ), // Synchronous active low reset.
.int_dmem_req    (int_dmem_req    ), // Memory request
.int_dmem_addr   (int_dmem_addr   ), // Memory request address
.int_dmem_wen    (int_dmem_wen    ), // Memory request write enable
.int_dmem_strb   (int_dmem_strb   ), // Memory request write strobe
.int_dmem_wdata  (int_dmem_wdata  ), // Memory write data.
.int_dmem_gnt    (int_dmem_gnt    ), // Memory response valid
.int_dmem_err    (int_dmem_err    ), // Memory response error
.int_dmem_rdata  (int_dmem_rdata  ), // Memory response read data
.ext_dmem_req    (    dmem_req    ), // Memory request
.ext_dmem_addr   (    dmem_addr   ), // Memory request address
.ext_dmem_wen    (    dmem_wen    ), // Memory request write enable
.ext_dmem_strb   (    dmem_strb   ), // Memory request write strobe
.ext_dmem_wdata  (    dmem_wdata  ), // Memory write data.
.ext_dmem_gnt    (    dmem_gnt    ), // Memory response valid
.ext_dmem_err    (    dmem_err    ), // Memory response error
.ext_dmem_rdata  (    dmem_rdata  ), // Memory response read data
.mmio_req        (mmio_req        ), // MMIO enable
.mmio_wen        (mmio_wen        ), // MMIO write enable
.mmio_addr       (mmio_addr       ), // MMIO address
.mmio_wdata      (mmio_wdata      ), // MMIO write data
.mmio_gnt        (mmio_gnt        ), // Request grant.
.mmio_rdata      (mmio_rdata      ), // MMIO read data
.mmio_error      (mmio_error      )  // MMIO error
);


//
// Designer Assertions
// ------------------------------------------------------------

`ifdef DESIGNER_ASSERTION_CONTROL_FLOW_BUS

always @(posedge g_clk) if(g_resetn && $past(g_resetn)) begin
    
    cover(cf_valid);

    cover(cf_ack);

    cover(cf_valid && !cf_ack);

    cover(cf_valid &&  cf_ack);

    if($past(s2_cf_valid) && !$past(s2_cf_ack) && !s3_cf_valid) begin
        
        // Don't enforce these when s3_cf_valid is set, since
        // s3 takes precedence, and can cancel an s2 control flow
        // change request.
        
        assert($stable(s2_cf_target));
        assert($stable(s2_cf_valid ));

    end

    if($past(s3_cf_valid) && !$past(s3_cf_ack)) begin

        assert($stable(s3_cf_target));
        assert($stable(s3_cf_valid ));

    end

end

`endif

endmodule
