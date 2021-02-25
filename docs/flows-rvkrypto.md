
# rvkrypto-fips flow

The core implements the RISC-V scalar cryptography extensions.
Part of the validation for this is being able to run the most important
algorithms that the extension tries to accelerate.
Namely: AES(-GCM), SHA256, SHA512, SHA3, SM3 and SM4.

The `extern/rvkrypto-fips` submodule 
(from [here](https://github.com/rvkrypto/rvkrypto-fips))
contains a small battery of test vectors, and implementations of each
algorithm.

## Relevant files

- `src/rvkrypto/Makefile.in` contains the build and run orchestration.

- `extern/rvkrypto-fips` is the submodule containing all of the test
  framework source code.

## Checkout

- Make sure you have the submodule checked out:

```
git submodule update --init extern/rvkrypto-fips
```

## Building

- Note that you will need a toolchain which supports the RISC-V scalar
  cryptography extension to do this. An experimental one can be
  obtained [here](https://github.com/riscv/riscv-crypto).

- From the root directory of the core repository (`$REPO_HOME`), run
  
```
make rvkrypto-build
```

- This will place the build artifacts in `$REPO_WORK/rvkrypto`, and also
  build the core complex testbench for the core, and place a *copy* of
  the testbench in `$REPO_WORK/rvkrypto`.

- Note the `.gtkwl` file can be used for GTKWave signal annotations on
  the decoded instructions.

## Running

- From the root directory of the core repository (`$REPO_HOME`), run
  
```
make rvkrypto-run
```

- This will run the built program, and output `SIM_PASS` if all of the
  test vectors passed, or `SIM_FAIL` if not.
  Verbose output for each passing/failing test vector is disabled.

- If wavedumping is required, uncomment the `+WAVES=` line at the bottom of
  `src/rvkrypto/Makefile.in`.

