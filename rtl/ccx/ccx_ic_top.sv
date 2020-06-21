
//
// module: ccx_ic_top
//
//  Core complex interconnect top.
//
module ccx_ic_top #(
parameter   AW = 39,    // Address width
parameter   DW = 64     // Data width
)(

input  wire       g_clk     ,
input  wire       g_resetn  ,

core_mem_bus.RSP  if_imem   , // CPU instruction memory
core_mem_bus.RSP  if_dmem   , // CPU data        memory

core_mem_bus.REQ  if_rom    ,
core_mem_bus.REQ  if_ram    ,
core_mem_bus.REQ  if_ext

);

//
// Parameters
// ------------------------------------------------------------

parameter ROM_MASK  = 'hFFFFFE00;
parameter ROM_BASE  = 'h00000000;
parameter ROM_SIZE  = 'h000003FF;

parameter RAM_MASK  = 'hFFFE0000;
parameter RAM_BASE  = 'h00010000;
parameter RAM_SIZE  = 'h0000FFFF;

parameter EXT_MASK  = 'hE0000000;
parameter EXT_BASE  = 'h10000000;
parameter EXT_SIZE  = 'h0FFFFFFF;

//
// Internal busses
// ------------------------------------------------------------

// Instruction memory busses.
core_mem_bus if_imem_rom;
core_mem_bus if_imem_ram;
core_mem_bus if_imem_ext;

// Data memory busses.
core_mem_bus if_dmem_rom;
core_mem_bus if_dmem_ram;
core_mem_bus if_dmem_ext;

//
// Submodule instances
// ------------------------------------------------------------

//
// Core instruction memory router.
ccx_ic_router #(
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
) i_ccx_ic_router_imem (
.g_clk      (g_clk      ),
.g_resetn   (g_resetn   ),
.if_core    (if_imem    ), // CPU instruction memory
.if_rom     (if_imem_rom),
.if_ram     (if_imem_ram),
.if_ext     (if_imem_ext) 
);

//
// Core Data Memory router.
ccx_ic_router #(
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
) i_ccx_ic_router_dmem (
.g_clk      (g_clk      ),
.g_resetn   (g_resetn   ),
.if_core    (if_dmem    ), // CPU data memory
.if_rom     (if_dmem_rom),
.if_ram     (if_dmem_ram),
.if_ext     (if_dmem_ext) 
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

endmodule
