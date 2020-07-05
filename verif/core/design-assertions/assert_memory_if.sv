
//
// module: assert_memory_if
//
//  Asserts the correctness of the core memory interfaces.
//
module assert_memory_if (

input  wire                 f_clk        , // Global clock
input  wire                 g_resetn     , // Global active low sync reset.
              
input  wire                 mem_req      , // Memory request
input  wire [ MEM_ADDR_R:0] mem_addr     , // Memory request address
input  wire                 mem_wen      , // Memory request write enable
input  wire [ MEM_STRB_R:0] mem_strb     , // Memory request write strobe
input  wire [ MEM_DATA_R:0] mem_wdata    , // Memory write data.
input  wire                 mem_gnt      , // Memory response valid
input  wire                 mem_err      , // Memory response error
input  wire [ MEM_DATA_R:0] mem_rdata      // Memory response read data
);

//
// Common core parameters and constants.
`include "core_common.svh"


//
// Assume that we do not get memory bus errors
always @(posedge f_clk) if(g_resetn && $stable(g_resetn)) begin

    cover(mem_req);

    cover(mem_req && mem_gnt);

    cover(mem_req && mem_err);
    
    cover($past(mem_req) && mem_err);
    
    cover($past(mem_req) && mem_err && $past(mem_gnt));

    if($past(mem_req) && !$past(mem_gnt)) begin
        
        assert($stable(mem_req      ));

        assert($stable(mem_addr     ));
        
        assert($stable(mem_wen      ));
        
        assert($stable(mem_strb     ));

        assert($stable(mem_wdata    ));

    end

end

endmodule
