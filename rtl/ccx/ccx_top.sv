
module ccx_top (

input  wire         f_clk        , // Global free-running clock.
input  wire         g_resetn     , // Synchronous negative level reset.
input  wire         g_clk_test_en, // Clock test enable.

input  wire         int_sw       , // External interrupt
input  wire         int_ext      , // Software interrupt

output wire         emem_req     , // Memory request
output wire [ 38:0] emem_addr    , // Memory request address
output wire         emem_wen     , // Memory request write enable
output wire [  7:0] emem_strb    , // Memory request write strobe
output wire [ 63:0] emem_wdata   , // Memory write data.
input  wire         emem_gnt     , // Memory response valid
input  wire         emem_err     , // Memory response error
input  wire [ 63:0] emem_rdata   , // Memory response read data

output wire         wfi_sleep    , // Core is asleep due to WFI.

output wire         trs_valid    , // Instruction trace valid
output wire [ 31:0] trs_instr    , // Instruction trace data
output wire [ 63:0] trs_pc         // Instruction trace PC

);

// Inital address of the program counter post reset.
parameter   PC_RESET_ADDRESS= 'h00000000;

// Base address of the memory mapped IO region.
parameter   MMIO_BASE = 39'h0000_0000_0002_0000;
parameter   MMIO_SIZE = 39'h0000_0000_0000_00FF;
parameter   MMIO_MASK = ~MMIO_SIZE           ;

localparam  AW = 39;    // Address width
localparam  DW = 64;    // Data width

//
// Internal address mapping.
// ------------------------------------------------------------

parameter   ROM_MEMH  = ""        ;
parameter   ROM_BASE  = 39'h00000000;
parameter   ROM_SIZE  = 39'h000003FF;
localparam  ROM_MASK  = ~ROM_SIZE ;
localparam  ROM_WIDTH = 64        ;
localparam  ROM_DEPTH = ROM_SIZE+1;

parameter   RAM_MEMH  = ""          ;
parameter   RAM_BASE  = 39'h00010000;
parameter   RAM_SIZE  = 39'h0000FFFF;
localparam  RAM_MASK  =  ~RAM_SIZE;
localparam  RAM_WIDTH = 64        ;
localparam  RAM_DEPTH = RAM_SIZE+1;

parameter   EXT_BASE  = 39'h10000000;
parameter   EXT_SIZE  = 39'h0FFFFFFF;
localparam  EXT_MASK  = ~EXT_SIZE ;

//
// Clock control
// ------------------------------------------------------------

parameter CLK_GATE_EN      = 1'b1; // Enable core-level clock gating

// CCX level gated clock
wire g_clk = f_clk;

//
// Internal interfaces / buses / wires
// ------------------------------------------------------------

core_mem_bus        if_ext       ;

assign emem_req     = if_ext.req   ;
assign emem_addr    = if_ext.addr  ;
assign emem_wen     = if_ext.wen   ;
assign emem_strb    = if_ext.strb  ;
assign emem_wdata   = if_ext.wdata ;
assign if_ext.gnt   = emem_gnt     ;
assign if_ext.err   = emem_err     ;
assign if_ext.rdata = emem_rdata   ;

//
// Core instruction and data memory interfaces.
core_mem_bus #(.AW(AW),.DW(DW)) core_imem;
core_mem_bus #(.AW(AW),.DW(DW)) core_dmem;

//
// RAM and ROM interfaces
core_mem_bus #(.AW(AW),.DW(DW)) if_ram;
core_mem_bus #(.AW(AW),.DW(DW)) if_rom;
core_mem_bus #(.AW(AW),.DW(DW)) if_mmio;

//
// Core timer & counter related wires.
wire                 core_int_ti       ; // Timer interrupt.
wire                 core_instr_ret    ; // Instruction retired;
        
wire [         63:0] core_ctr_time     ; // The time counter value.
wire [         63:0] core_ctr_cycle    ; // The cycle counter value.
wire [         63:0] core_ctr_instret  ; // The instret counter value.
        
wire                 core_inhibit_cy   ; // Stop cycle counter incrementing.
wire                 core_inhibit_tm   ; // Stop time counter incrementing.
wire                 core_inhibit_ir   ; // Stop instret incrementing.

                               
//
// Submodule instances
// ------------------------------------------------------------

//
// instance: core_top
//
//  Instance of main micro-controller.
//
core_top #(
.PC_RESET_ADDRESS   (PC_RESET_ADDRESS),
.CLK_GATE_EN        (CLK_GATE_EN     )
) i_core_top (
.f_clk        (f_clk             ), // global free running clock
.g_clk_test_en(g_clk_test_en     ), // Gated clock test enable.
.g_resetn     (g_resetn          ), // global active low sync reset.
.int_sw       (int_sw            ), // software interrupt
.int_ext      (int_ext           ), // hardware interrupt
.int_ti       (core_int_ti       ), // Timer interrupt
.imem_req     (core_imem.req     ), // Memory request
.imem_addr    (core_imem.addr    ), // Memory request address
.imem_wen     (core_imem.wen     ), // Memory request write enable
.imem_strb    (core_imem.strb    ), // Memory request write strobe
.imem_wdata   (core_imem.wdata   ), // Memory write data.
.imem_gnt     (core_imem.gnt     ), // Memory response valid
.imem_err     (core_imem.err     ), // Memory response error
.imem_rdata   (core_imem.rdata   ), // Memory response read data
.dmem_req     (core_dmem.req     ), // Memory request
.dmem_addr    (core_dmem.addr    ), // Memory request address
.dmem_wen     (core_dmem.wen     ), // Memory request write enable
.dmem_strb    (core_dmem.strb    ), // Memory request write strobe
.dmem_wdata   (core_dmem.wdata   ), // Memory write data.
.dmem_gnt     (core_dmem.gnt     ), // Memory response valid
.dmem_err     (core_dmem.err     ), // Memory response error
.dmem_rdata   (core_dmem.rdata   ), // Memory response read data
.wfi_sleep    (wfi_sleep         ), // Core asleep due to WFI
.instr_ret    (core_instr_ret    ), // Instruction retired;
.ctr_time     (core_ctr_time     ), // The time counter value.
.ctr_cycle    (core_ctr_cycle    ), // The cycle counter value.
.ctr_instret  (core_ctr_instret  ), // The instret counter value.
.inhibit_cy   (core_inhibit_cy   ), // Stop cycle counter incrementing.
.inhibit_tm   (core_inhibit_tm   ), // Stop time counter incrementing.
.inhibit_ir   (core_inhibit_ir   ), // Stop instret incrementing.
.trs_valid    (trs_valid         ), // Instruction trace valid
.trs_instr    (trs_instr         ), // Instruction trace data
.trs_pc       (trs_pc            )  // Instruction trace PC
);


