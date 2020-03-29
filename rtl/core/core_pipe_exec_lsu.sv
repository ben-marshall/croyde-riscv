
//
// Module: core_pipe_exec_lsu
//
//  Responsible for all data memory accesses
//
module core_pipe_exec_lsu (

input   wire                g_clk       , // Global clock enable.
input   wire                g_resetn    , // Global synchronous reset

input   wire                valid       , // Inputs are valid
input   wire [        XL:0] addr        , // Address of the access.
input   wire [        XL:0] wdata       , // Data being written (if any)
input   wire                load        , //
input   wire                store       , //
input   wire                d_double    , //
input   wire                d_word      , //
input   wire                d_half      , //
input   wire                d_byte      , //
input   wire                sext        , // Sign extend read data

output  reg                 ready       , // Read data ready
output  wire                trap_bus    , // Bus error
output  wire                trap_addr   , // Address alignment error
output  wire [        XL:0] rdata       , // Read data

output wire                 dmem_req    , // Memory request
output wire [ MEM_ADDR_R:0] dmem_addr   , // Memory request address
output wire                 dmem_wen    , // Memory request write enable
output wire [ MEM_STRB_R:0] dmem_strb   , // Memory request write strobe
output wire [ MEM_DATA_R:0] dmem_wdata  , // Memory write data.
input  wire                 dmem_gnt    , // Memory response valid
input  wire                 dmem_err    , // Memory response error
input  wire [ MEM_DATA_R:0] dmem_rdata    // Memory response read data

);

// Common parameters and width definitions.
`include "core_common.svh"

always @(posedge g_clk) begin
    if(!g_resetn) begin
        ready <= 1'b0;
    end else begin
        ready <= (req_sent || addr_err) && !ready;
    end
end

wire req_sent = dmem_req && dmem_gnt;

//
// Transaction validity

wire    addr_err =
    d_double    &&  |addr[2:0]      ||
    d_word      &&  |addr[1:0]      ||
    d_half      &&   addr[  0]      ;

wire    txn_okay = !addr_err        ;

//
// Write data positioning.

wire [ 5:0] data_shift     = {addr[2:0], 3'b000};

//
// Read data positioning.

wire [XL:0] rdata_shifted  = dmem_rdata >> data_shift;

wire [XL:0] mask_ls_byte   = {56'h0,  8'hF};
wire [XL:0] mask_ls_half   = {48'h0, 16'hFFFF};
wire [XL:0] mask_ls_word   = {32'h0, 32'hFFFFFFFF};

wire [XL:0] sext_byte      = {{56{sext && rdata_shifted[ 7]}},  8'b0};
wire [XL:0] sext_half      = {{48{sext && rdata_shifted[15]}}, 16'b0};
wire [XL:0] sext_word      = {{32{sext && rdata_shifted[31]}}, 32'b0};

wire [XL:0] rdata_byte     = (rdata_shifted & mask_ls_byte) | sext_byte;
wire [XL:0] rdata_half     = (rdata_shifted & mask_ls_half) | sext_half;
wire [XL:0] rdata_word     = (rdata_shifted & mask_ls_word) | sext_word;

assign      rdata          =
    d_byte      ? rdata_byte    :
    d_half      ? rdata_half    :
    d_word      ? rdata_word    :
                  dmem_rdata ;


//
// Simple bus assignments.

assign  trap_bus     = dmem_err && ready;

assign  trap_addr    = addr_err && ready;

assign  dmem_wen     = store;

assign  dmem_req     = valid && txn_okay && !ready;

assign  dmem_addr    = {addr[XL:3], 3'b000};

assign  dmem_wdata   = wdata    << data_shift           ;

assign  dmem_strb    = valid     ? strb : 8'b0          ;

wire    [7:0] strb   ;

assign  strb[7]      = d_double                         ||
                       d_word   &&  addr[  2]           ||
                       d_half   &&  addr[2:1] == 2'd3   ||
                       d_byte   &&  addr[2:0] == 3'd7   ;

assign  strb[6]      = d_double                         ||
                       d_word   &&  addr[  2]           ||
                       d_half   &&  addr[2:1] == 2'd3   ||
                       d_byte   &&  addr[2:0] == 3'd6   ;

assign  strb[5]      = d_double                         ||
                       d_word   &&  addr[  2]           ||
                       d_half   &&  addr[2:1] == 2'd2   ||
                       d_byte   &&  addr[2:0] == 3'd5   ;

assign  strb[4]      = d_double                         ||
                       d_word   &&  addr[  2]           ||
                       d_half   &&  addr[2:1] == 2'd2   ||
                       d_byte   &&  addr[2:0] == 3'd4   ;

assign  strb[3]      = d_double                         ||
                       d_word   && !addr[  2]           ||
                       d_half   &&  addr[2:1] == 2'd1   ||
                       d_byte   &&  addr[2:0] == 3'd3   ;

assign  strb[2]      = d_double                         ||
                       d_word   && !addr[  2]           ||
                       d_half   &&  addr[2:1] == 2'd1   ||
                       d_byte   &&  addr[2:0] == 3'd2   ;

assign  strb[1]      = d_double                         ||
                       d_word   && !addr[  2]           ||
                       d_half   &&  addr[2:1] == 2'd0   ||
                       d_byte   &&  addr[2:0] == 3'd1   ;

assign  strb[0]      = d_double                         ||
                       d_word   && !addr[  2]           ||
                       d_half   &&  addr[2:1] == 2'd0   ||
                       d_byte   &&  addr[2:0] == 3'd0   ;

endmodule

