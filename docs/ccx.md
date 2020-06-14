
# Core Complex

*Describes the example core-complex for uc64. This module includes
 tightly integrated memories and trace/debug modules external to the
 core.*

---

## Overview

The core complex (CCX) contains:

- The micro-controller CPU.

- A dual port, configurably sized RAM.

- A dual port 1K ROM.

- An external bus port, with bridge modules for conversion between
  different standards.

Eventually, it will also contain debug and trace functionality.


## Interconnect

The table below shows how the CPU memory ports are mapped through the
interconnect to the RAM, ROM and external ports.

All ports have a 64-bit data bus.

Peripheral  | Base Address | Range        | CPU Data | CPU Instructions
------------|--------------|--------------|----------|------------------
ROM Port 0  |`0x0000000000`| 1K           |       x  | 
ROM Port 1  |`0x0000000000`| 1K           |          | x
RAM Port 0  |`0x0000010000`| 4-64K        |       x  | 
RAM Port 1  |`0x0000010000`| 4-64K        |          | x
Ext Port 0  |`0x0100000000`| 4GB          |       x  | 
Ext Port 1  |`0x0100000000`| 4GB          |          | x


