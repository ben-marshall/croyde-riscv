
# Energy Efficiency

*A guide to the various energy efficiency optimisations used by the core.*

---

## Clock gating


Clock gating is used aggressivley to avoid clocking registers whos
values do not need to change.
The separate clock signals are listed below, along with the part of the
core they are requested by.


Clock Signal | Usage
-------------|--------------------------------------------------
`fclk`       | Global free-running clock, used for in-core timers.
`gclk`       | Global gated clock, used by default in the core.
`gclk_rf_a`  | Register file group A gated clock. Argument registers.
`gclk_rf_t`  | Register file group T gated clock. Temporary registers.
`gclk_rf_s`  | Register file group S gated clock. Saved & Other registers.
`gclk_mdu`   | Multiplier gated clock.
`gclk_csr`   | CSR unit gated clock.


- Each `gclk*` clock signal has an associated `*_req` line:

  - When the `*_req` line is set, the clock *must* be delivered.

  - When the `*_req` line is low, the clock *may* be gated. The core
    cannot assume that just because `*_req` is low, the clock will not tick.


## Single Bit Sign Extension

- TBD

## Glitch Minimisation

- TBD

