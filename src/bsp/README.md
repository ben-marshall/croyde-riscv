
# Board Support Package

*Information on the Board Support Package (BSP) for accessing peripherals.*

---

- The BSP provides simple hooks for accessing onboard peripherals.

- Anything using the BSP simply includes `croyde_bsp.h`.

- Each SoC must implement `croyde_bsp_<soc name>.c`

