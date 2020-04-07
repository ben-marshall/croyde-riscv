
# Pipeline

*Describes the main processing pipeline of the CPU.*

---

- The pipeline is 3 stages long:

  - Fetch

  - Decode / Operand Gather

  - Execute

## Fetch

- 64-bit wide memory bus

- 96-bit fetch buffer.  96 bits = 64 bits (memory bus width) + 32 bits
  (largest instruction size).

- The fetch buffer also tracks bus error bits. Each 16-bit halfword
  in the buffer is tagged with a "is this data associated with an
  instruction bus error?" bit.

- It maintains it's own copy of the program counter, and a separate register
  containing the instruction fetch address.

- It makes the following data fields available to the decode and operand
  gather stage:

    Bits | Name      | Description
    -----|-----------|-----------------------------------------------------
     32  | `s1_instr`| 32-bit instruction word ready for decoding.
     1   | `s1_ferr` | Fetch error associated with these `s1_instr` bits?
     1   | `s1_i16bit`| Eat a 16 bit instruction from the buffer.
     1   | `s1_i32bit`| Eat a 32 bit instruction from the buffer.

  Note that `s1_i[16/32]bit` are driven by the decode stage, other signals
  are driven by the fetch stage.
    
- The control flow change bus is driven from *either* decode *or*
  execute, and communicates all interrupts, exceptions, branches and jumps to
  the fetch stage.

    Bits | Name         | Dir | Description
    -----|--------------|-----|---------------------------------------------
     1   | `cf_valid`   | in  | Control flow change request valid
     1   | `cf_ack`     | out | Control flow change acknowledged.
     64  | `cf_target`  | in  | Target address of the control flow change.
     4   | `cf_cause`   | in  | Cause of the control flow change.

## Decode / Execute

- Decodes instructions and selects inputs to functional units.

- Computes data memory & branch target addresses using the ALU.

- Non-trap control flow changes take place here.

- The pipeline register data fields presented to writeback are:

    Bits | Name         | Description
    -----|--------------|---------------------------------------------
       1 | s2_valid     | Execute has instruction ready for writeback
       1 | s2_ready     | Writeback ready for new instruction
       2 | s2_full      | Instruction in writeback stage
       5 | s2_rd        | Destination GPR
    XLEN | s2_wdata     | Write data for CSRs / GPRs
    XLEN | s2_pc        | Program counter for instruction
       3 | s2_csr_op    | Control & Status Register operation
       4 | s2_cfu_op    | Control flow change operations: mret/ebreak etc
       5 | s2_lsu_op    | Load/store unit operation
       2 | s2_wb_op     | Writeback data sourcing
       1 | s2_trap      | Raise trap.

## Writeback

- This stage writes back data to the register file, accesses CSRs,
  finalises control flow changes and finishes memory accesses.

