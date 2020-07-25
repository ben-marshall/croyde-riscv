
//
// module: bridge_ccx_axi4_lite
//
//  A module for bridging the Core Complex (CCX) external memory
//  interface into an AXI4 Lite implementation.
//
module bridge_ccx_axi4_lite (

input  wire            axi_aclk    , // AXI Clock
input  wire            axi_aresetn , // AXI Reset

output wire            axi_awvalid , //
input  wire            axi_awready , //
output wire [  AW-1:0] axi_awaddr  , //
output wire [     2:0] axi_awprot  , //

output wire            axi_wvalid  , //
input  wire            axi_wready  , //
output wire [  DW-1:0] axi_wdata   , //
output wire [     7:0] axi_wstrb   , //

output wire            axi_arvalid , //
input  wire            axi_arready , //
output wire [  AW-1:0] axi_araddr  , //
output wire [     2:0] axi_arprot  , //

input  wire            axi_bvalid  , //
output wire            axi_bready  , //
input  wire [     1:0] axi_bresp   , //

input  wire            axi_rvalid  , //
output wire            axi_rready  , //
input  wire [  DW-1:0] axi_rdata   , //
input  wire [     1:0] axi_rresp   , //

input  wire            ccx_req     , // Memory request
input  wire            ccx_rtype   , // Request type: 0=instr,1=data.
input  wire [  AW-1:0] ccx_addr    , // Memory request address
input  wire            ccx_wen     , // Memory request write enable
input  wire [     7:0] ccx_strb    , // Memory request write strobe
input  wire [  DW-1:0] ccx_wdata   , // Memory write data.
output wire            ccx_gnt     , // Memory response valid
output reg             ccx_err     , // Memory response error
output reg  [  DW-1:0] ccx_rdata     // Memory response read data

);

parameter   AW = 39;    // Address width
parameter   DW = 64;    // Data width

//
// Constant signal assignments:
// ------------------------------------------------------------

assign axi_rready = 1'b1;
assign axi_bready = 1'b1;

//                   Unprivilidged, Un-secured, Instruciton / Data
assign axi_arprot = {1'b0         , 1'b0      , !ccx_rtype};
assign axi_awprot = {1'b0         , 1'b0      , !ccx_rtype};

assign axi_awaddr = ccx_addr;
assign axi_araddr = ccx_addr;

assign axi_wdata  = ccx_wdata;
assign axi_wstrb  = ccx_strb ;

//
// Request / Response tracking.
// ------------------------------------------------------------

// New request this cycle?
wire    req_rd     = axi_arvalid && axi_arready;
wire    req_wa     = axi_awvalid && axi_awready;
wire    req_wr     = axi_wvalid  && axi_wready;

// New response this cycle?
wire    rsp_rd     = axi_rvalid  && axi_rready;
wire    rsp_wr     = axi_bvalid  && axi_bready;

reg     req_rd_out ;
reg     req_wa_out ;
reg     req_wr_out ;
wire  n_req_rd_out = req_rd_out ? !rsp_rd || req_rd : req_rd;
wire  n_req_wa_out = req_wa_out ? !rsp_wr || req_wa : req_wa;
wire  n_req_wr_out = req_wr_out ? !rsp_wr || req_wr : req_wr;

// Request channel valids
assign  axi_arvalid = !req_rd_out && ccx_req && !ccx_wen;
assign  axi_awvalid = !req_wa_out && ccx_req &&  ccx_wen;
assign  axi_wvalid  = !req_wr_out && ccx_req &&  ccx_wen;

// CCX Response signals
wire [DW:0] n_ccx_rdata = axi_rdata;
wire        n_ccx_err   = rsp_rd ? |axi_rresp : | axi_bresp;
assign        ccx_gnt   = rsp_rd || rsp_wr;

always @(posedge axi_aclk) begin
    if(!axi_aresetn) begin
        ccx_rdata <= {DW{1'b0}} ;
        ccx_err   <= 1'b0       ;
    end else if(ccx_gnt) begin
        ccx_rdata <= n_ccx_rdata ;
        ccx_err   <= n_ccx_err   ;
    end
end

always @(posedge axi_aclk) begin
    if(!axi_aresetn) begin
        req_rd_out <= 1'b0;
        req_wa_out <= 1'b0;
        req_wr_out <= 1'b0;
    end else begin
        req_rd_out <= n_req_rd_out;
        req_wa_out <= n_req_wa_out;
        req_wr_out <= n_req_wr_out;
    end
end

endmodule

