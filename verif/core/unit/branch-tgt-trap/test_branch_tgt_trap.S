
.extern c_trap_handler

.balign 4
.global test_trap_handler
.func   test_trap_handler
test_trap_handler:

    addi    sp, sp, -32
    sd      ra, 0(sp)
    sd      s0, 8(sp)
    sd      s1,16(sp)
    sd      s2,24(sp)

    call c_trap_handler

    // Increment mepc
    csrr    s0, mepc        // Read current epc value

    lbu     s1, 0(s0)       // Load least significant byte of instruction.
    li      s2, 0b11        // Create mask
    andi    s1, s0, 0b11    // get two LSBs of instruction word

    addi    s0, s0, 2       // Always add at-least 2 to jump over C instr.
    bne     s1, s2, .dont_add_extra_2
    addi    s0, s0, 2       // Add extra 2 if it was a 4-byte instr.

.dont_add_extra_2:
    csrw    mepc, s0        // Replace updated mepc.
    
    ld      ra, 0(sp)
    ld      s0, 8(sp)
    ld      s1,16(sp)
    ld      s2,24(sp)
    addi    sp, sp,  32

    mret

.endfunc

