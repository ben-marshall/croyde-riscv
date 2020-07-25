
`include "ccx_if.svh"

//
// module: ccx_ic_top
//
//  Core complex interconnect top.
//
module ccx_ic_top #(
parameter        AW = 39,    // Address width
parameter        DW = 64,    // Data width
parameter ROM_BASE  = 39'h00000000,
parameter ROM_SIZE  = 39'h000003FF,
parameter RAM_BASE  = 39'h00010000,
parameter RAM_SIZE  = 39'h0000FFFF,
parameter EXT_BASE  = 39'h10000000,
parameter EXT_SIZE  = 39'h0FFFFFFF,
parameter MMIO_BASE = 39'h00020000,
parameter MMIO_SIZE = 39'h000000FF
)(

input  wire       g_clk     ,
input  wire       g_resetn  ,

core_mem_bus.RSP  if_imem   , // CPU instruction memory
core_mem_bus.RSP  if_dmem   , // CPU data        memory

core_mem_bus.REQ  if_rom    ,
core_mem_bus.REQ  if_ram    ,
core_mem_bus.REQ  if_ext    ,
core_mem_bus.REQ  if_mmio

);

//
// Internal busses
// ------------------------------------------------------------

// Instruction memory busses.
core_mem_bus #() if_imem_rom  ();
core_mem_bus #() if_imem_ram  ();
core_mem_bus #() if_imem_ext  ();
core_mem_bus #() if_imem_mmio ();

// Data memory busses.
core_mem_bus #() if_dmem_rom  ();
core_mem_bus #() if_dmem_ram  ();
core_mem_bus #() if_dmem_ext  ();
core_mem_bus #() if_dmem_mmio ();

//
// Submodule instances
// ------------------------------------------------------------

//
// Core instruction memory router.
ccx_ic_router #(
.AW       (AW        ),    // Address width
.DW       (DW        ),    // Data width
.ROM_BASE (ROM_BASE  ),
.ROM_SIZE (ROM_SIZE  ),
.RAM_BASE (RAM_BASE  ),
.RAM_SIZE (RAM_SIZE  ),
.EXT_BASE (EXT_BASE  ),
.EXT_SIZE (EXT_SIZE  ),
.MMIO_BASE(MMIO_BASE ),
.MMIO_SIZE(MMIO_SIZE )
) i_ccx_ic_router_imem (
.g_clk      (g_clk       ),
.g_resetn   (g_resetn    ),
.if_core    (if_imem     ), // CPU instruction memory
.if_rom     (if_imem_rom ),
.if_ram     (if_imem_ram ),
.if_ext     (if_imem_ext ),
.if_mmio    (if_imem_mmio) 
);

//
// Core Data Memory router.
ccx_ic_router #(
.AW       (AW        ),    // Address width
.DW       (DW        ),    // Data width
.ROM_BASE (ROM_BASE  ),
.ROM_SIZE (ROM_SIZE  ),
.RAM_BASE (RAM_BASE  ),
.RAM_SIZE (RAM_SIZE  ),
.EXT_BASE (EXT_BASE  ),
.EXT_SIZE (EXT_SIZE  ),
.MMIO_BASE(MMIO_BASE ),
.MMIO_SIZE(MMIO_SIZE )
) i_ccx_ic_router_dmem (
.g_clk      (g_clk       ),
.g_resetn   (g_resetn    ),
.if_core    (if_dmem     ), // CPU data memory
.if_rom     (if_dmem_rom ),
.if_ram     (if_dmem_ram ),
.if_ext     (if_dmem_ext ),
.if_mmio    (if_dmem_mmio) 
);


//
// ROM arbiter
ccx_ic_arbiter i_ccx_ic_arbiter_rom (
.g_clk      (g_clk      ),
.g_resetn   (g_resetn   ),
.req_0      (if_dmem_rom),
.req_1      (if_imem_rom),
.rsp        (if_rom     )
);


//
// RAM arbiter
ccx_ic_arbiter i_ccx_ic_arbiter_ram (
.g_clk      (g_clk      ),
.g_resetn   (g_resetn   ),
.req_0      (if_dmem_ram),
.req_1      (if_imem_ram),
.rsp        (if_ram     )
);


//
// EXT arbiter
ccx_ic_arbiter i_ccx_ic_arbiter_ext (
.g_clk      (g_clk      ),
.g_resetn   (g_resetn   ),
.req_0      (if_dmem_ext),
.req_1      (if_imem_ext),
.rsp        (if_ext     )
);

//
// ROM arbiter
ccx_ic_arbiter i_ccx_ic_arbiter_mmio(
.g_clk      (g_clk       ),
.g_resetn   (g_resetn    ),
.req_0      (if_dmem_mmio),
.req_1      (if_imem_mmio),
.rsp        (if_mmio     )
);

endmodule
