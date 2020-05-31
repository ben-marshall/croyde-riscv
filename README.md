
# uc64

*A 3-stage, 64-bit RISC-V rv64imc micro-controller.*
[![Build Status](https://travis-ci.org/ben-marshall/uc64.svg?branch=master)](https://travis-ci.org/ben-marshall/uc64)
[![Documentation Status](https://readthedocs.org/projects/uc64/badge/?version=latest)](https://uc64.readthedocs.io/en/latest/?badge=latest)

---

This is a very simple 3-stage 64-bit micro-controller, implementing the
`rv64imc` instruction set.

- [Getting Started](#Getting-Started)
- [Block Diagram](#Block-Diagram)
- [Documentaton](docs/)
- [Todo List](docs/todo.md)

## Block Diagram

![Block Diagram](docs/pipeline-diagram.png)

## Getting Started

- Required Dependencies:
  [Yosys](http://www.clifford.at/yosys/documentation.html),
  [Verilator](https://www.veripool.org/projects/verilator/wiki/Intro),
  [Boolector](https://boolector.github.io/),
  [Symbiyosys](https://symbiyosys.readthedocs.io/en/latest/)
  and a
  [RISC-V Toolchain](https://github.com/riscv/riscv-gnu-toolchain).

- Checkout the repository:
  ```sh
   git checkout https://github.com/ben-marshall/uc64.git
   cd uc64/
   git submodule update --init --recursive
  ```

- Setup the project workspace:
  ```sh
  source bin/conf.sh
  ```

- Synthesise the core using Yosys:
  ```
  make synthesise-cmos
  ```
  The results will be placed in `$REPO_WORK/synthesise`.


- Verify the core using the 
  [riscv-formal](https://github.com/SymbioticEDA/riscv-formal/)
  framework.

  ```sh
  make riscv-formal-clean
  make riscv-formal-prepare
  make riscv-formal-run RV_FORMAL_NJOBS=$(nproc)
  ```

- Run designer assertions on the internals of the core:

  ```
  make  design-assertions
  ```

- Run the unit tests set:

  ```
  make unit-tests-build
  make unit-tests-run
  ```

