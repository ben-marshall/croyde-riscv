
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

wire        slt_lsb         = 
    (op_slt  && (word ? slt_signed_w   : slt_signed  )) ||
    (op_sltu && (word ? slt_unsigned_w : slt_unsigned)) ;

assign      cmp_lt          = slt_lsb;

wire [XL:0] slt_result      = {{XL{1'b0}}, slt_lsb};

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
//  TODO
// ------------------------------------------------------------

wire [XL:0] shift_in    = opr_a;

wire [XL:0] shift_l5    = shift_amt[5] ? {opr_a   [31:0], 32'b0} : opr_a   ;
wire [XL:0] shift_l4    = shift_amt[4] ? {shift_l5[47:0], 16'b0} : shift_l5;
wire [XL:0] shift_l3    = shift_amt[3] ? {shift_l4[55:0],  8'b0} : shift_l4;
wire [XL:0] shift_l2    = shift_amt[2] ? {shift_l3[59:0],  4'b0} : shift_l3;
wire [XL:0] shift_l1    = shift_amt[1] ? {shift_l2[61:0],  2'b0} : shift_l2;
wire [XL:0] shift_l0    = shift_amt[0] ? {shift_l1[62:0],  1'b0} : shift_l1;

wire [ 5:0] shift_amt   = opr_b[5:0];

wire [XL:0] shift_result= shift_l0;


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
