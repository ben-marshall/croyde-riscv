
//
// Module: core_top 
//
//  The top level module of the core.
//
module core_top (

input  wire                 g_clk        , // Global clock
input  wire                 g_resetn     , // Global active low sync reset.
              
output wire                 imem_req     , // Memory request
output wire [ MEM_ADDR_R:0] imem_addr    , // Memory request address
output wire                 imem_wen     , // Memory request write enable
output wire [ MEM_STRB_R:0] imem_strb    , // Memory request write strobe
output wire [ MEM_DATA_R:0] imem_wdata   , // Memory write data.
input  wire                 imem_gnt     , // Memory response valid
input  wire                 imem_err     , // Memory response error
input  wire [ MEM_DATA_R:0] imem_rdata   , // Memory response read data

output wire                 dmem_req     , // Memory request
output wire [ MEM_ADDR_R:0] dmem_addr    , // Memory request address
output wire                 dmem_wen     , // Memory request write enable
output wire [ MEM_STRB_R:0] dmem_strb    , // Memory request write strobe
output wire [ MEM_DATA_R:0] dmem_wdata   , // Memory write data.
input  wire                 dmem_gnt     , // Memory response valid
input  wire                 dmem_err     , // Memory response error
input  wire [ MEM_DATA_R:0] dmem_rdata   , // Memory response read data

output wire                 trs_valid    , // Instruction trace valid
output wire [         31:0] trs_instr    , // Instruction trace data
output wire [         XL:0] trs_pc         // Instruction trace PC

);


