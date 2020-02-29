
# Todo List

---

## RTL

- [ ] Fix flushing of fetch -> decode register such that we loose a
      branch instruction if a decode-stage branch is taken when execute is
      not ready to recieve it.

  - [X] Decode CF valid should not be asserted until the EX stage is
        ready.

- [X] Execute stage ready signal.

  - [X] Decode stage to EX stage register progression

- [ ] Execute stage FU integration.

  - [X] CSR unit

    - [X] CSR based exceptions

  - [ ] Branch unit

  - [ ] Load/Store unit

  - [ ] ALU

  - [ ] MDU

- [ ] Execute stage data writeback selection

  - [ ] Stop multiple writebacks in the same instruction.

## Verif

- [ ] RTL signal tracking from fetch to execute and retirement.

- [ ] riscv-formal wrapper.

