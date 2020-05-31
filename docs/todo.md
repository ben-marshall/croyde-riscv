
# Todo List

---

## RTL

- [ ] ALU

  - [ ] SLTU[.w] optimisation / reuse adder circuit

- [ ] Configurable physical address bit width

  - [ ] Top level parameter

  - [ ] Trap on bad jump/branch target address.

  - [ ] Set by default to by `SV39` compatible.

- [ ] `WFI` instruction implementation.

  - [ ] Hardware.

  - [ ] Unit Test.

- [ ] MPU

- [ ] Trace

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

- [ ] csrw mcycle
- [ ] csrw minstret
