

interface core_rvfi_csr_trace ();

`include "core_common.svh"

logic [XL:0] mstatus  ;
logic [XL:0] misa     ;
logic [XL:0] medeleg  ;
logic [XL:0] mideleg  ;
logic [XL:0] mie      ;
logic [XL:0] mtvec    ;
logic [XL:0] mscratch ;
logic [XL:0] mepc     ;
logic [XL:0] mcause   ;
logic [XL:0] mtval    ;
logic [XL:0] mip      ;
logic [XL:0] mvendorid;
logic [XL:0] marchid  ;
logic [XL:0] mimpid   ;
logic [XL:0] mhartid  ;
logic [XL:0] cycle    ;
logic [XL:0] mtime    ;
logic [XL:0] instret  ;
logic [XL:0] mcountin ;

modport O (
output mstatus  ,
output misa     ,
output medeleg  ,
output mideleg  ,
output mie      ,
output mtvec    ,
output mscratch ,
output mepc     ,
output mcause   ,
output mtval    ,
output mip      ,
output mvendorid,
output marchid  ,
output mimpid   ,
output mhartid  ,
output cycle    ,
output mtime    ,
output instret  ,
output mcountin  
);

modport I (
input mstatus  ,
input misa     ,
input medeleg  ,
input mideleg  ,
input mie      ,
input mtvec    ,
input mscratch ,
input mepc     ,
input mcause   ,
input mtval    ,
input mip      ,
input mvendorid,
input marchid  ,
input mimpid   ,
input mhartid  ,
input cycle    ,
input mtime    ,
input instret  ,
input mcountin  
);

endinterface

