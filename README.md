
# uc64

*A 3-stage, 64-bit RISC-V rv64imc micro-controller.*

---

This is a very simple 3-stage 64-bit micro-controller, implementing the
`rv64imc` instruction set.

![Pipeline Diagram](docs/pipeline-diagram.png)

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

## Documentation 

- See the [Documentation](docs/) in `docs/`.
  - [Functional Requirements](docs/functional-requirements.md)
  - [Instruction Listing](docs/instruction-listing.md)
  - [Memory interfaces](docs/memory-interface.md)
  - [Pipeline Structure](docs/pipeline.md)
  - [Project Organisation](docs/project-organisation.md)
- [Todo List](todo.md)

