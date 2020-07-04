
# Unit Test Flow

This flow contains simple sanity checks for specific pieces of
functionality.

*It is not a complete verification flow*.
It is only used to make sure a change hasn't done something
catastrophic.

The unit tests are split into two main catagories:

- The `core` unit tests use the `core`-level testbench, and are designed
  to probe features contained *within* the CPU core only.

- The Core Complex (`ccx`) tests use the `ccx`-level testbench, which
  instantiates the core with some embedded SRAM, a ROM and a simple
  interconnect. These tests probe interractions within the CCX like
  memory mappings, bus errors and external memory port accesses.

## Running the flow:

Build all of the unit tests:
```
make build-unit-tests-core  # Build all core level tests.
make build-unit-tests-ccx   # "     "   ccx  "     "
```

Run all of the unit tests:
```
make run-unit-tests-core    # Run all core level tests.
make run-unit-tests-ccx     # "   "   ccx  "     "
```

Build/run a specific test:
```
make build-unit-core-[TEST NAME]
make build-unit-ccx-[TEST NAME]
make run-unit-core-[TEST NAME]
make run-unit-ccx-[TEST NAME]
```

## Flow outputs:

Outputs from each unit test simulation are put in

- `work/core/unit/[test name]` for core-level tests.
- `work/ccx/unit/[test name]` for ccx-level tests.

Each such directory contains:

- A `.vcd` wave dump file.

- The `.elf` file corresponding to the unit test program.

- A disassembly of the `.elf` file.

- A `.srec` of the `.elf` file. This is the format used to load
  the program into the simulator memory.

- A `.gtlwl` file. This is derived from the disassembly, and can be
  used by GTKWave's translation function to display disassembled
  instructions in the wave form viewer.

## Relevant files.

- `verif/share/unit` - Contains Makefile and common code infrastructure
  used across the core and ccx unit tests.

- `verif/core/unit`- Contains all unit tests for the core.

  - `verif/core/unit/share` - shared core level test code.

  - Each test lives in its own sub-directory.

- `verif/core/unit`- Contains all unit tests for the ccx .

  - `verif/ccx/unit/share` - shared ccx level test code.
  
  - Each test lives in its own sub-directory.

