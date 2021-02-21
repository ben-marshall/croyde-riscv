
//
// module: prim_clock_gate
//
//  Primitive gate cell for the core - simulation model.
//
module prim_clock_gate (
input   wire    clk_in      ,   // Free-running clock input
input   wire    clk_req     ,   // Clock request
input   wire    tst_en      ,   // Test enable.
output  wire    clk_out         // Output clock
);

//
// Enable clock if clock request or test enable.
wire    clk_en = clk_req || tst_en;

`ifdef CLOCK_GATE_NO_LATCH

//
// Running in formal proof environment, so avoid latches and just use
// a simple AND gate.

assign clk_out = clk_in && clk_en;

`else

reg     latch_out /* verilator clock_enable */;

//
// Not running in formal proof environment, so latches are fine.

assign  clk_out= latch_out && clk_in;

//
// Negative level latch.
/* verilator lint_off LATCH */
always @(*) begin if(!clk_in) begin
    latch_out = clk_en;
end end
/* verilator lint_on LATCH */

`endif

endmodule

