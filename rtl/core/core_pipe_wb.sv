
//
// module: core_pipe_wb
//
//  Writeback stage. Responsible for GPR writebacks, CSR accesses,
//  Load data processing, trap raising.
//
module core_pipe_wb (

input  wire                 g_clk           , // Global clock
input  wire                 g_resetn        , // Global active low sync reset.

output wire                 s3_cf_valid     , // Control flow change?
input  wire                 s3_cf_ack       , // Control flow acknwoledged
output wire [         XL:0] s3_cf_target    , // Control flow destination

input  wire                 s3_valid        , // New instruction ready
output wire                 s3_ready        , // WB ready for new instruciton.
input  wire                 s3_full         , // WB has an instr in it.
input  wire [         XL:0] s3_pc           , // Writeback stage PC
input  wire [         31:0] s3_instr        , // Writeback stage instr word
input  wire [         XL:0] s3_wdata        , // Writeback stage instr word
input  wire [ REG_ADDR_R:0] s3_rd           , // Writeback stage instr word
input  wire [   LSU_OP_R:0] s3_lsu_op       , // Writeback LSU op
input  wire [   CSR_OP_R:0] s3_csr_op       , // Writeback CSR op
input  wire [         11:0] s3_csr_addr     , // CSR Address
input  wire [   CFU_OP_R:0] s3_cfu_op       , // Writeback CFU op
input  wire [    WB_OP_R:0] s3_wb_op        , // Writeback Data source.
input  wire                 s3_trap         , // Raise a trap

output wire                 s3_rd_wen       , // RD write enable
output wire [ REG_ADDR_R:0] s3_rd_addr      , // RD write addr
output wire [         XL:0] s3_rd_wdata     , // RD write data.

output wire                 csr_en          , // CSR Access Enable
output wire                 csr_wr          , // CSR Write Enable
output wire                 csr_wr_set      , // CSR Write - Set
output wire                 csr_wr_clr      , // CSR Write - Clear
output wire [         11:0] csr_addr        , // Address of the CSR to access.
output wire [         XL:0] csr_wdata       , // Data to be written to a CSR
input  wire [         XL:0] csr_rdata       , // CSR read data
input  wire                 csr_error       , // CSR access error

input  wire                 dmem_req        , // Memory request
input  wire [ MEM_ADDR_R:0] dmem_addr       , // Memory request address
input  wire                 dmem_wen        , // Memory request write enable
input  wire [ MEM_STRB_R:0] dmem_strb       , // Memory request write strobe
input  wire [ MEM_DATA_R:0] dmem_wdata      , // Memory write data.
input  wire                 dmem_gnt        , // Memory response valid
input  wire                 dmem_err        , // Memory response error
input  wire [ MEM_DATA_R:0] dmem_rdata        // Memory response read data

);


// Common parameters and width definitions.
`include "core_common.svh"

//
// MISC Useful signals
// ------------------------------------------------------------

// A new instruction will arrive on the next cycle.
wire   e_new_instr  =  s3_valid && s3_ready;

wire   e_instr_ret  =  e_new_instr && s3_full;

wire   e_cf_change  = s3_cf_valid && s3_cf_ack;

assign s3_ready     = !s3_full  || s3_full && !cfu_wait;


//
// GPR Writeback control
// ------------------------------------------------------------

reg       rd_wen_enable;

always  @(posedge g_clk) begin
    if(!g_resetn) begin
        rd_wen_enable <= 1'b0;
    end else if(e_new_instr) begin
        rd_wen_enable <= 1'b1;
    end else if(s3_rd_wen) begin
        rd_wen_enable <= 1'b0;
    end
end

wire    wb_none    = s3_wb_op == WB_OP_NONE    ;
wire    wb_wdata   = s3_wb_op == WB_OP_WDATA   ;
wire    wb_lsu     = s3_wb_op == WB_OP_LSU     ;
wire    wb_csr     = s3_wb_op == WB_OP_CSR     ;

assign  s3_rd_wen  = rd_wen_enable && (wb_wdata || wb_lsu || wb_csr);

assign  s3_rd_wdata=
    {XLEN{wb_wdata  }}  & s3_wdata  |
    {XLEN{wb_lsu    }}  & lsu_wdata |
    {XLEN{wb_csr    }}  & csr_rdata ;

assign  s3_rd_addr = s3_rd          ;

//
// CSR Control
// ------------------------------------------------------------

reg     csr_op_done   ;

always @(posedge g_clk) begin
    if(!g_resetn) begin
        csr_op_done <= 1'b0;
    end else if(e_new_instr) begin
        csr_op_done <= 1'b0;
    end else if(csr_en) begin
        csr_op_done <= 1'b0;
    end
end

wire    csr_op_rd   = s3_csr_op[CSR_OP_RD ];
wire    csr_op_wr   = s3_csr_op[CSR_OP_WR ];
wire    csr_op_set  = s3_csr_op[CSR_OP_SET];
wire    csr_op_clr  = s3_csr_op[CSR_OP_CLR];

assign  csr_en      = !csr_op_done && (
        csr_op_rd || csr_op_wr || csr_op_set || csr_op_clr
    );

assign  csr_wr      = csr_op_wr     ;
assign  csr_wr_set  = csr_op_set    ;
assign  csr_wr_clr  = csr_op_clr    ;
assign  csr_addr    = s3_csr_addr   ;
assign  csr_wdata   = s3_wdata      ;


//
// LSU Control
// ------------------------------------------------------------

wire [XL:0] lsu_wdata = 0;

//
// Control flow changes
// ------------------------------------------------------------

wire        cfu_wait  = 1'b0;

//
// Submodule instances.
// ------------------------------------------------------------




endmodule

