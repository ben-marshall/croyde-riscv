
# Embench

*Describes the Embench build simulation flow.*

---

## Embench Overview

- From the [Embench Website](https://embench.org/)

  ```
  Dhrystone and Coremark have been the defacto standard microcontroller
  benchmark suites for the last thirty years, but these benchmarks no longer
  reflect the needs of modern embedded systems. Embench™ was explicitly
  designed to meet the requirements of modern connected embedded systems. The
  benchmarks are relevant, portable, and well implemented. 
  ```

- The source code for the Embench suite is 
  [taken from Github](https://github.com/embench/embench-iot),
  and exists as a submodule to this repository under `extern/embench-iot`.


## Building Embench

- Make sure that the Embench submodule is checked out with the repository:

  ```
  git submodule update --init extern/embench-iot
  ```

- To build the Embench suite such that it will run inside the
  CCX testbench, run:

  ```
  make build-embench-binaries
  ```

  This runs the Embench build flow, with various parameters setting the
  correct architecture, linker script and compiler etc.

  Build artefacts will be placed in `work/embench/src/[BENCHMARK NAME]`.

  - **Note:** Embench benchmarks contain a `LOCAL_SCALE_FACTOR` preprocessor
    directive indicating how many times to run the benchmark.
    It takes *far* too long to run the benchmarks in simulation with
    the default values. During the build flow, a `sed` command
    replaces these values with `1`, which is enough for this core which
    has no caches or branch prediction.

    See the `build-embench-binaries' target in `flow/embench/Makefile.in`
    to see where this happens.

- After the vanilla Embench suite builds are complete, run:

  ```
  make build-embench-targets
  ```

  This creates disassembly files for each benchmark (for debugging)
  and Verilog hex files for loading into the simulator.

## Running Embench

- To run every Embench benchmark, run:

  ```
  make run-embench-targets
  ```

  This will run every benchmark inside the ccx level testbench.
  It can take a while.

  By default, the flow does not dump VCD files for the simulations
  (much too slow and large) but this can be added by running:

  ```
  make EMBENCH_WAVES=1 run-embench-targets
  ```

  The VCD wave file will appear in `work/embench/src/[BENCHMARK NAME]`.


- Individual benchmarks can be run using:

  ```
  make run-embench-[BENCHMARK NAME]
  ```

