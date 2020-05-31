
# Pipeline

*Describes the main processing pipeline of the CPU.*

---

- The pipeline is 3 stages long:

  - Fetch

  - Decode + Execute

  - Writeback

## Fetch

- `64`-bit wide memory bus

- `128`-bit fetch buffer.  `128` bits = `64` bits (memory bus width) * `2`
  (largest instruction size).

- The fetch buffer also tracks bus error bits. Each 16-bit halfword
  in the buffer is tagged with a "is this data associated with an
  instruction bus error?" bit.

- It maintains it's own copy of the program counter, and a separate register
  containing the instruction fetch address.

- It makes the following data fields available to the decode and operand
  gather stage:

    Bits | Name       | Description
    -----|------------|-----------------------------------------------------
     32  | `s1_instr` | 32-bit instruction word ready for decoding.
     1   | `s1_ferr`  | Fetch error associated with these `s1_instr` bits?
     1   | `s1_i16bit`| `s1_instr` contains 16-bit instruction.
     1   | `s1_i32bit`| `s1_instr` contains 32-bit instruction.
     1   | `s1_eat_2` | Eat 2 bytes from the buffer.
     1   | `s1_eat_4` | Eat 4 bytes from the buffer.

  Note that `s1_eat_[2,4]` are driven by the decode stage, other signals
  are driven by the fetch stage.
    
- The control flow change bus is driven from *either* execute *or*
  writeback, and communicates all interrupts, exceptions, branches and jumps to
  the fetch stage. The writeback stage takes priority in the event of
  contention.

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
       1 |`s3_valid    `| Execute has instruction ready for writeback
       1 |`s3_ready    `| Writeback ready for new instruction
       2 |`s3_full     `| Instruction in writeback stage
       5 |`s3_rd       `| Destination GPR
    XLEN |`s3_wdata    `| Write data for CSRs / GPRs
    XLEN |`s3_npc      `| Next program counter - for jump and link.
    XLEN |`s3_pc       `| Program counter for instruction
       3 |`s3_csr_op   `| Control & Status Register operation
       4 |`s3_cfu_op   `| Control flow change operations: mret/ebreak etc
       5 |`s3_lsu_op   `| Load/store unit operation
       2 |`s3_wb_op    `| Writeback data sourcing
       1 |`s3_trap     `| Raise trap.

## Writeback

- This stage writes back data to the register file, accesses CSRs,
  finalises control flow changes and finishes memory accesses.

