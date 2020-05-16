
# Todo List

---

## RTL

- [ ] ALU

  - [ ] SLTU[.w] optimisation / reuse adder circuit

- [ ] M Extension

    - [ ] insn div
    - [ ] insn divu
    - [ ] insn divuw
    - [ ] insn divw
    - [ ] insn mul
    - [ ] insn mulh
    - [ ] insn mulhsu
    - [ ] insn mulhu
    - [ ] insn mulw
    - [ ] insn rem
    - [ ] insn remu
    - [ ] insn remuw
    - [ ] insn remw

- [ ] Configurable physical address bit width

  - [ ] Top level parameter

  - [ ] Trap on bad jump/branch target address.

- [X] Interrupts

  - [X] Timer

  - [ ] External

  - [ ] SW

  - [X] Vectoring

  - [ ] MIP.MSIP writing

- [ ] MPU

- [ ] Trace

  - [ ] Fix tracing of instructions which trapped.

- [ ] Core Complex

  - [ ] Integrated Memories

  - [ ] Debug

- [ ] Performance Optmisations

  - [ ] `c.add`, `c.ld/w/h/b[u]` fusion.

- [ ] Energy Optimisations

  - [ ] High halves of operand registers.

  - [ ] Register file sign extension bits.

  - [ ] Clock request lines

- [ ] Benchmarking

  - [ ] Dhrystone

  - [ ] Embench


## Verif

- [x] rvfi - `pc_fwd`
- [ ] rvfi - `liveness`
- [ ] csrw mcycle
- [ ] csrw minstret
- [ ] insn div
- [ ] insn divu
- [ ] insn divuw
- [ ] insn divw
- [ ] insn mul
- [ ] insn mulh
- [ ] insn mulhsu
- [ ] insn mulhu
- [ ] insn mulw
- [ ] insn rem
- [ ] insn remu
- [ ] insn remuw
- [ ] insn remw

