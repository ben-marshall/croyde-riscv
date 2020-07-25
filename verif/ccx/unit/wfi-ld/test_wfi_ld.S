
.text

.func   test_trap_handler
.global test_trap_handler
.balign 4
test_trap_handler:

    call c_trap_handler

    mret

.endfunc


.func   do_wfi_load
.global do_wfi_load
do_wfi_load:
    wfi
    ld  a0, 0(a0)
    ret
.endfunc

