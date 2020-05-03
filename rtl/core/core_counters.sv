

//
// module: core_counters
//
//  Responsible for all performance counters and timers.
//
module core_counters (

input                      g_clk            , // global clock
input                      g_resetn         , // synchronous reset

input                      instr_ret        , // Instruction retired.
output reg                 timer_interrupt  , // Raise a timer interrupt

output wire [        63:0] ctr_time         , // The time counter value.
output reg  [        63:0] ctr_cycle        , // The cycle counter value.
output reg  [        63:0] ctr_instret      , // The instret counter value.

input  wire                inhibit_cy       , // Stop cycle counter incrementing.
input  wire                inhibit_tm       , // Stop time counter incrementing.
input  wire                inhibit_ir       , // Stop instret incrementing.

input  wire                mmio_req         , // MMIO enable
input  wire                mmio_wen         , // MMIO write enable
input  wire [MEM_ADDR_R:0] mmio_addr        , // MMIO address
input  wire [MEM_DATA_R:0] mmio_wdata       , // MMIO write data
output wire                mmio_gnt         , // Request grant.
output reg  [MEM_DATA_R:0] mmio_rdata       , // MMIO read data
output reg                 mmio_error         // MMIO error

);

`include "core_common.svh"

// Base address of the memory mapped IO region.
parameter   MMIO_BASE_ADDR        = 'h0000_0000_0001_0000;
parameter   MMIO_BASE_MASK        = 'h0000_0000_0001_FFFF;

// Base address of the MTIME memory mapped register.
localparam  MMIO_MTIME_ADDR       = MMIO_BASE_ADDR;

// Base address of the MTIMECMP memory mapped register.
localparam  MMIO_MTIMECMP_ADDR    = MMIO_BASE_ADDR + 8;

// Reset value of the MTIMECMP register.
parameter   MMIO_MTIMECMP_RESET   = -1;

// ---------------------- Memory mapped registers -----------------------

wire    addr_mtime_lo    =
    (mmio_addr& MMIO_BASE_MASK)==(MMIO_MTIME_ADDR    & MMIO_BASE_MASK);

wire    addr_mtimecmp_lo =
    (mmio_addr& MMIO_BASE_MASK)==(MMIO_MTIMECMP_ADDR & MMIO_BASE_MASK);

reg  [63:0] mapped_mtime;
reg  [63:0] mapped_mtimecmp;

wire [63:0] n_mapped_mtime = mapped_mtime + 1;

wire n_timer_interrupt = mapped_mtime >= mapped_mtimecmp;

wire wr_mtime_lo = addr_mtime_lo && mmio_wen && mmio_req;

always @(posedge g_clk) begin
    if(!g_resetn) begin
        mapped_mtime <= 0;
    end else if(wr_mtime_lo) begin
        mapped_mtime <= mmio_wdata;
    end else if(!inhibit_tm) begin
        mapped_mtime <= n_mapped_mtime;
    end
end

always @(posedge g_clk) begin
    if(!g_resetn) begin
        timer_interrupt <= 0;
    end else begin
        timer_interrupt <= n_timer_interrupt;
    end
end

wire wr_mtimecmp_lo = addr_mtimecmp_lo && mmio_wen && mmio_req;

always @(posedge g_clk) begin
    if(!g_resetn) begin

        mapped_mtimecmp <= MMIO_MTIMECMP_RESET;

    end else if(wr_mtimecmp_lo) begin

        mapped_mtimecmp <= mmio_wdata;

    end
end


// ---------------------- MMIO Bus Reads --------------------------------

wire [XL:0] n_mmio_rdata =
    {64{addr_mtime_lo   }} & mapped_mtime    |
    {64{addr_mtimecmp_lo}} & mapped_mtimecmp ;

wire        n_mmio_error = mmio_req && !(
    addr_mtime_lo       ||
    addr_mtimecmp_lo
);

assign mmio_gnt = 1'b1;

always @(posedge g_clk) begin
    if(!g_resetn) begin
        mmio_error <=  1'b0;
        mmio_rdata <= 64'b0;
    end else if(mmio_req) begin
        mmio_error <= n_mmio_error;
        if(!mmio_wen) begin
            mmio_rdata <= n_mmio_rdata;
        end
    end
end


// ---------------------- CSR registers ---------------------------------

//
// time register
//

assign ctr_time = mapped_mtime;


//
// instret register
//

wire [63:0] n_ctr_instret = ctr_instret + 1;

// Register inserted to break up long timing path to instret register
// load enable bit.
reg     instr_ret_r;

always @(posedge g_clk) begin
    instr_ret_r <= instr_ret;
end

always @(posedge g_clk) begin
    if(!g_resetn) begin

        ctr_instret <= 0;

    end else if(instr_ret_r && !inhibit_ir) begin

        ctr_instret <= n_ctr_instret;

    end
end

//
// Cycle counter register
//

wire [63:0] n_ctr_cycle = ctr_cycle + 1;

always @(posedge g_clk) begin
    if(!g_resetn) begin
        ctr_cycle <= 0;
    end else if(!inhibit_cy) begin
        ctr_cycle <= n_ctr_cycle;
    end
end

endmodule

