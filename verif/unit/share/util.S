
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


.func __rd_mstatus
.global __rd_mstatus
__rd_mstatus:
    csrr a0, mstatus
    ret
.endfunc


.func __wr_mstatus
.global __wr_mstatus
__wr_mstatus:
    csrrw a0, mstatus, a0
    ret
.endfunc


.func __set_mstatus
.global __set_mstatus
__set_mstatus:
    csrs    mstatus, a0
    ret
.endfunc


.func __clr_mstatus
.global __clr_mstatus
__clr_mstatus:
    csrc    mstatus, a0
    ret
.endfunc


.func __rd_mie
.global __rd_mie
__rd_mie:
    csrr a0, mie
    ret
.endfunc


.func __wr_mie
.global __wr_mie
__wr_mie:
    csrrw a0, mie, a0
    ret
.endfunc


.func __set_mie
.global __set_mie
__set_mie:
    csrs    mie, a0
    ret
.endfunc


.func __clr_mie
.global __clr_mie
__clr_mie:
    csrc    mie, a0
    ret
.endfunc
