
.data

.text

.extern handler_machine_timer

.balign 64
.func __handler_machine_timer
.global __handler_machine_timer
__handler_machine_timer:

    addi sp,sp,-(32*4)
    sw x1 ,4*1 (sp)
    sw x2 ,4*2 (sp)
    sw x3 ,4*3 (sp)
    sw x4 ,4*4 (sp)
    sw x5 ,4*5 (sp)
    sw x6 ,4*6 (sp)
    sw x7 ,4*7 (sp)
    sw x8 ,4*8 (sp)
    sw x9 ,4*9 (sp)
    sw x10,4*10(sp)
    sw x11,4*11(sp)
    sw x12,4*12(sp)
    sw x13,4*13(sp)
    sw x14,4*14(sp)
    sw x15,4*15(sp)
    sw x16,4*16(sp)
    sw x17,4*17(sp)
    sw x18,4*18(sp)
    sw x19,4*19(sp)
    sw x20,4*20(sp)
    sw x21,4*21(sp)
    sw x22,4*22(sp)
    sw x23,4*23(sp)
    sw x24,4*24(sp)
    sw x25,4*25(sp)
    sw x26,4*26(sp)
    sw x27,4*27(sp)
    sw x28,4*28(sp)
    sw x29,4*29(sp)
    sw x30,4*30(sp)
    sw x31,4*31(sp)

    jal handler_machine_timer
    
    lw x1 ,4*1 (sp)
    lw x2 ,4*2 (sp)
    lw x3 ,4*3 (sp)
    lw x4 ,4*4 (sp)
    lw x5 ,4*5 (sp)
    lw x6 ,4*6 (sp)
    lw x7 ,4*7 (sp)
    lw x8 ,4*8 (sp)
    lw x9 ,4*9 (sp)
    lw x10,4*10(sp)
    lw x11,4*11(sp)
    lw x12,4*12(sp)
    lw x13,4*13(sp)
    lw x14,4*14(sp)
    lw x15,4*15(sp)
    lw x16,4*16(sp)
    lw x17,4*17(sp)
    lw x18,4*18(sp)
    lw x19,4*19(sp)
    lw x20,4*20(sp)
    lw x21,4*21(sp)
    lw x22,4*22(sp)
    lw x23,4*23(sp)
    lw x24,4*24(sp)
    lw x25,4*25(sp)
    lw x26,4*26(sp)
    lw x27,4*27(sp)
    lw x28,4*28(sp)
    lw x29,4*29(sp)
    lw x30,4*30(sp)
    lw x31,4*31(sp)
    addi sp,sp,32*4

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
.balign 4; j __handler_machine_timer    // 07 - Machine Timer Interrupt
.balign 4; j test_fail                  // 08 - User External Interrupt
.balign 4; j test_fail                  // 09 - Supervisor External Interrupt
.balign 4; j test_fail                  // 10 - Reserved
.balign 4; j test_fail                  // 11 - Machine External Interrupt
.balign 4; j test_fail                  // 12 - Reserved
.balign 4; j test_fail                  // 13 - Reserved
.balign 4; j test_fail                  // 14 - Reserved
.balign 4; j test_fail                  // 15 - Reserved
.balign 4; j test_fail                  // 16 - NMI


