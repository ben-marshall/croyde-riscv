
`include "core_interfaces.svh"

//
// Module: core_top 
//
//  The top level module of the core.
//
module core_top (

input  wire                 g_clk        , // Global clock
input  wire                 g_resetn     , // Global active low sync reset.
              
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
core_rvfi.OUT               rvfi         , // Formal checker interface.
`endif

output wire                 trs_valid    , // Instruction trace valid
output wire [         31:0] trs_instr    , // Instruction trace data
output wire [         XL:0] trs_pc         // Instruction trace PC

);


// Common parameters and width definitions.
`include "core_common.svh"

// Inital address of the program counter post reset.
parameter   PC_RESET_ADDRESS      = 64'h80000000;

// TODO implement trace interface proper.
assign trs_valid = 1'b0;
assign trs_instr = 32'b0;
assign trs_pc    = 64'b0;

//
// Memory Interface Unpacking
// ------------------------------------------------------------

core_mem_if if_imem();

assign imem_req         = if_imem.req   ;
assign imem_addr        = if_imem.addr  ;
assign imem_wen         = if_imem.wen   ;
assign imem_strb        = if_imem.strb  ;
assign imem_wdata       = if_imem.wdata ;
assign if_imem.gnt      = imem_gnt      ;
assign if_imem.err      = imem_err      ;
assign if_imem.rdata    = imem_rdata    ;

core_mem_if if_dmem();

assign dmem_req         = if_dmem.req   ;
assign dmem_addr        = if_dmem.addr  ;
assign dmem_wen         = if_dmem.wen   ;
assign dmem_strb        = if_dmem.strb  ;
assign dmem_wdata       = if_dmem.wdata ;
assign if_dmem.gnt      = dmem_gnt      ;
assign if_dmem.err      = dmem_err      ;
assign if_dmem.rdata    = dmem_rdata    ;

//
// Control flow change busses
// ------------------------------------------------------------

wire                 cf_valid    ; // Control flow change?
wire                 cf_ack      ; // Control flow change acknwoledged
wire [         XL:0] cf_target   ; // Control flow change destination
wire [ CF_CAUSE_R:0] cf_cause    ; // Control flow change cause

wire                 s1_cf_valid ; // DE Control flow change?
wire                 s1_cf_ack   ; // DE Control flow change acknwoledged
wire [         XL:0] s1_cf_target; // DE Control flow change destination
wire [ CF_CAUSE_R:0] s1_cf_cause ; // DE Control flow change cause

wire                 s2_cf_valid ; // EX Control flow change?
wire                 s2_cf_ack   ; // EX Control flow change acknwoledged
wire [         XL:0] s2_cf_target; // EX Control flow change destination
wire [ CF_CAUSE_R:0] s2_cf_cause ; // EX Control flow change cause

assign cf_valid     = s1_cf_valid || s2_cf_valid;

assign s1_cf_ack    = cf_ack;
assign s2_cf_ack    = cf_ack;

assign cf_cause     = s2_cf_valid ? s2_cf_cause     : s1_cf_cause   ;
assign cf_target    = s2_cf_valid ? s2_cf_target    : s1_cf_target  ;

wire   s1_flush     = cf_valid && cf_ack;

//
// Inter-stage wiring
// ------------------------------------------------------------

core_pipe_fd                s1() ; // Fetch -> decode interface.

wire [ REG_ADDR_R:0] s1_rs1_addr ; // RS1 Address
wire [         XL:0] s1_rs1_data ; // RS1 Read Data (Forwarded)
wire [ REG_ADDR_R:0] s1_rs2_addr ; // RS2 Address
wire [         XL:0] s1_rs2_data ; // RS2 Read Data (Forwarded)

core_pipe_de                s2() ; // Decode -> Execute interface.

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
wire [         XL:0] csr_mtvec   ; // Current MTVEC.
               
wire                 exec_mret   =0; // MRET instruction executed.
               
wire                 mstatus_mie ; // Global interrupt enable.
wire                 mie_meie    ; // External interrupt enable.
wire                 mie_mtie    ; // Timer interrupt enable.
wire                 mie_msie    ; // Software interrupt enable.
               
wire                 mip_meip    =0; // External interrupt pending
wire                 mip_mtip    =0; // Timer interrupt pending
wire                 mip_msip    =0; // Software interrupt pending
               
wire [         63:0] ctr_time    =0; // The time counter value.
wire [         63:0] ctr_cycle   =0; // The cycle counter value.
wire [         63:0] ctr_instret =0; // The instret counter value.
               
wire                 inhibit_cy  ; // Stop cycle counter incrementing.
wire                 inhibit_tm  ; // Stop time counter incrementing.
wire                 inhibit_ir  ; // Stop instret incrementing.
               
wire                 trap_cpu    =0; // A trap occured due to CPU
wire                 trap_int    =0; // A trap occured due to interrupt
wire [          5:0] trap_cause  =0; // A trap occured due to interrupt
wire [         XL:0] trap_mtval  =0; // Value associated with the trap.
wire [         XL:0] trap_pc     =0; // PC value associated with the trap.

//
// Submodule instances.
// ------------------------------------------------------------


//
// Instance: core_pipe_fetch
//
//  Pipeline Fetch Stage
//
core_pipe_fetch i_core_pipe_fetch (
.g_clk        (g_clk        ), // Global clock
.g_resetn     (g_resetn     ), // Global active low sync reset.
.cf_valid     (cf_valid     ), // Control flow change?
.cf_ack       (cf_ack       ), // Control flow change acknwoledged
.cf_target    (cf_target    ), // Control flow change destination
.cf_cause     (cf_cause     ), // Control flow change cause
.if_imem      (if_imem      ), // Memory requests
.s1           (s1           )  // Fetch -> Decode interface
);


//
// Instance: core_pipe_decode
//
//  Pipeline decode / operand gather stage.
//
core_pipe_decode i_core_pipe_decode(
.g_clk       (g_clk       ), // Global clock
.g_resetn    (g_resetn    ), // Global active low sync reset.
.s1          (s1          ), // Fetch -> Decode interface
.s1_flush    (s1_flush    ), // Flush stage
.s1_cf_valid (s1_cf_valid ), // Control flow change?
.s1_cf_ack   (s1_cf_ack   ), // Control flow change acknwoledged
.s1_cf_target(s1_cf_target), // Control flow change destination
.s1_cf_cause (s1_cf_cause ), // Control flow change cause
.s1_rs1_addr (s1_rs1_addr ), // RS1 Address
.s1_rs1_data (s1_rs1_data ), // RS1 Read Data (Forwarded)
.s1_rs2_addr (s1_rs2_addr ), // RS2 Address
.s1_rs2_data (s1_rs2_data ), // RS2 Read Data (Forwarded)
.s2          (s2          )  // Decode -> Execute
);


//
// Instance: core_pipe_exec
//
//  Top level for the execute stage of the pipeline.
//
core_pipe_exec i_core_pipe_exec(
.g_clk          (g_clk          ), // Global clock
.g_resetn       (g_resetn       ), // Global active low sync reset.
`ifdef RVFI
.rvfi           (rvfi           ), // Formal checker interface.
`endif
.s2             (s2             ), // Decode -> Execute
.s2_rd_wen      (s2_rd_wen      ), // GPR write enable
.s2_rd_addr     (s2_rd_addr     ), // GPR write address
.s2_rd_wdata    (s2_rd_wdata    ), // GPR write data
.csr_en         (csr_en         ), // CSR Access Enable
.csr_wr         (csr_wr         ), // CSR Write Enable
.csr_wr_set     (csr_wr_set     ), // CSR Write - Set
.csr_wr_clr     (csr_wr_clr     ), // CSR Write - Clear
.csr_addr       (csr_addr       ), // Address of the CSR to access.
.csr_wdata      (csr_wdata      ), // Data to be written to a CSR
.csr_rdata      (csr_rdata      ), // CSR read data
.csr_mepc       (csr_mepc       ), // Current MEPC  value
.csr_mtvec      (csr_mtvec      ), // Current MTVEC value
.csr_error      (csr_error      ), // CSR access error.
.s2_cf_valid    (s2_cf_valid    ), // EX Control flow change?
.s2_cf_ack      (s2_cf_ack      ), // EX Control flow acknwoledged
.s2_cf_target   (s2_cf_target   ), // EX Control flow destination
.s2_cf_cause    (s2_cf_cause    ), // EX Control flow change cause
.if_dmem        (if_dmem        )  // Memory requests
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
.csr_mtvec        (csr_mtvec        ), // Current MTVEC.
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

endmodule
