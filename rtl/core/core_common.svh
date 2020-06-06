
//
// Header File: core_common.vh
//
//  Contains common constants used throughout the CPU core.
//  Expects to be included *inside* modules.
//


localparam  XLEN        = 64;       // Word width of the CPU
localparam  XL          = XLEN-1;   // For signals which are XLEN wide.
localparam  ILEN        = 32    ;
localparam  NRET        = 1     ;

parameter   MEM_ADDR_W  = 39;       // Memory address bus width
parameter   MEM_STRB_W  =  8;       // Memory strobe bits width
parameter   MEM_DATA_W  = 64;       // Memory data bits width

localparam  MEM_ADDR_R  = MEM_ADDR_W - 1; // Memory address bus width
localparam  MEM_STRB_R  = MEM_STRB_W - 1; // Memory strobe bits width
localparam  MEM_DATA_R  = MEM_DATA_W - 1; // Memory data bits width

localparam  CF_CAUSE_W  =  7;               // Control flow change cause width
localparam  CF_CAUSE_R  =  CF_CAUSE_W - 1;

localparam  FD_IBUF_W   = 32             ;  // Fetch -> decode buffer width
localparam  FD_IBUF_R   = FD_IBUF_W   - 1;
localparam  FD_ERR_W    = FD_IBUF_W   /16;
localparam  FD_ERR_R    = FD_ERR_W    - 1;

localparam  REG_ADDR_W  = 5             ;
localparam  REG_ADDR_R  = REG_ADDR_W - 1;

localparam  REG_ZERO    = 5'b0          ;
localparam  REG_RA      = 5'd1          ;
localparam  REG_SP      = 5'd2          ;

//
// CSR Trap codes
// See PRA 3.1.20 (mcause) for cause code values

localparam TRAP_NONE    = 7'b111111;
localparam TRAP_IALIGN  = 7'b0 ;
localparam TRAP_IACCESS = 7'b1 ;
localparam TRAP_IOPCODE = 7'd2 ;
localparam TRAP_BREAKPT = 7'd3 ;
localparam TRAP_LDALIGN = 7'd4 ;
localparam TRAP_LDACCESS= 7'd5 ;
localparam TRAP_STALIGN = 7'd6 ;
localparam TRAP_STACCESS= 7'd7 ;
localparam TRAP_ECALLM  = 7'd11;

localparam TRAP_INT_MSI = 7'd3 ;
localparam TRAP_INT_MTI = 7'd7 ;
localparam TRAP_INT_MEI = 7'd11;

//
// Writeback opcodes
localparam WB_OP_W          = 2;
localparam WB_OP_R          = WB_OP_W - 1;

localparam WB_OP_NONE       = 2'b00;
localparam WB_OP_WDATA      = 2'b01;
localparam WB_OP_LSU        = 2'b10;
localparam WB_OP_CSR        = 2'b11;

//
// Load/Store opcodes

localparam LSU_OP_W         = 7;
localparam LSU_OP_R         = LSU_OP_W - 1;

localparam LSU_OP_LOAD      = 0;
localparam LSU_OP_STORE     = 1;
localparam LSU_OP_BYTE      = 2;
localparam LSU_OP_HALF      = 3;
localparam LSU_OP_WORD      = 4;
localparam LSU_OP_DOUBLE    = 5;
localparam LSU_OP_SEXT      = 6;


//
// CSR Opcodes

localparam CSR_OP_W         = 4;
localparam CSR_OP_R         = CSR_OP_W - 1;

localparam CSR_OP_NOP       = 4'b000;
localparam CSR_OP_RD        = 0;
localparam CSR_OP_WR        = 1;
localparam CSR_OP_SET       = 2;
localparam CSR_OP_CLR       = 3;

//
//  CFU Opcodes

localparam CFU_OP_W         = 3;
localparam CFU_OP_R         = CFU_OP_W - 1;

localparam CFU_OP_NOP       = 3'b000;
localparam CFU_OP_TAKEN     = 3'b001;
localparam CFU_OP_IGNORE    = 3'b010;
localparam CFU_OP_MRET      = 3'b101;
localparam CFU_OP_TRAP      = 3'b111;

