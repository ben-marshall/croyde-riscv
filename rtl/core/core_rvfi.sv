
`ifdef RVFI

module  core_rvfi (
input g_clk     ,
input g_resetn  ,

`RVFI_OUTPUTS   ,

//
// Inputs which the core uses to drive the RVFI interface.
input wire                         n_valid          ,
input wire [NRET * ILEN   - 1 : 0] n_insn           ,
input wire [NRET * ILEN   - 1 : 0] n_intr           ,
input wire [NRET * ILEN   - 1 : 0] n_trap           ,

input wire [NRET *    5   - 1 : 0] n_rs1_addr       ,
input wire [NRET *    5   - 1 : 0] n_rs2_addr       ,
input wire [NRET * XLEN   - 1 : 0] n_rs1_rdata      ,
input wire [NRET * XLEN   - 1 : 0] n_rs2_rdata      ,

input wire                         n_rd_valid       ,
input wire [NRET *    5   - 1 : 0] n_rd_addr        ,
input wire [NRET * XLEN   - 1 : 0] n_rd_wdata       ,

input wire [NRET * XLEN   - 1 : 0] n_pc_rdata       ,
input wire [NRET * XLEN   - 1 : 0] n_pc_wdata       ,

input wire                         n_mem_req_valid  ,
input wire                         n_mem_rsp_valid  ,
input wire [NRET * XLEN   - 1 : 0] n_mem_addr       ,
input wire [NRET * XLEN/8 - 1 : 0] n_mem_rmask      ,
input wire [NRET * XLEN/8 - 1 : 0] n_mem_wmask      ,
input wire [NRET * XLEN   - 1 : 0] n_mem_rdata      ,
input wire [NRET * XLEN   - 1 : 0] n_mem_wdata      
);

// Common parameters and width definitions.
`include "core_common.svh"
        
//
// Make sure that the RVFI_OUTPUTS are declared here as "reg" types.
// It is left ambiguous by the `RVFI_OUTPUTS macro.
reg rvfi_insn     ;
reg rvfi_intr     ;
reg rvfi_trap     ;
reg rvfi_rs1_addr ;
reg rvfi_rs2_addr ;
reg rvfi_rs1_rdata;
reg rvfi_rs2_rdata;
reg rvfi_pc_rdata ;
reg rvfi_pc_wdata ;
reg rvfi_rd_addr  ;
reg rvfi_rd_wdata ;
reg rvfi_mem_addr ;
reg rvfi_mem_rmask;
reg rvfi_mem_wmask;
reg rvfi_mem_rdata;
reg rvfi_mem_wdata;


//
// Logic for updateing the RVFI outputs based on the n_* inputs

reg rvalid;

assign rvfi_valid = rvalid;

always @(posedge g_clk) begin
    if(!g_resetn) begin
        rvalid <= 1'b0;
    end else begin
        rvalid <= n_valid;
    end
end

always @(posedge g_clk) begin
    if(n_valid) begin
        rvfi_insn        <= n_insn        ;
        rvfi_intr        <= n_intr        ;
        rvfi_trap        <= n_trap        ;

        rvfi_rs1_addr    <= n_rs1_addr    ;
        rvfi_rs2_addr    <= n_rs2_addr    ;
        rvfi_rs1_rdata   <= n_rs1_rdata   ;
        rvfi_rs2_rdata   <= n_rs2_rdata   ;

        rvfi_pc_rdata    <= n_pc_rdata    ;
        rvfi_pc_wdata    <= n_pc_wdata    ;
    end
end

always @(posedge g_clk) begin
    if(n_rd_valid) begin
        rvfi_rd_addr     <= n_rd_addr     ;
        rvfi_rd_wdata    <= n_rd_wdata    ;
    end
end

endmodule

`endif
