
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

assign      ready       = any_mul ? mul_done    :
                          any_div ? div_done    : 
                                    1'b0        ;

//
// Argument storage
// ------------------------------------------------------------

reg [XL:0] s_rs1;
reg [XL:0] s_rs2;

reg [XL:0] n_rs1_mul;
reg [XL:0] n_rs2_mul;

wire [XL:0] n_rs1_div;
wire [XL:0] n_rs2_div;

always @(posedge g_clk) begin
    if(!g_resetn || flush) begin
        s_rs1 <= {XLEN{1'b0}};
        s_rs2 <= {XLEN{1'b0}};
    end else if(div_start || div_run) begin
        s_rs1 <= n_rs1_div;
        s_rs2 <= n_rs2_div;
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
localparam MUL_END   = (MUL_UNROLL & 'd1) ==0 ? 0 : 1;

wire        mul_start = valid && any_mul && !mul_run && !mul_done;
wire        mul_hi    = op_mulh || op_mulhu || op_mulhsu;

assign      result_mul= 
              op_word ? {{32{mul_state[XL]}}, mul_state[XL:32]} :
    mul_hi            ? mul_state[MW:64]                        :
                        mul_state[XL: 0]                        ;

reg  [MW:0]   mul_state;
reg  [MW:0] n_mul_state;

reg         mul_run ;
reg         mul_done;
reg  [ 6:0] mul_ctr ;
reg  [XL:0] to_add  ;
reg  [XLEN:0] mul_add_l;
reg  [XLEN:0] mul_add_r;
reg  [XLEN:0] mul_sum;

reg         mul_l_sign;
reg         mul_r_sign;
reg         sub_last  ;

wire        lhs_signed = op_mulh || op_mulhsu;
wire        rhs_signed = op_mulh;

integer i;
always @(*) begin
    
    n_mul_state = mul_state;
    sub_last    = 1'b0;

    for(i = 0; i < MUL_UNROLL; i = i + 1) begin
        sub_last    = i == (MUL_UNROLL - 1) &&
                      mul_ctr == MUL_UNROLL &&
                      rhs_signed && s_rs2[MUL_UNROLL-1];
        to_add      = s_rs2[i] ? s_rs1 : 64'b0;
        mul_l_sign  = lhs_signed ? n_mul_state[MW] : 1'b0;
        mul_r_sign  = rhs_signed ? to_add[XL]      : 1'b0;
        mul_add_l   = {mul_l_sign,n_mul_state[MW:XLEN]};
        mul_add_r   = {mul_r_sign,to_add              };
        if(sub_last) begin
            mul_add_r = ~mul_add_r;
        end
        mul_sum     = mul_add_l + mul_add_r + {64'b0,sub_last};
        n_mul_state = {mul_sum, n_mul_state[XL:1]};
        n_rs1_mul   = s_rs1;
        n_rs2_mul   = s_rs2 >> MUL_UNROLL;
    end
end

always @(posedge g_clk) begin
    if (!g_resetn || flush) begin
        mul_run     <= 1'b0;
        mul_done    <= 1'b0;
        mul_ctr     <= 'd0;
        mul_state   <= {MLEN{1'b0}};
    end else if (mul_start) begin
        mul_run     <= 1'b1;
        mul_done    <= 1'b0;
        mul_state   <= 'b0;
        mul_ctr     <= op_word ? 'd32 : 'd64;
    end else if(mul_run) begin
        if(mul_ctr == MUL_END) begin
            mul_done    <= 1'b1;
            mul_run     <= 1'b0;
            if(MUL_UNROLL == 1) begin
                mul_state   <= n_mul_state;
            end
        end else begin
            mul_ctr     <= mul_ctr - MUL_UNROLL;
            mul_state   <= n_mul_state;
        end
    end
end


//
// Divider
// ------------------------------------------------------------

// rs1 = dividend
// rs2 = divisor

reg     [MW:0]  divisor ;
reg     [MW:0]n_divisor ;

wire    [XL:0]  dividend    = s_rs1;
reg     [XL:0]n_dividend    ;
assign        n_rs1_div     = n_dividend;

wire    [XL:0]  quotient     = s_rs2;
reg     [XL:0]n_quotient    ;
assign        n_rs2_div     = n_quotient;


wire            div_start   = valid && any_div && !div_run && !div_done;
wire            div_signed  = op_div || op_rem;
wire            div_sign_lhs= div_signed && (op_word ? rs1[31] : rs1[XL]);
wire            div_sign_rhs= div_signed && (op_word ? rs2[31] : rs2[XL]);

wire            div_div     = op_div || op_divu;
wire            div_rem     = op_rem || op_remu;

wire            div_less    = divisor <= {{XLEN{1'b0}},dividend};

wire    [XL:0]  qmask       = 64'b1 << (div_ctr-1);

wire            div_rs2_nz  = op_word ? |rs2[31:0] : |rs2;

wire            div_outsign = 
    div_div ? (div_sign_lhs != div_sign_rhs) && div_rs2_nz    :
              (div_sign_lhs                )                  ;

reg         div_run ;
reg         div_done;
wire      n_div_done = div_run && div_ctr == 0;
reg  [ 6:0] div_ctr ;

wire    [XL:0] neg_rs1      = -(op_word ? {{32{rs1[31]}},rs1[31:0]} : rs1);

wire    [XL:0] div_div_out  = div_outsign ? -dividend : dividend;
wire    [XL:0] div_qot_out  = div_outsign ? -quotient : quotient;

wire    [XL:0] div_pre_sext = div_div ? div_qot_out : div_div_out;

assign         result_div   = 
    op_word ? { {32{div_pre_sext[31]}}, div_pre_sext[31:0]} : div_pre_sext;

always @(*) begin
    n_dividend = dividend;
    n_quotient = quotient;
    n_divisor = divisor >> 1;

    if(div_start) begin
        if(op_word) begin
            n_dividend = div_sign_lhs ? {        neg_rs1      } :
                                        { 32'b0,     rs1[31:0]} ;
            n_divisor  = (div_sign_rhs ? -{{XLEN+32{div_sign_rhs}}, rs2[31:0]}:
                                          {{XLEN+32{1'b0        }}, rs2[31:0]}) << 31;
        end else begin
            n_dividend = div_sign_lhs ? neg_rs1 : rs1;
            n_divisor  = (div_sign_rhs ? -{{XLEN{div_sign_rhs}}, rs2}:
                                          {{XLEN{1'b0        }}, rs2}) << XL;
        end
        n_quotient  = 'b0;

    end else if(div_run) begin

        if(div_less && !n_div_done) begin
            n_dividend = dividend - divisor[XL:0];
            n_quotient = quotient | qmask;
        end

    end
end


always @(posedge g_clk) begin
    if(!g_resetn || flush) begin
        div_run     <= 1'b0;
        div_done    <= 1'b0;
        div_ctr     <= 'b0;
    end else if(div_start) begin
        div_run     <= 1'b1;
        div_ctr     <= op_word ? 'd32 : 'd64;
        divisor     <= n_divisor ;
    end else if(div_run) begin
        if(div_ctr == 0) begin
            div_done<= n_div_done;
            div_run <= 1'b0;
        end else begin
            divisor <= n_divisor ;
            div_ctr <= div_ctr - 7'd1;
        end
    end
end

endmodule