//
// instance: ccx_ic_top
//
//  Core complex memory interconnect.
//
ccx_ic_top #(
.AW       (AW        ),    // Address width
.DW       (DW        ),    // Data width
.ROM_MASK (ROM_MASK  ),
.ROM_BASE (ROM_BASE  ),
.ROM_SIZE (ROM_SIZE  ),
.RAM_MASK (RAM_MASK  ),
.RAM_BASE (RAM_BASE  ),
.RAM_SIZE (RAM_SIZE  ),
.EXT_MASK (EXT_MASK  ),
.EXT_BASE (EXT_BASE  ),
.EXT_SIZE (EXT_SIZE  ),
.MMIO_MASK(MMIO_MASK ),
.MMIO_BASE(MMIO_BASE ),
.MMIO_SIZE(MMIO_SIZE )
) i_ccx_ic_top (
.g_clk     (g_clk           ),
.g_resetn  (g_resetn        ),
.if_imem   (core_imem       ), // cpu instruction memory
.if_dmem   (core_dmem       ), // cpu data        memory
.if_rom    (if_rom          ),
.if_ram    (if_ram          ),
.if_ext    (if_ext          ),
.if_mmio   (if_mmio         )
);

//
// Core memory mapped peripherals.
// ------------------------------------------------------------

//
// module: core_counters
//
//  Responsible for all performance counters and timers.
//
core_counters #(
.MMIO_MASK (MMIO_MASK   ),
.MMIO_BASE (MMIO_BASE   ),
.MMIO_SIZE (MMIO_SIZE   ),
.MEM_ADDR_W(AW          )
) i_core_counters (
.g_clk           (g_clk           ), // global clock
.g_resetn        (g_resetn        ), // synchronous reset
.timer_interrupt (core_int_ti     ), // Timer interrupt
.instr_ret       (core_instr_ret  ), // Instruction retired;
.ctr_time        (core_ctr_time   ), // The time counter value.
.ctr_cycle       (core_ctr_cycle  ), // The cycle counter value.
.ctr_instret     (core_ctr_instret), // The instret counter value.
.inhibit_cy      (core_inhibit_cy ), // Stop cycle counter incrementing.
.inhibit_tm      (core_inhibit_tm ), // Stop time counter incrementing.
.inhibit_ir      (core_inhibit_ir ), // Stop instret incrementing.
.mmio_req        (if_mmio.req     ), // MMIO enable
.mmio_wen        (if_mmio.wen     ), // MMIO write enable
.mmio_addr       (if_mmio.addr    ), // MMIO address
.mmio_wdata      (if_mmio.wdata   ), // MMIO write data
.mmio_gnt        (if_mmio.gnt     ), // MMIO grant
.mmio_rdata      (if_mmio.rdata   ), // MMIO read data
.mmio_error      (if_mmio.err     )  // MMIO error
);

//
// Memories
// ------------------------------------------------------------

mem_sram_wxd #(
.WIDTH (ROM_WIDTH),
.ROM   (        1),
.DEPTH (ROM_DEPTH),
.MEMH  (ROM_MEMH ) 
) i_rom (
.g_clk       (g_clk             ),
.g_resetn    (g_resetn          ),
.cen         (if_rom.req        ),
.wstrb       (rom_wstrb         ),
.addr        (if_rom.addr[ 9:0] ),
.wdata       (if_rom.wdata      ),
.rdata       (if_rom.rdata      ), 
.err         (if_rom.err        )
);

assign if_rom.gnt = 1'b1;
wire   [7:0] rom_wstrb = if_rom.wen ? if_rom.strb : 8'b0;


mem_sram_wxd #(
.WIDTH (RAM_WIDTH),
.ROM   (        0),
.DEPTH (RAM_DEPTH),
.MEMH  (RAM_MEMH ) 
) i_ram (
.g_clk       (g_clk             ),
.g_resetn    (g_resetn          ),
.cen         (if_ram.req        ),
.wstrb       (ram_wstrb         ),
.addr        (if_ram.addr[15:0] ),
.wdata       (if_ram.wdata      ),
.rdata       (if_ram.rdata      ),
.err         (if_ram.err        )
);

assign if_ram.gnt = 1'b1;
wire   [7:0] ram_wstrb = if_ram.wen ? if_ram.strb : 8'b0;

endmodule

