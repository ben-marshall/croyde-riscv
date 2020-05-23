
//
// module: core_pipe_exec_mdu
//
//  Core multiply divide unit
//
module core_pipe_exec_mdu (

input  wire         g_clk       , // Clock
input  wire         g_resetn    , // Active low synchronous reset.

input  wire         flush       , // Flush and stop any execution.

input  wire         valid       , // Inputs are valid.
input  wire         op_word     , // word-wise operation on 32-bit data.
input  wire         op_mul      , //
input  wire         op_mulh     , //
input  wire         op_mulhu    , //
input  wire         op_mulhsu   , //
input  wire         op_div      , //
input  wire         op_divu     , //
input  wire         op_rem      , //
input  wire         op_remu     , //
input  wire [XL: 0] rs1         , // Source register 1
input  wire [XL: 0] rs2         , // Source register 2

output wire         ready       , // Finished computing
output wire [XL: 0] rd            // Result

);

`include "core_common.svh"

localparam MLEN = XLEN*2;
localparam MW   = MLEN-1;

//
// Result signals.
// ------------------------------------------------------------

wire [XL:0] result_mul  ;
wire [XL:0] result_div  ;

wire        any_div     = op_div || op_divu || op_rem   || op_remu  ;
wire        any_mul     = op_mul || op_mulh || op_mulhu || op_mulhsu;

assign      rd          = any_mul ? result_mul  : result_div;

assign      ready       = any_mul ? mul_done    : 1'b0      ;

//
// Argument storage
// ------------------------------------------------------------

reg [XL:0] s_rs1;
reg [XL:0] s_rs2;

reg [XL:0] n_rs1_mul;
reg [XL:0] n_rs2_mul;

always @(posedge g_clk) begin
    if(!g_resetn || flush) begin
        s_rs1 <= {XLEN{1'b0}};
        s_rs2 <= {XLEN{1'b0}};
    end else if(mul_start) begin
        s_rs1 <= rs1;
        s_rs2 <= rs2;
    end else if(mul_run) begin
        s_rs1 <= n_rs1_mul;
        s_rs2 <= n_rs2_mul;
    end
end

//
// Multiplier
// ------------------------------------------------------------

parameter MUL_UNROLL = 4;

wire        mul_start = valid && any_mul && !mul_run;

reg  [MW:0]   mul_state;
reg  [MW:0] n_mul_state;

reg         mul_run ;
reg         mul_done;
reg  [ 5:0] mul_ctr ;

always @(*) begin
    // FIXME
    n_mul_state = mul_state + 1;
    n_rs1_mul   = s_rs1 >> 1;
    n_rs2_mul   = s_rs2 << 1;
end

always @(posedge g_clk) begin
    if (!g_resetn || flush) begin
        mul_run     <= 1'b0;
        mul_done    <= 1'b0;
        mul_ctr     <= 6'd0;
        mul_state   <= {MLEN{1'b0}};
    end else if (mul_start) begin
        mul_run     <= 1'b1;
        mul_done    <= 1'b0;
        mul_ctr     <= op_word ? 6'd63 : 6'd31;
    end else if(mul_run) begin
        mul_state <= n_mul_state;
        if(mul_ctr == 0) begin
            mul_done    <= 1'b1;
            mul_run     <= 1'b0;
        end else begin
            mul_ctr     <= mul_ctr - 1;
        end
    end
end

endmodule

