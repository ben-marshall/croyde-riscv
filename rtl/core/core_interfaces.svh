
`ifndef __CORE_INTERFACES_SVH__
`define __CORE_INTERFACES_SVH__

interface core_mem_if ();

parameter   MEM_ADDR_W  = 64;       // Memory address bus width
parameter   MEM_STRB_W  =  8;       // Memory strobe bits width
parameter   MEM_DATA_W  = 64;       // Memory data bits width

localparam  MEM_ADDR_R  = MEM_ADDR_W - 1; // Memory address bus width
localparam  MEM_STRB_R  = MEM_STRB_W - 1; // Memory strobe bits width
localparam  MEM_DATA_R  = MEM_DATA_W - 1; // Memory data bits width

wire                 req     ; // Memory request
wire [ MEM_ADDR_R:0] addr    ; // Memory request address
wire                 wen     ; // Memory request write enable
wire [ MEM_STRB_R:0] strb    ; // Memory request write strobe
wire [ MEM_DATA_R:0] wdata   ; // Memory write data.
wire                 gnt     ; // Memory response valid
wire                 err     ; // Memory response error
wire [ MEM_DATA_R:0] rdata   ; // Memory response read data

// Requestor
modport REQ (
    output req     ,
    output addr    ,
    output wen     ,
    output strb    ,
    output wdata   ,
    input  gnt     ,
    input  err     ,
    input  rdata    
);

// Responder
modport RSP (
    input  req     ,
    input  addr    ,
    input  wen     ,
    input  strb    ,
    input  wdata   ,
    output gnt     ,
    output err     ,
    output rdata    
);

endinterface

`endif
