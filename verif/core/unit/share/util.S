
.data

#define MMIO_BASE   0x00010000
#define MTIME       (MMIO_BASE + 0)
#define MTIMECMP    (MMIO_BASE + 8)

.text

.func   __rd_mtime
.global __rd_mtime
__rd_mtime:
    li a0, MTIME            // Base address of MTIME register
    ld a0, 0(a0)
    ret
.endfunc

.func   __rd_mtimecmp
.global __rd_mtimecmp
__rd_mtimecmp:
    li a0, MTIMECMP         // Base address of MTIMECMP register
    ld a0, 0(a0)
    ret
.endfunc

.func   __wr_mtimecmp
.global __wr_mtimecmp
__wr_mtimecmp:
    li a1, MTIMECMP         // Base address of MTIMECMP register
    sw a0, 0(a1)            // a0 = new mtimecmp value
    ret
.endfunc

.func   __rdcycle
.global __rdcycle
__rdcycle:
    rdcycle  a0
    ret
.endfunc

.func   __rdtime
.global __rdtime
__rdtime:
    rdtime  a0
    ret
.endfunc

.func   __rdinstret
.global __rdinstret
__rdinstret:
    rdinstret  a0
    ret
.endfunc


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

