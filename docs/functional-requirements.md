
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

- `K` [scalar cryptography](https://github.com/riscv/riscv-crypto) extension.

### Privilieged ISA Support

**Machine Mode:**

- Physical memory only.

- `misa`        CSR - hard wired to show `rv64imck`.
- `mvendorid`   CSR - parameterised.
- `marchid`     CSR - parameterised.
- `mimpid`      CSR - parameterised.
- `mhartid`     CSR - Read-only, hard-wired to zero.
- `mstatus`     CSR
    - `SD`   -        Hard wired to zero. `XS` and `FS` both zero.
    - `MBE`  - WARL - Hard wired to zero.
    - `SBE`  - WARL - Hard wired to  ero.
    - `SXL`  - WARL - Hard wired to zero. Only M-Mode implemented.
    - `UXL`  - WARL - Hard wired to `2`. User mode implemented. RV64 Only
    - `TSR`  -        Hard wired to zero. S-Mode not supported.
    - `TW`   - WARL - Read/Write.
    - `TVM`  -        Hard wired to zero. S-Mode not supported.
    - `MXR`  - WARL - Hard wired to zero. No virtual memory implemented.
    - `SUM`  - WARL - Hard wired to zero. S-Mode not supported.
    - `MPRV` - WARL - Read/Write.
    - `XS`   - WARL - Hard wired to zero. No extra architectural state.
    - `FS`   - WARL - Hard wired to zero. Floating point not supported.
    - `MPP`  - WARL - Read/Write.
    - `SPP`  - WARL - Hard wired to zero.
    - `MPIE` - WARL - Read/Write.
    - `UBE`  - WARL - Hard wired to zero.
    - `SPIE` - WARL - Hard wired to zero.
    - `UPIE` - WARL - Hard wired to zero.
    - `MIE`  - WARL - Read/Write.
    - `SIE`  - WARL - Hard wired to zero.
    - `UIE`  - WARL - Hard wired to zero.
- `mtvec`       CSR
    - `BASE` - WARL - Read/write all `62` bits when `mode=0`.
      If `mode=1` (vectored) then writable bits are parameterised.
    - `MODE` - WARL - Vectored and directed mode implemented. In vectored
      mode, `BASE` must be correctly aligned to allow or'ing in offset
      from base.
- `medeleg`     CSR - Hard wired to zero. Only M-Mode implemented.
- `mideleg`     CSR - Hard wired to zero. Only M-Mode implemented.
- `mtime`       CSR - Implemented. Alias for `mcycle`.
- `mtimecmp`    CSR - Implemented.
- `mcycle`      CSR - Implemented.
- `minstret`    CSR - Implemented.
- `mcounteren`  CSR - Hard wired to zero. Only M-Mode implemented.
- `mcountinhibit` CSR - Implemented.
    - `HPMn` - Hard wired to zero. No Hardware perf monitors implemented.
    - `IR` - Read/Write.
    - `CY` - Read/Write.
- `mscratch`    CSR - Implemented. Read/Write.
- `mepc`        CSR - Implemented. Read/Write.
- `mcause`      CSR - Implemented. Read/Write.
    - `IR`      - Read/Write.
    - `CODE`    - WLRL.
- `mtval`       CSR - Not implemented / hardwired to zero.


**Supervisor Mode**

Not implemented.


**User Mode**

Not implemented.


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

