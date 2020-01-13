
//
// Header File: core_common.vh
//
//  Contains common constants used throughout the CPU core.
//  Expects to be included *inside* modules.
//


parameter   XLEN        = 64;       // Word width of the CPU
localparam  XL          = XLEN-1;   // For signals which are XLEN wide.

parameter   MEM_ADDR_W  = 64;       // Memory address bus width
parameter   MEM_STRB_W  =  4;       // Memory strobe bits width
parameter   MEM_DATA_W  = 64;       // Memory data bits width

localparam  MEM_ADDR_R  = MEM_ADDR_W - 1; // Memory address bus width
localparam  MEM_STRB_R  = MEM_STRB_W - 1; // Memory strobe bits width
localparam  MEM_DATA_R  = MEM_DATA_W - 1; // Memory data bits width

localparam  CF_CAUSE_W  =  5;               // Control flow change cause width
localparam  CF_CAUSE_R  =  CF_CAUSE_W - 1;

localparam  FD_IBUF_W   = 32             ;  // Fetch -> decode buffer width
localparam  FD_IBUF_R   = FD_IBUF_W   - 1;
localparam  FD_ERR_W    = FD_IBUF_W   /16;
localparam  FD_ERR_R    = FD_ERR_W    - 1;

localparam  REG_ADDR_W  = 5             ;
localparam  REG_ADDR_R  = REG_ADDR_W - 1;
