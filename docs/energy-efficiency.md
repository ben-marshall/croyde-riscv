
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
`f_clk`      | Global free-running clock, used for in-core timers.
`g_clk`      | Global gated clock, used by default in the core.
`g_clk_rf`   | Register file gated clock.
`g_clk_mul`  | Multiplier gated clock.

- The core level `g_clk_*` is derived from the `f_clk`.

- Each `g_clk*` clock signal has an associated `*_req` line:

  - When the `*_req` line is set, the clock *must* be delivered.

  - When the `*_req` line is low, the clock *may* be gated. The core
    cannot assume that just because `*_req` is low, the clock will not tick.

The `g_clk` signals are derived from `f_clk`:

```
             ----[Clk Gate]-----> g_clk
             |    ^
             |    |- g_clk_req
             |
             |
--> f_clk ---|---[Clk Gate]-----> g_clk_rf
             |    ^
             |    |- g_clk_rf_req
             |
             |
             ----[Clk Gate]-----> g_clk_mul
                  ^
                  |- g_clk_rf_req
```

## Single Bit Sign Extension

- TBD

## Glitch Minimisation

- TBD

