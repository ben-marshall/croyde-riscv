
//
// module: core_pipe_wb
//
//  Writeback stage. Responsible for GPR writebacks, CSR accesses,
//  Load data processing, trap raising.
//
module core_pipe_wb (

input  wire                 g_clk           , // Global clock
input  wire                 g_resetn        , // Global active low sync reset.

output wire                 s3_cf_valid     , // Control flow change?
input  wire                 s3_cf_ack       , // Control flow acknwoledged
output wire [         XL:0] s3_cf_target    , // Control flow destination

input  wire                 int_pending     , // Interrupt pending but disabled
input  wire                 int_request     , // Interrupt pending to be taken
input  wire [ CF_CAUSE_R:0] int_cause       , // Cause code for the interrupt.
input  wire [         XL:0] int_tvec        , // Interrupt trap vector
output wire                 int_ack         , // Interrupt taken acknowledge

input  wire                 s3_valid        , // New instruction ready
output wire                 s3_ready        , // WB ready for new instruciton.
input  wire                 s3_full         , // WB has an instr in it.
input  wire [         XL:0] s3_pc           , // Writeback stage PC
input  wire [         XL:0] s3_n_pc         , // Writeback stage next PC
input  wire [         31:0] s3_instr        , // Writeback stage instr word
input  wire [         XL:0] s3_wdata        , // Writeback stage instr word
input  wire [ REG_ADDR_R:0] s3_rd           , // Writeback stage instr word
input  wire [   LSU_OP_R:0] s3_lsu_op       , // Writeback LSU op
input  wire [   CSR_OP_R:0] s3_csr_op       , // Writeback CSR op
input  wire [         11:0] s3_csr_addr     , // CSR Address
input  wire [   CFU_OP_R:0] s3_cfu_op       , // Writeback CFU op
input  wire [    WB_OP_R:0] s3_wb_op        , // Writeback Data source.
input  wire                 s3_trap         , // Raise a trap

output wire                 s3_fwd_rd_wen   , // RD write en for fwd network
output wire                 s3_rd_wen       , // RD write enable
output wire [ REG_ADDR_R:0] s3_rd_addr      , // RD write addr
output wire [         XL:0] s3_rd_wdata     , // RD write data.

output wire                 csr_en          , // CSR Access Enable
output wire                 csr_wr          , // CSR Write Enable
output wire                 csr_wr_set      , // CSR Write - Set
output wire                 csr_wr_clr      , // CSR Write - Clear
output wire [         11:0] csr_addr        , // Address of the CSR to access.
output wire [         XL:0] csr_wdata       , // Data to be written to a CSR
input  wire [         XL:0] csr_rdata       , // CSR read data
input  wire                 csr_error       , // Bad CSR access

input  wire [         XL:0] mtvec_base      , // Current trap vector addr
input  wire [         XL:0] csr_mepc        , // Current mepc

input  wire                 mode_m          , // Currently in Machine mode.
input  wire                 mode_u          , // Currently in User    mode.
input  wire                 mstatus_tw      , // Timeout wait for WFI.

output wire                 trap_cpu        , // trap occured due to CPU
output wire                 trap_int        , // trap occured due to interrupt
output wire [ CF_CAUSE_R:0] trap_cause      , // 
output wire [         XL:0] trap_mtval      , // Value associated with trap.
output wire [         XL:0] trap_pc         , // PC associated with the trap.

output wire                 exec_mret       , // MRET instruction executed.
output wire                 instr_ret       ,

input  wire                 dmem_req        , // Memory request
input  wire [ MEM_ADDR_R:0] dmem_addr       , // Memory request address
input  wire                 dmem_wen        , // Memory request write enable
input  wire [ MEM_STRB_R:0] dmem_strb       , // Memory request write strobe
input  wire [ MEM_DATA_R:0] dmem_wdata      , // Memory write data.
input  wire                 dmem_gnt        , // Memory response valid
input  wire                 dmem_err        , // Memory response error
input  wire [ MEM_DATA_R:0] dmem_rdata      , // Memory response read data

`ifdef RVFI
input  wire [ REG_ADDR_R:0] s3_rs1_addr     ,
input  wire [ REG_ADDR_R:0] s3_rs2_addr     ,
input  wire [         XL:0] s3_rs1_rdata    ,
input  wire [         XL:0] s3_rs2_rdata    ,
input  wire                 s3_dmem_valid   ,
input  wire [ MEM_ADDR_R:0] s3_dmem_addr    ,
input  wire [ MEM_STRB_R:0] s3_dmem_strb    ,
input  wire [ MEM_DATA_R:0] s3_dmem_wdata   ,
`DA_CSR_INPUTS(_s3)                         ,
`DA_CSR_OUTPUTS(wire,_out)                  ,
`RVFI_OUTPUTS                               ,
`endif

output wire                 wfi_sleep       , // Core asleep due to WFI.

output wire                 trs_valid       , // Instruction trace valid
output wire [         31:0] trs_instr       , // Instruction trace data
output wire [         XL:0] trs_pc            // Instruction trace PC

);


// Common parameters and width definitions.
`include "core_common.svh"

//
// MISC Useful signals
// ------------------------------------------------------------

// A new instruction will arrive on the next cycle.
wire   e_new_instr  =  s3_valid && s3_ready;

wire   e_instr_ret  =  e_new_instr && s3_full ||
                       s3_full && trapped && e_cf_change;

assign instr_ret    =  e_instr_ret;

wire   e_cf_change  = s3_cf_valid && s3_cf_ack;

assign s3_ready     = !s3_full  || s3_full && !cfu_wait;


//
// GPR Writeback control
// ------------------------------------------------------------

reg       rd_wen_enable;

always  @(posedge g_clk) begin
    if(!g_resetn) begin
        rd_wen_enable <= 1'b0;
    end else if(e_new_instr) begin
        rd_wen_enable <= 1'b1;
    end else if(s3_rd_wen) begin
        rd_wen_enable <= 1'b0;
    end
end

wire    wb_none    = s3_wb_op == WB_OP_NONE    ;
wire    wb_wdata   = s3_wb_op == WB_OP_WDATA   ;
wire    wb_lsu     = s3_wb_op == WB_OP_LSU     ;
wire    wb_csr     = s3_wb_op == WB_OP_CSR     ;

wire    wb_gpr_any = wb_wdata || lsu_wen || wb_csr;

// Faster write enable signal without cancelation due to a CPU trap.
// Used for the forwarding network only.
assign  s3_fwd_rd_wen = rd_wen_enable && s3_full && wb_gpr_any;

// Slower write enable signal which is cleared on a trap, used for the
// actual GPR register write enables.
assign  s3_rd_wen  =  s3_fwd_rd_wen     &&
                     !trap_cpu          &&
                     !trapped           ;


assign  s3_rd_wdata=
    {XLEN{wb_wdata  }}  & s3_wdata  |
    {XLEN{wb_lsu    }}  & lsu_rdata |
    {XLEN{wb_csr    }}  & csr_rdata ;

assign  s3_rd_addr = s3_rd          ;

//
// CSR Control
// ------------------------------------------------------------

reg     csr_op_error  ;
reg     csr_op_done   ;

always @(posedge g_clk) begin
    if(!g_resetn) begin
        csr_op_done <= 1'b0;
        csr_op_error<= 1'b0;
    end else if(e_new_instr) begin
        csr_op_done <= 1'b0;
        csr_op_error<= 1'b0;
    end else if(csr_en) begin
        csr_op_done <= 1'b1;
        csr_op_error<= csr_error;
    end
end

wire    trap_csr    = csr_en      && csr_error      ||
                      csr_op_done && csr_op_error   ;

wire    csr_op_rd   = s3_full && s3_csr_op[CSR_OP_RD ];
wire    csr_op_wr   = s3_full && s3_csr_op[CSR_OP_WR ];
wire    csr_op_set  = s3_full && s3_csr_op[CSR_OP_SET];
wire    csr_op_clr  = s3_full && s3_csr_op[CSR_OP_CLR];
        
wire    csr_op_any  = csr_op_rd || csr_op_wr || csr_op_set || csr_op_clr;

assign  csr_en      = !csr_op_done && csr_op_any;

assign  csr_wr      = csr_op_wr     ;
assign  csr_wr_set  = csr_op_set    ;
assign  csr_wr_clr  = csr_op_clr    ;
assign  csr_addr    = s3_csr_addr   ;
assign  csr_wdata   = s3_wdata      ;


//
// LSU Control
// ------------------------------------------------------------

wire [ 5:0] data_shift     = {s3_wdata[2:0], 3'b000};

wire        lsu_wen        = lsu_load               ;

//
// Read data positioning.

wire [XL:0] lsu_rdata;

wire        lsu_load       = s3_lsu_op[LSU_OP_LOAD  ];
wire        lsu_store      = s3_lsu_op[LSU_OP_STORE ];
wire        lsu_byte       = s3_lsu_op[LSU_OP_BYTE  ];
wire        lsu_half       = s3_lsu_op[LSU_OP_HALF  ];
wire        lsu_word       = s3_lsu_op[LSU_OP_WORD  ];
wire        lsu_double     = s3_lsu_op[LSU_OP_DOUBLE];
wire        lsu_sext       = s3_lsu_op[LSU_OP_SEXT  ];

wire [XL:0] rdata_shifted  = dmem_rdata >> data_shift;

wire [XL:0] mask_ls_byte   = {56'h0,  8'hFF};
wire [XL:0] mask_ls_half   = {48'h0, 16'hFFFF};
wire [XL:0] mask_ls_word   = {32'h0, 32'hFFFFFFFF};

wire [XL:0] sext_byte      = {{56{lsu_sext && rdata_shifted[ 7]}},  8'b0};
wire [XL:0] sext_half      = {{48{lsu_sext && rdata_shifted[15]}}, 16'b0};
wire [XL:0] sext_word      = {{32{lsu_sext && rdata_shifted[31]}}, 32'b0};

wire [XL:0] rdata_byte     = (rdata_shifted & mask_ls_byte) | sext_byte;
wire [XL:0] rdata_half     = (rdata_shifted & mask_ls_half) | sext_half;
wire [XL:0] rdata_word     = (rdata_shifted & mask_ls_word) | sext_word;

assign      lsu_rdata      =
    lsu_byte    ? rdata_byte    :
    lsu_half    ? rdata_half    :
    lsu_word    ? rdata_word    :
                  dmem_rdata ;

reg         p_lsu_req      ;
always @(posedge g_clk) begin
    if(!g_resetn) begin
        p_lsu_req <= 1'b0;
    end else begin
        p_lsu_req <= dmem_req && dmem_gnt;
    end
end

wire        lsu_trap_load  = lsu_load   && dmem_err && p_lsu_req;
wire        lsu_trap_store = lsu_store  && dmem_err && p_lsu_req;
wire        trap_lsu       = lsu_trap_load || lsu_trap_store;


//
// Control flow changes
// ------------------------------------------------------------

reg         cf_done      ; // Enforce 1 control flow change per instruction.

always @(posedge g_clk) begin
    if(!g_resetn || e_new_instr) begin
        cf_done <= 1'b0;
    end else begin
        cf_done <= cf_done || (s3_cf_valid && s3_cf_ack);
    end
end

wire        cfu_wfi      = s3_cfu_op == CFU_OP_WFI  && s3_full;

// Trap the WFI as in user mode and mstatus.tw=1
wire        cfu_wfi_trap = cfu_wfi && !mode_m && mstatus_tw;

// Execute the WFI - wait for the interrupt.
wire        cfu_wfi_ex   = cfu_wfi && (mode_m || !mstatus_tw);

// Execute an MRET instruction.
wire        cfu_mret     = s3_cfu_op == CFU_OP_MRET && s3_full;

// Wait for interrupt instruction.

reg         wfi_woken    ;
wire      n_wfi_woken    = wfi_woken ? !e_new_instr : wfi_wakeup && !e_new_instr;

always @(posedge g_clk) begin
    if(!g_resetn) begin
        wfi_woken <= 1'b0;
    end else begin
        wfi_woken <= n_wfi_woken;
    end
end

assign      wfi_sleep    = cfu_wfi_ex && !int_pending && !wfi_woken;
wire        wfi_wakeup   = cfu_wfi_ex &&  int_pending;

wire        cfu_wait     = s3_cf_valid && !s3_cf_ack    ||
                           wfi_sleep                    ;

assign      s3_cf_target = cfu_mret     ?   csr_mepc    :
                           raise_int    ?   int_tvec    :
                                            mtvec_base  ;

assign      s3_cf_valid  = !cf_done && (
    r_trapped || trap_cpu || raise_int || cfu_mret
);

assign      exec_mret    = cfu_mret && e_instr_ret;

//
// Traps and interrupts.
// ------------------------------------------------------------

// Raise trap due to CFU in previous cycle.
wire   trap_cfu       = s3_cfu_op == CFU_OP_TRAP;

wire   trapped        = trap_cpu || r_trapped;
reg    r_trapped      ;

always @(posedge g_clk) begin
    if(!g_resetn || e_new_instr) begin
        r_trapped <= 1'b0;
    end else begin
        r_trapped <= trapped;
    end
end

reg    delay_int_request  ;
always @(posedge g_clk) if(!g_resetn) begin
    delay_int_request <= 1'b0;
end else begin
    delay_int_request <= dmem_req && !dmem_gnt;
end

wire   raise_int      = int_request && !delay_int_request;

assign int_ack        = raise_int && e_cf_change;

// trap occured due to CPU
assign trap_cpu       = s3_full && !raise_int && (
    s3_trap     ||
    trap_cfu    ||
    trap_csr    ||
    trap_lsu    ||
    cfu_wfi_trap
);

assign trap_int       = int_ack; // trap occured due to interrupt

wire   cause_iopcode  = csr_error || cfu_wfi_trap;

assign trap_cause     = raise_int       ? int_cause             :
                        s3_trap         ? {2'b00, s3_rd       } :
                        lsu_trap_load   ? TRAP_LDACCESS         :
                        lsu_trap_store  ? TRAP_STACCESS         :
                        cause_iopcode   ? TRAP_IOPCODE          :
                                        'b0                     ;

assign trap_mtval     = 0 ;

// - should be n_s3_pc iff we are trapping due to an interrupt.
// - Note that if the interrupted instruction is a control flow
//   change, then we must still select the next *natural* PC, not the
//   target of the contrl flow change.
assign trap_pc        = trap_int ? s3_n_pc : s3_pc;

//
// Trace
// ------------------------------------------------------------

assign trs_valid = e_instr_ret  ;
assign trs_pc    = s3_pc        ;
assign trs_instr = s3_instr     ;


//
// RVFI Interface
// ------------------------------------------------------------

`ifdef RVFI

reg  r_int_on_this_instr ;
wire   int_on_this_instr = trap_int || r_int_on_this_instr;

wire [1:0] s3_mode         = mode_m ? 2'b11 : 2'b00;

reg    int_on_prev_instr ;

always @(posedge g_clk) begin
    if(!g_resetn) begin
        r_int_on_this_instr <= 1'b0;
        int_on_prev_instr   <= 1'b0;
    end else if(e_instr_ret) begin
        r_int_on_this_instr <= 1'b0;
        int_on_prev_instr   <= int_on_this_instr;
    end else begin
        r_int_on_this_instr <= int_on_this_instr;
    end
end


wire                  n_rvfi_intr           = int_on_prev_instr;
wire                  n_rvfi_trap           = trap_cpu;

wire                  n_rvfi_mem_req_valid  = lsu_load || lsu_store;
wire                  rvfi_mem_req          = dmem_req && dmem_gnt;
reg                   n_rvfi_mem_rsp_valid  ;

always @(posedge g_clk) begin
    if(!g_resetn) n_rvfi_mem_rsp_valid     <= 1'b0;
    else          n_rvfi_mem_rsp_valid     <= rvfi_mem_req;
end

wire [XLEN/8 - 1 : 0] n_rvfi_mem_rmask    = lsu_store ? 8'b0 : s3_dmem_strb;
wire [XLEN/8 - 1 : 0] n_rvfi_mem_wmask    = lsu_store ? s3_dmem_strb : 8'b0;

core_rvfi i_core_rvfi (
.g_clk              (g_clk                  ),
.g_resetn           (g_resetn               ),
`RVFI_CONN                                   ,
`DA_CSR_CONN(_s3,_s3)                        ,
`DA_CSR_CONN(_out,_out)                      ,
.n_valid            (e_instr_ret            ),
.n_insn             (s3_instr               ),
.n_intr             (int_on_this_instr      ),
.n_trap             (n_rvfi_trap            ),
.n_rs1_addr         (s3_rs1_addr            ),
.n_rs2_addr         (s3_rs2_addr            ),
.n_rs1_rdata        (s3_rs1_rdata           ),
.n_rs2_rdata        (s3_rs2_rdata           ),
.n_rd_valid         (s3_rd_wen              ),
.n_rd_addr          (s3_rd_addr             ),
.n_rd_wdata         (s3_rd_wdata            ),
.n_cf_change        (e_cf_change            ),
.n_cf_target        (s3_cf_target           ),
.n_pc_rdata         (s3_pc                  ),
.n_pc_wdata         (s3_n_pc                ),
.n_mode             (s3_mode                ),
.n_mem_req_valid    (n_rvfi_mem_req_valid   ),
.n_mem_rsp_valid    (n_rvfi_mem_rsp_valid   ),
.n_mem_addr         (s3_dmem_addr           ),
.n_mem_rmask        (n_rvfi_mem_rmask       ),
.n_mem_wmask        (n_rvfi_mem_wmask       ),
.n_mem_rdata        (dmem_rdata             ),
.n_mem_wdata        (s3_dmem_wdata          )
);

`endif

endmodule

