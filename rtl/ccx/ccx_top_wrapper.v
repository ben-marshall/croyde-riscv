
//
// module: ccx_top_wrapper
//
//  Stupid workaround for Vivado. Doesn't let you instance SV as
//  The top of a module in a block design, but it will let you
//  instance an SV module inside a plain verilog module. Hmmmm.
//
module ccx_top_wrapper #(
// Inital address of the program counter post reset.
parameter PC_RESET_ADDRESS  = 39'h00000000,

// Use a FPGA-inference-friendly implementation of the register file.
parameter FPGA_REGFILE      = 0,

// Base address of the memory mapped IO region.
parameter MMIO_BASE         = 39'h0000_0000_0002_0000,
parameter MMIO_SIZE         = 39'h0000_0000_0000_00FF,

parameter ROM_MEMH          = "none",
parameter RAM_MEMH          = "none",

parameter ROM_BASE          = 39'h0000_0000,
parameter ROM_SIZE          = 39'h0000_03FF,
parameter RAM_BASE          = 39'h0001_0000,
parameter RAM_SIZE          = 39'h0000_FFFF,
parameter EXT_BASE          = 39'h0010_0000,
parameter EXT_SIZE          = 39'h000F_FFFF,
parameter CLK_GATE_EN       = 1'b1  // Enable core-level clock gating
) (

input  wire         f_clk        , // Global free-running clock.
input  wire         g_resetn     , // Synchronous negative level reset.
input  wire         g_clk_test_en, // Clock test enable.

input  wire         int_sw       , // External interrupt
input  wire         int_ext      , // Software interrupt

output wire         emem_req     , // Memory request
output wire         emem_rtype   , // Memory request type.
output wire [ 38:0] emem_addr    , // Memory request address
output wire         emem_wen     , // Memory request write enable
output wire [  7:0] emem_strb    , // Memory request write strobe
output wire [ 63:0] emem_wdata   , // Memory write data.
output wire [  1:0] emem_prv     , // Memory Privilidge level.
input  wire         emem_gnt     , // Memory response valid
input  wire         emem_err     , // Memory response error
input  wire [ 63:0] emem_rdata   , // Memory response read data

output wire         wfi_sleep    , // Core is asleep due to WFI.

output wire         trs_valid    , // Instruction trace valid
output wire [ 31:0] trs_instr    , // Instruction trace data
output wire [ 63:0] trs_pc         // Instruction trace PC

);

ccx_top #(
.PC_RESET_ADDRESS(PC_RESET_ADDRESS),
.FPGA_REGFILE    (FPGA_REGFILE    ),
.MMIO_BASE       (MMIO_BASE       ),
.MMIO_SIZE       (MMIO_SIZE       ),
.ROM_MEMH        (ROM_MEMH        ),
.ROM_BASE        (ROM_BASE        ),
.ROM_SIZE        (ROM_SIZE        ),
.RAM_MEMH        (RAM_MEMH        ),
.RAM_BASE        (RAM_BASE        ),
.RAM_SIZE        (RAM_SIZE        ),
.EXT_BASE        (EXT_BASE        ),
.EXT_SIZE        (EXT_SIZE        ),
.CLK_GATE_EN     (CLK_GATE_EN     )
) i_ccx_top (
.f_clk        (f_clk        ), // Global free-running clock.
.g_resetn     (g_resetn     ), // Synchronous negative level reset.
.g_clk_test_en(g_clk_test_en), // Clock test enable.
.int_sw       (int_sw       ), // External interrupt
.int_ext      (int_ext      ), // Software interrupt
.emem_req     (emem_req     ), // Memory request
.emem_rtype   (emem_rtype   ), // Memory request type.
.emem_addr    (emem_addr    ), // Memory request address
.emem_wen     (emem_wen     ), // Memory request write enable
.emem_strb    (emem_strb    ), // Memory request write strobe
.emem_wdata   (emem_wdata   ), // Memory write data.
.emem_prv     (emem_prv     ), // Memory privilidge level.
.emem_gnt     (emem_gnt     ), // Memory response valid
.emem_err     (emem_err     ), // Memory response error
.emem_rdata   (emem_rdata   ), // Memory response read data
.wfi_sleep    (wfi_sleep    ), // Core is asleep due to WFI.
.trs_valid    (trs_valid    ), // Instruction trace valid
.trs_instr    (trs_instr    ), // Instruction trace data
.trs_pc       (trs_pc       )  // Instruction trace PC
);

endmodule

