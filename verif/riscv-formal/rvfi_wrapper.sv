
//
// module: rvfi_wrapper
//
//  Wraps the core in the required assumptions and trivial logic needed to
//  interface properly with the RVFI environment.
//
module rvfi_wrapper (
	input clock,
	input reset,
	`RVFI_OUTPUTS
);

//
// Common core parameters and constants.

localparam  XLEN        = 64;       // Word width of the CPU
localparam  XL          = XLEN-1;   // For signals which are XLEN wide.
localparam  ILEN        = 32    ;
localparam  NRET        = 1     ;

parameter   MEM_ADDR_W  = 64;       // Memory address bus width
parameter   MEM_STRB_W  =  8;       // Memory strobe bits width
parameter   MEM_DATA_W  = 64;       // Memory data bits width

localparam  MEM_ADDR_R  = MEM_ADDR_W - 1; // Memory address bus width
localparam  MEM_STRB_R  = MEM_STRB_W - 1; // Memory strobe bits width
localparam  MEM_DATA_R  = MEM_DATA_W - 1; // Memory data bits width


// Base address of the memory mapped IO region.
parameter   MMIO_BASE_ADDR  = 'h0000_0000_0000_1000;
parameter   MMIO_BASE_MASK  = 'h0000_0000_0000_1FFF;

(*keep*)      wire                 g_resetn     = !reset;
(*keep*)      
(*keep*)      wire                 imem_req     ; // Mem request
(*keep*)      wire [ MEM_ADDR_R:0] imem_addr    ; // Mem request address
(*keep*)      wire                 imem_wen     ; // Mem request write enable
(*keep*)      wire [ MEM_STRB_R:0] imem_strb    ; // Mem request write strobe
(*keep*)      wire [ MEM_DATA_R:0] imem_wdata   ; // Mem write data.
(*keep*) rand reg                  imem_gnt     ; // Mem response valid
(*keep*) rand reg                  imem_err     ; // Mem response error
(*keep*) rand reg  [ MEM_DATA_R:0] imem_rdata   ; // Mem response read data

(*keep*)      wire                 dmem_req     ; // Mem request
(*keep*)      wire [ MEM_ADDR_R:0] dmem_addr    ; // Mem request address
(*keep*)      wire                 dmem_wen     ; // Mem request write enable
(*keep*)      wire [ MEM_STRB_R:0] dmem_strb    ; // Mem request write strobe
(*keep*)      wire [ MEM_DATA_R:0] dmem_wdata   ; // Mem write data.
(*keep*) rand reg                  dmem_gnt     ; // Mem response valid
(*keep*) rand reg                  dmem_err     ; // Mem response error
(*keep*) rand reg  [ MEM_DATA_R:0] dmem_rdata   ; // Mem response read data

(*keep*)      wire                 trs_valid    ; // Instruction trace valid
(*keep*)      wire [         31:0] trs_instr    ; // Instruction trace data
(*keep*)      wire [         XL:0] trs_pc       ; // Instruction trace PC

(*keep*) rand reg                  int_sw       ; // software interrupt
(*keep*) rand reg                  int_ext      ; // hardware interrupt


//
// Fairness and assumptions
// ------------------------------------------------------------

rvfi_fairness #(
.MMIO_BASE_ADDR(MMIO_BASE_ADDR),
.MMIO_BASE_MASK(MMIO_BASE_MASK),
.MEM_ADDR_W    (MEM_ADDR_W    )
) i_rvfi_fairness (
.g_clk        (clock        ), // Global clock
.g_resetn     (g_resetn     ), // Global active low sync reset.
.int_sw       (int_sw       ), // Software interrupt
.int_ext      (int_ext      ), // External interrupt
.imem_req     (imem_req     ), // Memory request
.imem_addr    (imem_addr    ), // Memory request address
.imem_wen     (imem_wen     ), // Memory request write enable
.imem_strb    (imem_strb    ), // Memory request write strobe
.imem_wdata   (imem_wdata   ), // Memory write data.
.imem_gnt     (imem_gnt     ), // Memory response valid
.imem_err     (imem_err     ), // Memory response error
.imem_rdata   (imem_rdata   ), // Memory response read data
.dmem_req     (dmem_req     ), // Memory request
.dmem_addr    (dmem_addr    ), // Memory request address
.dmem_wen     (dmem_wen     ), // Memory request write enable
.dmem_strb    (dmem_strb    ), // Memory request write strobe
.dmem_wdata   (dmem_wdata   ), // Memory write data.
.dmem_gnt     (dmem_gnt     ), // Memory response valid
.dmem_err     (dmem_err     ), // Memory response error
.dmem_rdata   (dmem_rdata   ), // Memory response read data
`RVFI_CONN                   , // Formal checker interface.
.trs_valid    (trs_valid    ), // Instruction trace valid
.trs_instr    (trs_instr    ), // Instruction trace data
.trs_pc       (trs_pc       )  // Instruction trace PC
);


//
// DUT Instance
// ------------------------------------------------------------


core_top #(
.MMIO_BASE_ADDR(MMIO_BASE_ADDR),
.MMIO_BASE_MASK(MMIO_BASE_MASK),
.MEM_ADDR_W    (MEM_ADDR_W    )
) i_dut (
.g_clk        (clock        ), // Global clock
.g_resetn     (g_resetn     ), // Global active low sync reset.
.int_sw       (int_sw       ), // Software interrupt
.int_ext      (int_ext      ), // External interrupt
.imem_req     (imem_req     ), // Memory request
.imem_addr    (imem_addr    ), // Memory request address
.imem_wen     (imem_wen     ), // Memory request write enable
.imem_strb    (imem_strb    ), // Memory request write strobe
.imem_wdata   (imem_wdata   ), // Memory write data.
.imem_gnt     (imem_gnt     ), // Memory response valid
.imem_err     (imem_err     ), // Memory response error
.imem_rdata   (imem_rdata   ), // Memory response read data
.dmem_req     (dmem_req     ), // Memory request
.dmem_addr    (dmem_addr    ), // Memory request address
.dmem_wen     (dmem_wen     ), // Memory request write enable
.dmem_strb    (dmem_strb    ), // Memory request write strobe
.dmem_wdata   (dmem_wdata   ), // Memory write data.
.dmem_gnt     (dmem_gnt     ), // Memory response valid
.dmem_err     (dmem_err     ), // Memory response error
.dmem_rdata   (dmem_rdata   ), // Memory response read data
`RVFI_CONN                   , // Formal checker interface.
.trs_valid    (trs_valid    ), // Instruction trace valid
.trs_instr    (trs_instr    ), // Instruction trace data
.trs_pc       (trs_pc       )  // Instruction trace PC
);

endmodule
