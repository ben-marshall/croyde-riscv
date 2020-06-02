
#include <stdint.h>

#include "unit_test.h"

#define DECL_RD_CSR(CSR) volatile inline uint64_t rd_##CSR() { \
    uint64_t rd; asm volatile ("csrr %0, " #CSR : "=r"(rd)); return rd; \
}

#define DECL_WR_CSR(CSR) volatile inline void wr_##CSR(uint64_t rs1) { \
    asm volatile ("csrw " #CSR ", %0" : : "r"(rs1));   \
}

DECL_RD_CSR(mcause)
DECL_RD_CSR(mtvec)
DECL_WR_CSR(mtvec)

__attribute__((noreturn))
__attribute__((aligned(4)))
void trap_handler()  {

    int64_t mcause = (int64_t)rd_mcause();

    if(mcause < 0) {
        // This test should not deal with any interrupts.
        test_fail();
    }

    __putstr("mcause: "); __puthex8(mcause); __putchar('\n');
    
    // Return from m-mode exception.
    asm ("mret");
}

int test_main() {

    // Set MTVEC to the trap handler.
    void * trap_handler_addr = &trap_handler;
    wr_mtvec((uint64_t)trap_handler_addr);

    return 0;

}
