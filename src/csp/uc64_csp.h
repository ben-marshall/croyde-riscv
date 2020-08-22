
#include <stdint.h>

#ifndef __UC64_CSP_H__
#define __UC64_CSP_H__

#define UC64_STR_VALUE(arg)      #arg

//
// Timers and Counters
// ------------------------------------------------------------

uint64_t volatile * const uc64_csp_mtime    ;
uint64_t volatile * const uc64_csp_mtimecmp ;

inline volatile uint64_t uc64_csp_rd_mtime() {
    return *uc64_csp_mtime;
}

inline volatile uint64_t uc64_csp_rd_mtimecmp() {
    return *uc64_csp_mtimecmp;
}

inline void uc64_csp_wr_mtime(uint64_t new_value) {
    *uc64_csp_mtime = new_value;
}

inline void uc64_csp_wr_mtimecmp(uint64_t new_value) {
    *uc64_csp_mtimecmp = new_value;
}

inline          void     uc64_csp_wfi() {
    asm volatile("wfi");
}

inline uint64_t uc64_csp_rdtime() {
    uint64_t rd;
    asm volatile("rdtime %0":"=r"(rd):);
    return rd;
}

inline uint64_t uc64_csp_rdcycle() {
    uint64_t rd;
    asm volatile("rdcycle %0":"=r"(rd):);
    return rd;
}

inline uint64_t uc64_csp_rdinstret() {
    uint64_t rd;
    asm volatile("rdinstret %0":"=r"(rd):);
    return rd;
}


//
// PMP configuration
// ------------------------------------------------------------

//! Bitmask for pmp region "Readable" bit.
#define UC64_PMPCFG_R 0x01

//! Bitmask for pmp region "Writable" bit.
#define UC64_PMPCFG_W 0x02

//! Bitmask for pmp region "eXecutable" bit.
#define UC64_PMPCFG_X 0x04

//! Bitmask for pmp region "Locked" bit.
#define UC64_PMPCFG_L 0x80

//! Bitmask for pmp region "Address Match Mode" bit.
#define UC64_PMPCFG_A 0x60

//! The mode of a single pmp region
typedef enum {
    PMPCFG_OFF      = 0x00,
    PMPCFG_TOR      = 0x20,
    PMPCFG_NA4      = 0x40,
    PMPCFG_NAPOT    = 0x60
} uc64_pmpcfg_mode_t ;


//! Type of a pmpcfg CSR register.
typedef uint64_t uc64_pmpcfg_t;


//! Type of a single PMP region config. A uc64_pmpcfg contains 8 of these.
typedef uint8_t  uc64_pmpregion_t;


//! Get the current mode of a pmp region.
inline uc64_pmpcfg_mode_t uc64_get_pmpregion_mode (uc64_pmpregion_t p) {
    return (uc64_pmpcfg_mode_t)(p & UC64_PMPCFG_A);
}


//! Set the current mode of a pmp region.
inline uc64_pmpregion_t uc64_set_pmpregion_mode (
    uc64_pmpregion_t   r,
    uc64_pmpcfg_mode_t m
) {
    return ((r & ~(UC64_PMPCFG_A)) |  m);
}


#define  UC64_RD_PMP_ADDR(ADDR)                             \
inline volatile uint64_t      uc64_get_pmpaddr##ADDR() {    \
    uint64_t rd; asm volatile (                             \
        "csrr %0,pmpaddr" UC64_STR_VALUE(ADDR)              \
        : "=r"(rd)                                          \
        :                                                   \
    );                                                      \
    return rd;                                              \
}

#define  UC64_WR_PMP_ADDR(ADDR)                             \
inline volatile void uc64_set_pmpaddr##ADDR(uint64_t x) {   \
    asm volatile (                                          \
        "csrw pmpaddr"UC64_STR_VALUE(ADDR)", %0"            \
        :                                                   \
        : "r"(x)                                            \
    );                                                      \
}

#define  UC64_RD_PMP_CFG(CFG)                               \
inline volatile uc64_pmpcfg_t uc64_get_pmpcfg##CFG() {      \
    uc64_pmpcfg_t rd; asm volatile (                        \
        "csrr %0,pmpcfg" UC64_STR_VALUE(CFG)                \
        : "=r"(rd)                                          \
        :                                                   \
    );                                                      \
    return rd;                                              \
}

#define  UC64_WR_PMP_CFG(CFG)                               \
inline volatile void uc64_set_pmpcfg##CFG(uc64_pmpcfg_t x) {\
    asm volatile (                                          \
        "csrw pmpcfg"UC64_STR_VALUE(CFG)", %0"              \
        :                                                   \
        : "r"(x)                                            \
    );                                                      \
}


UC64_RD_PMP_CFG( 0)
UC64_RD_PMP_CFG( 2)

UC64_WR_PMP_CFG( 0)
UC64_WR_PMP_CFG( 2)

UC64_RD_PMP_ADDR( 0)
UC64_RD_PMP_ADDR( 1)
UC64_RD_PMP_ADDR( 2)
UC64_RD_PMP_ADDR( 3)
UC64_RD_PMP_ADDR( 4)
UC64_RD_PMP_ADDR( 5)
UC64_RD_PMP_ADDR( 6)
UC64_RD_PMP_ADDR( 7)
UC64_RD_PMP_ADDR( 8)
UC64_RD_PMP_ADDR( 9)
UC64_RD_PMP_ADDR(10)
UC64_RD_PMP_ADDR(11)
UC64_RD_PMP_ADDR(12)
UC64_RD_PMP_ADDR(13)
UC64_RD_PMP_ADDR(14)
UC64_RD_PMP_ADDR(15)

UC64_WR_PMP_ADDR( 0)
UC64_WR_PMP_ADDR( 1)
UC64_WR_PMP_ADDR( 2)
UC64_WR_PMP_ADDR( 3)
UC64_WR_PMP_ADDR( 4)
UC64_WR_PMP_ADDR( 5)
UC64_WR_PMP_ADDR( 6)
UC64_WR_PMP_ADDR( 7)
UC64_WR_PMP_ADDR( 8)
UC64_WR_PMP_ADDR( 9)
UC64_WR_PMP_ADDR(10)
UC64_WR_PMP_ADDR(11)
UC64_WR_PMP_ADDR(12)
UC64_WR_PMP_ADDR(13)
UC64_WR_PMP_ADDR(14)
UC64_WR_PMP_ADDR(15)


#endif

