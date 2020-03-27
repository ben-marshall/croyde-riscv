
`include "core_interfaces.svh"

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

core_mem_if.REQ             if_imem     , // Instruction memory bus.
core_pipe_fd.FETCH          s1            // Fetch -> decode interface.

);


// Common parameters and width definitions.
`include "core_common.svh"

// Inital address of the program counter post reset.
parameter   PC_RESET_ADDRESS      = 64'h80000000;

//
// Constant assignments.
// ------------------------------------------------------------

assign if_imem.wen     = 1'b0;
assign if_imem.strb    = {MEM_STRB_W{1'b0}};
assign if_imem.wdata   = {MEM_DATA_W{1'b0}};

//
// Event tracking
// ------------------------------------------------------------

wire e_cf_change    = cf_valid && cf_ack;

wire e_imem_req     = if_imem.req && if_imem.gnt;
wire e_imem_recv    = imem_recv;

wire e_eat_2        = s1.eat_2;
wire e_eat_4        = s1.eat_4;

//
// Control flow change bus
// ------------------------------------------------------------

assign  cf_ack      = if_imem.req && if_imem.gnt || !if_imem.req;

//
// Instruction fetch address tracking.
// ------------------------------------------------------------

// Are we recieving a memory response this cycle?
reg                 imem_recv  ;

reg                 imem_req_r ;
assign              if_imem.req   = imem_req_r;

// Next instruction memory fetch request enable.
wire                n_imem_req  = buf_ready;

// Next instruction fetch address
wire [MEM_ADDR_R:0] n_imem_addr = if_imem.addr + 8;

always @(posedge g_clk) begin
    if(!g_resetn) begin
        imem_req_r  <= 1'b0;
        imem_recv   <= 1'b0;
        if_imem.addr   <= PC_RESET_ADDRESS;
    end else begin
        imem_req_r  <= n_imem_req;
        imem_recv   <= if_imem.req && if_imem.gnt;
        if(e_cf_change) begin
            if_imem.addr <= cf_target;
        end else if(e_imem_req) begin
            if_imem.addr <= n_imem_addr;
        end
    end
end

//
// Program Counter Tracking
// ------------------------------------------------------------

wire [XL:0] n_s1_pc = s1.pc + {61'b0, s1.i32bit, s1.i16bit, 1'b0};

assign      s1.npc  = n_s1_pc;

always @(posedge g_clk) begin
    if(!g_resetn) begin
        s1.pc <= PC_RESET_ADDRESS;
    end else if(e_cf_change) begin
        s1.pc <= cf_target;
    end else if(e_eat_2 || e_eat_4) begin
        s1.pc <= n_s1_pc;
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

wire [63:0] buf_data_in     = if_imem.rdata    ;
wire        buf_error_in    = if_imem.err      ;

wire        buf_fill_en     = imem_recv && !ignore_rsp;

reg         buf_fill_2      ; // Load top 2 bytes of input data.
reg         buf_fill_4      ; // Load top 4 bytes of input data.
reg         buf_fill_6      ; // Load top 6 bytes of input data.
reg         buf_fill_8      ; // Load top 8 bytes of input data.

wire [31:0] buf_data_out    ; // Data out of the buffer.
wire [ 1:0] buf_error_out   ; // Is data tagged with fetch error?

wire        buf_drain_2     = s1.i16bit && s1.eat_2;
wire        buf_drain_4     = s1.i32bit && s1.eat_4;

// Is the buffer ready to accept more data?
wire        buf_ready       = n_buf_depth  <= 4;

// Is there currently a 16 or 32 bit instruction in the buffer?
assign      s1.i16bit       = buf_depth >= 2 && buf_data_out[1:0] != 2'b11;
assign      s1.i32bit       = buf_depth >= 4 && buf_data_out[1:0] == 2'b11;

// Can we present a valid instruction to the decode stage?
assign      s1.instr        = buf_data_out[31:0];
assign      s1.ferr         = buf_error_out[1:0];


always @(posedge g_clk) begin
    if(!g_resetn) begin
        buf_fill_2 <= 1'b0;
        buf_fill_4 <= 1'b0;
        buf_fill_6 <= 1'b0;
        buf_fill_8 <= 1'b0;
    end else if(e_cf_change) begin
        buf_fill_2 <= cf_target[3:0] == 4'd6;
        buf_fill_4 <= cf_target[3:0] == 4'd4;
        buf_fill_6 <= cf_target[3:0] == 4'd2;
        buf_fill_8 <= cf_target[3:0] == 4'd0;
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

