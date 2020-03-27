
interface core_rvfi (
    input g_clk     ,
    input g_resetn
);

// Common parameters and width definitions.
`include "core_common.svh"

//
// Outputs which the core presents to the model checkers.
logic [NRET          - 1 : 0] valid         ;
logic [NRET *   64   - 1 : 0] order         ;
logic [NRET * ILEN   - 1 : 0] insn          ;
logic [NRET          - 1 : 0] trap          ;
logic [NRET          - 1 : 0] halt          ;
logic [NRET          - 1 : 0] intr          ;
logic [NRET * 2      - 1 : 0] mode          ;
logic [NRET * 2      - 1 : 0] ixl           ;

logic [NRET *    5   - 1 : 0] rs1_addr      ;
logic [NRET *    5   - 1 : 0] rs2_addr      ;
logic [NRET * XLEN   - 1 : 0] rs1_rdata     ;
logic [NRET * XLEN   - 1 : 0] rs2_rdata     ;

logic [NRET *    5   - 1 : 0] rd_addr       ;
logic [NRET * XLEN   - 1 : 0] rd_wdata      ;

logic [NRET * XLEN   - 1 : 0] pc_rdata      ;
logic [NRET * XLEN   - 1 : 0] pc_wdata      ;

logic [NRET * XLEN   - 1 : 0] mem_addr      ;
logic [NRET * XLEN/8 - 1 : 0] mem_rmask     ;
logic [NRET * XLEN/8 - 1 : 0] mem_wmask     ;
logic [NRET * XLEN   - 1 : 0] mem_rdata     ;
logic [NRET * XLEN   - 1 : 0] mem_wdata     ;

//
// Inputs which the core uses to drive the RVFI interface.
logic                         n_valid       ;
logic [NRET * ILEN   - 1 : 0] n_insn        ;
logic [NRET * ILEN   - 1 : 0] n_intr        ;
logic [NRET * ILEN   - 1 : 0] n_trap        ;

logic [NRET *    5   - 1 : 0] n_rs1_addr    ;
logic [NRET *    5   - 1 : 0] n_rs2_addr    ;
logic [NRET * XLEN   - 1 : 0] n_rs1_rdata   ;
logic [NRET * XLEN   - 1 : 0] n_rs2_rdata   ;

logic                         n_rd_valid    ;
logic [NRET *    5   - 1 : 0] n_rd_addr     ;
logic [NRET * XLEN   - 1 : 0] n_rd_wdata    ;

logic [NRET * XLEN   - 1 : 0] n_pc_rdata    ;
logic [NRET * XLEN   - 1 : 0] n_pc_wdata    ;

logic                         n_mem_req_valid;
logic                         n_mem_rsp_valid;
logic [NRET * XLEN   - 1 : 0] n_mem_addr    ;
logic [NRET * XLEN/8 - 1 : 0] n_mem_rmask   ;
logic [NRET * XLEN/8 - 1 : 0] n_mem_wmask   ;
logic [NRET * XLEN   - 1 : 0] n_mem_rdata   ;
logic [NRET * XLEN   - 1 : 0] n_mem_wdata   ;

//
// Logic for updateing the RVFI outputs based on the n_* inputs

always @(posedge g_clk) begin
    if(!g_resetn) begin
        valid <= 1'b0;
    end else begin
        valid <= n_valid;
    end
end

always @(posedge g_clk) begin
    if(n_valid) begin
        insn        <= n_insn        ;
        intr        <= n_intr        ;
        trap        <= n_trap        ;
                    
        rs1_addr    <= n_rs1_addr    ;
        rs2_addr    <= n_rs2_addr    ;
        rs1_rdata   <= n_rs1_rdata   ;
        rs2_rdata   <= n_rs2_rdata   ;
                    
        pc_rdata    <= n_pc_rdata    ;
        pc_wdata    <= n_pc_wdata    ;
    end
end

always @(posedge g_clk) begin
    if(n_rd_valid) begin
        rd_addr     <= n_rd_addr     ;
        rd_wdata    <= n_rd_wdata    ;
    end
end

modport OUT  (
    output valid       ,
    output order       ,
    output insn        ,
    output trap        ,
    output halt        ,
    output intr        ,
    output mode        ,
    output ixl         ,

    output rs1_addr    ,
    output rs2_addr    ,
    output rs1_rdata   ,
    output rs2_rdata   ,

    output rd_addr     ,
    output rd_wdata    ,

    output pc_rdata    ,
    output pc_wdata    ,

    output mem_addr    ,
    output mem_rmask   ,
    output mem_wmask   ,
    output mem_rdata   ,
    output mem_wdata    
);

modport IN (
    input n_valid       ,
    input n_insn        ,
    input n_intr        ,
    input n_trap        ,

    input n_rs1_addr    ,
    input n_rs2_addr    ,
    input n_rs1_rdata   ,
    input n_rs2_rdata   ,

    input n_rd_valid    ,
    input n_rd_addr     ,
    input n_rd_wdata    ,

    input n_pc_rdata    ,
    input n_pc_wdata    ,

    input n_mem_req_valid,
    input n_mem_rsp_valid,
    input n_mem_addr    ,
    input n_mem_rmask   ,
    input n_mem_wmask   ,
    input n_mem_rdata   ,
    input n_mem_wdata   
);

endinterface
