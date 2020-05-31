
## Functional Requirements

*Functional requirements for what the core must implement.*

---

## Architectural

These are the parts of the RISC-V architecture the core will
implement.

- `RV32I` base architecture

  - `M` standard extension.

  - `C` standard extension.

- Machine Mode

  - Physical memory only.


## Micro-architectural

- Three stages: Fetch, Decode + Execute, Writeback

- Separate instruction fetch and data memory busses.


**Fetch:**

  - 32-bit instruction fetch bus.

  - 128-bit fetch buffer.

  - Decoder: 1x 32/16 bit instructions decoded per cycle.


**Decode+Execute:**

  - Decode operands
  
  - Read registers

  - Select functional units: ALU / LSU / CSR / CFU etc.

    - Non-trapping control flow changes are taken here.

  - Compute results for writeback.


**Writeback:**

  - GPR writes.

  - CSR access.

  - Data Memory access.

  - Single forwarding path from execute to Decode.

  - Traps and interrupts are raised here.

