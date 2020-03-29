
# Todo List

---

## RTL

- [ ] Fix fetch so that it only ever asks for addresses on a 64-bit boundary
      and loads that data into the buffer as appropriate.

- [ ] Memory interface Formal checkers

- [ ] ALU

  - [ ] SLTU[.w]

  - [ ] Shifts

## Verif

- [x] RTL signal tracking from fetch to execute and retirement.

- [x] riscv-formal wrapper.

csrw mcycle ch0/status:FAIL 0 23
csrw minstret ch0/status:FAIL 0 22
insn c andi ch0/status:FAIL 0 16
insn div ch0/status:FAIL 0 15
insn divu ch0/status:FAIL 0 15
insn divuw ch0/status:FAIL 0 15
insn divw ch0/status:FAIL 0 15
insn mul ch0/status:FAIL 0 17
insn mulh ch0/status:FAIL 0 18
insn mulhsu ch0/status:FAIL 0 17
insn mulhu ch0/status:FAIL 0 17
insn mulw ch0/status:FAIL 0 17
insn rem ch0/status:FAIL 0 16
insn remu ch0/status:FAIL 0 16
insn remuw ch0/status:FAIL 0 16
insn remw ch0/status:FAIL 0 16
liveness ch0/status:FAIL 0 23
unique ch0/status:FAIL 0 24
