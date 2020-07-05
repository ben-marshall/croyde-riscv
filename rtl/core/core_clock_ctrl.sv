
//
// module: core_clock_ctrl
//
//  Core-level clock gating control.
//
module core_clock_ctrl (

input  wire f_clk           , // Global free running clock
input  wire g_resetn        , // Global active low synchronous reset.
input  wire g_clk_test_en   , // Clock test enable.

input  wire g_clk_req       , // Core level gated clock request
output wire g_clk           , // Core level gated clock

input  wire g_clk_rf_req    , // Register file gated clock request
output wire g_clk_rf        , // Register file gated clock

input  wire g_clk_mul_req   , // Multiplier gated clock request
output wire g_clk_mul         // Multiplier gated clock

);

parameter CLK_GATE_EN      = 1'b1; // Enable core-level clock gating

generate if (CLK_GATE_EN == 1'b0) begin : clk_gating_disabled

assign  g_clk       = f_clk;
assign  g_clk_rf    = f_clk;
assign  g_clk_mul   = f_clk;

end else begin : clk_gating_enabled

//
// Core level clock gating
prim_clock_gate i_core_clock_core (
.clk_in (f_clk          ),   // Free-running clock input
.clk_req(g_clk_req      ),   // Clock request
.tst_en (g_clk_test_en  ),   // Test enable.
.clk_out(g_clk          )    // Output clock
);

//
// Register file clock gating
prim_clock_gate i_core_clock_rf (
.clk_in (f_clk          ),   // Free-running clock input
.clk_req(g_clk_rf_req   ),   // Clock request
.tst_en (g_clk_test_en  ),   // Test enable.
.clk_out(g_clk_rf       )    // Output clock
);

//
// MDU file clock gating
prim_clock_gate i_core_clock_mul (
.clk_in (f_clk          ),   // Free-running clock input
.clk_req(g_clk_mul_req  ),   // Clock request
.tst_en (g_clk_test_en  ),   // Test enable.
.clk_out(g_clk_mul      )    // Output clock
);

end endgenerate

endmodule
