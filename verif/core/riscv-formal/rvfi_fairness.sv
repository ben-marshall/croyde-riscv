
//
// module: rvfi_fairness
//
//  Contains fairness assumptions for the core so that the RVFI
//  environment "plays fair".
//
module rvfi_fairness (

input  wire                 f_clk        , // Global clock
input  wire                 g_resetn     , // Global active low sync reset.

input  wire                 int_sw       , // software interrupt
input  wire                 int_ext      , // hardware interrupt
input  wire                 int_ti       , // timer    interrupt
              
input  wire                 imem_req     , // Memory request
input  wire [ MEM_ADDR_R:0] imem_addr    , // Memory request address
input  wire                 imem_wen     , // Memory request write enable
input  wire [ MEM_STRB_R:0] imem_strb    , // Memory request write strobe
input  wire [ MEM_DATA_R:0] imem_wdata   , // Memory write data.
input  wire                 imem_gnt     , // Memory response valid
input  wire                 imem_err     , // Memory response error
input  wire [ MEM_DATA_R:0] imem_rdata   , // Memory response read data

input  wire                 dmem_req     , // Memory request
input  wire [ MEM_ADDR_R:0] dmem_addr    , // Memory request address
input  wire                 dmem_wen     , // Memory request write enable
input  wire [ MEM_STRB_R:0] dmem_strb    , // Memory request write strobe
input  wire [ MEM_DATA_R:0] dmem_wdata   , // Memory write data.
input  wire                 dmem_gnt     , // Memory response valid
input  wire                 dmem_err     , // Memory response error
input  wire [ MEM_DATA_R:0] dmem_rdata   , // Memory response read data

`RVFI_INPUTS                             , // Formal checker interface.

input  wire                 wfi_sleep    , // Core is asleep due to WFI.

input  wire                 instr_ret    , // Instruction retired;

input  wire [         63:0] ctr_time     , // The time counter value.
input  wire [         63:0] ctr_cycle    , // The cycle counter value.
input  wire [         63:0] ctr_instret  , // The instret counter value.

input  wire                 inhibit_cy   , // Stop cycle counter.
input  wire                 inhibit_tm   , // Stop time counter.
input  wire                 inhibit_ir   , // Stop instret incrementing.

input  wire                 trs_valid    , // Instruction trace valid
input  wire [         31:0] trs_instr    , // Instruction trace data
input  wire [         XL:0] trs_pc         // Instruction trace PC

);

localparam  XLEN        = 64;       // Word width of the CPU
localparam  XL          = XLEN-1;   // For signals which are XLEN wide.
localparam  ILEN        = 32    ;
localparam  NRET        = 1     ;

parameter   MEM_ADDR_W  = 64;       // Memory address bus width
parameter   MEM_STRB_W  =  8;       // Memory strobe bits width
parameter   MEM_DATA_W  = 64;       // Memory data bits width

localparam  MEM_ADDR_R  = MEM_ADDR_W - 1; // Memory address bus width
localparam  MEM_STRB_R  = MEM_STRB_W - 1; // Memory strobe bits width
localparam  MEM_DATA_R  = MEM_DATA_W - 1; // Memory data bits width

//
// Assume that we start in reset.
initial assume(g_resetn == 1'b0);

//
// Assume no interrupts for now - TODO
always @(posedge f_clk) begin

    assume(!int_sw);
    
    assume(!int_ext);

    assume(!int_ti );

end

//
// Assume that if we make a request outside of the physical memory
// address space, this will always be answered with a memory bus error.
generate if(MEM_ADDR_W < XLEN) begin

    localparam UPPER_BITS_W = XLEN-MEM_ADDR_W;
    localparam UPPER_BITS_R = UPPER_BITS_W - 1;

    wire [UPPER_BITS_R:0] imem_upper_bits = imem_addr[XLEN:XLEN-UPPER_BITS_W];
    wire [UPPER_BITS_R:0] dmem_upper_bits = dmem_addr[XLEN:XLEN-UPPER_BITS_W];

    always @(posedge f_clk) begin
        if($past(imem_req) && $past(imem_gnt)) begin
            if(|$past(imem_upper_bits) == 0) begin
                assume(imem_err);
            end
        end
        if($past(dmem_req) && $past(dmem_gnt)) begin
            if(|$past(dmem_upper_bits) == 0) begin
                assume(dmem_err);
            end
        end
    end

end endgenerate


//
// Assume that we do not get memory bus errors  TODO
always @(posedge f_clk) begin

    if($past(imem_req) && $past(imem_gnt)) begin
        assume(!imem_err);
    end
    
    if($past(dmem_req) && $past(dmem_gnt)) begin
        assume(!dmem_err);
    end

end


`ifdef CORE_FAIRNESS

//
// Stop the memory busses stalling for more than 5 cycles in a row.
// ------------------------------------------------------------

reg [4:0] delay_imem;
reg [4:0] delay_dmem;

localparam MAX_DELAY_IMEM = 5;
localparam MAX_DELAY_DMEM = 5;

always @(posedge f_clk) begin
    if(!g_resetn) begin
        delay_imem <= 0;
    end else if(imem_req && imem_gnt) begin
        delay_imem <= 'b0;
    end else if(imem_req && !imem_gnt) begin
        delay_imem <= delay_imem + 1;
    end
    assume(delay_imem < MAX_DELAY_IMEM);
end

always @(posedge f_clk) begin
    if(!g_resetn) begin
        delay_dmem <= 0;
    end else if(dmem_req && dmem_gnt) begin
        delay_dmem <= 'b0;
    end else if(dmem_req && !dmem_gnt) begin
        delay_dmem <= delay_dmem + 1;
    end
    assume(delay_dmem < MAX_DELAY_DMEM);
end

//
// Assume we never stay asleep due to a WFI for more than N cycles
// in a row.
// ------------------------------------------------------------

parameter MAX_WFI_SLEEP_CYCLES = 10;

reg  [4:0]   wfi_sleep_counter;
wire [4:0] n_wfi_sleep_counter = wfi_sleep_counter + 5'd1;

always @(posedge f_clk) begin
    if(!wfi_sleep || !g_resetn) begin
        wfi_sleep_counter <= 5'b0;
    end else if(wfi_sleep) begin
        wfi_sleep_counter <= n_wfi_sleep_counter;
    end
end

always @(posedge f_clk) begin
    assume(wfi_sleep_counter < MAX_WFI_SLEEP_CYCLES);
end

`endif


//
// Assume that the counters behave sensibly
// ------------------------------------------------------------

always @(posedge f_clk) begin

    if($past(inhibit_cy)) assume(ctr_cycle  == ($past(ctr_cycle  )      ));
    else                  assume(ctr_cycle  == ($past(ctr_cycle  )+64'd1));

    if($past(inhibit_tm)) assume(ctr_time   == ($past(ctr_time   )      ));
    else                  assume(ctr_cycle  == ($past(ctr_cycle  )+64'd1));

    if($past(inhibit_ir)) begin
        assume(ctr_instret== ($past(ctr_instret)      ));
    end else if($past(instr_ret && !inhibit_ir)) begin
        assume(ctr_instret == ($past(ctr_instret + 64'd1)));
    end


    if($stable(inhibit_tm)) assume($stable(int_ti));

end

endmodule
