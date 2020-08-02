
`include "ccx_if.svh"

//
// module: ccx_ic_router
//
//  Core complex interconnect router.
//  - Routes requests from the CPU to the RAM/ROM/EXT memory ports.
//
module ccx_ic_router #(
parameter   AW          = 39,    // Address width
parameter   DW          = 64,    // Data width
parameter   ROM_BASE    = 39'h0000000000,
parameter   ROM_SIZE    = 39'h00000003FF,
parameter   RAM_BASE    = 39'h0000010000,
parameter   RAM_SIZE    = 39'h000000FFFF,
parameter   EXT_BASE    = 39'h7F10000000,
parameter   EXT_SIZE    = 39'h000FFFFFFF,
parameter   MMIO_BASE   = 39'h00020000  ,
parameter   MMIO_SIZE   = 39'h000000FF
)(

input  wire      g_clk      ,
input  wire      g_resetn   ,

core_mem_bus.RSP if_core    , // CPU instruction memory

core_mem_bus.REQ if_rom     ,
core_mem_bus.REQ if_ram     ,
core_mem_bus.REQ if_ext     ,
core_mem_bus.REQ if_mmio

);

//
// Parameters
// ------------------------------------------------------------

localparam  ROM_MASK  = ~ROM_SIZE;

localparam  RAM_MASK  = ~RAM_SIZE;

localparam  EXT_MASK  = ~EXT_SIZE;

localparam  MMIO_MASK = ~MMIO_SIZE;

//
// Utility functions
// ------------------------------------------------------------

//
// Function to check if an address matches a particular peripheral
//
function [0:0] address_match (
input [AW-1:0] address  ,   // The address to match
input [AW-1:0] mask     ,   // Mask bits to match top addr bits with
input [AW-1:0] base     ,   // Base address of the range
input [AW-1:0] range        // Size of the range.
);
    address_match = (address &  mask) == (           base) &&
                    (address & ~mask) == (address & range)  ;
endfunction


//
// Which addresses match which peripherals?
// ------------------------------------------------------------

wire map_core_rom = address_match(if_core.addr, ROM_MASK, ROM_BASE, ROM_SIZE);
wire map_core_ram = address_match(if_core.addr, RAM_MASK, RAM_BASE, RAM_SIZE);
wire map_core_ext = address_match(if_core.addr, EXT_MASK, EXT_BASE, EXT_SIZE);
wire map_core_mmio= address_match(if_core.addr,MMIO_MASK,MMIO_BASE,MMIO_SIZE);

wire map_core_none= !map_core_rom   && 
                    !map_core_ram   &&
                    !map_core_ext   &&
                    !map_core_mmio  ;


// Check the mappings are sensible.
always @(posedge g_clk) begin

    // TODO
    
end


//
// Route request wires
// ------------------------------------------------------------

// Always assigned wires.
assign  if_rom.addr     = if_core.addr    ;
assign  if_rom.wen      = if_core.wen     ;
assign  if_rom.strb     = if_core.strb    ;
assign  if_rom.wdata    = if_core.wdata   ;
assign  if_rom.prv      = if_core.prv     ;
assign  if_rom.rtype    = if_core.rtype   ;

assign  if_ram.addr     = if_core.addr    ;
assign  if_ram.wen      = if_core.wen     ;
assign  if_ram.strb     = if_core.strb    ;
assign  if_ram.wdata    = if_core.wdata   ;
assign  if_ram.prv      = if_core.prv     ;
assign  if_ram.rtype    = if_core.rtype   ;

assign  if_ext.addr     = if_core.addr    ;
assign  if_ext.wen      = if_core.wen     ;
assign  if_ext.strb     = if_core.strb    ;
assign  if_ext.wdata    = if_core.wdata   ;
assign  if_ext.prv      = if_core.prv     ;
assign  if_ext.rtype    = if_core.rtype   ;

assign  if_mmio.addr    = if_core.addr    ;
assign  if_mmio.wen     = if_core.wen     ;
assign  if_mmio.strb    = if_core.strb    ;
assign  if_mmio.wdata   = if_core.wdata   ;
assign  if_mmio.prv     = if_core.prv     ;
assign  if_mmio.rtype   = if_core.rtype   ;

// Request lines masked by mapping lines.
assign  if_rom.req      = if_core.req && map_core_rom;
assign  if_ram.req      = if_core.req && map_core_ram;
assign  if_ext.req      = if_core.req && map_core_ext;
assign  if_mmio.req     = if_core.req && map_core_mmio;

//
// Request/Response Tracking.
// ------------------------------------------------------------

reg    rsp_route_rom       ;
reg    rsp_route_ram       ;
reg    rsp_route_ext       ;
reg    rsp_route_mmio      ;
reg    rsp_route_none      ;

wire n_rsp_route_rom = if_rom.req    && if_core.gnt;
wire n_rsp_route_ram = if_ram.req    && if_core.gnt;
wire n_rsp_route_ext = if_ext.req    && if_core.gnt;
wire n_rsp_route_mmio= if_mmio.req   && if_core.gnt;
wire n_rsp_route_none= map_core_none && if_core.gnt;

always @(posedge g_clk) begin
    if(!g_resetn) begin
        rsp_route_rom   <= 1'b0;
        rsp_route_ram   <= 1'b0;
        rsp_route_ext   <= 1'b0;
        rsp_route_mmio  <= 1'b0;
        rsp_route_none  <= 1'b0;
    end else begin
        rsp_route_rom   <= n_rsp_route_rom ;
        rsp_route_ram   <= n_rsp_route_ram ;
        rsp_route_ext   <= n_rsp_route_ext ;
        rsp_route_mmio  <= n_rsp_route_mmio;
        rsp_route_none  <= n_rsp_route_none;
    end
end

//
// Response Routing.
// ------------------------------------------------------------

assign if_core.gnt  = map_core_rom   ? if_rom.gnt   :
                      map_core_ram   ? if_ram.gnt   :
                      map_core_ext   ? if_ext.gnt   :
                      map_core_mmio  ? if_mmio.gnt  :
                                       1'b1         ;

assign if_core.err  = rsp_route_rom  ? if_rom.err   :
                      rsp_route_ram  ? if_ram.err   :
                      rsp_route_ext  ? if_ext.err   :
                      rsp_route_mmio ? if_mmio.err  :
                                       1'b1         ;

assign if_core.rdata= rsp_route_rom  ? if_rom.rdata :
                      rsp_route_ram  ? if_ram.rdata :
                      rsp_route_ext  ? if_ext.rdata :
                      rsp_route_mmio ? if_mmio.rdata:
                                       64'b0        ;

endmodule



