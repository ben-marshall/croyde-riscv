
# Unit Test Flow

This flow contains simple sanity checks for specific pieces of
functionality.

*It is not a complete verification flow*.
It is only used to make sure a change hasn't done something
catastrophic.

## Running the flow:

Build all of the unit tests:
```
make unit-tests-build
```

Run all of the unit tests:
```
make unit-tests-run
```

Build/run a specific test:
```
make build-unit-[test name]
make run-unit-[test name]
```

## Flow outputs:

Outputs from each unit test simulation are put in
`work/unit/[test name]`.
Each such directory will contain:

- A `.vcd` wave dump file.

- The `.elf` file corresponding to the unit test program.

- A disassembly of the `.elf` file.

- A `.srec` of the `.elf` file. This is the format used to load
  the program into the simulator memory.

- A `.gtlwl` file. This is derived from the disassembly, and can be
  used by GTKWave's translation function to display disassembled
  instructions in the wave form viewer.

## Relevant files.

- See `verif/unit/`

- `Makefile.in` contains the top level make targets and macros.

- Each sub-directory contains a single test.

- The `share/` directory contains files used by multiple tests.

