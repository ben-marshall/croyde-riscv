
//
// Module: core_pipe_decode
//
//  Pipeline decode / operand gather stage.
//
module core_pipe_decode (

input  wire                 g_clk       , // Global clock
input  wire                 g_resetn    , // Global active low sync reset.

input  wire                 s1_16bit    , // 16 bit instruction?
input  wire                 s1_32bit    , // 32 bit instruction?
input  wire [  FD_IBUF_R:0] s1_instr    , // Instruction to be decoded
input  wire [         XL:0] s1_pc       , // Program Counter
input  wire [   FD_ERR_R:0] s1_ferr     , // Fetch bus error?
output wire                 s2_eat_2    , // Decode eats 2 bytes
output wire                 s2_eat_4      // Decode eats 4 bytes

);

// Common parameters and width definitions.
`include "core_common.vh"

// Generated decoder
`include "core_pipe_decode.vh"

assign s2_eat_2 = s1_16bit;
assign s2_eat_4 = s1_32bit;


endmodule

