
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

  - [X] Internal reg bits to store current operating mode.

  - [X] `MPP` bit updating on a trap.

  - [X] `UXL` bits of `mstatus`

  - [X] `MPRV` bits of `mstatus`.
    
    - [X] Routing to load/store unit and eventually to PMP.

  - [X] `TW` bit of mstatus functionality. Timeout wait.

  - [X] Distinguish user mode accesses to CSRs

  - [ ] Verif designer assertions.

## Verif

- [ ] csrw mcycle
- [ ] csrw minstret
- [ ] Re-enable `pc_fwd` riscv-formal check
- [ ] Re-enable `liveness` riscv-formal check

