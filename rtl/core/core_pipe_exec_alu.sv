
//
// module: core_pipe_exec_alu
//
//  Integer ALU module
//
module core_pipe_exec_alu (

input  wire [   XL:0]   opr_a   , // Input operand A
input  wire [   XL:0]   opr_b   , // Input operand B
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

//
// Add / Sub
// ------------------------------------------------------------

wire [XL:0] addsub_rhs      = op_sub ? ~opr_b : opr_b               ;

wire [XL:0] addsub_output   = opr_a + addsub_rhs + {{XL{1'b0}},op_sub};
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

wire [XL:0] xor_output      = opr_a ^ opr_b;
wire [XL:0]  or_output      = opr_a | opr_b;
wire [XL:0] and_output      = opr_a & opr_b;

wire [XL:0] bitwise_result  = {XLEN{op_xor}} & xor_output |
                              {XLEN{op_or }} &  or_output |
                              {XLEN{op_and}} & and_output ;

//
// Shifts
// ------------------------------------------------------------

wire [XL:0] shift_in_r  = {word ? 32'b0 : opr_a[XL:32], opr_a[31:0]};
wire [XL:0] shift_in_l  ;

wire [XL:0] shift_in    = op_sll ? shift_in_l : shift_in_r;

wire [ 5:0] shift_amnt  = {!word && opr_b[5] , opr_b[4:0]};

wire [XL:0] shift_out_r = shift_in    >> shift_amnt     ;
wire [XL:0] shift_out_l ;

wire        shift_abit  = word ? opr_a[31] : opr_a[XL];
wire [XL:0] shift_amask = shift_abit ? ~({64{1'b1}} >> shift_amnt) : 64'b0;

genvar i;
generate for(i = 0; i < XLEN; i = i + 1) begin
    assign shift_in_l [i] = shift_in_r [XL-i];
    assign shift_out_l[i] = shift_out_r[XL-i];
end endgenerate

wire [XL:0] shift_sraw  = {
    {32{shift_in_r [31 ]  || shift_amask[XL   ]}},
        shift_out_r[31:0] |  shift_amask[XL:32]
};

wire [XL:0] shift_sra   = shift_out_r | shift_amask;

wire [XL:0] shift_result=
    {64{op_sll  &&  word}} & {{32{shift_out_l[31]}}, shift_out_l[31:0]} |
    {64{op_srl  &&  word}} & {{32{shift_out_r[31]}}, shift_out_r[31:0]} |
    {64{op_sra  &&  word}} &                         shift_sraw         |
    {64{op_sll  && !word}} &                         shift_out_l        |
    {64{op_srl  && !word}} &                         shift_out_r        |
    {64{op_sra  && !word}} &                         shift_sra          ;


//
// Result multiplexing
// ------------------------------------------------------------

wire sel_addsub = op_add || op_sub  ;
wire sel_slt    = op_slt || op_sltu ;
wire sel_shift  = op_sll || op_sra  || op_srl;

assign result =
                         bitwise_result             |
    {XLEN{sel_addsub}} & addsub_result              |
    {XLEN{sel_slt   }} & slt_result                 |
    {XLEN{sel_shift }} & shift_result               ;

endmodule
