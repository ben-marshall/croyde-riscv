
# Unit Tests

*A set of simple directed unit tests for particular features of the core.*

---

Each test:
- Runs the same boot sequence (found in `share/boot.S`) before jumping
  to the `test_main` function.
- The `test_main` function runs the test and returns `0` for success
  and non-zero for failure.
- Test source files are kept in `$FRV_HOME/verif/unit/<test name>/`
- For each test there exists a `Makefile.in` in it's source directory.
  - This adds things like build targets and source files.
