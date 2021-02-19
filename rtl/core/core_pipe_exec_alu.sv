
//
// module: core_pipe_exec_alu
//
//  Integer ALU module
//
module core_pipe_exec_alu (

input  wire [   XL:0]   opr_a   , // Input operand A
input  wire [   XL:0]   opr_b   , // Input operand B
input  wire [    5:0]   shamt   , // Shift amount.
input  wire             word    , // Operate on low 32-bits of XL.

input  wire             op_add  , // Select output of adder
input  wire             op_sub  , // Subtract opr_a from opr_b else add
input  wire             op_xor  , // Select XOR operation result
input  wire             op_or   , // Select OR
input  wire             op_and  , //        AND
input  wire             op_slt  , // Set less than
input  wire             op_sltu , //                Unsigned
input  wire             op_srl  , // Shift right logical
input  wire             op_sll  , // Shift left logical
input  wire             op_sra  , // Shift right arithmetic
input  wire             op_xorn , // 
input  wire             op_andn , // 
input  wire             op_orn  , // 
input  wire             op_ror  , //
input  wire             op_rol  , //
input  wire             op_pack , //
input  wire             op_packh, //
input  wire             op_packu, //
input  wire             op_grev , //
input  wire             op_gorc , //
input  wire             op_xpermn,//
input  wire             op_xpermb,//

output wire [   XL:0]   add_out , // Result of adding opr_a and opr_b
output wire             cmp_eq  , // Result of opr_a == opr_b
output wire             cmp_lt  , // Result of opr_a <  opr_b
output wire             cmp_ltu , // Result of opr_a <  opr_b

output wire [   XL:0]   result    // Operation result

);

