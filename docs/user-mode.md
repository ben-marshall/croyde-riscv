
# User Mode

*Notes on the implementation of user mode within the core.*

---

## User Level Register listing

**Note:** These registers are only implemented for the `N` extension.
They are not yet implemented within the core.

Address | Name      | Description
--------|-----------|------------------
0x000   |`ustatus  `| User status register
0x004   |`uie      `| User Interrupt enable register
0x005   |`utvec    `| User trap vector register
0x040   |`uscratch `| User Scratch register
0x041   |`uepc     `| User Exception program counter
0x042   |`ucause   `| User cause
0x043   |`utval    `| User trap value
0x044   |`uip      `| User Interrupt Pending

## Relevant Machine-Mode Registers

## mstatus

- `mpp` field, bits `12:11`.
- Stores previous privilidge level

> 3.1.6.1 - When a trap is taken from privilege mode y into privilege mode x,
> x PIE is set to the value of x IE; x IE is set to 0; and x PP is set to y.

> Interrupts for lower-privilege modes, `w<x`, are always globally disabled
> regardless of the setting of any global `w` IE bit for the lower-privilege
> mode. Interrupts for higher-privilege modes, `y>x`, are always globally
> enabled regardless of the setting of the global yIE bit for the
> higher-privilege mode.

- `uxl` - Set to RV64, hard wired to `2`

- `mprv` - Read/Writeable. If set, apply load/store address translation
   checks etc as though privilidge is `mpp`. Else, abide by checks
   in current privilidge mode.

   - Set to `0` when `mret` into u-mode is executed.

- `tw` - Timeout wait. If set, allow WFI to execute without invalid
   opcode exception in usermode for upto some time limit. Else, trigger trap.


## Verification

### Misc

- Interrupt in U-mode
- Traps in U-mode
  - Invalid opcode
  - ld access / align
  - st access / align
- Is the correct `mstatus.MPP` value set?
- Do we end up in user mode again after an MRET with the right `MPP`?

### `misa`

- Is the `U` bit set?
- Is it read-only?

### `mstatus`

- `mstatus.MPP` stores previous mode on trap/interrupt. 
  - Is `mstatus.MPP` read/writable given a CSR instruction?
  - Does `mstatus.MPP` only return leagal values when read?
  - Does `mstatus.MPP` cause a trap when an illegal value is written?
  - On an MRET:
    - Do we end up in the right privilidge mode based on `mstatus.MPP`.
    - Does the `mstatus.IE` bit take the right value given `mstatus.MPIE`?
- `mstatus.UXL` - should be hard-wired to indicate RV64.
- `mstatus.MPRV` modifies privilidge level memory acesses happen at.
  - If `0`, behave as normal.
  - If `1`, behave as if current mode is the one in `mstatus.MPP`.
  - Load/store with `mstatus.MPRV` set/clear to ROM/RAM.
  - On an MRET:
    - If new mode is less privilidged than M, does `mstatus.MPRV` get cleared?
- `mstatus.TW` - Timeout wait to trap WFI in user mode.
  - Does `WFI` trap into M-mode when `mstatus.TW=1`?
    - Check we get an illegal opcode exception.
  - Does `WFI` *not* trap into M-mode when `mstatus.TW=0`.

### `medeleg`, `mideleg`

Interrupt and trap handler delegation registers.

- All hard-wired to zero, since we don't support the `N` extension *yet*.
- After a trap or interrupt, we should *always* be in M-mode.

### `time`, `cycle`, `instret`

- If `mcounteren.[IR/TM/CY]` is zero, and the corresponding register is
  read in user mode, do we get an illegal opcode exception?

