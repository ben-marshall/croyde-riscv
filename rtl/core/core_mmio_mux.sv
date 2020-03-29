
//
// module: core_mmio_mux
//
//  Responsible for muxing the data memory bus between core internal
//  and external accesses.
//
module core_mmio_mux (

input  wire        g_clk            , // Global clock
input  wire        g_resetn         , // Synchronous active low reset.

input  wire                 int_dmem_req  , // Memory request
input  wire [ MEM_ADDR_R:0] int_dmem_addr , // Memory request address
input  wire                 int_dmem_wen  , // Memory request write enable
input  wire [ MEM_STRB_R:0] int_dmem_strb , // Memory request write strobe
input  wire [ MEM_DATA_R:0] int_dmem_wdata, // Memory write data.
output wire                 int_dmem_gnt  , // Memory response valid
output wire                 int_dmem_err  , // Memory response error
output wire [ MEM_DATA_R:0] int_dmem_rdata, // Memory response read data

output wire                 ext_dmem_req  , // Memory request
output wire [ MEM_ADDR_R:0] ext_dmem_addr , // Memory request address
output wire                 ext_dmem_wen  , // Memory request write enable
output wire [ MEM_STRB_R:0] ext_dmem_strb , // Memory request write strobe
output wire [ MEM_DATA_R:0] ext_dmem_wdata, // Memory write data.
input  wire                 ext_dmem_gnt  , // Memory response valid
input  wire                 ext_dmem_err  , // Memory response error
input  wire [ MEM_DATA_R:0] ext_dmem_rdata, // Memory response read data

output wire                 mmio_req         , // MMIO enable
output wire                 mmio_wen         , // MMIO write enable
output wire [         63:0] mmio_addr        , // MMIO address
output wire [         63:0] mmio_wdata       , // MMIO write data
input  wire                 mmio_gnt         , // Request grant.
input  wire [         63:0] mmio_rdata       , // MMIO read data
input  wire                 mmio_error         // MMIO error

);

`include "core_common.svh"

// Base address of the memory mapped IO region.
parameter   MMIO_BASE_ADDR  = 64'h0000_0000_0000_1000;
parameter   MMIO_BASE_MASK  = 64'h0000_0000_0000_1FFF;
parameter   MMIO_TOP        = MMIO_BASE_ADDR | MMIO_BASE_MASK;

`ifdef RVFI
//
// Assume no MMIO accesses while doing proofs.
// This is a big one...
            
wire int_dmem_below_mmio = int_dmem_addr <   MMIO_BASE_ADDR                  ;
wire int_dmem_above_mmio = int_dmem_addr >  (MMIO_BASE_ADDR | MMIO_BASE_MASK);

always @(posedge g_clk) begin
    if(int_dmem_req && int_dmem_gnt) begin
        assume(int_dmem_below_mmio || int_dmem_above_mmio);
    end
end
`endif

//
// Constant assignments
assign ext_dmem_addr  = int_dmem_addr ;
assign ext_dmem_wen   = int_dmem_wen  ;
assign ext_dmem_strb  = int_dmem_strb ;
assign ext_dmem_wdata = int_dmem_wdata;

assign mmio_addr      = int_dmem_addr ;
assign mmio_wen       = int_dmem_wen  ;
assign mmio_wdata     = int_dmem_wdata;

//
// Did we hit the MMIO region or not?

wire [63:0] a_mask    = int_dmem_addr &  MMIO_BASE_MASK;
wire [63:0] a_base    = int_dmem_addr |  MMIO_BASE_ADDR;

wire        mmio_hit  = a_mask == a_base;

reg         route_rsp_mmio  ;

assign  int_dmem_gnt =  mmio_hit ?  mmio_gnt : ext_dmem_gnt;
assign  ext_dmem_req = !mmio_hit && int_dmem_req;
assign  mmio_req     =  mmio_hit && int_dmem_req;

//
// Where do we route the response from?

always @(posedge g_clk) begin
    if(!g_resetn) begin
        route_rsp_mmio <= 1'b0;
    end else if(int_dmem_req && int_dmem_gnt) begin
        route_rsp_mmio <= mmio_hit;
    end
end

assign int_dmem_err     = route_rsp_mmio ? mmio_error   : ext_dmem_err  ;
assign int_dmem_rdata   = route_rsp_mmio ? mmio_rdata   : ext_dmem_rdata;

endmodule
