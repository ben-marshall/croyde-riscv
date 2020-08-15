
//
// module: core_pmp
//
//  Physical memory protection registers.
//
module core_pmp #(
parameter ADDR_WIDTH = 56, // Width of the physical memory addresses.
parameter NUM_REGIONS=  8, // Number of protection regions to implement.
parameter EN_TOR     =  1  // Enable top of range matching mode?
)(

input  wire         f_clk           , // Free-running clock.
input  wire         g_clk           , // Gated clock for CSR regs.
output wire         g_clk_req       , // Gated clock request
input  wire         g_resetn        , // Synchronous active low reset

input  wire [AW: 0] imem_addr       , // Instruction Port address.
input  wire [ 1: 0] imem_prv        , // 10 = M-mode, 01 = U-mode
input  wire         imem_req        , // Instruction Port check enable.
output wire         imem_trap       , // Instruction Port trap access.
output reg          imem_error      , // Instruction port error response.

input  wire [AW: 0] dmem_addr       , // Data Port address.
input  wire [ 1: 0] dmem_prv        , // 01 = M-mode, 10 = U-mode
input  wire         dmem_wen        , // Data read if 0, write if 1.
input  wire         dmem_req        , // Data Port check enable.
output wire         dmem_trap       , // Data Port trap access.
output reg          dmem_error      , // Data port error response.

core_csrs_if.RSP    csr               // CSR interface

);

// Base addresses for CSR registers.
localparam CSR_CFG_REGS_BASE  = 12'h3A0;
localparam CSR_ADDR_REGS_BASE = 12'h3AE;

// Signal widths
localparam AW       = ADDR_WIDTH - 1;
localparam NR       = NUM_REGIONS- 1;

localparam [1:0] A_OFF    = 2'b00;
localparam [1:0] A_TOR    = 2'b01;
localparam [1:0] A_NA4    = 2'b10;
localparam [1:0] A_NAPOT  = 2'b11;

assign g_clk_req = (NUM_REGIONS > 0) && csr.en && csr.wr;

reg  [AW:0] addr_regs [63:0]; // Storage for the addresses
reg  [ 7:0] cfg_regs  [63:0]; // Storage for cfgs

                              // Control bits pulled from cfg_regs[i].
wire        cfg_l     [64:0]; // Lock bit
wire [ 1:0] cfg_a     [64:0]; // Address matching
wire        cfg_x     [63:0]; // Executable?
wire        cfg_w     [63:0]; // Writable?
wire        cfg_r     [63:0]; // Readable?

assign      cfg_l[64] = 1'b0;
assign      cfg_a[64] = 2'b0;

wire [63:0] match_d         ; // Does region I match on data  access?
wire [63:0] match_i         ; // Does region I match on instr access?
wire [63:0] trap_d          ; // Trap data  access
wire [63:0] trap_i          ; // Trap instr access

//
// CSR Read logic
// ------------------------------------------------------------

wire [63:0] cfg_csr_regs [15:0];

genvar k;
generate for(k = 0; k < 16; k = k + 2) begin

    assign cfg_csr_regs[k+0] = {
        cfg_regs[k+7],
        cfg_regs[k+6],
        cfg_regs[k+5],
        cfg_regs[k+4],
        cfg_regs[k+3],
        cfg_regs[k+2],
        cfg_regs[k+1],
        cfg_regs[k+0]
    };

    assign cfg_csr_regs[k+1] = 64'b0;

end endgenerate

wire access_cfg_reg = csr.addr[11:4] == 8'h3a && !csr.addr[0];
    
wire access_addr_reg=
    csr.addr[11:8] == 4'h3 && (
        csr.addr[7:4] == 4'hB   ||
        csr.addr[7:4] == 4'hC   ||
        csr.addr[7:4] == 4'hD   ||
        csr.addr[7:4] == 4'hE
    );

