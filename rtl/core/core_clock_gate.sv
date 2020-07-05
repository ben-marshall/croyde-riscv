
//
// module: core_clock_gate
//
//  Clock gate cell for the core - simulation model.
//
module core_clock_gate (
input   wire    clk_in      ,   // Free-running clock input
input   wire    clk_req     ,   // Clock request
input   wire    tst_en      ,   // Test enable.
output  wire    clk_out         // Output clock
);

//
// Enable clock if clock request or test enable.
wire    clk_en = clk_req || tst_en;

reg     latch_out;

`ifndef RISCV_FORMAL

//
// Not running in formal proof environment, so latches are fine.

assign  clk_out= latch_out && clk_en;

//
// Negative level latch.
always @(*) begin if(!clk_in) begin
    latch_out = clk_en;
end end

`else

//
// Running in formal proof environment, so avoid latches and just use
// a simple AND gate.

assign clk_out = clk_in && clk_en;

`endif

endmodule