// Common parameters and width definitions.
`include "core_common.vh"

// Inital address of the program counter post reset.
parameter   PC_RESET_ADDRESS      = 64'h80000000;

// TODO implement trace interface proper.
assign trs_valid = 1'b0;
assign trs_instr = 32'b0;
assign trs_pc    = 64'b0;


//
// Constant assignments.
// ------------------------------------------------------------

assign imem_wen     = 1'b0;
assign imem_strb    = {MEM_STRB_W{1'b0}};
assign imem_wdata   = {MEM_DATA_W{1'b0}};

//
// Inter-stage wiring
// ------------------------------------------------------------

wire                 cf_valid    ; // Control flow change?
wire                 cf_ack      ; // Control flow change acknwoledged
wire [         XL:0] cf_target   ; // Control flow change destination
wire [ CF_CAUSE_R:0] cf_cause    ; // Control flow change cause

wire                 s2_cf_valid ; // Control flow change?
wire                 s2_cf_ack   ; // Control flow change acknwoledged
wire [         XL:0] s2_cf_target; // Control flow change destination
wire [ CF_CAUSE_R:0] s2_cf_cause ; // Control flow change cause

wire                 s1_16bit    ; // 16 bit instruction?
wire                 s1_32bit    ; // 32 bit instruction?
wire [  FD_IBUF_R:0] s1_instr    ; // Instruction to be decoded
wire [         XL:0] s1_pc       ; // Program Counter
wire [         XL:0] s1_npc      ; // Next Program Counter
wire [   FD_ERR_R:0] s1_ferr     ; // Fetch bus error?
wire                 s2_eat_2    ; // Decode eats 2 bytes
wire                 s2_eat_4    ; // Decode eats 4 bytes

wire [ REG_ADDR_R:0] s2_rs1_addr ; // RS1 Address
wire [         XL:0] s2_rs1_data ; // RS1 Read Data (Forwarded)
wire [ REG_ADDR_R:0] s2_rs2_addr ; // RS2 Address
wire [         XL:0] s2_rs2_data ; // RS2 Read Data (Forwarded)

wire                 s2_valid    ;
wire                 s3_ready    ;
wire [         XL:0] s2_pc       ;
wire [         XL:0] s2_opr_a    ;
wire [         XL:0] s2_opr_b    ;
wire [         XL:0] s2_opr_c    ;
wire [ REG_ADDR_R:0] s2_rd       ;
wire [   ALU_OP_R:0] s2_alu_op   ;
wire [   ALU_OP_R:0] s2_lsu_op   ;
wire [   ALU_OP_R:0] s2_mdu_op   ;
wire [   ALU_OP_R:0] s2_csr_op   ;
wire [   ALU_OP_R:0] s2_cfu_op   ;
wire                 s2_op_w     ;
wire [         32:0] s2_instr    ;

//
// Submodule instances.
// ------------------------------------------------------------


//
// Instance: core_pipe_fetch
//
//  Pipeline Fetch Stage
//
core_pipe_fetch i_core_pipe_fetch (
.g_clk        (g_clk        ), // Global clock
.g_resetn     (g_resetn     ), // Global active low sync reset.
.cf_valid     (cf_valid     ), // Control flow change?
.cf_ack       (cf_ack       ), // Control flow change acknwoledged
.cf_target    (cf_target    ), // Control flow change destination
.cf_cause     (cf_cause     ), // Control flow change cause
.imem_req     (imem_req     ), // Memory request
.imem_addr    (imem_addr    ), // Memory request address
.imem_gnt     (imem_gnt     ), // Memory response valid
.imem_err     (imem_err     ), // Memory response error
.imem_rdata   (imem_rdata   ), // Memory response read data
.s1_16bit     (s1_16bit     ), // 16 bit instruction?
.s1_32bit     (s1_32bit     ), // 32 bit instruction?
.s1_instr     (s1_instr     ), // Instruction to be decoded
.s1_pc        (s1_pc        ), // Program Counter
.s1_npc       (s1_npc       ), // Next Program Counter
.s1_ferr      (s1_ferr      ), // Fetch bus error?
.s2_eat_2     (s2_eat_2     ), // Decode eats 2 bytes
.s2_eat_4     (s2_eat_4     )  // Decode eats 4 bytes
);


//
// Instance: core_pipe_decode
//
//  Pipeline decode / operand gather stage.
//
core_pipe_decode i_core_pipe_decode(
.g_clk       (g_clk       ), // Global clock
.g_resetn    (g_resetn    ), // Global active low sync reset.
.s1_16bit    (s1_16bit    ), // 16 bit instruction?
.s1_32bit    (s1_32bit    ), // 32 bit instruction?
.s1_instr    (s1_instr    ), // Instruction to be decoded
.s1_pc       (s1_pc       ), // Program Counter
.s1_npc      (s1_npc      ), // Next Program Counter
.s1_ferr     (s1_ferr     ), // Fetch bus error?
.s2_eat_2    (s2_eat_2    ), // Decode eats 2 bytes
.s2_eat_4    (s2_eat_4    ), // Decode eats 4 bytes
.s2_cf_valid (s2_cf_valid ), // Control flow change?
.s2_cf_ack   (s2_cf_ack   ), // Control flow change acknwoledged
.s2_cf_target(s2_cf_target), // Control flow change destination
.s2_cf_cause (s2_cf_cause ), // Control flow change cause
.s2_rs1_addr (s2_rs1_addr ), // RS1 Address
.s2_rs1_data (s2_rs1_data ), // RS1 Read Data (Forwarded)
.s2_rs2_addr (s2_rs2_addr ), // RS2 Address
.s2_rs2_data (s2_rs2_data ), // RS2 Read Data (Forwarded)
.s2_valid    (s2_valid    ), // 
.s3_ready    (s3_ready    ), // 
.s2_pc       (s2_pc       ), // 
.s2_opr_a    (s2_opr_a    ), // 
.s2_opr_b    (s2_opr_b    ), // 
.s2_opr_c    (s2_opr_c    ), // 
.s2_rd       (s2_rd       ), // 
.s2_alu_op   (s2_alu_op   ), // 
.s2_lsu_op   (s2_lsu_op   ), // 
.s2_mdu_op   (s2_mdu_op   ), // 
.s2_csr_op   (s2_csr_op   ), // 
.s2_cfu_op   (s2_cfu_op   ), // 
.s2_op_w     (s2_op_w     ), // 
.s2_instr    (s2_instr    )  // 
);

endmodule