// Common parameters and width definitions.
`include "core_common.svh"

//
// Miscellaneous
// ------------------------------------------------------------

assign cmp_eq               = opr_a == opr_b;

wire        neg_opr_b       = op_sub || op_xorn || op_orn || op_andn;

wire [XL:0] opr_b_n         = neg_opr_b ? ~opr_b : opr_b;

//
// Add / Sub
// ------------------------------------------------------------

wire [XL:0] addsub_output   = opr_a + opr_b_n + {{XL{1'b0}},op_sub} ;
assign      add_out         = addsub_output                         ;

wire [31:0] addsub_upper    = word  ? {32{addsub_output[   31]}}    :
                                          addsub_output[XL:32]      ;

wire [XL:0] addsub_result   = {addsub_upper, addsub_output[31:0]}   ;

//
// SLT / SLTU
// ------------------------------------------------------------

// TODO
wire        slt_signed      = $signed(opr_a) < $signed(opr_b);

// TODO
wire        slt_signed_w    = $signed(opr_a[31:0]) < $signed(opr_b[31:0]);

// TODO
wire        slt_unsigned    = $unsigned(opr_a) < $unsigned(opr_b);
                                                                           
// TODO                                                                    
wire        slt_unsigned_w  = $unsigned(opr_a[31:0]) < $unsigned(opr_b[31:0]);

wire        slt_lsbu        = word ? slt_unsigned_w : slt_unsigned ;

wire        slt_lsb         = word ? slt_signed_w   : slt_signed   ;

assign      cmp_ltu         = slt_lsbu;
assign      cmp_lt          = slt_lsb;

wire [XL:0] slt_result      = {{XL{1'b0}}, op_slt ? slt_lsb : slt_lsbu};

//
// Bitwise Operations
// ------------------------------------------------------------

wire [XL:0] xor_output      = opr_a ^ opr_b_n;
wire [XL:0]  or_output      = opr_a | opr_b_n;
wire [XL:0] and_output      = opr_a & opr_b_n;

wire [XL:0] bitwise_result  =
    {XLEN{op_xor || op_xorn}} & xor_output |
    {XLEN{op_or  || op_orn }} &  or_output |
    {XLEN{op_and || op_andn}} & and_output ;

//
// Shifts
// ------------------------------------------------------------

// Sign bit for arithmetic right shifts.
wire sbit = op_sra && (word ? opr_a[31] : opr_a[XL]);

wire sh_rotate = op_ror || op_rol;
wire sh_left   = op_rol || op_sll;
wire sh_right  = op_ror || op_srl || op_sra;

wire [2*XLEN-1:0] shift_in_r  = 
    !sh_rotate &&  word ? {64'b0       , {32{sbit}} , opr_a[31:0]} :
    !sh_rotate && !word ? {{64{sbit}}  , opr_a                   } :
     sh_rotate && !word ? {opr_a       , opr_a                   } :
     sh_rotate &&  word ? {{XLEN{1'b0}}, opr_a[31:0], opr_a[31:0]} :
                        0                                       ;

wire [2*XLEN-1:0] shift_in_l  ;

wire [2*XLEN-1:0] shift_in    = sh_left ? shift_in_l : shift_in_r;

wire [ 5:0] shift_amnt  = {!word && shamt[5] , shamt[4:0]};

wire [2*XLEN-1:0] shift_out_r = shift_in    >> shift_amnt     ;
wire [2*XLEN-1:0] shift_out_l ;

genvar i;
generate for(i = 0; i < XLEN*2; i = i + 1) begin
    assign shift_in_l [i] = shift_in_r [XL-i];
    assign shift_out_l[i] = shift_out_r[XL-i];
end endgenerate

wire sh_sel_rol = sh_left && word &&  op_rol;
wire sh_sel_sh  = sh_left && word && !op_rol;

wire [XL:0] shift_result=
    {64{sh_sel_rol      }} & {{32{shift_out_l[31]}}, shift_out_l[XL:32]} |
    {64{sh_sel_sh       }} & {{32{shift_out_l[31]}}, shift_out_l[31: 0]} |
    {64{sh_right&&  word}} & {{32{shift_out_r[31]}}, shift_out_r[31: 0]} |
    {64{sh_left && !word}} &                         shift_out_l[XL: 0]  |
    {64{sh_right&& !word}} &                         shift_out_r[XL: 0]  ;

//
// Pack Instructions
// ------------------------------------------------------------

wire [XL:0] result_pack     = {       opr_b[31: 0], opr_a[31: 0]};
wire [XL:0] result_packw    = {32'b0, opr_b[15: 0], opr_a[15: 0]};
wire [XL:0] result_packu    = {       opr_b[63:32], opr_a[63:32]};
wire [XL:0] result_packuw   = {32'b0, opr_b[31:16], opr_a[31:16]};
wire [XL:0] result_packh    = {48'b0, opr_b[ 7: 0], opr_a[ 7: 0]};

wire [XL:0] pack_result     =
    op_pack     && !word ?   result_pack     :
    op_pack     &&  word ?   result_packw    :
    op_packu    && !word ?   result_packu    :
    op_packu    &&  word ?   result_packuw   :
    op_packh             ?   result_packh    :
                                64'b0           ;

//
// GREV
// ------------------------------------------------------------

function [7:0] rev_bits_in_byte;
    input [7:0] i; // I'd love to use {<<{}} operator but it makes Vivado cry.
    rev_bits_in_byte = {i[0],i[1],i[2],i[3],i[4],i[5],i[6],i[7]};
endfunction

// bits in bytes
wire [XL:0] grev_7  = {
    rev_bits_in_byte(opr_a[7*8+:8]),
    rev_bits_in_byte(opr_a[6*8+:8]),
    rev_bits_in_byte(opr_a[5*8+:8]),
    rev_bits_in_byte(opr_a[4*8+:8]),
    rev_bits_in_byte(opr_a[3*8+:8]),
    rev_bits_in_byte(opr_a[2*8+:8]),
    rev_bits_in_byte(opr_a[1*8+:8]),
    rev_bits_in_byte(opr_a[0*8+:8])
};

// bytes in 64-bit word
wire [XL:0] grev_56 = {
    opr_a[0*8+:8],
    opr_a[1*8+:8],
    opr_a[2*8+:8],
    opr_a[3*8+:8],
    opr_a[4*8+:8],
    opr_a[5*8+:8],
    opr_a[6*8+:8],
    opr_a[7*8+:8]
};

// bytes in 32-bit word
wire [XL:0] grev_24 = {
    opr_a[4*8+:8],
    opr_a[5*8+:8],
    opr_a[6*8+:8],
    opr_a[7*8+:8],
    opr_a[0*8+:8],
    opr_a[1*8+:8],
    opr_a[2*8+:8],
    opr_a[3*8+:8]
};

wire [XL:0] grev_result =
    shamt == 6'd7  ? grev_7 :
    shamt == 6'd56 ? grev_56:
    shamt == 6'd24 ? grev_24:
                     0      ;

//
// GORC
// ------------------------------------------------------------

wire [XL:0] gorc_3 = 0;

wire [XL:0] gorc_4 = 0;

wire [XL:0] gorc_7 = 0;

wire [XL:0] gorc_result =
    shamt == 6'd3  ? gorc_3 :
    shamt == 6'd4  ? gorc_4 :
    shamt == 6'd7  ? gorc_7 :
                     0      ;

//
// XPERM
// ------------------------------------------------------------

wire [3:0] xperm_n_lut [15:0];
wire [7:0] xperm_b_lut [ 7:0];

wire [XL:0] xperm_n_result;
wire [XL:0] xperm_b_result;

genvar n;
generate for(n=0; n < 16; n=n+1) begin
    assign xperm_n_lut[n] = opr_a[n*4+:4] & {4{op_xpermn}};

    wire [3:0] idx_n      = opr_b[n*4+:4];

    assign xperm_n_result[n*4+:4] = xperm_n_lut[idx_n];
end endgenerate

genvar b;
generate for(b=0; b < 8; b=b+1) begin
    assign xperm_b_lut[b] = opr_a[b*8+:8] & {8{op_xpermb}};

    wire [2:0] idx_n        = opr_b[b*8  +:3];
    wire [4:0] idx_hi       = opr_b[b*8+3+:5];

    assign xperm_b_result[b*8+:8] = |idx_hi ? 8'b0 : xperm_b_lut[idx_n];
end endgenerate


//
// Result multiplexing
// ------------------------------------------------------------

wire sel_addsub = op_add || op_sub  ;
wire sel_slt    = op_slt || op_sltu ;
wire sel_shift  = op_sll || op_sra  || op_srl || op_ror || op_rol;
wire sel_pack   = op_pack|| op_packh|| op_packu;

assign result =
                         bitwise_result             |
    {XLEN{op_xpermn }} & xperm_n_result             |
    {XLEN{op_xpermb }} & xperm_b_result             |
    {XLEN{op_grev   }} & grev_result                |
    {XLEN{op_gorc   }} & gorc_result                |
    {XLEN{sel_pack  }} & pack_result                |
    {XLEN{sel_addsub}} & addsub_result              |
    {XLEN{sel_slt   }} & slt_result                 |
    {XLEN{sel_shift }} & shift_result               ;

endmodule
