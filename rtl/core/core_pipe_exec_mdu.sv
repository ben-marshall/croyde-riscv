
//
// module: core_pipe_exec_mdu
//
//  Core multiply divide unit
//
module core_pipe_exec_mdu (

input  wire         g_clk       , // Clock
output wire         g_clk_req   , // Clock Request
input  wire         g_resetn    , // Active low synchronous reset.

input  wire         flush       , // Flush and stop any execution.

input  wire         valid       , // Inputs are valid.
input  wire         op_word     , // word-wise operation on 32-bit data.
input  wire         op_mul      , //
input  wire         op_mulh     , //
input  wire         op_mulhu    , //
input  wire         op_mulhsu   , //
input  wire         op_clmul    , //
input  wire         op_clmulh   , //
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

// When to request a clock signal.
assign      g_clk_req   = valid || flush;

//
// Result signals.
// ------------------------------------------------------------

wire [XL:0] result_mul  ;
wire [XL:0] result_clmul;
wire [XL:0] result_div  ;

wire        any_div     = op_div || op_divu || op_rem   || op_remu  ;
wire        any_mul     = op_mul || op_mulh || op_mulhu || op_mulhsu;
wire        any_clmul   = op_clmul || op_clmulh;

assign      rd          = any_mul   ? result_mul  : 
                          any_clmul ? result_clmul:
                                      result_div  ;

assign      ready       = any_mul   ? mul_done    :
                          any_div   ? div_done    : 
                          any_clmul ? clmul_done  : 
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

reg  [XL:0] n_rs1_clmul;
reg  [XL:0] n_rs2_clmul;

reg  [MW:0]   mdu_state;

always @(posedge g_clk) begin
    if(!g_resetn || flush) begin
        s_rs1       <= {XLEN{1'b0}};
        s_rs2       <= {XLEN{1'b0}};
    end else if(n_div_start || div_start || div_run) begin
        s_rs1       <= n_rs1_div;
        s_rs2       <= n_rs2_div;
        mdu_state   <= n_divisor;
    end else if(mul_start || clmul_start) begin
        s_rs1       <= rs1;
        s_rs2       <= rs2;
        mdu_state   <= {2*XLEN{1'b0}};
    end else if(mul_run) begin
        s_rs1       <= n_rs1_mul;
        s_rs2       <= n_rs2_mul;
        if(!n_mul_done || MUL_UNROLL == 1) begin
            mdu_state   <= n_mul_state;
        end
    end else if(clmul_run) begin
        s_rs1       <= n_rs1_clmul;
        s_rs2       <= n_rs2_clmul;
        if(!n_clmul_done || CLMUL_UNROLL == 1) begin
            mdu_state   <= n_clmul_state;
        end
    end
end

//
// Op counter
// ------------------------------------------------------------

reg  [ 6:0 ]    mdu_ctr ;
reg             mdu_done;
wire          n_mdu_done = n_mul_done || n_div_done || n_clmul_done;
reg             mdu_run ;

wire            mdu_start = mul_start || div_start || clmul_start;

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
        if(any_mul   && mdu_ctr == MUL_END    ||
           any_clmul && mdu_ctr == CLMUL_END  ||
           any_div   && mdu_ctr ==       0    ) begin
            mdu_done    <= n_mdu_done;
            mdu_run     <= 1'b0;
        end else begin
            mdu_ctr     <= mdu_ctr - (any_mul   ? MUL_UNROLL   : 
                                      any_clmul ? CLMUL_UNROLL : 7'd1);
        end
    end
end

//
// Carry-less Multiplier
// ------------------------------------------------------------

parameter  CLMUL_UNROLL = 8;
localparam CLMUL_END    = 0;

wire       clmul_start  = valid && any_clmul && !clmul_run && !clmul_done;
reg        clmul_run    ; // Is the carry-less multiplier currently running?
reg        clmul_done   ; // Is the carry-less multiplier complete.
wire     n_clmul_done   = mdu_ctr == CLMUL_END && clmul_run;

// This is what we write back to GPR[rd].
assign result_clmul = op_clmulh   ? mdu_state[MW:XLEN] : mdu_state[XL:0] ;

reg [MW:0] n_clmul_state;
reg [XL:0] clmul_rhs    ;

integer j;
always @(*) begin
    n_clmul_state = mdu_state;
    n_rs1_clmul = s_rs1;
    n_rs2_clmul = s_rs2 >> CLMUL_UNROLL;

    for(j = 0; j < CLMUL_UNROLL; j = j + 1) begin
        clmul_rhs = s_rs2[j] ? s_rs1 : {XLEN{1'b0}};
        n_clmul_state = {
            1'b0                                ,
            n_clmul_state[MW:XLEN] ^ clmul_rhs  ,
            n_clmul_state[XL:1]            
        };
    end
end

always @(posedge g_clk) begin
    if (!g_resetn || flush) begin
        clmul_run     <= 1'b0;
        clmul_done    <= 1'b0;
    end else if (clmul_start) begin
        clmul_run     <= 1'b1;
        clmul_done    <= 1'b0;
    end else if(clmul_run) begin
        if(mdu_ctr == CLMUL_END) begin
            clmul_done    <= n_clmul_done;
            clmul_run     <= 1'b0;
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
wire          n_div_start   = valid && any_div && !div_run && !div_done &&
                              !div_start;
reg             div_start   ;

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

wire    [XL:0] neg_rs1      = -(op_word?{{32{s_rs1[31]}},s_rs1[31:0]}:s_rs1);
wire    [XL:0] neg_rs2      = -(op_word?{{32{s_rs2[31]}},s_rs2[31:0]}:s_rs2);

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

    if(n_div_start) begin
        n_dividend = rs1;
        n_quotient = rs2;
        n_divisor  = 0;
    end else if(div_start) begin
      n_dividend = div_sign_lhs ? neg_rs1                                 :
                                  s_rs1 & {{32{!op_word}}, {32{1'b1}}}    ;
      if(op_word) begin
          n_divisor  =(div_sign_rhs?{{XLEN+32{neg_rs2[32] }},neg_rs2[31:0]}:
                                    {{XLEN+32{1'b0        }},s_rs2[31:0]}) << 31;
      end else begin
          n_divisor  = (div_sign_rhs ? -{{XLEN{div_sign_rhs}}, s_rs2}:
                                        {{XLEN{1'b0        }}, s_rs2}) << XL;
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
        div_start <= 1'b0;
    end else begin
        div_start <= n_div_start;
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

