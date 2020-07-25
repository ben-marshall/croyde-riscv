
.data


.func __rdmcountinhibit
.global __rdmcountinhibit
__rdmcountinhibit:
    csrr a0,mucounteren
                             // Toolchain doesnt recognise mcountinhibit
    ret
.endfunc

.func __wrmcountinhibit
.global __wrmcountinhibit
__wrmcountinhibit:
    csrrw a0,mucounteren, a0
                            // Toolchain doesnt recognise mcountinhibit
    ret
.endfunc

