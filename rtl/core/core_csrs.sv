
//
// module: core_csrs
//
//  Responsible for keeping control/status registers up to date.
//
module core_csrs (

input              g_clk            , // global clock
input              g_resetn         , // synchronous reset

input              csr_en           , // CSR Access Enable
input              csr_wr           , // CSR Write Enable
input              csr_wr_set       , // CSR Write - Set
input              csr_wr_clr       , // CSR Write - Clear
input       [11:0] csr_addr         , // Address of the CSR to access.
input       [XL:0] csr_wdata        , // Data to be written to a CSR
output wire [XL:0] csr_rdata        , // CSR read data
output wire        csr_error        , // Bad CSR access

output wire [XL:0] csr_mepc         , // Current EPC.
output wire [XL:0] mtvec_base       , // Current MTVEC base address.
output wire [ 1:0] mtvec_mode       , // Current MTVEC vector mode.

input  wire        exec_mret        , // MRET instruction executed.

output reg         mode_m           , // Currently in Machine mode.
output reg         mode_u           , // Currently in User    mode.

`ifdef RVFI
`DA_CSR_OUTPUTS(wire,)              , // CSR Value tracing.
`endif

output wire        mstatus_tw       , // Timeout wait for WFI.
output wire        mstatus_mie      , // Global interrupt enable.
output wire        mstatus_mprv_m   , // Memory access like machine mode.
output wire        mstatus_mprv_u   , // Memory access like user    mode.
output reg         mie_meie         , // External interrupt enable.
output reg         mie_mtie         , // Timer interrupt enable.
output reg         mie_msie         , // Software interrupt enable.

input  wire        mip_meip         , // External interrupt pending
input  wire        mip_mtip         , // Timer interrupt pending
input  wire        mip_msip         , // Software interrupt pending

input  wire [63:0] ctr_time         , // The time counter value.
input  wire [63:0] ctr_cycle        , // The cycle counter value.
input  wire [63:0] ctr_instret      , // The instret counter value.

output wire        inhibit_cy       , // Stop cycle counter incrementing.
output wire        inhibit_tm       , // Stop time counter incrementing.
output wire        inhibit_ir       , // Stop instret incrementing.

input  wire        trap_cpu         , // A trap occured due to CPU
input  wire        trap_int         , // A trap occured due to interrupt
input  wire [CF_CAUSE_R:0] trap_cause, // A trap occured due to interrupt
input  wire [XL:0] trap_mtval       , // Value associated with the trap.
input  wire [XL:0] trap_pc            // PC value associated with the trap.

);

// Common core parameters and constants
`include "core_common.svh"

//
// CSR addresses and constant values.
// -------------------------------------------------------------------------

localparam ADDR_CYCLE       = 12'hC00;
localparam ADDR_TIME        = 12'hC01;
localparam ADDR_INSTRET     = 12'hC02;

localparam ADDR_MCYCLE      = 12'hB00;
localparam ADDR_MINSTRET    = 12'hB02;

localparam ADDR_MCOUNTIN    = 12'h320;

localparam ADDR_MSTATUS     = 12'h300;
localparam ADDR_MISA        = 12'h301;
localparam ADDR_MEDELEG     = 12'h302;
localparam ADDR_MIDELEG     = 12'h303;
localparam ADDR_MIE         = 12'h304;
localparam ADDR_MTVEC       = 12'h305;

localparam ADDR_MSCRATCH    = 12'h340;
localparam ADDR_MEPC        = 12'h341;
localparam ADDR_MCAUSE      = 12'h342;
localparam ADDR_MTVAL       = 12'h343;
localparam ADDR_MIP         = 12'h344;

localparam ADDR_MVENDORID   = 12'hF11;
localparam ADDR_MARCHID     = 12'hF12;
localparam ADDR_MIMPID      = 12'hF13;
localparam ADDR_MHARTID     = 12'hF14;


//
// CSR: MISA
// -------------------------------------------------------------------------

wire [   1:0] reg_misa_mxl        = 2'b10;    // XLEN=64
wire [XL-2:0] reg_misa_extensions = 62'b100000101;
wire [XL  :0] reg_misa = {
    reg_misa_mxl,
    reg_misa_extensions
};


//
// CSR: constants
// -------------------------------------------------------------------------

parameter   MVENDORID           = 64'b0;
parameter   MARCHID             = 64'b0;
parameter   MIMPID              = 64'b0;
parameter   MHARTID             = 64'b0;

wire [XL:0] reg_mvendorid       = MVENDORID;
wire [XL:0] reg_marchid         = MARCHID;
wire [XL:0] reg_mimpid          = MIMPID;
wire [XL:0] reg_mhartid         = MHARTID;

wire [XL:0] reg_medeleg         = 64'b0;
wire [XL:0] reg_mideleg         = 64'b0;


//
// CSR: MIP / MIE
// -------------------------------------------------------------------------

wire [XL:0] reg_mip = {52'b0,mip_meip,3'b0,mip_mtip,3'b0,mip_msip,3'b0};

wire wen_mie = mode_m && csr_en && csr_wr  && csr_addr == ADDR_MIE;

wire [XL:0] reg_mie = {52'b0,mie_meie,3'b0,mie_mtie,3'b0,mie_msie,3'b0};

wire [XL:0] n_reg_mie = 
    csr_wr_set ? reg_mie |  csr_wdata :
    csr_wr_clr ? reg_mie & ~csr_wdata :
                            csr_wdata ;

always @(posedge g_clk) begin
    if(!g_resetn) begin
        mie_meie <= 1'b0;
        mie_mtie <= 1'b0;
        mie_msie <= 1'b0;
    end else if(wen_mie) begin
        mie_meie <= n_reg_mie[11];
        mie_mtie <= n_reg_mie[ 7];
        mie_msie <= n_reg_mie[ 3];
    end
end


//
// CSR: MSTATUS
// -------------------------------------------------------------------------

localparam  MPP_M   = 2'b11;
localparam  MPP_U   = 2'b00;

wire        reg_mstatus_sd      = 0; // FS,XS always zero.
wire [ 1:0] reg_mstatus_uxl     = 2'b10; // UXL - UXLEN = 64 = MXLEN
reg  [ 7:0] reg_mstatus_wpri1      ;
wire        reg_mstatus_tsr     = 0; // Supervisor mode not implemented.
reg         reg_mstatus_tw      = 0; // WFI instruction not implemented.
wire        reg_mstatus_tvm     = 0; // Supervisor mode not implemented.
wire        reg_mstatus_mxr     = 0; // Supervisor mode not implemented.
wire        reg_mstatus_sum     = 0; // Supervisor mode not implemnted.
reg         reg_mstatus_mprv       ;
wire [ 1:0] reg_mstatus_xs      = 0; // No non-standard extensions.
wire [ 1:0] reg_mstatus_fs      = 0; // Floating point not implemented.
reg  [ 1:0] reg_mstatus_mpp        ; 
reg  [ 1:0] reg_mstatus_wpri2      ;
wire        reg_mstatus_spp     = 0; // N Ext not implemented
reg         reg_mstatus_mpie       ;
reg         reg_mstatus_wpri3      ;
wire        reg_mstatus_spie    = 0; // Supervisor mode not implemented
wire        reg_mstatus_upie    = 0; // N Ext not implemented
reg         reg_mstatus_mie        ;
reg         reg_mstatus_wpri4      ;
wire        reg_mstatus_sie     = 0; // Supervisor mode not implemented
wire        reg_mstatus_uie     = 0; // N Ext not implemented

// Machine level global interrupt enable.
assign      mstatus_mie     = reg_mstatus_mie;

// Timeout wait for WFI.
assign      mstatus_tw      = reg_mstatus_tw;

// Access memory as though in machine mode.
assign      mstatus_mprv_m  = !reg_mstatus_mprv || 
                               reg_mstatus_mprv && mstatus_mpp_m;

// Access memory as though in user mode.
assign      mstatus_mprv_u  =  reg_mstatus_mprv && mstatus_mpp_u;

wire [XL:0] reg_mstatus         = {
    reg_mstatus_sd    ,
    30'b0             ,
    reg_mstatus_uxl   ,
    reg_mstatus_wpri1 ,
    reg_mstatus_tsr   ,
    reg_mstatus_tw    ,
    reg_mstatus_tvm   ,
    reg_mstatus_mxr   ,
    reg_mstatus_sum   ,
    reg_mstatus_mprv  ,
    reg_mstatus_xs    ,
    reg_mstatus_fs    ,
    reg_mstatus_mpp   ,
    reg_mstatus_wpri2 ,
    reg_mstatus_spp   ,
    reg_mstatus_mpie  ,
    reg_mstatus_wpri3 ,
    reg_mstatus_spie  ,
    reg_mstatus_upie  ,
    reg_mstatus_mie   ,
    reg_mstatus_wpri4 ,
    reg_mstatus_sie   ,
    reg_mstatus_uie    
};

wire        wen_mstatus     = mode_m && csr_wr && csr_addr == ADDR_MSTATUS;
wire        wen_mstatus_mie = wen_mstatus || trap_cpu || trap_int || exec_mret;
wire        wen_mstatus_mpie= wen_mstatus || trap_cpu || trap_int || exec_mret;

wire        n_mstatus_mie       =
    trap_int      ? 1'b0                                :
    trap_cpu      ? 1'b0                                :
    exec_mret     ? reg_mstatus_mpie                    :
    csr_wr_set    ? reg_mstatus_mie |  csr_wdata[3] :
    csr_wr_clr    ? reg_mstatus_mie & ~csr_wdata[3] :
                    csr_wdata[3]                ;

wire        n_mstatus_mpie      = 
    trap_int      ? reg_mstatus_mie                 :
    trap_cpu      ? reg_mstatus_mie                 :
    exec_mret     ? 0                               :
    csr_wr_set    ? reg_mstatus_mie |  csr_wdata[7] :
    csr_wr_clr    ? reg_mstatus_mie & ~csr_wdata[7] :
                    csr_wdata[7]                    ;

wire        n_mstatus_tw        =
    csr_wr_set    ? reg_mstatus_mie |  csr_wdata[21]:
    csr_wr_clr    ? reg_mstatus_mie & ~csr_wdata[21]:
                    csr_wdata[21]                   ;

wire        n_mstatus_wpri4     = csr_wdata[ 2: 2];
wire        n_mstatus_wpri3     = csr_wdata[ 6: 6];
wire [ 1:0] n_mstatus_wpri2     = csr_wdata[10: 9];
wire [ 7:0] n_mstatus_wpri1     = csr_wdata[30:23];

wire        n_mstatus_mprv      = 
    exec_mret && !n_mode_m  ? 1'b0                              :
    csr_wr_set              ? reg_mstatus_mie |  csr_wdata[17]  :
    csr_wr_clr              ? reg_mstatus_mie & ~csr_wdata[17]  :
                              csr_wdata[17]                     ;


// TODO: csr instruction writes of mpp.
wire [ 1:0] n_mstatus_mpp = {n_mode_m, n_mode_m};
wire        mstatus_mpp_m = reg_mstatus_mpp == MPP_M;
wire        mstatus_mpp_u = reg_mstatus_mpp == MPP_U;

always @(posedge g_clk) begin
    if(!g_resetn) begin
        reg_mstatus_mprv <= 1'b0;
    end else begin
        reg_mstatus_mprv <= n_mstatus_mprv;
    end
end

always @(posedge g_clk) begin
    if(!g_resetn) begin
        reg_mstatus_mpp <= MPP_M;
    end else if(update_mode) begin
        reg_mstatus_mpp <= n_mstatus_mpp;
    end
end

always @(posedge g_clk) begin
    if(!g_resetn) begin
        reg_mstatus_mie  <= 0;
    end else if (wen_mstatus_mie) begin
        reg_mstatus_mie  <= n_mstatus_mie ;
    end
end

always @(posedge g_clk) begin
    if(!g_resetn) begin
        reg_mstatus_mpie  <= 0;
    end else if (wen_mstatus_mpie) begin
        reg_mstatus_mpie  <= n_mstatus_mpie ;
    end
end

always @(posedge g_clk) begin
    if(!g_resetn) begin
        reg_mstatus_wpri1 <= 0;
        reg_mstatus_wpri2 <= 0;
        reg_mstatus_wpri3 <= 0;
        reg_mstatus_wpri4 <= 0;
        reg_mstatus_tw    <= 1'b0;
    end else if (wen_mstatus) begin
        reg_mstatus_wpri1 <= n_mstatus_wpri1;
        reg_mstatus_wpri2 <= n_mstatus_wpri2;
        reg_mstatus_wpri3 <= n_mstatus_wpri3;
        reg_mstatus_wpri4 <= n_mstatus_wpri4;
        reg_mstatus_tw    <= n_mstatus_tw   ;
    end
end

//
// Current mode tracking.
// -------------------------------------------------------------------------

wire    n_mode_m = trap_cpu                         || 
                   trap_int                         ||
                   exec_mret    && mstatus_mpp_m    ;

wire    n_mode_u = !trap_cpu                        &&
                   !trap_int                        &&
                   exec_mret    && mstatus_mpp_u    ;

wire    update_mode = exec_mret || trap_cpu || trap_int;

always @(posedge g_clk) begin
    if(!g_resetn) begin
        mode_m <= 1'b1;
        mode_u <= 1'b0;
    end else if(update_mode) begin
        mode_m <= n_mode_m;
        mode_u <= n_mode_u;
    end
end

`ifdef DESIGNER_ASSERTION_CSR_MODE

always @(posedge g_clk) if(g_resetn) begin

    // We must always be in either Machine mode or User mode.
    assert(mode_m ^ mode_u);
    
    // Always access memory either as M mode or U Mode.
    assert(mstatus_mprv_m ^ mstatus_mprv_u);

    // mstats.MPP field must always have a valid value.
    assert(mstatus_mpp_m ^ mstatus_mpp_u);

end

`endif


//
// CSR: MTVEC
//
//  See PRA setion 3.2.12 (mtvec)
//
// -------------------------------------------------------------------------

// Reset value of mtvec.base
parameter  MTVEC_BASE_RESET     = 64'h0000_0000_C000_0000;

// Reset value of mtvec.mode
parameter  MTVEC_MODE_RESET     = 2'b00;

// Alignment required when writing mtvec.base with mtvec.mode = vectored.
parameter  MTVEC_VECT_BASE_MASK = 64'hFFFF_FFFF_FFFF_FF80;

reg  [XL-2:0] reg_mtvec_base  ;
reg  [   1:0] reg_mtvec_mode  ;


wire [XL:0] reg_mtvec       = {
    reg_mtvec_base,
    reg_mtvec_mode
};

assign        mtvec_base    = {reg_mtvec_base, 2'b00}   ;
assign        mtvec_mode    =  reg_mtvec_mode           ;

wire          wen_mtvec     = mode_m && csr_wr && csr_addr == ADDR_MTVEC;


wire [XL-2:0] n_mtvec_base  = {
    csr_wr_set ? reg_mtvec_base[XL-2:0] |  csr_wdata[XL:2] :
    csr_wr_clr ? reg_mtvec_base[XL-2:0] & ~csr_wdata[XL:2] :
                 csr_wdata     [XL  :2]                    };


wire [   1:0] n_mtvec_mode  = {
    csr_wr_set ? reg_mtvec_mode[ 1:0] |  csr_wdata[ 1:0] :
    csr_wr_clr ? reg_mtvec_mode[ 1:0] & ~csr_wdata[ 1:0] :
                 csr_wdata     [ 1:0]                    };

wire bad_mtvec_mode = n_mtvec_mode[1];
wire bad_mtvec_align= n_mtvec_mode[0] && 
                      |({n_mtvec_base,2'b00} & ~MTVEC_VECT_BASE_MASK);

wire          bad_mtvec_val = bad_mtvec_mode || bad_mtvec_align;

wire          csr_error_mtvec = bad_mtvec_val && wen_mtvec;


always @(posedge g_clk) begin
    if(!g_resetn) begin
        reg_mtvec_base <= MTVEC_BASE_RESET[XL:2];
        reg_mtvec_mode <= MTVEC_MODE_RESET      ;
    end else if(wen_mtvec && !bad_mtvec_val) begin
        reg_mtvec_base <= n_mtvec_base;
        reg_mtvec_mode <= n_mtvec_mode;
    end
end


//
// CSR: MSCRATCH
// -------------------------------------------------------------------------

reg [XL:0] reg_mscratch;

wire[XL:0] n_reg_mscratch = 
    csr_wr_set ? reg_mscratch |  csr_wdata :
    csr_wr_clr ? reg_mscratch & ~csr_wdata :
                 csr_wdata                 ;

wire       wen_mscratch = mode_m && csr_wr && csr_addr == ADDR_MSCRATCH;

always @(posedge g_clk) begin
    if(!g_resetn) begin
        reg_mscratch <= 0;
    end else if(wen_mscratch) begin
        reg_mscratch <= n_reg_mscratch;
    end
end


//
// CSR: MTVAL
// -------------------------------------------------------------------------

reg  [XL:0] reg_mtval   ;
wire [XL:0] n_reg_mtval =
    trap_cpu? trap_mtval            :
    csr_wr_set ? reg_mtval |  csr_wdata:
    csr_wr_clr ? reg_mtval & ~csr_wdata:
                 csr_wdata             ;

wire wen_mtval = mode_m && csr_wr && csr_addr == ADDR_MTVAL;

always @(posedge g_clk) begin
    if(!g_resetn) begin
        reg_mtval <= 0          ;
    end else if(wen_mtval || trap_cpu) begin
        reg_mtval <= n_reg_mtval;
    end
end


//
// CSR: MEPC
// -------------------------------------------------------------------------

reg  [XL-1:0] reg_mepc_mepc;
wire        reg_mepc_warl = 1'b0;

wire [XL:0] reg_mepc = {
    reg_mepc_mepc,
    reg_mepc_warl
};

// Allow forwarding of mepc value for case when mret is in
// ex stage causing a CF change, and CSR write in wb stage writing
// to mepc.
assign      csr_mepc = wen_mepc ? {n_mepc,1'b0} : {reg_mepc_mepc, 1'b0};

wire        wen_mepc = mode_m && csr_wr  && csr_addr == ADDR_MEPC   ||
                       trap_cpu                                     ||
                       trap_int                                     ;

wire [XL-1:0] n_mepc   =
    trap_int || trap_cpu? trap_pc[XL:1]                     :
    csr_wr_set          ? reg_mepc_mepc |  csr_wdata[XL:1]  :
    csr_wr_clr          ? reg_mepc_mepc & ~csr_wdata[XL:1]  :
                          csr_wdata[XL:1]                   ;

always @(posedge g_clk) begin
    if(!g_resetn) begin
        reg_mepc_mepc <= 0;
    end else if(wen_mepc) begin
        reg_mepc_mepc <= n_mepc;
    end
end


//
// MCAUSE
// -------------------------------------------------------------------------

reg           reg_mcause_interrupt ;// Interrupts not implemented.
reg  [XL-1:0] reg_mcause_cause     ;

wire [XL:0] reg_mcause = {
    reg_mcause_interrupt,
    reg_mcause_cause
};

wire        wen_mcause = mode_m && csr_wr  && csr_addr == ADDR_MCAUSE   ||
                         trap_cpu                                       ||
                         trap_int                                       ;

wire [XL-1:0] n_mcause_cause =
    trap_int || trap_cpu ? {32'b0,24'b0, trap_cause   }            :
    csr_wr_set           ? reg_mcause_cause |  csr_wdata[XL-1:0]   :
    csr_wr_clr           ? reg_mcause_cause & ~csr_wdata[XL-1:0]   :
                           csr_wdata[XL-1:0]                       ;

wire        wen_valid_mcause = 
    csr_wdata == {32'b0,25'b0,TRAP_IALIGN  } ||
    csr_wdata == {32'b0,25'b0,TRAP_IACCESS } ||
    csr_wdata == {32'b0,25'b0,TRAP_IOPCODE } ||
    csr_wdata == {32'b0,25'b0,TRAP_BREAKPT } ||
    csr_wdata == {32'b0,25'b0,TRAP_LDALIGN } ||
    csr_wdata == {32'b0,25'b0,TRAP_LDACCESS} ||
    csr_wdata == {32'b0,25'b0,TRAP_STALIGN } ||
    csr_wdata == {32'b0,25'b0,TRAP_STACCESS} ||
    csr_wdata == {32'b0,25'b0,TRAP_ECALLM  } ||
    csr_addr  != ADDR_MCAUSE             ;

always @(posedge g_clk) begin
    if(!g_resetn) begin
        reg_mcause_cause     <= 0; 
        reg_mcause_interrupt <= 0;
    end else if(wen_mcause && wen_valid_mcause) begin
        reg_mcause_cause     <= n_mcause_cause;
        reg_mcause_interrupt <= trap_int;
    end
end


//
// MCOUNTERIN
// -------------------------------------------------------------------------

reg mcountin_ir;
reg mcountin_tm = 1'b0;
reg mcountin_cy;

assign inhibit_ir = mcountin_ir;
assign inhibit_cy = mcountin_cy;
assign inhibit_tm = mcountin_tm;

wire wen_mcountin = mode_m && csr_wr && csr_addr == ADDR_MCOUNTIN;

always @(posedge g_clk) begin
    if(!g_resetn) begin
        mcountin_ir <= 1'b0;
        mcountin_cy <= 1'b0;
    end else if(wen_mcountin) begin
        mcountin_ir <= csr_wdata[2];
        mcountin_cy <= csr_wdata[0];
    end
end

wire [XL:0] reg_mcountin = {
    61'b0, 
    mcountin_ir,
    mcountin_tm,
    mcountin_cy
};


//
// CSR read responses.
// -------------------------------------------------------------------------

wire   read_mstatus   = mode_m && csr_en && csr_addr == ADDR_MSTATUS  ;
wire   read_misa      = mode_m && csr_en && csr_addr == ADDR_MISA     ;
wire   read_medeleg   = mode_m && csr_en && csr_addr == ADDR_MEDELEG  ;
wire   read_mideleg   = mode_m && csr_en && csr_addr == ADDR_MIDELEG  ;
wire   read_mie       = mode_m && csr_en && csr_addr == ADDR_MIE      ;
wire   read_mtvec     = mode_m && csr_en && csr_addr == ADDR_MTVEC    ;
wire   read_mscratch  = mode_m && csr_en && csr_addr == ADDR_MSCRATCH ;
wire   read_mepc      = mode_m && csr_en && csr_addr == ADDR_MEPC     ;
wire   read_mcause    = mode_m && csr_en && csr_addr == ADDR_MCAUSE   ;
wire   read_mtval     = mode_m && csr_en && csr_addr == ADDR_MTVAL    ;
wire   read_mip       = mode_m && csr_en && csr_addr == ADDR_MIP      ;
wire   read_mvendorid = mode_m && csr_en && csr_addr == ADDR_MVENDORID;
wire   read_marchid   = mode_m && csr_en && csr_addr == ADDR_MARCHID  ;
wire   read_mimpid    = mode_m && csr_en && csr_addr == ADDR_MIMPID   ;
wire   read_mhartid   = mode_m && csr_en && csr_addr == ADDR_MHARTID  ;
wire   read_cycle     =           csr_en && csr_addr == ADDR_CYCLE    ;
wire   read_time      =           csr_en && csr_addr == ADDR_TIME     ;
wire   read_instret   =           csr_en && csr_addr == ADDR_INSTRET  ;
wire   read_mcycle    = mode_m && csr_en && csr_addr == ADDR_MCYCLE   ;
wire   read_minstret  = mode_m && csr_en && csr_addr == ADDR_MINSTRET ;
wire   read_mcountin  = mode_m && csr_en && csr_addr == ADDR_MCOUNTIN ;

wire   valid_addr     = 
    read_mstatus   ||
    read_misa      ||
    read_medeleg   ||
    read_mideleg   ||
    read_mie       ||
    read_mtvec     ||
    read_mscratch  ||
    read_mepc      ||
    read_mcause    ||
    read_mtval     ||
    read_mip       ||
    read_mvendorid ||
    read_marchid   ||
    read_mimpid    ||
    read_mhartid   ||
    read_cycle     ||
    read_time      ||
    read_instret   ||
    read_mcycle    ||
    read_minstret  ||
    read_mcountin   ;

wire invalid_addr = !valid_addr;

assign csr_error = invalid_addr && csr_wr   ||
                   csr_error_mtvec          ;

assign csr_rdata =
    {64{read_mstatus  }} & reg_mstatus          |
    {64{read_misa     }} & reg_misa             |
    {64{read_medeleg  }} & reg_medeleg          |
    {64{read_mideleg  }} & reg_mideleg          |
    {64{read_mie      }} & reg_mie              |
    {64{read_mtvec    }} & reg_mtvec            |
    {64{read_mscratch }} & reg_mscratch         |
    {64{read_mepc     }} & reg_mepc             |
    {64{read_mcause   }} & reg_mcause           |
    {64{read_mtval    }} & reg_mtval            |
    {64{read_mip      }} & reg_mip              |
    {64{read_mvendorid}} & reg_mvendorid        |
    {64{read_marchid  }} & reg_marchid          |
    {64{read_mimpid   }} & reg_mimpid           |
    {64{read_mhartid  }} & reg_mhartid          |
    {64{read_cycle    }} & ctr_cycle            |
    {64{read_time     }} & ctr_time             |
    {64{read_instret  }} & ctr_instret          |
    {64{read_mcycle   }} & ctr_cycle            |
    {64{read_minstret }} & ctr_instret          |
    {64{read_mcountin }} & reg_mcountin         ;

`ifdef RVFI
assign da_mstatus    = reg_mstatus   ;
assign da_misa       = reg_misa      ;
assign da_medeleg    = reg_medeleg   ;
assign da_mideleg    = reg_mideleg   ;
assign da_mie        = reg_mie       ;
assign da_mtvec      = reg_mtvec     ;
assign da_mscratch   = reg_mscratch  ;
assign da_mepc       = reg_mepc      ;
assign da_mcause     = reg_mcause    ;
assign da_mtval      = reg_mtval     ;
assign da_mip        = reg_mip       ;
assign da_mvendorid  = reg_mvendorid ;
assign da_marchid    = reg_marchid   ;
assign da_mimpid     = reg_mimpid    ;
assign da_mhartid    = reg_mhartid   ;
assign da_cycle      = ctr_cycle     ;
assign da_mtime      = ctr_time      ;
assign da_instret    = ctr_instret   ;
assign da_cycle      = ctr_cycle     ;
assign da_instret    = ctr_instret   ;
assign da_mcountin   = reg_mcountin  ;
`endif

endmodule

