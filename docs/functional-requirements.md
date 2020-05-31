
## Functional Requirements

*Functional requirements for what the core must implement.*

---

## Architectural

These are the parts of the RISC-V architecture the core will
implement.

### User Level ISA Support

- `RV64I` base architecture

- `M` standard extension.

- `C` standard extension.

### Privilieged ISA Support

**Machine Mode:**

- Physical memory only.

- `misa`        CSR - hard wired to show `rv64imc`.
- `mvendorid`   CSR - parameterised.
- `marchid`     CSR - parameterised.
- `mimpid`      CSR - parameterised.
- `mhartid`     CSR - Read-only, hard-wired to zero.
- `mstatus`     CSR
    - `SD`   -        Hard wired to zero. `XS` and `FS` both zero.
    - `SXL`  - WARL - Hard wired to zero. Only M-Mode implemented.
    - `UXL`  - WARL - Hard wired to zero. Only M-Mode implemented.
    - `TSR`  -        Hard wired to zero. S-Mode not supported.
    - `TW`   -        Hard wired to zero. Only M-Mode implemented.
    - `TVM`  -        Hard wired to zero. S-Mode not supported.
    - `MXR`  - WARL - Hard wired to zero. No virtual memory implemented.
    - `SUM`  - WARL - Hard wired to zero. S-Mode not supported.
    - `MPRV` - WARL - Hard wired to zero. No memory protection implemented.
    - `XS`   - WARL - Hard wired to zero. No extra architectural state.
    - `FS`   - WARL - Hard wired to zero. Floating point not supported.
    - `MPP`  - WARL - Hard wired to zero.
    - `SPP`  - WARL - Hard wired to zero.
    - `MPIE` - WARL - Read/Write.
    - `SPIE` - WARL - Hard wired to zero.
    - `UPIE` - WARL - Hard wired to zero.
    - `MIE`  - WARL - Read/Write.
    - `SIE`  - WARL - Hard wired to zero.
    - `UIE`  - WARL - Hard wired to zero.


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

