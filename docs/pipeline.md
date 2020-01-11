
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
     PCW | `s1_pc`   | Program Counter valid in the decode stage.
     32  | `s1_instr`| 32-bit instruction word ready for decoding.
     1   | `s1_ferr` | Fetch error associated with these `s1_instr` bits?

- It uses the following control signals to communicate readiness with the
  decode stage:

    Bits | Name      | Driver | Description
    -----|-----------|--------|---------------------------------------------
     1   | `s1_valid`| fetch  | Is the data presented to decode valid?
     1   | `s2_eat_2`| decode | Decode eats 2 bytes from decode buffer.
     1   | `s2_eat_4`| decode | Decode eats 4 bytes from decode buffer.
    
- The control flow change bus is driven from *either* decode *or*
  execute, and communicates all interrupts, exceptions, branches and jumps to
  the fetch stage.

    Bits | Name         | Dir | Description
    -----|--------------|-----|---------------------------------------------
     1   | `cf_valid`   | in  | Control flow change request valid
     1   | `cf_ack`     | out | Control flow change acknowledged.
     64  | `cf_target`  | in  | Target address of the control flow change.
     4   | `cf_cause`   | in  | Cause of the control flow change.

## Decode / Operand Gather

- Turns the 32-bits of `s1_instr` into a wider pipeline encoding ready for
  execution.

- Responsible for gathering register and program counter operands into the
  right pipeline registers.

- Can cause control flow changes for non-conditional branches and jumps.

- The pipeline register data fields presented to execute are:

    Bits | Name         | Description
    -----|--------------|---------------------------------------------
     64  | `s3_opr_a`   | ALU / Branch operand A
     64  | `s3_opr_b`   | B
     64  | `s3_opr_c`   | C
     64  | `s3_pc`      | Program counter for the instruction.
      4  | `s3_fu`      | Which functional unit will process the instruction?
      7  | `s3_op`      | Which operation to perform?
      5  | `s3_rd`      | Destination writeback register.

## Execute

- Computes ALU results,
  accesses CSRs,
  accesses memory,
  triggers conditional control flow changes
  and
  raises exceptions / interrupts.

- Only this stage can write back to the register file.
 
