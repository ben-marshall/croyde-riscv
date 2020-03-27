
`ifndef __CORE_INTERFACES_SVH__
`define __CORE_INTERFACES_SVH__

//
// interface: Core Memory Interface
//
//  An AHB-like interface for memory transactions.
//
interface core_mem_if ();

// Common parameters and width definitions.
`include "core_common.svh"

logic                 req     ; // Memory request
logic [ MEM_ADDR_R:0] addr    ; // Memory request address
logic                 wen     ; // Memory request write enable
logic [ MEM_STRB_R:0] strb    ; // Memory request write strobe
logic [ MEM_DATA_R:0] wdata   ; // Memory write data.
logic                 gnt     ; // Memory response valid
logic                 err     ; // Memory response error
logic [ MEM_DATA_R:0] rdata   ; // Memory response read data

// Requestor
modport REQ (
    output req     ,
    output addr    ,
    output wen     ,
    output strb    ,
    output wdata   ,
    input  gnt     ,
    input  err     ,
    input  rdata    
);

// Responder
modport RSP (
    input  req     ,
    input  addr    ,
    input  wen     ,
    input  strb    ,
    input  wdata   ,
    output gnt     ,
    output err     ,
    output rdata    
);

endinterface


//
// interface: Fetch -> Decode pipeline interface
//
interface core_pipe_fd ();

// Common parameters and width definitions.
`include "core_common.svh"

logic                 i16bit   ; // 16 bit instruction?
logic                 i32bit   ; // 32 bit instruction?
logic [  FD_IBUF_R:0] instr    ; // Instruction to be decoded
logic [         XL:0] pc       ; // Program Counter
logic [         XL:0] npc      ; // Next Program Counter
logic [   FD_ERR_R:0] ferr     ; // Fetch bus error?
logic                 eat_2    ; // Decode eats 2 bytes
logic                 eat_4    ; // Decode eats 4 bytes

modport FETCH(
    output i16bit   ,
    output i32bit   ,
    output instr    ,
    output pc       ,
    output npc      ,
    output ferr     ,
    input  eat_2    ,
    input  eat_4    
);

modport DECODE(
    input  i16bit   ,
    input  i32bit   ,
    input  instr    ,
    input  pc       ,
    input  npc      ,
    input  ferr     ,
    output eat_2    ,
    output eat_4    
);

endinterface


//
// interface: Decode -> Execute pipeline interface
//
interface core_pipe_de ();

// Common parameters and width definitions.
`include "core_common.svh"

logic                 valid    ; // Decode instr ready for execute
logic                 ready    ; // Execute ready for new instr.
logic [         XL:0] pc       ; // Execute stage PC
logic [         XL:0] opr_a    ; // EX stage operand a
logic [         XL:0] opr_b    ; //    "       "     b
logic [         XL:0] opr_c    ; //    "       "     c
logic [ REG_ADDR_R:0] rd       ; // EX stage destination reg address.
logic [   ALU_OP_R:0] alu_op   ; // ALU operation
logic [   LSU_OP_R:0] lsu_op   ; // LSU operation
logic [   MDU_OP_R:0] mdu_op   ; // Mul/Div Operation
logic [   CSR_OP_R:0] csr_op   ; // CSR operation
logic [   CFU_OP_R:0] cfu_op   ; // Control flow unit operation
logic                 op_w     ; // Is the operation on a word?
logic [         31:0] instr    ; // Encoded instruction for trace.

modport DECODE (
    output valid    ,
    input  ready    ,
    output pc       ,
    output opr_a    ,
    output opr_b    ,
    output opr_c    ,
    output rd       ,
    output alu_op   ,
    output lsu_op   ,
    output mdu_op   ,
    output csr_op   ,
    output cfu_op   ,
    output op_w     ,
    output instr     
);


modport EXECUTE (
    input  valid    ,
    output ready    ,
    input  pc       ,
    input  opr_a    ,
    input  opr_b    ,
    input  opr_c    ,
    input  rd       ,
    input  alu_op   ,
    input  lsu_op   ,
    input  mdu_op   ,
    input  csr_op   ,
    input  cfu_op   ,
    input  op_w     ,
    input  instr     
);

endinterface


`endif
