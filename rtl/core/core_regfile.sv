

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

reg  [XL:0] regs  [31:0];

assign  rs1_data    = |rs1_addr ? regs[rs1_addr] : {XLEN{1'b0}};
assign  rs2_data    = |rs2_addr ? regs[rs2_addr] : {XLEN{1'b0}};

assign  g_clk_req   = rd_wen;

always @(posedge g_clk) begin
    if(rd_wen && |rd_addr) begin
        regs[rd_addr] <= rd_wdata;
    end
end

endmodule
