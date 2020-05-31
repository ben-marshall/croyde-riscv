
# Yosys Synthesis Flow

This flow is used to get a rough idea of the size of the core, and the
length of it's critical timing paths.

It does not target an actual technology, only the internal Yosys Cell
representation.

## Running the flow:

```
make synthesise-cmos
```

Make sure that you have sourced `bin/conf.sh` to set up the workspace.

## Flow outputs:

Flow results are place in `work/synthesise/`.

- `logic-loops.rpt` reports any combinatorial loops found in the design.

- `synth-cmos.rpt` contains longest topological path length and cell
  count results.

- `synth.log` contains the log of the entire synthesis run.

## Relevant files:

- See the `flow/synthesis/` directory.

- `Makefile.in` contains the make targets used to synthesis the core.

- `synth-cmos.tcl` is the script which drives Yosys to synthesis the core.
