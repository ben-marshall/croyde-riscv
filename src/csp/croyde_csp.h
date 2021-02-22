
#include <stdint.h>

#ifndef __UC64_CSP_H__
#define __UC64_CSP_H__

uint64_t volatile * const croyde_csp_mtime    ;
uint64_t volatile * const croyde_csp_mtimecmp ;

inline volatile uint64_t croyde_csp_rd_mtime() {
    return *croyde_csp_mtime;
}

inline volatile uint64_t croyde_csp_rd_mtimecmp() {
    return *croyde_csp_mtimecmp;
}

inline void croyde_csp_wr_mtime(uint64_t new_value) {
    *croyde_csp_mtime = new_value;
}

inline void croyde_csp_wr_mtimecmp(uint64_t new_value) {
    *croyde_csp_mtimecmp = new_value;
}

inline          void     croyde_csp_wfi() {
    asm volatile("wfi");
}

inline uint64_t croyde_csp_rdtime() {
    uint64_t rd;
    asm volatile("rdtime %0":"=r"(rd):);
    return rd;
}

inline uint64_t croyde_csp_rdcycle() {
    uint64_t rd;
    asm volatile("rdcycle %0":"=r"(rd):);
    return rd;
}

inline uint64_t croyde_csp_rdinstret() {
    uint64_t rd;
    asm volatile("rdinstret %0":"=r"(rd):);
    return rd;
}

#endif

