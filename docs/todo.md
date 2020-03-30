
# Todo List

---

## RTL

- [ ] Fix fetch so that it only ever asks for addresses on a 64-bit boundary
      and loads that data into the buffer as appropriate.

- [ ] ALU

  - [ ] SLTU[.w] optimisation / reuse adder circuit

  - [ ] Shifts / optimise

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

- [ ] LSU address calculation in decode.

- [ ] Interrupts

  - [ ] Timer

  - [ ] External

  - [ ] SW

  - [ ] NMI

  - [ ] Vectoring

- [ ] MPU

- [ ] Trace

- [ ] Core Complex

  - [ ] Integrated Memories

  - [ ] Debug

- [ ] Benchmarking

  - [ ] Dhrystone

  - [ ] Embench


## Verif

- [x] RTL signal tracking from fetch to execute and retirement.

- [x] riscv-formal wrapper.

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
