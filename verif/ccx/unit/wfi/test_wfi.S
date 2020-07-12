
.text

.func   test_trap_handler
.global test_trap_handler
.balign 4
test_trap_handler:

    call c_trap_handler

    mret

.endfunc
