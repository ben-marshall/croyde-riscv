
# riscv-formal Flow

This flow is the principle way that instruction implementations
are verified.

It uses the [riscv-formal](https://github.com/SymbioticEDA/riscv-formal)
framework.

Note that this flow checks only user-level instruction behaviours.
It does not check privilidged architecture operations or interractions.

## Running the flow:

```
make riscv-formal-clean
make riscv-formal-prepare
make riscv-formal-run
```

By default the flow will run `$(nproc)` checks in parallel.
This can be tuned by specifying the `RV_FORMAL_NJOBS=X` makefile
parameter explicitly.

A single proof may be re-run with the following commands:

```
make riscv-formal-clean
make riscv-formal-prepare
sby -f work/riscv-formal/[proof name].sby
```

## Flow outputs:

- All flow outputs are placed in `work/riscv-formal`

- Each directory corresponds to the output of a single check.

## Relevant files:

- See `verif/riscv-formal` for project specific files.

- `rvfi_wrapper.sv` wraps the core and exposes the formal verification
  interface (`RVFI`) signals.
  It also instantiates any fairness assumption blocks.

- `rvfi_fairness.sv` contains assumptions which make the
  formal engines "play fair`.
  These include maximum stall lengths and constrains on how the
  externally driven memory interface signals behave.

