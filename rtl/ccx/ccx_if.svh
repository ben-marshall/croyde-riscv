
`ifndef CORE_MEM_BUS_SVH
`define CORE_MEM_BUS_SVH

//
// Core memory bus interface
interface core_mem_bus();

localparam  AW = 39;    // Address width
localparam  DW = 64;    // Data width

localparam  MEM_ADDR_R =  AW      - 1;
localparam  MEM_DATA_R =  DW      - 1;
localparam  MEM_STRB_R = (DW / 8) - 1;

logic                 req     ; // Memory request
logic                 rtype   ; // Request type: 0 = instruction, 1 = data.
logic [ MEM_ADDR_R:0] addr    ; // Memory request address
logic                 wen     ; // Memory request write enable
logic [ MEM_STRB_R:0] strb    ; // Memory request write strobe
logic [ MEM_DATA_R:0] wdata   ; // Memory write data.
logic                 gnt     ; // Memory response valid
logic                 err     ; // Memory response error
logic [ MEM_DATA_R:0] rdata   ; // Memory response read data

// Requestor
modport REQ (
output req     , // Memory request
output rtype   , // Request type
output addr    , // Memory request address
output wen     , // Memory request write enable
output strb    , // Memory request write strobe
output wdata   , // Memory write data.
input  gnt     , // Memory response valid
input  err     , // Memory response error
input  rdata     // Memory response read data
);

// Responder
modport RSP (
input  req     , // Memory request
input  rtype   , // Request type
input  addr    , // Memory request address
input  wen     , // Memory request write enable
input  strb    , // Memory request write strobe
input  wdata   , // Memory write data.
output gnt     , // Memory response valid
output err     , // Memory response error
output rdata     // Memory response read data
);

endinterface

`endif
