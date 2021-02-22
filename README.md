
# Croyde RISC-V

*A 3-stage, 64-bit RISC-V rv64imck micro-controller.*
[![Build Status](https://www.travis-ci.com/ben-marshall/croyde-riscv.svg?branch=master)](https://www.travis-ci.com/ben-marshall/croyde-riscv)
[![Documentation Status](https://readthedocs.org/projects/croyde-riscv/badge/?version=latest)](https://croyde-riscv.readthedocs.io/en/latest/?badge=latest)

---

- [Getting Started](#Getting-Started)
- [Block Diagram](#Block-Diagram)
- [Documentaton](docs/)
- [FAQ](#FAQ)

## Features & Block Diagram

This is a very simple 3-stage 64-bit micro-controller, implementing the
`rv64imc` instruction set.
It comes as a *core* module, and a *core complex* (CCX), which wraps the
core with timers, boot ROM, some RAM and other small peripherals, with
a memory port to the outside world.

The full 

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
   git checkout https://github.com/ben-marshall/croyde-riscv.git
   cd croyde-riscv/
   git submodule update --init --recursive
  ```

- Setup the project workspace:
  ```sh
  source bin/conf.sh
  ```

- [Synthesise the core](docs/flows-synthesis.md) using Yosys
  [Yosys](http://www.clifford.at/yosys/documentation.html).

- Verify the core using the 
  [riscv-formal](docs/flows-riscv-formal.md)
  framework.

- Run the RISC-V
  [architectural compliance tests](docs/flows-arch-tests.md).

- Run the [confidence tests](docs/flows-unit-tests.md) set.


## FAQ

- 

