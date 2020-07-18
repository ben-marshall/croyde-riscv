
//
// module: mem_sram_n64
//
//  For use with Xilinx FPGAs
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
output reg  [W:0]   rdata       ,
output wire         err
);

/* verilator lint_off WIDTH */
parameter [255*8:0] MEMH  = "";   // Memory file to read.
/* verilator lint_on  WIDTH */

localparam W      = WIDTH-1;
localparam D      = DEPTH-1;
localparam S      = WIDTH/8-1;
localparam B      = (WIDTH/8 * DEPTH)-1;
localparam A      = $clog2(DEPTH)-1; 

always @(posedge g_clk) begin
    if(cen) rdata <= addr;
end
assign err = 1'b0;
				
endmodule
