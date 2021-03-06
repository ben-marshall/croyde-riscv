
`ifdef RVFI

module  core_rvfi (
input g_clk     ,
input g_resetn  ,

`RVFI_OUTPUTS   ,
`DA_CSR_INPUTS(_s3)                         ,
`DA_CSR_OUTPUTS(reg,_out)                   ,

//
// Inputs which the core uses to drive the RVFI interface.
input wire                         n_valid          ,
input wire [NRET * ILEN   - 1 : 0] n_insn           ,
input wire                         n_intr           ,
input wire                         n_trap           ,

input wire [NRET *    5   - 1 : 0] n_rs1_addr       ,
input wire [NRET *    5   - 1 : 0] n_rs2_addr       ,
input wire [NRET * XLEN   - 1 : 0] n_rs1_rdata      ,
input wire [NRET * XLEN   - 1 : 0] n_rs2_rdata      ,

input wire                         n_rd_valid       ,
input wire [NRET *    5   - 1 : 0] n_rd_addr        ,
input wire [NRET * XLEN   - 1 : 0] n_rd_wdata       ,

input wire                         n_cf_change      ,
input wire [NRET * XLEN   - 1 : 0] n_cf_target      ,

input wire [NRET * XLEN   - 1 : 0] n_pc_rdata       ,
input wire [NRET * XLEN   - 1 : 0] n_pc_wdata       ,

input wire [NRET *    2   - 1 : 0] n_mode           ,

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
reg rvfi_mode     ;

assign rvfi_halt = 1'b0;

reg         rvfi_order      ;
initial     rvfi_order      = 0;
wire [XL:0] n_rvfi_order    = rvfi_order + 1;

always @(posedge g_clk) begin
    if(n_valid) begin
        rvfi_order <= n_rvfi_order;
    end
end

//
// Ignore first valid bit after reset.
reg first_seen;
always @(posedge g_clk) begin
    if(!g_resetn) begin
        first_seen <= 1'b0;
    end else begin
        first_seen <= first_seen || n_valid;
    end
end

//
// Logic for updateing the RVFI outputs based on the n_* inputs

reg rvalid;

assign rvfi_valid = rvalid;

always @(posedge g_clk) begin
    if(!g_resetn) begin
        rvalid <= 1'b0;
    end else begin
        rvalid <= n_valid && first_seen;
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

        rvfi_mode        <= n_mode        ;

        da_out_mstatus   <= da_s3_mstatus  ;
        da_out_misa      <= da_s3_misa     ;
        da_out_medeleg   <= da_s3_medeleg  ;
        da_out_mideleg   <= da_s3_mideleg  ;
        da_out_mie       <= da_s3_mie      ;
        da_out_mtvec     <= da_s3_mtvec    ;
        da_out_mscratch  <= da_s3_mscratch ;
        da_out_mepc      <= da_s3_mepc     ;
        da_out_mcause    <= da_s3_mcause   ;
        da_out_mtval     <= da_s3_mtval    ;
        da_out_mip       <= da_s3_mip      ;
        da_out_mvendorid <= da_s3_mvendorid;
        da_out_marchid   <= da_s3_marchid  ;
        da_out_mimpid    <= da_s3_mimpid   ;
        da_out_mhartid   <= da_s3_mhartid  ;
        da_out_cycle     <= da_s3_cycle    ;
        da_out_mtime     <= da_s3_mtime    ;
        da_out_instret   <= da_s3_instret  ;
        da_out_mcountin  <= da_s3_mcountin ;
    end
end

always @(posedge g_clk) begin
    if(n_valid) begin
        rvfi_pc_rdata    <= n_pc_rdata    ;
    end

    if(n_valid || (n_cf_change)) begin
        rvfi_pc_wdata <= n_cf_change ? n_cf_target : n_pc_wdata    ;
    end
end

reg    hold_rd_data;
wire n_hold_rd_data = hold_rd_data ? !n_valid : n_rd_valid && !n_valid;

always @(posedge g_clk) begin
    hold_rd_data <= n_hold_rd_data;
end

always @(posedge g_clk) begin
    if(n_rd_valid || (n_valid && !hold_rd_data)) begin
        if(n_rd_valid) begin
            rvfi_rd_addr     <= n_rd_addr       ;
        end else begin
            rvfi_rd_addr     <= 5'b0            ;
        end
        if(n_rd_valid && |n_rd_addr) begin
            rvfi_rd_wdata    <= n_rd_wdata  ;
        end else begin
            rvfi_rd_wdata    <= 0           ;
        end
    end
end

always @(posedge g_clk) begin
    if(n_mem_req_valid || n_valid) begin
        rvfi_mem_addr   <= n_mem_addr   ;
        rvfi_mem_rmask  <= n_mem_rmask  ;
        rvfi_mem_wmask  <= n_mem_wmask  ;
        rvfi_mem_wdata  <= n_mem_wdata  ;
    end

    if(n_mem_rsp_valid) begin
        rvfi_mem_rdata  <= n_mem_rdata  ;
    end
end

endmodule

`endif
