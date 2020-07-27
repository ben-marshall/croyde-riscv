
`ifndef DA_MACROS_SVH
`define DA_MACROS_SVH

`define DA_CSR_CONN(UNIQ1, UNIQ2)   \
.da``UNIQ1``_mstatus   (da``UNIQ2``_mstatus   ), \
.da``UNIQ1``_misa      (da``UNIQ2``_misa      ), \
.da``UNIQ1``_medeleg   (da``UNIQ2``_medeleg   ), \
.da``UNIQ1``_mideleg   (da``UNIQ2``_mideleg   ), \
.da``UNIQ1``_mie       (da``UNIQ2``_mie       ), \
.da``UNIQ1``_mtvec     (da``UNIQ2``_mtvec     ), \
.da``UNIQ1``_mscratch  (da``UNIQ2``_mscratch  ), \
.da``UNIQ1``_mepc      (da``UNIQ2``_mepc      ), \
.da``UNIQ1``_mcause    (da``UNIQ2``_mcause    ), \
.da``UNIQ1``_mtval     (da``UNIQ2``_mtval     ), \
.da``UNIQ1``_mip       (da``UNIQ2``_mip       ), \
.da``UNIQ1``_mvendorid (da``UNIQ2``_mvendorid ), \
.da``UNIQ1``_marchid   (da``UNIQ2``_marchid   ), \
.da``UNIQ1``_mimpid    (da``UNIQ2``_mimpid    ), \
.da``UNIQ1``_mhartid   (da``UNIQ2``_mhartid   ), \
.da``UNIQ1``_cycle     (da``UNIQ2``_cycle     ), \
.da``UNIQ1``_mtime     (da``UNIQ2``_mtime     ), \
.da``UNIQ1``_instret   (da``UNIQ2``_instret   ), \
.da``UNIQ1``_mcountin  (da``UNIQ2``_mcountin  ) \

`define DA_CSR_INPUTS(UNIQ)            \
input [XL:0] da``UNIQ``_mstatus     ,   \
input [XL:0] da``UNIQ``_misa        ,   \
input [XL:0] da``UNIQ``_medeleg     ,   \
input [XL:0] da``UNIQ``_mideleg     ,   \
input [XL:0] da``UNIQ``_mie         ,   \
input [XL:0] da``UNIQ``_mtvec       ,   \
input [XL:0] da``UNIQ``_mscratch    ,   \
input [XL:0] da``UNIQ``_mepc        ,   \
input [XL:0] da``UNIQ``_mcause      ,   \
input [XL:0] da``UNIQ``_mtval       ,   \
input [XL:0] da``UNIQ``_mip         ,   \
input [XL:0] da``UNIQ``_mvendorid   ,   \
input [XL:0] da``UNIQ``_marchid     ,   \
input [XL:0] da``UNIQ``_mimpid      ,   \
input [XL:0] da``UNIQ``_mhartid     ,   \
input [XL:0] da``UNIQ``_cycle       ,   \
input [XL:0] da``UNIQ``_mtime       ,   \
input [XL:0] da``UNIQ``_instret     ,   \
input [XL:0] da``UNIQ``_mcountin    

`define DA_CSR_OUTPUTS(TYPE,UNIQ)           \
output TYPE [XL:0] da``UNIQ``_mstatus     ,   \
output TYPE [XL:0] da``UNIQ``_misa        ,   \
output TYPE [XL:0] da``UNIQ``_medeleg     ,   \
output TYPE [XL:0] da``UNIQ``_mideleg     ,   \
output TYPE [XL:0] da``UNIQ``_mie         ,   \
output TYPE [XL:0] da``UNIQ``_mtvec       ,   \
output TYPE [XL:0] da``UNIQ``_mscratch    ,   \
output TYPE [XL:0] da``UNIQ``_mepc        ,   \
output TYPE [XL:0] da``UNIQ``_mcause      ,   \
output TYPE [XL:0] da``UNIQ``_mtval       ,   \
output TYPE [XL:0] da``UNIQ``_mip         ,   \
output TYPE [XL:0] da``UNIQ``_mvendorid   ,   \
output TYPE [XL:0] da``UNIQ``_marchid     ,   \
output TYPE [XL:0] da``UNIQ``_mimpid      ,   \
output TYPE [XL:0] da``UNIQ``_mhartid     ,   \
output TYPE [XL:0] da``UNIQ``_cycle       ,   \
output TYPE [XL:0] da``UNIQ``_mtime       ,   \
output TYPE [XL:0] da``UNIQ``_instret     ,   \
output TYPE [XL:0] da``UNIQ``_mcountin    

`define DA_CSR_WIRES(UNIQ)    \
wire [XL:0] da``UNIQ``_mstatus     ;   \
wire [XL:0] da``UNIQ``_misa        ;   \
wire [XL:0] da``UNIQ``_medeleg     ;   \
wire [XL:0] da``UNIQ``_mideleg     ;   \
wire [XL:0] da``UNIQ``_mie         ;   \
wire [XL:0] da``UNIQ``_mtvec       ;   \
wire [XL:0] da``UNIQ``_mscratch    ;   \
wire [XL:0] da``UNIQ``_mepc        ;   \
wire [XL:0] da``UNIQ``_mcause      ;   \
wire [XL:0] da``UNIQ``_mtval       ;   \
wire [XL:0] da``UNIQ``_mip         ;   \
wire [XL:0] da``UNIQ``_mvendorid   ;   \
wire [XL:0] da``UNIQ``_marchid     ;   \
wire [XL:0] da``UNIQ``_mimpid      ;   \
wire [XL:0] da``UNIQ``_mhartid     ;   \
wire [XL:0] da``UNIQ``_cycle       ;   \
wire [XL:0] da``UNIQ``_mtime       ;   \
wire [XL:0] da``UNIQ``_instret     ;   \
wire [XL:0] da``UNIQ``_mcountin    ;   \

`endif

