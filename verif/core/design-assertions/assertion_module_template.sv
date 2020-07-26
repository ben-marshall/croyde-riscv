
`include "rvfi_macros.vh"

//
// module: assertion_module_template
//
//  A template module for writing more complex assertions which can
//  re-use the RISC-V formal outputs.
//
//
module assertion_module_template (
input wire                 clock        ,
input wire                 clock_test   , // Gated clock test
input wire                 g_resetn     

      `ifdef RVFI
      `RVFI_INPUTS                      ,
      `endif

input wire                 imem_req     , // Mem request
input wire [ MEM_ADDR_R:0] imem_addr    , // Mem request address
input wire                 imem_wen     , // Mem request write enable
input wire [ MEM_STRB_R:0] imem_strb    , // Mem request write strobe
input wire [ MEM_DATA_R:0] imem_wdata   , // Mem write data.
input wire                 imem_gnt     , // Mem response valid
input wire                 imem_err     , // Mem response error
input wire [ MEM_DATA_R:0] imem_rdata   , // Mem response read data

input wire                 dmem_req     , // Mem request
input wire [ MEM_ADDR_R:0] dmem_addr    , // Mem request address
input wire                 dmem_wen     , // Mem request write enable
input wire [ MEM_STRB_R:0] dmem_strb    , // Mem request write strobe
input wire [ MEM_DATA_R:0] dmem_wdata   , // Mem write data.
input wire                 dmem_gnt     , // Mem response valid
input wire                 dmem_err     , // Mem response error
input wire [ MEM_DATA_R:0] dmem_rdata   , // Mem response read data

input wire                 trs_valid    , // Instruction trace valid
input wire [         31:0] trs_instr    , // Instruction trace data
input wire [         XL:0] trs_pc       , // Instruction trace PC

input wire                 int_sw       , // software interrupt
input wire                 int_ext      , // hardware interrupt
input wire                 int_ti       , // timer    interrupt

input                      instr_ret    , // Instruction retired;

input wire [         63:0] ctr_time     , // The time counter value.
input wire [         63:0] ctr_cycle    , // The cycle counter value.
input wire [         63:0] ctr_instret  , // The instret counter value.

input wire                 inhibit_cy   , // Stop cycle counter.
input wire                 inhibit_tm   , // Stop time counter.
input wire                 inhibit_ir     // Stop instret incrementing.

);

//
// Common core parameters and constants.
`include "core_common.svh"


endmodule
