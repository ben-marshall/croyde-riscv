
# Architectural Tests

This flow runs the official RISC-V
[Architectural Test Framework](https://github.com/riscv/riscv-compliance).
These tests try to check for the most common architectural functionality
and corner cases, and *must pass* in order for a design to be described
as properly supporting RISC-V.

*It is not a complete verification flow*.
It should only be used to make sure a change hasn't done something
catastrophic, and that we implement the bare minimum of functionality.

## Running the flow:

Run all of the architectural tests:
```
arch-test-all
```

Compile a particular test suite:
```
make arch-test-compile-croyde-C
make arch-test-compile-croyde-I
make arch-test-compile-croyde-M
```

Simulate and verify the correctness of a particular test suite:
```
make arch-test-verify-croyde-C
make arch-test-verify-croyde-I
make arch-test-verify-croyde-M
```

Clean up results and build artifacts:
```
make arch-test-clean
```

**Note:** The architectural tests all use the *core* level testbench.
This is to enable very large (in terms of memory) architectural tests
to run, without having to fit them into the fixed size CCX RAMs.

## Flow outputs:

Compilation output from building each test suite is placed in

- `/work/riscv-arch-test/croyde/rv64i_m/<SUITE NAME>`

Each of these folders contains all artifacts for each test in a suite.

This includes:

- `*.elf` - The compiled test file, usually per instruction.
- `*.elf.bin` - A binary version of the ELF file.
- `*.elf.srec` - An SREC version of the ELF file, used by the simulator.
- `*.elf.objdump` - Disassembly of the test.
- `*.elf.symbols` - Address and symbol name for every symbol in a test. Used
  to identify pass/fail/signature begin/end addresses for the testbench.
- `*.elf.vcd` - Output wavedump of the simulation.
- `*.signature.output` - Signature file, used to check the results.

## Relevant files.

- `extern/riscv-arch-tests` - This submodule is the upstream source of the
  architectural compliance tests.

- `flow/arch-test/Makefile.in` - The top level makefile for running and
  managing the flow. It acts as a wrapper around the makefile in the
  submodule.

- `flow/arch-test/croyde/` - Directory containing target (I.e. core being
  tested) implementations of boot code, assertion macros and linker
  scripts.

