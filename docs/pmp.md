
# Physical Memory Protection

*Details the implementation of the Physical Memory Protection mechanism
 described in section 3.6 of the Privilidged ISA manual.*

---

## Integration

- The PMPs exist inside the `core_top` module.

- A configurable number of regions can be instantiated by altering
  the `PMP_NUM_REGIONS` parameter.

  - Setting `PMP_NUM_REGIONS=0` will disable the PMP regions altogether.

  - By default, `16` regions are instanced.

- All data and instruction accesses pass through the PMPs.

  - A request is stopped from leaving the core if a trap is
    detected.

  - A trapped request simply has it's `req` line gated by the PMP
    check, and it's `error` response line asserted by the PMP block.


## Test cases

These are simple *smoke test* cases.
They do not cover the full range of behaviours of the PMPs, and are
not a substitute for proper verification.

- `pmpcfg*`

  - Are the R/W/X fields readable / writable?
    
    - Cross with `L` bit being set.
  
  - Which `A` fields can be set?
    
    - Cross with `L` bit being set.

- `pmpaddr*`

  - Can we read/write `pmpaddrI` value?

    - Cross with `pmpcfgI.L` being set.

    - Cross with `pmpcfg(I+1).L` being set, with `pmpcfg(I+1).A=TOR`.

- In User mode:

  - For each active region, try to:
  
    - Read

    - Write

    - Execute

  - Check that given the region properties, we got the expected
    results.

  - Can we do a partial access of a region? E.g. take a 4-byte
    region, and do a double-word access over it?

- In machine mode:

  - Are the checks only applied when the `L` bit of the `cfg` register
    is set?

  - "If no entry matches an M-mode access, the access succeeds. If
     no entry matches an S/U-mode access, the access fails."

- CSR Access:

  - Since we are in RV64 - does accessing `pmpcfg1/3/5...` correctly
    cause a trap?

  - Does an access to the pmp registers in Umode cause a trap?

  - 
