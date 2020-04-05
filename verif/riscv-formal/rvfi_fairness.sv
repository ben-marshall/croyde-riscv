
//
// module: rvfi_fairness
//
//  Contains fairness assumptions for the core so that the RVFI
//  environment "plays fair".
//
module rvfi_fairness (

input  wire                 g_clk        , // Global clock
input  wire                 g_resetn     , // Global active low sync reset.

input  wire                 int_sw       , // software interrupt
input  wire                 int_ext      , // hardware interrupt
              
input  wire                 imem_req     , // Memory request
input  wire [ MEM_ADDR_R:0] imem_addr    , // Memory request address
input  wire                 imem_wen     , // Memory request write enable
input  wire [ MEM_STRB_R:0] imem_strb    , // Memory request write strobe
input  wire [ MEM_DATA_R:0] imem_wdata   , // Memory write data.
input  wire                 imem_gnt     , // Memory response valid
input  wire                 imem_err     , // Memory response error
input  wire [ MEM_DATA_R:0] imem_rdata   , // Memory response read data

input  wire                 dmem_req     , // Memory request
input  wire [ MEM_ADDR_R:0] dmem_addr    , // Memory request address
input  wire                 dmem_wen     , // Memory request write enable
input  wire [ MEM_STRB_R:0] dmem_strb    , // Memory request write strobe
input  wire [ MEM_DATA_R:0] dmem_wdata   , // Memory write data.
input  wire                 dmem_gnt     , // Memory response valid
input  wire                 dmem_err     , // Memory response error
input  wire [ MEM_DATA_R:0] dmem_rdata   , // Memory response read data

`RVFI_INPUTS                             , // Formal checker interface.

input  wire                 trs_valid    , // Instruction trace valid
input  wire [         31:0] trs_instr    , // Instruction trace data
input  wire [         XL:0] trs_pc         // Instruction trace PC

);

//
// Common core parameters and constants.
`include "core_common.svh"

// Base address of the memory mapped IO region.
parameter   MMIO_BASE_ADDR  = 64'h0000_0000_0000_1000;
parameter   MMIO_BASE_MASK  = 64'h0000_0000_0000_1FFF;

//
// Assume that we start in reset.
initial assume(g_resetn == 1'b0);

//
// Assume no interrupts for now - TODO
always @(posedge g_clk) begin

    assume(!int_sw);
    
    assume(!int_ext);

end


//
// Assume that we do not get memory bus errors  TODO
always @(posedge g_clk) begin

    if($past(imem_req) && $past(imem_gnt)) begin
        assume(!imem_err);
    end
    
    if($past(dmem_req) && $past(dmem_gnt)) begin
        assume(!dmem_err);
    end

end


`ifdef CORE_FAIRNESS

reg [4:0] delay_imem;
reg [4:0] delay_dmem;

localparam MAX_DELAY_IMEM = 5;
localparam MAX_DELAY_DMEM = 5;

always @(posedge g_clk) begin
    if(!g_resetn) begin
        delay_imem <= 0;
        delay_dmem <= 0;
    end else begin
        delay_imem <= delay_imem + (imem_req && !imem_gnt);
        delay_dmem <= delay_dmem + (dmem_req && !dmem_gnt);
    end

    assume(delay_imem < MAX_DELAY_IMEM);
    assume(delay_dmem < MAX_DELAY_DMEM);
end

`endif

endmodule
