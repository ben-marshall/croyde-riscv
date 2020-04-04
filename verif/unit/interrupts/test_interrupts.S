
.data

.balign 4
original_mtvec: .word 0x0
int_seen_addr:  .word 0x0

.extern interrupt_seen

.text

.func setup_timer_interrupt_handler
.global setup_timer_interrupt_handler
setup_timer_interrupt_handler:

    la t0, int_seen_addr
    la t1, timer_interrupt_handler
    la t2, original_mtvec
    
    sw a0,0(t0)         // int_seen_addr <- indicator address

    csrrw t1, mtvec, t1 // mtvec <- timer_interrupt_handler, t1 <- mtvec
    sw t1, 0(t2)        // original_mtvec <- t1=mtvec

    ret
.endfunc


.balign 4
.func timer_interrupt_handler
.global timer_interrupt_handler
timer_interrupt_handler:

    addi sp,sp,-32
    sw t0, 4(sp)
    sw t1, 8(sp)
    sw t2,12(sp)
    sw t3,16(sp)
    sw t4,20(sp)

    la t0, int_seen_addr
    lw t0, 0(t0)

    la t1, original_mtvec
    lw t1, 0(t1)

    li t2, 0x1
    sw t2,0(t0)         // int_seen_addr <- 1

    csrw mtvec, t1

    csrr t3, mcause     // Check mcause == 7, with MSB bit set.
    li   t4, 0x8000000000000007
    bne  t3, t4, test_fail

    li t3, 0x00001008   // Set mtime cmp to something enormous.
    li t4, -1
    sw t4, 0(t3)
    sw t4, 4(t3)
    
    lw t0, 4(sp)
    lw t1, 8(sp)
    lw t2,12(sp)
    lw t3,16(sp)
    lw t4,20(sp)
    addi sp,sp,32

    mret
.endfunc

.extern mtvec_test_code

.balign 4
.func mtvec_trap_handler_unaligned
.global mtvec_trap_handler_unaligned
mtvec_trap_handler_unaligned:

    addi sp,sp,-32
    sw t0, 4(sp)
    sw t1, 8(sp)
    sw t2,12(sp)
    sw t3,16(sp)
    sw t4,20(sp)

    la t0, mtvec_test_code
    li t1, 1
    sb t1, 0(t0)
    
    la t0, interrupt_seen
    li t1, 1
    sw t1, 0(t0)
    
    li t3, 0x00001008   // Set mtime cmp to something enormous.
    li t4, -1
    sw t4, 0(t3)
    sw t4, 4(t3)

    lw t0, 4(sp)
    lw t1, 8(sp)
    lw t2,12(sp)
    lw t3,16(sp)
    lw t4,20(sp)
    addi sp,sp,32

    mret
.endfunc


.balign 128
.func mtvec_trap_handler_aligned
.global mtvec_trap_handler_aligned
mtvec_trap_handler_aligned:

    addi sp,sp,-32
    sw t0, 4(sp)
    sw t1, 8(sp)
    sw t2,12(sp)
    sw t3,16(sp)
    sw t4,20(sp)
    
    la t0, mtvec_test_code
    li t1, 1
    sb t1, 0(t0)
    
    la t0, interrupt_seen
    li t1, 1
    sw t1, 0(t0)

    csrr t0, mepc       // Increment mepc by 4.
    addi t0, t0, 4
    csrw mepc, t0
    
    li t3, 0x00001008   // Set mtime cmp to something enormous.
    li t4, -1
    sw t4, 0(t3)
    sw t4, 4(t3)
    
    lw t0, 4(sp)
    lw t1, 8(sp)
    lw t2,12(sp)
    lw t3,16(sp)
    lw t4,20(sp)
    addi sp,sp,32

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


