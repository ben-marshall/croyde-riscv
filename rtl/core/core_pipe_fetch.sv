
//
// Module: core_pipe_fetch
//
//  Pipeline fetch stage.
//
module core_pipe_fetch (

input  wire                 g_clk       , // Global clock
input  wire                 g_resetn    , // Global active low sync reset.

input  wire                 cf_valid    , // Control flow change?
output wire                 cf_ack      , // Control flow change acknwoledged
input  wire [         XL:0] cf_target   , // Control flow change destination
input  wire [ CF_CAUSE_R:0] cf_cause    , // Control flow change cause

output wire                 imem_req    , // Memory request
output reg  [ MEM_ADDR_R:0] imem_addr   , // Memory request address
output wire                 imem_wen    , // Memory request write enable
output wire [ MEM_STRB_R:0] imem_strb   , // Memory request write strobe
output wire [ MEM_DATA_R:0] imem_wdata  , // Memory write data.
input  wire                 imem_gnt    , // Memory response valid
input  wire                 imem_err    , // Memory response error
input  wire [ MEM_DATA_R:0] imem_rdata  , // Memory response read data

output wire                 s1_i16bit   , // 16 bit instruction?
output wire                 s1_i32bit   , // 32 bit instruction?
output wire [  FD_IBUF_R:0] s1_instr    , // Instruction to be decoded
output reg  [         XL:0] s1_pc       , // Program Counter
output wire [         XL:0] s1_npc      , // Next Program Counter
output wire [   FD_ERR_R:0] s1_ferr     , // Fetch bus error?
input  wire                 s1_eat_2    , // Decode eats 2 bytes
input  wire                 s1_eat_4      // Decode eats 4 bytes

);