wire [63-ADDR_WIDTH:0] apad = {63-AW{1'b0}};

assign csr.rdata = access_cfg_reg  ? cfg_csr_regs[csr.addr[3:0]]    :
                   access_addr_reg ? {apad,addr_regs[csr.addr[5:0]]}:
                                     64'b0                          ;

assign csr.error = !access_cfg_reg || !access_addr_reg;

//
// Trap raising
// ------------------------------------------------------------

assign dmem_trap  = |trap_d && dmem_req ;
assign imem_trap  = |trap_i && imem_req;

wire        imem_mmode = imem_prv[1];
wire        dmem_mmode = dmem_prv[1];
wire        imem_umode = imem_prv[0];
wire        dmem_umode = dmem_prv[0];

always @(posedge f_clk) if(!g_resetn) begin
    imem_error <= 1'b0;
    dmem_error <= 1'b0;
end else begin
    imem_error <= imem_trap;
    dmem_error <= dmem_trap;
end

// Portion of CSR write data used in setting/clearing/writing reg values.
wire [63:0] csr_wd_sel    =  csr.wdata[63:0];
wire [63:0] csr_wd_seln   = ~csr.wdata[63:0];

//
// Address Matching functions.
// ------------------------------------------------------------

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
generate for(i = 0; i < 64; i =i + 1) if(i < NUM_REGIONS) begin : gen_region_a

    // If cfg[i+1] is in TOR mode and locked, then don't allow
    // writes to this register.
    wire tor_lock= (cfg_a[i+1] == A_TOR) && cfg_l[i+1];

    wire csr_wen = csr.en && csr.wr && !cfg_l[i] && !tor_lock &&
                   csr.addr == (CSR_ADDR_REGS_BASE+i);

    wire [AW:0] csr_write_val =
        csr.wr_set ? addr_regs[i] |  csr_wd_sel [AW:0] :
        csr.wr_clr ? addr_regs[i] &  csr_wd_seln[AW:0] :
                                     csr_wd_sel [AW:0] ;

    always @(posedge g_clk) if(!g_resetn) begin
        addr_regs[i] <= {ADDR_WIDTH{1'b0}};
    end else if(csr_wen) begin
        addr_regs[i] <= csr_write_val;
    end

end else begin: no_region_a

    always @(*) addr_regs[i] = {ADDR_WIDTH{1'b0}};

end endgenerate

//
// Generate Config Registers
// ------------------------------------------------------------

genvar j;
generate for(j = 0; j < 64; j = j + 1) if(j < NUM_REGIONS) begin:gen_region_c

    localparam REGI = j % 8;
    localparam CSRI = (j / 4) & -2;

    wire csr_wen = csr.en && csr.wr && !cfg_l[j] &&
                   csr.addr == (CSR_ADDR_REGS_BASE+CSRI);

    wire [ 7:0] csr_write_val =
        csr.wr_set ? cfg_regs[j] |  csr_wd_sel [8*REGI+:8] :
        csr.wr_clr ? cfg_regs[j] &  csr_wd_seln[8*REGI+:8] :
                                    csr_wd_sel [8*REGI+:8] ;

    assign cfg_l[j] = cfg_regs[j][  7];
    assign cfg_a[j] = cfg_regs[j][4:3];
    assign cfg_x[j] = cfg_regs[j][  2];
    assign cfg_w[j] = cfg_regs[j][  1];
    assign cfg_r[j] = cfg_regs[j][  0];

    always @(posedge g_clk) if(!g_resetn) begin
        cfg_regs[j] <= 8'b0;
    end else if(csr_wen) begin
        cfg_regs[j] <= csr_write_val;
    end

    // What mode is this pmp region currently in?
    wire   mode_off     = cfg_a[j] == A_OFF  ;
    wire   mode_tor     = cfg_a[j] == A_TOR   && EN_TOR;
    wire   mode_na4     = cfg_a[j] == A_NA4  ;
    wire   mode_napot   = cfg_a[j] == A_NAPOT;

    wire [AW:0] tor_base = j == 0 ? {ADDR_WIDTH{1'b0}} : addr_regs[j-1];
    
    // Does this region match the data access address?
    assign match_d[j] = 
        mode_tor    && match_tor    (tor_base, addr_regs[j], dmem_addr) ||
        mode_na4    && match_na4    (          addr_regs[j], dmem_addr) ||
        mode_napot  && match_napot  (          addr_regs[j], dmem_addr) ;
    
    // Does this region match the instruction access address?
    assign match_i[j] = 
        mode_tor    && match_tor    (tor_base, addr_regs[j], imem_addr) ||
        mode_na4    && match_na4    (          addr_regs[j], imem_addr) ||
        mode_napot  && match_napot  (          addr_regs[j], imem_addr) ;

    // Should this region cause a data access trap?
    assign trap_d[j] = match_d[j] && (dmem_mmode && cfg_l[j]) && (
        (!dmem_wen  && !cfg_r[j]) ||
        ( dmem_wen  && !cfg_w[j])
    );

    // Should this region cause an instruction access trap?
    assign trap_i[j] = match_i[j] && !cfg_x[j] && (imem_mmode && cfg_l[j]); 

end else begin : no_region_c

    // Assign everything to 0.

    always @(*) cfg_regs[j] = 8'b0;
    assign cfg_l[j] = 1'b0;
    assign cfg_a[j] = 2'b0;
    assign cfg_x[j] = 1'b0;
    assign cfg_w[j] = 1'b0;
    assign cfg_r[j] = 1'b0;

    assign match_d[j] = 1'b0;
    assign match_i[j] = 1'b0;
    assign trap_i[j]  = 1'b0;
    assign trap_d[j]  = 1'b0;

end endgenerate

endmodule
