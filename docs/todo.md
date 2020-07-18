
# Todo List

---

## RTL

- [ ] ALU

  - [ ] SLTU[.w] optimisation / reuse adder circuit

- [ ] PMP Implementation

- [ ] Trace

- [ ] Debug

- [ ] Performance Optmisations

  - [ ] `c.add`, `c.ld/w/h/b[u]` fusion.

- [ ] Timing Optimisations

  - CFU `target_addr`, `target_lhs`, `alu_lhs` path.

- [ ] Energy Optimisations

  - [ ] High halves of operand registers.

  - [ ] Register file sign extension bits.

- [ ] CCX: Re-arrange interconnect so that arbiters are connected
           directly to core interfaces, so only one router and
           one arbiter is needed, rather than 4 arbiters and two routers.

- [ ] User mode

## Verif

- [ ] csrw mcycle
- [ ] csrw minstret

- [ ] Re-enable pc_fwd riscv-formal check
- [ ] Re-enable liveness riscv-formal check

- [ ] Clean up the unit tests.

  - [ ] Single point of origin for `__mtime*` addresses.

  - [ ] Stop re-defining macros.

- Unit tests for load/store/jump right after WFI
