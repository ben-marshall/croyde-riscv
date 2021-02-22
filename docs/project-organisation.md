
# Project Organisation

*How the project is organised, and what each directory contains*.

---

## Top level files and directories

- `README.md`
    Top level readme for the project.

- `Makefile`
    Top level makefile through which all design and verification flows are
    run.

- `mkdocs.yml`
    [MkDocs](https://www.mkdocs.org/)
    configuration file.
    Used by
    [readthedocs](https://readthedocs.org/)
    to generate
    [project documentation](https://croyde-riscv.readthedocs.io/en/latest/).

- `.travis.yml`
    [Travis CI](https://travis-ci.org/)
    configuration file.
    Used to coordinate the 
    [continuous integration flows](https://www.travis-ci.com/github/ben-marshall/croyde-riscv).

- `bin/`
    Miscellaneous project scripts.
    Contains the workspace setup script.

- `docs/`
    All project documentation.

- `extern/`
    External submodules and repositories.

- `flow/`
    Scripts and Makefiles for running design and verification flows.

- `rtl/`
    All synthesisable hardware description files live in this directory.

- `verif/`
    All verification flow code lives in here.
    This includes the formal verification wrapper files, and the
    software unit tests.

- `work/`
    This is the *build* directory.
    It contains the outputs of simulation, synthesis and verification
    flows.

