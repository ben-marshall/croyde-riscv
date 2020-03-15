
//
// Module: core_pipe_exec_lsu
//
//  Responsible for all data memory accesses
//
module core_pipe_exec_lsu (

input   wire                  g_clk       , // Global clock enable.
input   wire                  g_resetn    , // Global synchronous reset

input   wire                  valid       , // Inputs are valid
input   wire [          XL:0] wdata       , // Data being written (if any)
input   wire                  load        , //
input   wire                  store       , //
input   wire                  d_double    , //
input   wire                  d_word      , //
input   wire                  d_half      , //
input   wire                  d_byte      , //
input   wire                  sext        , // Sign extend read data

output  wire                  ready       , // Read data ready
output  wire                  trap_bus    , // Bus error
output  wire                  trap_addr   , // Address alignment error
output  wire [          XL:0] rdata       , // Read data

output wire                   dmem_req    , // Memory request
output wire [   MEM_ADDR_R:0] dmem_addr   , // Memory request address
output wire                   dmem_wen    , // Memory request write enable
output wire [   MEM_STRB_R:0] dmem_strb   , // Memory request write strobe
output wire [   MEM_DATA_R:0] dmem_wdata  , // Memory write data.
input  wire                   dmem_gnt    , // Memory response valid
input  wire                   dmem_err    , // Memory response error
input  wire [   MEM_DATA_R:0] dmem_rdata    // Memory response read data

);

// Common parameters and width definitions.
`include "core_common.vh"

assign ready = valid;

endmodule

