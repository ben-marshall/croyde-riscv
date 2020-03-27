
# Todo List

---

## RTL

- [ ] Fix fetch so that it only ever asks for addresses on a 64-bit boundary
      and loads that data into the buffer as appropriate.

- [X] Fetch -> Decode SV Interface

- [X] Decode -> Execute SV Interface

- [ ] Execute -> Trace SV Interface

- [ ] Memory interface Formal checkers

- [ ] ALU

  - [ ] SLTU[.w]

  - [ ] Shifts

- [ ] CSR bus converted to interface.

## Verif

- [ ] RTL signal tracking from fetch to execute and retirement.

- [ ] riscv-formal wrapper.

