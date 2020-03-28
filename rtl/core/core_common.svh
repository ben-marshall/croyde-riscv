
//
// Header File: core_common.vh
//
//  Contains common constants used throughout the CPU core.
//  Expects to be included *inside* modules.
//


parameter   XLEN        = 64;       // Word width of the CPU
localparam  XL          = XLEN-1;   // For signals which are XLEN wide.
localparam  ILEN        = 16    ;
localparam  NRET        = 1     ;

parameter   MEM_ADDR_W  = 64;       // Memory address bus width
parameter   MEM_STRB_W  =  8;       // Memory strobe bits width
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

//
// CSR Trap codes

localparam TRAP_NONE    = 6'b111111;
localparam TRAP_IALIGN  = 6'b0 ;
localparam TRAP_IACCESS = 6'b1 ;
localparam TRAP_IOPCODE = 6'd2 ;
localparam TRAP_BREAKPT = 6'd3 ;
localparam TRAP_LDALIGN = 6'd4 ;
localparam TRAP_LDACCESS= 6'd5 ;
localparam TRAP_STALIGN = 6'd6 ;
localparam TRAP_STACCESS= 6'd7 ;
localparam TRAP_ECALLM  = 6'd11;

localparam TRAP_INT_MSI = 6'd3 ;
localparam TRAP_INT_MTI = 6'd7 ;
localparam TRAP_INT_MEI = 6'd11;


//
// ALU Op codes

localparam ALU_OP_W         = 4;
localparam ALU_OP_R         = ALU_OP_W - 1;

localparam ALU_OP_NOP       = 4'h0;
localparam ALU_OP_ADD       = 4'h1;
localparam ALU_OP_SUB       = 4'h2;
localparam ALU_OP_SLL       = 4'h3;
localparam ALU_OP_SRL       = 4'h4;
localparam ALU_OP_SRA       = 4'h5;
localparam ALU_OP_AND       = 4'h6;
localparam ALU_OP_OR        = 4'h7;
localparam ALU_OP_NOT       = 4'h8;
localparam ALU_OP_XOR       = 4'h9;
localparam ALU_OP_SLT       = 4'hA;
localparam ALU_OP_SLTU      = 4'hB;

//
// MUL / DIV Opcodes

localparam MDU_OP_W         = 4;
localparam MDU_OP_R         = MDU_OP_W - 1;

localparam MDU_OP_NOP       = 4'h0;
localparam MDU_OP_MUL       = 4'h1;
localparam MDU_OP_MULH      = 4'h2;
localparam MDU_OP_MULHSU    = 4'h3;
localparam MDU_OP_MULHU     = 4'h4;
localparam MDU_OP_DIV       = 4'h5;
localparam MDU_OP_DIVU      = 4'h6;
localparam MDU_OP_REM       = 4'h7;
localparam MDU_OP_REMU      = 4'h8;

//
// Load/Store opcodes

localparam LSU_OP_W         = 5;
localparam LSU_OP_R         = LSU_OP_W - 1;

localparam LSU_OP_NOP       = 5'b0_000_0;
localparam LSU_OP_LB        = 5'b0_001_1;
localparam LSU_OP_LBU       = 5'b0_001_0;
localparam LSU_OP_LH        = 5'b0_010_1;
localparam LSU_OP_LHU       = 5'b0_010_0;
localparam LSU_OP_LW        = 5'b0_011_1;
localparam LSU_OP_LWU       = 5'b0_011_0;
localparam LSU_OP_LD        = 5'b0_100_1;
localparam LSU_OP_SB        = 5'b1_001_0;
localparam LSU_OP_SH        = 5'b1_010_0;
localparam LSU_OP_SW        = 5'b1_011_0;
localparam LSU_OP_SD        = 5'b1_100_0;

//
// CSR Opcodes

localparam CSR_OP_W         = 4;
localparam CSR_OP_R         = CSR_OP_W - 1;

localparam CSR_OP_NOP       = 4'b0000;
localparam CSR_OP_RD        = 0;
localparam CSR_OP_WR        = 1;
localparam CSR_OP_SET       = 2;
localparam CSR_OP_CLR       = 3;

//
//  CFU Opcodes

localparam CFU_OP_W         = 4;
localparam CFU_OP_R         = CFU_OP_W - 1;

localparam CFU_OP_NOP       = 4'h0;
localparam CFU_OP_J         = 4'h1;
localparam CFU_OP_JAL       = 4'h2;
localparam CFU_OP_BEQ       = 4'h3;
localparam CFU_OP_BNE       = 4'h4;
localparam CFU_OP_BLT       = 4'h5;
localparam CFU_OP_BLTU      = 4'h6;
localparam CFU_OP_BGE       = 4'h7;
localparam CFU_OP_BGEU      = 4'h8;
localparam CFU_OP_MRET      = 4'h9;
localparam CFU_OP_EBREAK    = 4'hA;
localparam CFU_OP_ECALL     = 4'hB;

