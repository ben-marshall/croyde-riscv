
#include <stdint.h>

#include "unit_test.h"

#define DECL_RD_CSR(CSR) volatile inline uint64_t rd_##CSR() { \
    uint64_t rd; asm volatile ("csrr %0, " #CSR : "=r"(rd)); return rd; \
}

#define DECL_WR_CSR(CSR) volatile inline void wr_##CSR(uint64_t rs1) { \
    asm volatile ("csrw " #CSR ", %0" : : "r"(rs1));   \
}

DECL_RD_CSR(mepc)
DECL_RD_CSR(mcause)
DECL_RD_CSR(mtvec)
DECL_WR_CSR(mtvec)

// Flag set/cleared by c_trap_handler.
int test_passed = 0;

// Address we will jump to.
int tgt_addr    = 0;

// Declaration for mtvec target address.
extern void test_trap_handler();

void c_trap_handler()  {

    int64_t mcause = (int64_t)rd_mcause();
    int64_t mepc   = (int64_t)rd_mepc  ();

    if(mcause < 0) {
        // This test should not deal with any interrupts.
        test_fail();
    }

    __putstr("mcause: "); __puthex8 (mcause); __putchar('\n');
    __putstr("mepc  : "); __puthex64(mepc); __putchar('\n');

    if(mepc != 0) {
        // MEPC should be zero, since this is the faulting address that
        // we jumped too.
        test_fail();
    }

    if(mcause == CAUSE_CODE_IACCESS) {
        // Pass immediately, since we cannot recover from this
        // kind of trap. mepc is written with the target of the
        // jump, rather than the instruction which caused the jump.
        test_pass();
    } else {
        test_fail();
    }
    
    return;
}

int test_main() {

    // Set MTVEC to the trap handler.
    wr_mtvec((uint64_t)(&test_trap_handler));

    // Jump to a non-existant physical address. 0 in this case.
    asm ("jr %0" : : "r"(tgt_addr));

    // Check we saw the exception handler only once.
    if(test_passed == 1) {
        test_pass();
    } else {
        test_fail();
    }

    return 0;

}
