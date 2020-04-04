
//
// module: core_interrupts
//
//  Handles interrupt prioritisation and raising.
//
module core_interrupts (

input  wire                 g_clk        , // global clock
input  wire                 g_resetn     , // global active low sync reset.

input  wire                 int_sw       , // Software interrupt
input  wire                 int_ext      , // External interrupt
input  wire                 int_ti       , // Timer interrupt

input  wire [         XL:0] mtvec_base   , // Machine trap vector base addr
input  wire [          1:0] mtvec_mode   , // Machine trap vector/direct mooe

input  wire                 mstatus_mie  , // Global interrupt enable.

input  wire                 mie_meie     , // External interrupt enable.
input  wire                 mie_mtie     , // Timer interrupt enable.
input  wire                 mie_msie     , // Software interrupt enable.

output wire                 mip_meip     , // External interrupt pending
output wire                 mip_mtip     , // Timer interrupt pending
output wire                 mip_msip     , // Software interrupt pending

output wire                 int_pending  , // To exec stage
output wire [ CF_CAUSE_R:0] int_cause    , // Cause code for the interrupt.
output wire [         XL:0] int_tvec     , // Interrupt trap vector
input  wire                 int_ack        // Interrupt taken acknowledge

);

//
// Common parameters
`include "core_common.svh"

//
// Unpack mtvec register

wire        mode_direct= !mtvec_mode[0];

wire        mode_vector=  mtvec_mode[0];


//
// Which interrupts are pending?
// ------------------------------------------------------------

wire    int_pend_ext        = int_ext && mie_meie           ;
wire    int_pend_ti         = int_ti  && mie_mtie           ;
wire    int_pend_sw         = int_sw  && mie_msie           ;

assign  mip_meip            = int_pend_ext                  ;
assign  mip_mtip            = int_pend_ti                   ;
assign  mip_msip            = int_pend_sw                   ;

assign  int_pending         = mstatus_mie && (
                                    int_pend_ext    ||
                                    int_pend_ti     ||
                                    int_pend_sw
                              );

//
// Raise interrupt request to the execute stage.
// ------------------------------------------------------------

//
// See PRA 3.1.20 (mcause) for cause code values
assign      int_cause       = int_pend_ext  ? TRAP_INT_MEI  :
                              int_pend_sw   ? TRAP_INT_MSI  :
                              int_pend_ti   ? TRAP_INT_MTI  :
                                              7'd0          ;

//
// PRA 3.1.12 - in vectored mode, set pc to mtvec.base + 4*cause
wire [XL:0] mtvec_offset    = 
    mode_vector   ? {{XL-8{1'b0}}, int_cause, 2'b00}        :
                     {XLEN{1'b0}}                           ;

assign      int_tvec        = mtvec_base | mtvec_offset     ;


//
// Designer Assertions
// ------------------------------------------------------------

`ifdef DESIGNER_ASSERTION_CORE_INTERRUPTS

always @(posedge g_clk) if(g_resetn) begin
    
    //
    // Should never be any overlap between base and offset, since we
    // just OR the two together rather than add them.
    assert((mtvec_offset & mtvec_base) == 0);

    //
    // Bit 1 of mtvec.mode should always be zero
    assert(!mtvec_mode[1]);

    //
    // Check we ever see some interrupts.

    cover(!int_pending                  );
    
    cover( int_pending                  );

    cover( int_pend_ext &&  mstatus_mie );
    cover( int_pend_ti  &&  mstatus_mie );
    cover( int_pend_sw  &&  mstatus_mie );
    
    cover( int_pend_ext && !mstatus_mie );
    cover( int_pend_ti  && !mstatus_mie );
    cover( int_pend_sw  && !mstatus_mie );

    cover( int_pending  &&  int_ack     );

    cover( int_pending  &&  int_ack && mode_direct  );
    cover( int_pending  &&  int_ack && mode_vector  );

end

`endif

endmodule

