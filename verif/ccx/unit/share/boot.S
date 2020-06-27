
.section .text.fsbl

//
// FSBL - First executed instruction.
// ------------------------------------------------------------

.global __fsbl_boot
__fsbl_boot:
    li   x1, 0
                            // Setup stack pointer. Provided by linker script.
    la   sp, __fsbl_stack_start
    li   x3, 0
    li   x4, 0
    li   x5, 0
    li   x6, 0
    li   x7, 0
    li   x8, 0
    li   x9, 0
    li  x10, 0
    li  x11, 0
    li  x12, 0
    li  x13, 0
    li  x14, 0
    li  x15, 0
    li  x16, 0
    li  x17, 0
    li  x18, 0
    li  x19, 0
    li  x20, 0
    li  x21, 0
    li  x22, 0
    li  x23, 0
    li  x24, 0
    li  x25, 0
    li  x26, 0
    li  x27, 0
    li  x28, 0
    li  x29, 0
    li  x30, 0
    li  x31, 0

                            // Disable interrupts
    csrci   mstatus , 0xF   // Clear mie, sie, uie
    csrw    mie     , zero  // Clear all timer/external/software int enable.

    la      t0      , __fsbl_trap_vector
    csrw    mtvec   , t0    // Set un-handled trap vectors.

    csrw    mscratch, 0     // Clear scratch register.
    csrw    mtval   , 0     // Clear mtval.

    j       __ram_begin     // Jump to first address in RAM.

//
// FSBL trap handler
// ------------------------------------------------------------

.balign 4
.global __fsbl_trap_vector
__fsbl_trap_vector:         // Un-handled trap.
    wfi                     // Slow pause loop.
    j __fsbl_trap_vector    // Loop forever.

