
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
parameter   PC_RESET_ADDRESS      = 64'h10000000;

// Base address of the memory mapped IO region.
parameter   MMIO_BASE_ADDR  = 64'h0000_0000_0000_1000;
parameter   MMIO_BASE_MASK  = 64'h0000_0000_0000_1FFF;

//
// Control flow change busses
// ------------------------------------------------------------

// See also: DESIGNER_ASSERTION_CONTROL_FLOW_BUS
wire                 cf_valid    ; // Control flow change?
wire                 cf_ack      ; // Control flow change acknwoledged
wire [         XL:0] cf_target   ; // Control flow change destination
wire [ CF_CAUSE_R:0] cf_cause    ; // Control flow change cause

wire                 int_pending ; // To exec stage from core_interrupts
wire [ CF_CAUSE_R:0] int_cause   ; // Cause code for the interrupt.
wire [         XL:0] int_tvec    ; // Interrupt trap vector
wire                 int_ack     ; // Interrupt taken acknowledge

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

`ifdef RVFI
wire [ REG_ADDR_R:0] s2_rs1_a    ;
wire [         XL:0] s2_rs1_d    ;
wire [ REG_ADDR_R:0] s2_rs2_a    ;
wire [         XL:0] s2_rs2_d    ;
`endif

wire                 s2_rd_wen   ;
wire [ REG_ADDR_R:0] s2_rd_addr  ;
wire [         XL:0] s2_rd_wdata ;


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
wire [         XL:0] mmio_addr   ; // MMIO address
wire [         XL:0] mmio_wdata  ; // MMIO write data
wire                 mmio_gnt    ; // MMIO grant
wire [         XL:0] mmio_rdata  ; // MMIO read data
wire                 mmio_error  ; // MMIO error

//
// Submodule instances.
// ------------------------------------------------------------


//
// Instance: core_pipe_fetch
//
//  Pipeline Fetch Stage
//
core_pipe_fetch #(
.PC_RESET_ADDRESS(PC_RESET_ADDRESS)
) i_core_pipe_fetch (
.g_clk        (g_clk        ), // Global clock
.g_resetn     (g_resetn     ), // Global active low sync reset.
.cf_valid     (cf_valid     ), // Control flow change?
.cf_ack       (cf_ack       ), // Control flow change acknwoledged
.cf_target    (cf_target    ), // Control flow change destination
.cf_cause     (cf_cause     ), // Control flow change cause
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
// Instance: core_pipe_decode
//
//  Pipeline decode / operand gather stage.
//
core_pipe_decode #(
.PC_RESET_ADDRESS(PC_RESET_ADDRESS)
) i_core_pipe_decode(
.g_clk        (g_clk        ), // Global clock
.g_resetn     (g_resetn     ), // Global active low sync reset.
.s1_i16bit    (s1_i16bit    ), // 16 bit instruction?
.s1_i32bit    (s1_i32bit    ), // 32 bit instruction?
.s1_instr     (s1_instr     ), // Instruction to be decoded
.s1_ferr      (s1_ferr      ), // Fetch bus error?
.s1_eat_2     (s1_eat_2     ), // Decode eats 2 bytes
.s1_eat_4     (s1_eat_4     ), // Decode eats 4 bytes
.s1_flush     (s1_flush     ), // Flush stage
.cf_valid     (cf_valid     ), // Control flow change?
.cf_ack       (cf_ack       ), // Control flow change acknwoledged
.cf_target    (cf_target    ), // Control flow change destination
.cf_cause     (cf_cause     ), // Control flow change cause
.s1_rs1_addr  (s1_rs1_addr  ), // RS1 Address
.s1_rs1_data  (s1_rs1_data  ), // RS1 Read Data (Forwarded)
.s1_rs2_addr  (s1_rs2_addr  ), // RS2 Address
.s1_rs2_data  (s1_rs2_data  ), // RS2 Read Data (Forwarded)
`ifdef RVFI
.s2_rs1_a     (s2_rs1_a     ),
.s2_rs1_d     (s2_rs1_d     ),
.s2_rs2_a     (s2_rs2_a     ),
.s2_rs2_d     (s2_rs2_d     ),
`endif
.s2_valid     (s2_valid     ), // Decode instr ready for execute
.s2_ready     (s2_ready     ), // Execute ready for new instr.
.s2_full      (s2_full      ), // Instruction present in regs?
.s2_trap      (s2_trap      ), // Raise trap. Cause in RD
.s2_pc        (s2_pc        ), // Execute stage PC
.s2_npc       (s2_npc       ), // Decode stage PC
.s2_opr_a     (s2_opr_a     ), // EX stage operand a
.s2_opr_b     (s2_opr_b     ), //    "       "     b
.s2_opr_c     (s2_opr_c     ), //    "       "     c
.s2_rd        (s2_rd        ), // EX stage destination reg address.
.s2_alu_op    (s2_alu_op    ), // ALU operation
.s2_lsu_op    (s2_lsu_op    ), // LSU operation
.s2_mdu_op    (s2_mdu_op    ), // Mul/Div Operation
.s2_csr_op    (s2_csr_op    ), // CSR operation
.s2_cfu_op    (s2_cfu_op    ), // Control flow unit operation
.s2_op_w      (s2_op_w      ), // Is the operation on a word?
.s2_instr     (s2_instr     )  // Encoded instruction for trace.
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
.rs1_data (s1_rs1_data ),
.rs2_data (s1_rs2_data ),
.rd_wen   (s2_rd_wen   ),
.rd_addr  (s2_rd_addr  ),
.rd_wdata (s2_rd_wdata ) 
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
.int_pending  (int_pending      ), // To exec stage
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
.MMIO_BASE_MASK(MMIO_BASE_MASK)
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
.MMIO_BASE_MASK(MMIO_BASE_MASK)
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

    if($past(cf_valid) && !$past(cf_ack)) begin
        
        assert($stable(cf_target));
        
        assert($stable(cf_cause ));

    end

end

`endif

endmodule
