
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

- Three stages: Fetch, Decode/Pre-execute, Execute/Writeback

- Separate instruction fetch and data memory busses.

- Fetch:

  - 32-bit instruction fetch bus.

  - 64-bit fetch buffer.

  - Decoder: 1x 32/16 bit instructions decoded per cycle.

- Decode/Pre-execute:

  - Decode operands
  
  - Read registers

  - Select functional units: ALU / LSU / CSR etc.

- Execute:

  - Compute results and write-back.

  - CSR access.

  - Data Memory access.

  - Single forwarding path from execute to Decode.
