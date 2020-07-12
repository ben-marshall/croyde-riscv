
.data

.extern interrupt_seen
.extern __mtime
.extern __mtimecmp

.text

.func mtvec_trap_handler_aligned
.global mtvec_trap_handler_aligned
mtvec_trap_handler_aligned:

    addi sp,sp,-48
    sd t0, 0(sp)
    sd t1, 8(sp)
    sd t2,16(sp)
    sd t3,24(sp)
    sd t4,32(sp)
    
    la t0, mtvec_test_code
    li t1, 1
    sb t1, 0(t0)
    
    la t0, interrupt_seen
    li t1, 1
    sb t1, 0(t0)

    csrr t0, mepc       // Increment mepc by 4.
    addi t0, t0, 4
    csrw mepc, t0
    
    la t3, 0x20008      // Set mtime cmp to something enormous.
    li t4, -1
    sd t4, 0(t3)
    
    ld t0, 0(sp)
    ld t1, 8(sp)
    ld t2,16(sp)
    ld t3,24(sp)
    ld t4,32(sp)
    addi sp,sp,48

    mret
.endfunc


.extern test_fail
.extern test_pass

.balign 128
.global vector_interrupt_table
vector_interrupt_table:
.balign 4; j test_fail                  // 00 - User SW interrupt / exception
.balign 4; j test_fail                  // 01 - Supervisor SW interrupt
.balign 4; j test_fail                  // 02 - Reserved
.balign 4; j test_fail                  // 03 - Machine SW interrupt
.balign 4; j test_fail                  // 04 - User Timer Interrupt
.balign 4; j test_fail                  // 05 - Supervisor Timer Interrupt
.balign 4; j test_fail                  // 06 - Reserved
.balign 4; j mtvec_trap_handler_aligned // 07 - Machine Timer Interrupt
.balign 4; j test_fail                  // 08 - User External Interrupt
.balign 4; j test_fail                  // 09 - Supervisor External Interrupt
.balign 4; j test_fail                  // 10 - Reserved
.balign 4; j test_fail                  // 11 - Machine External Interrupt
.balign 4; j test_fail                  // 12 - Reserved
.balign 4; j test_fail                  // 13 - Reserved
.balign 4; j test_fail                  // 14 - Reserved
.balign 4; j test_fail                  // 15 - Reserved
.balign 4; j test_fail                  // 16 - NMI


