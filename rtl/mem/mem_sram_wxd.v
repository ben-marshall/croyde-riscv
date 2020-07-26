
//
// module: mem_sram_wxd
//
//  A simple simulation memory model
//  - W bit wide word
//  - D words deep
//  - W/8 per-byte write strobes based
//  - Configurable pre-loaded memory file.
//  - Optional ROM switch.
//
module mem_sram_wxd  #(
parameter           WIDTH =  64,  // Width of each memory word.
parameter           ROM   =   0,  // Is this a read only memory?
parameter           DEPTH =1024,  // Number of 64-bit wordsin the memory.
/* verilator lint_off WIDTH */
parameter [255*8:0] MEMH  = ""    // Memory file to read.
/* verilator lint_on  WIDTH */
)(
input  wire         g_clk       ,
input  wire         g_resetn    ,
input  wire         cen         ,
input  wire [BLW:0] wstrb       ,
input  wire [WAW:0] addr        ,
input  wire [DW :0] wdata       ,
output reg  [DW :0] rdata       ,
output reg          err
);

localparam BYTE_LANES   = WIDTH / 8;
localparam SIZE_BYTES   = BYTE_LANES * DEPTH;
localparam WORD_ADDR_W  = $clog2(DEPTH);
localparam BYTE_ADDR_W  = WORD_ADDR_W + $clog2(BYTE_LANES);

localparam DW           = WIDTH       - 1   ;
localparam BLW          = BYTE_LANES  - 1   ;
localparam WAW          = WORD_ADDR_W - 1   ;
localparam BAW          = BYTE_ADDR_W - 1   ;

// Byte array of memory.
reg [7:0] mem [SIZE_BYTES-1:0];

// Byte aligned address.
wire [BAW:0] addrin = {addr, {$clog2(BYTE_LANES){1'b0}}};

initial begin
    //$display("Memory Width: %d Bits / %d Bytes" , WIDTH, BYTE_LANES);
    //$display("Memory Depth: %d Words", DEPTH);
    //$display("Memory Size : %d Bytes", SIZE_BYTES);
    //$display("Word addr w : %d Bits", WORD_ADDR_W);
    //$display("Byte addr w : %d Bits", BYTE_ADDR_W);
    if(MEMH != "") begin
        $display("Loading file: %s",MEMH);
        $readmemh(MEMH, mem);
    end
end

generate if(ROM == 0) begin
    always @(*) err = 1'b0;
end else begin
    always @(posedge g_clk) begin
        if(!g_resetn) begin
            err <= 1'b0;
        end else begin
            err <= |wstrb;
        end
    end
end endgenerate

genvar i;

generate for (i = 0; i < BYTE_LANES; i = i + 1) begin

    wire [BAW:0] idx = i;

    //
    // Reads
    always @(posedge g_clk) begin
        if(cen) begin
            rdata[8*i+:8] <= mem[addrin | idx];
        end
    end

    //
    // Writes
    if(ROM == 0) begin
    
        always @(posedge g_clk) begin
            if(cen && wstrb[i]) begin
                mem[addrin | idx] <= wdata[8*i+:8];
            end
        end

    end

end endgenerate

endmodule