// Common parameters and width definitions.
`include "core_common.svh"

// Inital address of the program counter post reset.
parameter   PC_RESET_ADDRESS      = 64'h10000000;

//
// Constant assignments.
// ------------------------------------------------------------

assign imem_wen     = 1'b0;
assign imem_strb    = {MEM_STRB_W{1'b0}};
assign imem_wdata   = {MEM_DATA_W{1'b0}};

//
// Event tracking
// ------------------------------------------------------------

wire e_cf_change    = cf_valid && cf_ack;

wire e_imem_req     = imem_req && imem_gnt;
wire e_imem_recv    = imem_recv;

wire e_eat_2        = s1_eat_2;
wire e_eat_4        = s1_eat_4;

//
// Control flow change bus
// ------------------------------------------------------------

assign  cf_ack      = imem_req && imem_gnt || !imem_req;

//
// Instruction fetch address tracking.
// ------------------------------------------------------------

// Are we recieving a memory response this cycle?
reg                 imem_recv  ;

reg                 imem_req_r ;
assign              imem_req   = imem_req_r;

// Next instruction memory fetch request enable.
wire                n_imem_req  = buf_ready || (imem_req && !imem_gnt);

// Next instruction fetch address
wire [MEM_ADDR_R:0] n_imem_addr = imem_addr + 8;

always @(posedge g_clk) begin
    if(!g_resetn) begin
        imem_req_r  <= 1'b0;
        imem_recv   <= 1'b0;
        imem_addr   <= PC_RESET_ADDRESS;
    end else begin
        imem_req_r  <= n_imem_req;
        imem_recv   <= imem_req && imem_gnt;
        if(e_cf_change) begin
            imem_addr <= cf_target & ~64'h7;
        end else if(e_imem_req) begin
            imem_addr <= n_imem_addr;
        end
    end
end

//
// Program Counter Tracking
// ------------------------------------------------------------

wire [XL:0] n_s1_pc = s1_pc + {61'b0, s1_i32bit, s1_i16bit, 1'b0};

assign      s1_npc  = n_s1_pc;

always @(posedge g_clk) begin
    if(!g_resetn) begin
        s1_pc <= PC_RESET_ADDRESS;
    end else if(e_cf_change) begin
        s1_pc <= cf_target;
    end else if(e_eat_2 || e_eat_4) begin
        s1_pc <= n_s1_pc;
    end
end

//
// When to ignore pending responses.
// ------------------------------------------------------------

reg  [1:0]   rsps_ignore        ;
reg  [1:0]   reqs_outstanding   ;

wire [1:0] n_reqs_outstanding   = reqs_outstanding + e_imem_req - e_imem_recv;

wire         ignore_rsp         = |rsps_ignore;

always @(posedge g_clk) begin
    if(!g_resetn) begin
        
        reqs_outstanding    <= 2'b00;
        rsps_ignore         <= 2'b00;

    end else begin

        reqs_outstanding    <= n_reqs_outstanding;

        if(|rsps_ignore) begin
            
            rsps_ignore <= rsps_ignore - 1;

        end else if(e_cf_change) begin
            
            rsps_ignore <= n_reqs_outstanding;

        end
    end
end

//
// Buffer interfacing
// ------------------------------------------------------------

// When to flush the instruction fetch buffer?
wire        buf_flush       = e_cf_change   ;

wire [ 4:0]   buf_depth     ; // How many bytes are in the buffer?
wire [ 4:0] n_buf_depth     ; //

wire [63:0] buf_data_in     = imem_rdata    ;
wire        buf_error_in    = imem_err      ;

wire        buf_fill_en     = imem_recv && !ignore_rsp;

reg         buf_fill_2      ; // Load top 2 bytes of input data.
reg         buf_fill_4      ; // Load top 4 bytes of input data.
reg         buf_fill_6      ; // Load top 6 bytes of input data.
reg         buf_fill_8      ; // Load top 8 bytes of input data.

wire [31:0] buf_data_out    ; // Data out of the buffer.
wire [ 1:0] buf_error_out   ; // Is data tagged with fetch error?

wire        buf_drain_2     = s1_i16bit && s1_eat_2;
wire        buf_drain_4     = s1_i32bit && s1_eat_4;

// Is the buffer ready to accept more data?
wire        buf_ready       = n_buf_depth  <= 8 && !e_imem_req;

// Is there currently a 16 or 32 bit instruction in the buffer?
assign      s1_i16bit       = buf_depth >= 2 && buf_data_out[1:0] != 2'b11;
assign      s1_i32bit       = buf_depth >= 4 && buf_data_out[1:0] == 2'b11;

// Can we present a valid instruction to the decode stage?
assign      s1_instr        = buf_data_out[31:0];
assign      s1_ferr         = buf_error_out[1:0];

reg         first_req_post_cf; // First request after a CF change.
wire      n_first_req_post_cf =
    first_req_post_cf ? !e_imem_req :
                         e_cf_change;

always @(posedge g_clk) begin
    if(!g_resetn) begin
        first_req_post_cf <= 1'b0;
    end else begin
        first_req_post_cf <= n_first_req_post_cf;
    end
end

always @(posedge g_clk) begin
    if(!g_resetn) begin
        buf_fill_2 <= 1'b0;
        buf_fill_4 <= 1'b0;
        buf_fill_6 <= 1'b0;
        buf_fill_8 <= 1'b0;
    end else if(e_cf_change) begin
        buf_fill_2 <= cf_target[2:0] == 3'd6;
        buf_fill_4 <= cf_target[2:0] == 3'd4;
        buf_fill_6 <= cf_target[2:0] == 3'd2;
        buf_fill_8 <= cf_target[2:0] == 3'd0;
    end else if(ignore_rsp || first_req_post_cf) begin
        // Do nothing
    end else if(e_imem_req) begin
        buf_fill_2 <= 1'b0;
        buf_fill_4 <= 1'b0;
        buf_fill_6 <= 1'b0;
        buf_fill_8 <= 1'b1;
    end else begin
        buf_fill_2 <= 1'b0;
        buf_fill_4 <= 1'b0;
        buf_fill_6 <= 1'b0;
        buf_fill_8 <= 1'b0;
    end
end


//
// Submodule instances
// ------------------------------------------------------------

core_pipe_fetch_buffer i_core_pipe_fetch_buffer (
.g_clk       (g_clk           ), // Global clock
.g_resetn    (g_resetn        ), // Global active low sync reset.
.flush       (buf_flush       ), // Flush data from the buffer.
.depth       (buf_depth       ), // How many bytes are in the buffer?
.n_depth     (n_buf_depth     ), //
.data_in     (buf_data_in     ), // Data in
.error_in    (buf_error_in    ), // Tag with error?
.fill_en     (buf_fill_en     ), // Buffer fill enable.
.fill_2      (buf_fill_2      ), // Load top 2 bytes of input data.
.fill_4      (buf_fill_4      ), // Load top 4 bytes of input data.
.fill_6      (buf_fill_6      ), // Load top 6 bytes of input data.
.fill_8      (buf_fill_8      ), // Load top 8 bytes of input data.
.data_out    (buf_data_out    ), // Data out of the buffer.
.error_out   (buf_error_out   ), // Is data tagged with fetch error?
.drain_2     (buf_drain_2     ), // Drain 2 bytes of data.
.drain_4     (buf_drain_4     )  // Drain 4 bytes of data.
);

endmodule

