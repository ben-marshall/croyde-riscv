
//
// interface: core_csrs_if
//
//  Simple interface to the CSR module.
//  Always gives a response in the same cycle.
//
interface core_csrs_if ();

parameter   XLEN = 64;
localparam  XL   = XLEN-1;

logic        en      ; // CSR Access Enable
logic        wr      ; // CSR Write Enable
logic        wr_set  ; // CSR Write - Set
logic        wr_clr  ; // CSR Write - Clear
logic [11:0] addr    ; // Address of the CSR to access.
logic [XL:0] wdata   ; // Data to be written to a CSR
logic [XL:0] rdata   ; // CSR read data
logic        error   ; // Bad CSR access

modport REQ (
output en      , // CSR Access Enable
output wr      , // CSR Write Enable
output wr_set  , // CSR Write - Set
output wr_clr  , // CSR Write - Clear
output addr    , // Address of the CSR to access.
output wdata   , // Data to be written to a CSR
input  rdata   , // CSR read data
input  error     // Bad CSR access
);

modport RSP (
input  en      , // CSR Access Enable
input  wr      , // CSR Write Enable
input  wr_set  , // CSR Write - Set
input  wr_clr  , // CSR Write - Clear
input  addr    , // Address of the CSR to access.
input  wdata   , // Data to be written to a CSR
output rdata   , // CSR read data
output error     // Bad CSR access
);

endinterface
