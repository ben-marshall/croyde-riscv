
module ccx_top (

input  wire         g_clk        , // Global clock.
input  wire         g_resetn     , // Synchronous negative level reset.

input  wire         int_sw       , // External interrupt
input  wire         int_ext      , // Software interrupt

core_mem_bus.req #(.AW(39),.DW(64)) if_ext,

output wire         trs_valid    , // Instruction trace valid
output wire [ 31:0] trs_instr    , // Instruction trace data
output wire [ XL:0] trs_pc         // Instruction trace PC

);

// Inital address of the program counter post reset.
parameter   PC_RESET_ADDRESS= 'h10000000;

// Base address of the memory mapped IO region.
parameter   MMIO_BASE_ADDR  = 'h0000_0000_0001_0000;
parameter   MMIO_BASE_MASK  = 'h0000_0000_0001_FFFF;

//
// Internal address mapping.
// ------------------------------------------------------------

parameter   ROM_MEMH  = ""        ;
parameter   ROM_BASE  = 'h00000000;
parameter   ROM_SIZE  = 'h000003FF;
localparam  ROM_MASK  = ~ROM_SIZE ;
localparam  ROM_WIDTH = 64        ;
localparam  ROM_DEPTH = ROM_SIZE+1;

parameter   RAM_BASE  = 'h00010000;
parameter   RAM_SIZE  = 'h0000FFFF;
localparam  RAM_MASK  =  ~RAM_SIZE;
localparam  RAM_WIDTH = 64        ;
localparam  RAM_DEPTH = RAM_SIZE+1;

parameter   EXT_BASE  = 'h10000000;
parameter   EXT_SIZE  = 'h0FFFFFFF;
localparam  EXT_MASK  = ~EXT_SIZE ;

//
// Internal interfaces / buses / wires
// ------------------------------------------------------------


//
// Core instruction and data memory interfaces.
core_mem_bus #(.AW(AW),.DW(DW)) core_imem;
core_mem_bus #(.AW(AW),.DW(DW)) core_dmem;

//
// RAM and ROM interfaces
core_mem_bus #(.AW(AW),.DW(DW)) if_ram;
core_mem_bus #(.AW(AW),.DW(DW)) if_rom;

                               
//
// Submodule instances
// ------------------------------------------------------------

//
// instance: core_top
//
//  Instance of main micro-controller.
//
core_top #(
.PC_RESET_ADDRESS   (PC_RESET_ADDRESS)
.MMIO_BASE_ADDR     (MMIO_BASE_ADDR  )
.MMIO_BASE_MASK     (MMIO_BASE_MASK  )
) i_core_top (
g_clk        (g_clk             ), // global clock
g_resetn     (g_resetn          ), // global active low sync reset.
int_sw       (int_sw            ), // software interrupt
int_ext      (int_ext           ), // hardware interrupt
imem_req     (core_imem.req     ), // Memory request
imem_addr    (core_imem.addr    ), // Memory request address
imem_wen     (core_imem.wen     ), // Memory request write enable
imem_strb    (core_imem.strb    ), // Memory request write strobe
imem_wdata   (core_imem.wdata   ), // Memory write data.
imem_gnt     (core_imem.gnt     ), // Memory response valid
imem_err     (core_imem.err     ), // Memory response error
imem_rdata   (core_imem.rdata   ), // Memory response read data
dmem_req     (core_dmem.req     ), // Memory request
dmem_addr    (core_dmem.addr    ), // Memory request address
dmem_wen     (core_dmem.wen     ), // Memory request write enable
dmem_strb    (core_dmem.strb    ), // Memory request write strobe
dmem_wdata   (core_dmem.wdata   ), // Memory write data.
dmem_gnt     (core_dmem.gnt     ), // Memory response valid
dmem_err     (core_dmem.err     ), // Memory response error
dmem_rdata   (core_dmem.rdata   ), // Memory response read data
trs_valid    (trs_valid         ), // Instruction trace valid
trs_instr    (trs_instr         ), // Instruction trace data
trs_pc       (trs_pc            )  // Instruction trace PC
);


//
// instance: ccx_ic_top
//
//  Core complex memory interconnect.
//
ccx_ic_top #(
.AW      (AW        ),    // Address width
.DW      (DW        ),    // Data width
.ROM_MASK(ROM_MASK  ),
.ROM_BASE(ROM_BASE  ),
.ROM_SIZE(ROM_SIZE  ),
.RAM_MASK(RAM_MASK  ),
.RAM_BASE(RAM_BASE  ),
.RAM_SIZE(RAM_SIZE  ),
.EXT_MASK(EXT_MASK  ),
.EXT_BASE(EXT_BASE  ),
.EXT_SIZE(EXT_SIZE  )
) i_ccx_ic_top (
.g_clk     (g_clk           ),
.g_resetn  (g_resetn        ),
.if_imem   (core_imem       ), // cpu instruction memory
.if_dmem   (core_dmem       ), // cpu data        memory
.if_rom    (if_ram          ),
.if_ram    (if_rom          ),
.if_ext    (if_ext          )
);

//
// Memories
// ------------------------------------------------------------

mem_sram_wxd  i_rom #(
.WIDTH (ROM_WIDTH),
.ROM   (        1),
.DEPTH (ROM_DEPTH),
.MEMH  (ROM_MEMH ) 
)(
.g_clk       (g_clk             ),
.g_resetn    (g_resetn          ),
.cen         (if_rom.req        ),
.wstrb       (if_rom.strb       ),
.addr        (if_rom.addr       ),
.wdata       (if_rom.wdata      ),
.rdata       (if_rom.rdata      ) 
);

assign if_rom.gnt = 1'b1;
assign if_rom.err = 1'b0;


mem_sram_wxd  i_ram #(
.WIDTH (RAM_WIDTH),
.ROM   (        1),
.DEPTH (RAM_DEPTH),
.MEMH  (RAM_MEMH ) 
)(
.g_clk       (g_clk             ),
.g_resetn    (g_resetn          ),
.cen         (if_ram.req        ),
.wstrb       (if_ram.strb       ),
.addr        (if_ram.addr       ),
.wdata       (if_ram.wdata      ),
.rdata       (if_ram.rdata      ) 
);

assign if_ram.gnt = 1'b1;
assign if_ram.err = 1'b0;

endmodule

