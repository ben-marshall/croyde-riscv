

//
// module: design_assertions_fairness
//
//  Contains fairness assumptions for the core so that the designer
//  assertions environment "plays fair".
//
module design_assertions_fairness (

input  wire                 f_clk        , // Global clock
input  wire                 g_resetn     , // Global active low sync reset.

input  wire                 int_sw       , // software interrupt
input  wire                 int_ext      , // hardware interrupt
              
input wire                 imem_req     , // Mem request
input wire                 imem_rtype   , // Memory request type: I/D
input wire [ MEM_ADDR_R:0] imem_addr    , // Mem request address
input wire                 imem_wen     , // Mem request write enable
input wire [ MEM_STRB_R:0] imem_strb    , // Mem request write strobe
input wire [ MEM_DATA_R:0] imem_wdata   , // Mem write data.
input wire [  MEM_PRV_R:0] imem_prv     , // Memory Privilidge level.
input wire                 imem_gnt     , // Mem response valid
input wire                 imem_err     , // Mem response error
input wire [ MEM_DATA_R:0] imem_rdata   , // Mem response read data

input wire                 dmem_req     , // Mem request
input wire                 dmem_rtype   , // Memory request type: I/D
input wire [ MEM_ADDR_R:0] dmem_addr    , // Mem request address
input wire                 dmem_wen     , // Mem request write enable
input wire [ MEM_STRB_R:0] dmem_strb    , // Mem request write strobe
input wire [ MEM_DATA_R:0] dmem_wdata   , // Mem write data.
input wire [  MEM_PRV_R:0] dmem_prv     , // Memory Privilidge level.
input wire                 dmem_gnt     , // Mem response valid
input wire                 dmem_err     , // Mem response error
input wire [ MEM_DATA_R:0] dmem_rdata   , // Mem response read data

input  wire                 trs_valid    , // Instruction trace valid
input  wire [         31:0] trs_instr    , // Instruction trace data
input  wire [         XL:0] trs_pc         // Instruction trace PC

);

//
// Common core parameters and constants.
`include "core_common.svh"

//
// Assume that we start in reset.
initial assume(g_resetn == 1'b0);

endmodule
