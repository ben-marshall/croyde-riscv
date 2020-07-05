

//
// module: core_regfile
//
//  Core register file. 2 read, 1 write.
//
module core_regfile (

input  wire                g_clk        , // Gated register file clock
output wire                g_clk_req    , // Register file clock request
input  wire                g_resetn     , // Global negative level reset.

input  wire [REG_ADDR_R:0] rs1_addr     ,
input  wire [REG_ADDR_R:0] rs2_addr     ,

output wire [        XL:0] rs1_data     ,
output wire [        XL:0] rs2_data     ,

input  wire                rd_wen       ,
input  wire [REG_ADDR_R:0] rd_addr      ,
input  wire [        XL:0] rd_wdata  

);

// Common parameters and width definitions.
`include "core_common.svh"

wire [XL:0] regs[31:0];

assign  rs1_data    = regs[rs1_addr];
assign  rs2_data    = regs[rs2_addr];

assign  g_clk_req   = rd_wen;

assign regs[0]      = 0;

genvar i;
generate for(i = 1; i < 32; i = i + 1) begin

    reg [XL:0] r;

    assign regs[i] = r;

    always @(posedge g_clk) begin
        if(rd_wen && (rd_addr == i)) begin
            r <= rd_wdata;
        end
    end

end endgenerate

endmodule
