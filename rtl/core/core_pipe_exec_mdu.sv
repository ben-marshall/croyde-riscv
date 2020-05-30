
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
// Argument / Variable storage
// ------------------------------------------------------------

reg  [XL:0] s_rs1;
reg  [XL:0] s_rs2;

reg  [XL:0] n_rs1_mul;
reg  [XL:0] n_rs2_mul;

wire [XL:0] n_rs1_div;
wire [XL:0] n_rs2_div;

reg  [MW:0]   mdu_state;

always @(posedge g_clk) begin
    if(!g_resetn || flush) begin
        s_rs1       <= {XLEN{1'b0}};
        s_rs2       <= {XLEN{1'b0}};
    end else if(div_start || div_run) begin
        s_rs1       <= n_rs1_div;
        s_rs2       <= n_rs2_div;
        mdu_state   <= n_divisor;
    end else if(mul_start) begin
        s_rs1       <= rs1;
        s_rs2       <= rs2;
        mdu_state   <= {2*XLEN{1'b0}};
    end else if(mul_run) begin
        s_rs1       <= n_rs1_mul;
        s_rs2       <= n_rs2_mul;
        if(!n_mul_done || MUL_UNROLL == 1) begin
            mdu_state   <= n_mul_state;
        end
    end
end

//
// Op counter
// ------------------------------------------------------------

reg  [ 6:0 ]    mdu_ctr ;
reg             mdu_done;
wire          n_mdu_done = n_mul_done || n_div_done;
reg             mdu_run ;

wire            mdu_start = mul_start || div_start;

always @(posedge g_clk) begin
    if (!g_resetn || flush) begin
        mdu_run     <= 1'b0;
        mdu_done    <= 1'b0;
        mdu_ctr     <= 'd0;
    end else if (mdu_start) begin
        mdu_run     <= 1'b1;
        mdu_done    <= 1'b0;
        mdu_ctr     <= op_word ? 'd32 : 'd64;
    end else if(mdu_run) begin
        if(any_mul && mdu_ctr == MUL_END    ||
           any_div && mdu_ctr ==       0    ) begin
            mdu_done    <= n_mdu_done;
            mdu_run     <= 1'b0;
        end else begin
            mdu_ctr     <= mdu_ctr - (any_mul ? MUL_UNROLL : 7'd1);
        end
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
    op_word ? {{32{mdu_state[XL]}}, mdu_state[XL:32]} :
    mul_hi  ?                       mdu_state[MW:64]  :
                                    mdu_state[XL: 0]  ;

wire      n_mul_done= mdu_ctr == MUL_END && mul_run;

reg           mul_run   ; // Is the multiplier currently running?
reg           mul_done  ; // Is the multiplier complete.
reg  [  XL:0] to_add    ; // The thing added to current accumulator.
reg           to_add_sign;// The thing added to current accumulator.
reg  [XLEN:0] mul_add_l ; // Left hand side of multiply addition.
reg  [XLEN:0] mul_add_r ; // Right hand side of multiply addition.
reg  [XLEN:0] mul_sum   ; // Output of multiply addition.
reg           sub_last  ; // Subtract during final iteration? 

// Treat inputs as signed?
wire          lhs_signed = op_mulh || op_mulhsu;
wire          rhs_signed = op_mulh;

reg           mul_l_sign; // Sign of current left operand.
reg           mul_r_sign; // Sign of current right operand.

reg  [MW:0]  n_mul_state;

integer i;
always @(*) begin
    
    n_mul_state = mdu_state;
    sub_last    = 1'b0;

    for(i = 0; i < MUL_UNROLL; i = i + 1) begin
        sub_last    = i == (MUL_UNROLL - 1) &&
                      mdu_ctr == MUL_UNROLL &&
                      rhs_signed && s_rs2[MUL_UNROLL-1];
        to_add      = s_rs2[i]   ? s_rs1      : 64'b0       ;
        to_add_sign = op_word    ? to_add[31] : to_add[XL]  ;
        mul_l_sign  = lhs_signed && n_mul_state[MW]         ;
        mul_r_sign  = lhs_signed && to_add_sign             ;
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
    end else if (mul_start) begin
        mul_run     <= 1'b1;
        mul_done    <= 1'b0;
    end else if(mul_run) begin
        if(mdu_ctr == MUL_END) begin
            mul_done    <= n_mul_done;
            mul_run     <= 1'b0;
        end
    end
end


//
// Divider
// ------------------------------------------------------------

// rs1 = dividend
// rs2 = divisor

wire    [MW: 0]  divisor = mdu_state ;
reg     [MW: 0]n_divisor ;

wire    [XL: 0]  dividend    = s_rs1;
reg     [XL: 0]n_dividend    ;
assign         n_rs1_div     = n_dividend;

wire    [XL: 0]  quotient     = s_rs2;
reg     [XL: 0]n_quotient    ;
assign         n_rs2_div     = n_quotient;

reg             div_run ;
reg             div_done;
wire          n_div_done = div_run && mdu_ctr == 0;

// start the divider running?
wire            div_start   = valid && any_div && !div_run && !div_done;

// Are we doing a signed operation?
wire            div_signed  = op_div || op_rem;

// Sign of the left/right hand operands.
wire            div_sign_lhs= div_signed && (op_word ? rs1[31] : rs1[XL]);
wire            div_sign_rhs= div_signed && (op_word ? rs2[31] : rs2[XL]);

//
// Are we doing a division or a remainder op?
wire            div_div     = op_div || op_divu;
wire            div_rem     = op_rem || op_remu;

wire            div_less    = divisor <= {{XLEN{1'b0}},dividend};

// Used to set bits of the quotient.
wire    [XL: 0] qmask       = 64'b1 << (mdu_ctr-1);

// Is rs2 *not* zero? Used to determine sign of output.
wire            div_rs2_nzw = |rs2[31:0];
wire            div_rs2_nz  = op_word ? div_rs2_nzw : div_rs2_nzw || |rs2[XL:32];


// Sign of the output for  division / remainder.
wire            div_outsign = 
    div_div ? (div_sign_lhs != div_sign_rhs) && div_rs2_nz    :
              (div_sign_lhs                )                  ;

wire    [XL:0] neg_rs1      = -(op_word ? {{32{rs1[31]}},rs1[31:0]} : rs1);
wire    [XL:0] neg_rs2      = -(op_word ? {{32{rs2[31]}},rs2[31:0]} : rs2);

wire    [XL:0] div_out      = div_div     ? quotient  : dividend;

wire    [XL:0] div_pre_sext = div_outsign ? -div_out  : div_out ;

assign         result_div   = 
    op_word ? { {32{div_pre_sext[31]}}, div_pre_sext[31:0]} : div_pre_sext;

//
// Next divider state values.
always @(*) begin
    n_dividend = dividend;
    n_quotient = quotient;
    n_divisor  = divisor >> 1;

    if(div_start) begin
      n_dividend = div_sign_lhs ? neg_rs1                               :
                                  rs1 & {{32{!op_word}}, {32{1'b1}}}    ;
      if(op_word) begin
          n_divisor  =(div_sign_rhs?{{XLEN+32{neg_rs2[32] }},neg_rs2[31:0]}:
                                    {{XLEN+32{1'b0        }},rs2[31:0]}) << 31;
      end else begin
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

//
// Divider register updating
always @(posedge g_clk) begin
    if(!g_resetn || flush) begin
        div_run     <= 1'b0;
        div_done    <= 1'b0;
    end else if(div_start) begin
        div_run     <= 1'b1;
    end else if(div_run) begin
        if(mdu_ctr == 0) begin
            div_done<= n_div_done;
            div_run <= 1'b0;
        end else begin
        end
    end
end

endmodule

