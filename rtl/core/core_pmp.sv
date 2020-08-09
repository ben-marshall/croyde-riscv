
//
// module: core_pmp
//
//  Physical memory protection registers.
//
module core_pmp #(
parameter ADDR_WIDTH = 32, // Width of the physical memory addresses.
parameter NUM_REGIONS=  8, // Number of protection regions to implement.
parameter EN_TOR     =  1  // Enable top of range matching mode?
)(

input  wire         g_clk           , // Gated clock
input  wire         g_clk_req       , // Gated clock request
input  wire         g_resetn        , // Synchronous active low reset

input  wire [AW: 0] instr_addr      , // Instruction Port address.
input  wire         instr_check     , // Instruction Port check enable.
output wire         instr_trap      , // Instruction Port trap access.

input  wire [AW: 0] data_addr       , // Data Port address.
input  wire         data_read       , // Data read if 1, write if 0.
input  wire         data_check      , // Data Port check enable.
output wire         data_trap       , // Data Port trap access.

input               csr_en          , // CSR Access Enable
input               csr_wr          , // CSR Write Enable
input               csr_wr_set      , // CSR Write - Set
input               csr_wr_clr      , // CSR Write - Clear
input       [11: 0] csr_addr        , // Address of the CSR to access.
input       [XL: 0] csr_wdata       , // Data to be written to a CSR
output wire [XL: 0] csr_rdata       , // CSR read data
output wire         csr_error         // Bad CSR access

);

// Base addresses for CSR registers.
localparam CSR_CFG_REGS_BASE  = 12'h3A0;
localparam CSR_ADDR_REGS_BASE = 12'h3AE;

// Signal widths
localparam AW       = ADDR_WIDTH - 1;
localparam NR       = NUM_REGIONS- 1;

localparam A_OFF    = 2'b00;
localparam A_TOR    = 2'b01;
localparam A_NA4    = 2'b10;
localparam A_NAPOT  = 2'b11;

assign g_clk_req = csr_en && csr_wr;

reg  [AW:0] addr_regs [63:0]; // Storage for the addresses
reg  [ 7:0] cfg_regs  [63:0]; // Storage for cfgs

                              // Control bits pulled from cfg_regs[i].
wire        cfg_l     [63:0]; // Lock bit
wire [ 1:0] cfg_a     [63:0]; // Address matching
wire        cfg_x     [63:0]; // Executable?
wire        cfg_w     [63:0]; // Writable?
wire        cfg_r     [63:0]; // Readable?

wire [63:0] match_d         ; // Does region I match on data  access?
wire [63:0] match_i         ; // Does region I match on instr access?
wire [63:0] trap_d          ; // Trap data  access
wire [63:0] trap_i          ; // Trap instr access

assign data_trap  = |trap_d && data_check ;
assign instr_trap = |trap_i && instr_check;

// Portion of CSR write data used in setting/clearing/writing reg values.
wire [AW:0] csr_wd_sel    =  csr_wdata[AW:0];
wire [AW:0] csr_wd_seln   = ~csr_wdata[AW:0];

//
// Matching function for the NaturallyAlignedPowerOfTwo range specificaiton.
function match_napot;
    input [AW:0] addr   ;
    input [AW:0] region ;
    match_napot = ((region & addr) == addr) && ((region | addr) == region);
endfunction

//
// Matching function for the TopOfRange specificaiton
function match_tor;
    input [AW:0] base;
    input [AW:0] top ;
    input [AW:0] addr;
    match_tor = (addr >= base) && (addr < top);
endfunction

//
// Matching function for a nautrally aligned 4-byte region.
function match_na4;
    input [AW:0] region ;
    input [AW:0] addr   ;
    match_na4 = region == addr;
endfunction

//
// Generate Address Registers
// ------------------------------------------------------------

genvar i;
generate for(i = 0; i < 64; i =i + 1) if(i < NUM_REGIONS) begin:


    wire tor_lock= i<63 ? cfg_a[i+1] == A_TOR && cfg_l[i+1] : 1'b0;

    wire csr_wen = csr_en && csr_wr && !cfg_l[i] && !tor_lock &&
                   csr_addr == (CSR_ADDR_REGS_BASE+i);

    wire [AW:0] csr_write_val =
        csr_wr_set ? addr_regs[i] |  csr_wd_sel  :
        csr_wr_clr ? addr_regs[i] &  csr_wd_seln :
                                     csr_wd_sel  ;

    always @(posedge g_clk) if(!g_resetn) begin
        addr_regs[i] <= {ADDR_WIDTH{1'b0}};
    end else if(csr_wen) begin
        addr_regs[i] <= csr_write_val;
    end

end else begin

    always @(*) addr_regs[i] = {ADDR_WIDTH{1'b0}};

end endgenerate

//
// Generate Config Registers
// ------------------------------------------------------------

genvar j;
generate for(j = 0; j < 64; j = j + 1) if(j < NUM_REGIONS) begin

    localparam REGI = j % 8;
    localparam CSRI = j / 8;

    wire csr_wen = csr_en && csr_wr && !cfg_l[j] &&
                   csr_addr == (CSR_ADDR_REGS_BASE+CSRI);

    wire [ 8:0] csr_write_val =
        csr_wr_set ? addr_regs[i] |  csr_wd_sel [8*REGI+:8] :
        csr_wr_clr ? addr_regs[i] &  csr_wd_seln[8*REGI+:8] :
                                     csr_wd_sel [8*REGI+:8] ;

    assign cfg_l[j] = cfg_regs[j][  7];
    assign cfg_a[j] = cfg_regs[j][4:3];
    assign cfg_x[j] = cfg_regs[j][  2];
    assign cfg_w[j] = cfg_regs[j][  1];
    assign cfg_r[j] = cfg_regs[j][  0];

    always @(posedge g_clk) if(!g_resetn) begin
        cfg_regs[i] <= 8'b0;
    end else if(csr_wen) begin
        cfg_regs[i] <= csr_write_val;
    end

    wire   mode_off     = cfg_a[j] == A_OFF  ;
    wire   mode_tor     = cfg_a[j] == A_TOR   && EN_TOR;
    wire   mode_na4     = cfg_a[j] == A_NA4  ;
    wire   mode_napot   = cfg_a[j] == A_NAPOT;

    wire [AW:0] tor_base = j == 0 ? {AW{1'b0}} : addr_regs[j-1];
    
    assign match_d[i] = 
        mode_tor    && match_tor    (tor_base, addr_regs[j], data_addr) ||
        mode_na4    && match_na4    (          addr_regs[j], data_addr) ||
        mode_napot  && match_napot  (          addr_regs[j], data_addr) ;
    
    assign match_i[i] = 
        mode_tor    && match_tor    (tor_base, addr_regs[j], instr_addr) ||
        mode_na4    && match_na4    (          addr_regs[j], instr_addr) ||
        mode_napot  && match_napot  (          addr_regs[j], instr_addr) ;

    assign trap_d[i] = match_d[i] && (
        ( data_read && !cfg_r[j]) ||
        (!data_read && !cfg_w[j])
    );

    assign trap_i[i] = match_i[i] && !cfg_x[i]; 

end else begin

    always @(*) cfg_regs[i] = 8'b0;
    assign cfg_l[j] = 1'b0;
    assign cfg_a[j] = 2'b0;
    assign cfg_x[j] = 1'b0;
    assign cfg_w[j] = 1'b0;
    assign cfg_r[j] = 1'b0;

    assign match_d[i] = 1'b0;
    assign match_i[i] = 1'b0;

end endgenerate

endmodule
