
# Core Complex

*Describes the example core-complex for Croyde RISC-V. This module includes
 tightly integrated memories and trace/debug modules external to the
 core.*

---

## Overview

The core complex (CCX) contains:

- The micro-controller CPU.

- A single port, configurably sized RAM.

- A single port 1K ROM.

- An external bus port, with bridge modules for conversion between
  different standards.

Eventually, it will also contain debug and trace functionality.


## Interconnect

The table below shows how the CPU memory ports are mapped through the
interconnect to the RAM, ROM and external ports.

All ports have a 64-bit data bus.

Peripheral  | Base Address | Range        | CPU Data | CPU Instructions
------------|--------------|--------------|----------|------------------
ROM Port 0  |`0x0000000000`| 1K           |       x  | x
RAM Port 0  |`0x0000010000`| 4-64K        |       x  | x
Ext Port 0  |`0x0120000000`| 1GB          |       x  | x

- Accessing an un-mapped part of the address space will cause a
  `LDACCESS` or `STACCESS` exception.

- Trying to write to the ROM will cause an `STACCESS` exception.

