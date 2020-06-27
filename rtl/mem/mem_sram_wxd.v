
//
// module: mem_sram_n64
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
parameter           DEPTH =1024   // Number of 64-bit wordsin the memory.
)(
input  wire         g_clk       ,
input  wire         g_resetn    ,
input  wire         cen         ,
input  wire [S:0]   wstrb       ,
input  wire [A:0]   addr        ,
input  wire [W:0]   wdata       ,
output reg  [W:0]   rdata        
);

/* verilator lint_off WIDTH */
parameter [255*8:0] MEMH  = "";   // Memory file to read.
/* verilator lint_on  WIDTH */

localparam W      = WIDTH-1;
localparam D      = DEPTH-1;
localparam S      = WIDTH/8-1;
localparam B      = (WIDTH/8 * DEPTH)-1;
localparam A      = $clog2(DEPTH)-1; 

// Byte array of memory.
reg [7:0] mem [B:0];

initial begin
    if(MEMH != "") begin
        $display("Loading file: %s",MEMH);
        $readmemh(MEMH, mem);
    end
end

genvar i;

generate for (i = 0; i < WIDTH / 8; i = i + 1) begin

    //
    // Reads
    always @(posedge g_clk) begin
        if(cen) begin
            rdata[8*i+:8] <= mem[addr | i];
        end
    end

    //
    // Writes
    if(ROM == 0) begin
    
        always @(posedge g_clk) begin
            if(cen && wstrb[i]) begin
                mem[addr | i] <= wdata[8*i+:8];
            end
        end

    end

end endgenerate

endmodule


