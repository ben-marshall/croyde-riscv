
# Todo List

---

## RTL

- [x] Fix fetch so that it only ever asks for addresses on a 64-bit boundary
      and loads that data into the buffer as appropriate.

- [ ] ALU

  - [ ] SLTU[.w] optimisation / reuse adder circuit

  - [x] Shifts / optimise

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

- [x] LSU address calculation in decode.

- [ ] Trap on bad jump/branch target address.

- [ ] Interrupts

  - [ ] Timer

  - [ ] External

  - [ ] SW

  - [ ] Vectoring

  - [ ] MIP.MSIP writing

- [ ] MPU

- [ ] Trace

- [ ] Core Complex

  - [ ] Integrated Memories

  - [ ] Debug

- [ ] Energy Optimisations

  - [ ] High halves of operand registers.

  - [ ] Register file sign extension bits.

  - [ ] Clock request lines

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

- [x] Designer assertions flow.

  - [x] Memory interface formal checkers.

  - [x] Control flow bus formal checkers.

