
#include "uc64_csp.h"
#include "unit_test.h"

/*!
@brief Test reading of the standard performance counters/timers.
@note Assumes that all counters are reset to zero and do not roll over during
the test.
*/
int test_main() {

    // The counters are enabled
    uint32_t enabled = __rdmcountinhibit();
    
    if((enabled&0x7) != 0x0) {
        __wrmcountinhibit(0x0);
    }


    uint64_t a_cycle      = uc64_csp_rdcycle();
    uint64_t a_time       = uc64_csp_rdtime();
    uint64_t a_instret    = uc64_csp_rdinstret();

    uint64_t b_cycle      = uc64_csp_rdcycle();
    uint64_t b_time       = uc64_csp_rdtime();
    uint64_t b_instret    = uc64_csp_rdinstret();


    if(a_cycle >= b_cycle) {
        __putstr("Second reading of cycle should be larger\n");
        return 1;
    }

    if(a_time >= b_time) {
        __putstr("Second reading of time should be larger.\n");
        return 2;
    }

    if(a_instret >= b_instret) {
        __putstr("Second reading of instret should be larger.\n");
        return 3;
    }

    // Disable the cycle counter register
    __wrmcountinhibit(0x1);
    
    
    a_cycle      = uc64_csp_rdcycle();
    a_time       = uc64_csp_rdtime();
    a_instret    = uc64_csp_rdinstret();

    b_cycle      = uc64_csp_rdcycle();
    b_time       = uc64_csp_rdtime();
    b_instret    = uc64_csp_rdinstret();


    if(a_cycle != b_cycle) {
        __putstr("Cycle disabled, should be identical.\n");
        return 4;
    }

    if(a_time >= b_time) {
        __putstr("Second reading of time should be larger.\n");
        return 5;
    }

    if(a_instret >= b_instret) {
        __putstr("Second reading of instret should be larger.\n");
        return 6;
    }
    
    // re-enable the cycle register.
    __wrmcountinhibit(0x0);
    
    a_cycle      = uc64_csp_rdcycle();
    a_time       = uc64_csp_rdtime();
    a_instret    = uc64_csp_rdinstret();

    b_cycle      = uc64_csp_rdcycle();
    b_time       = uc64_csp_rdtime();
    b_instret    = uc64_csp_rdinstret();

    if(a_cycle >= b_cycle) {
        __putstr("Cycle enabled, first reading should be smaller.\n");
        return 7;
    }

    if(a_instret >= b_instret) {
        __putstr("Second reading of instret should be larger.\n");
        return 9;
    }
    
    // Disable the instr ret register, re-enable the time register.
    __wrmcountinhibit(0x4);
    
    a_cycle      = uc64_csp_rdcycle();
    a_time       = uc64_csp_rdtime();
    a_instret    = uc64_csp_rdinstret();

    b_cycle      = uc64_csp_rdcycle();
    b_time       = uc64_csp_rdtime();
    b_instret    = uc64_csp_rdinstret();

    if(a_cycle >= b_cycle) {
        __putstr("Cycle enabled, first reading should be smaller.\n");
        return 10;
    }

    if(a_time >= b_time) {
        __putstr("time register enabled . first reading should be smaller.\n");
        return 11;
    }

    if(a_instret != b_instret) {
        __putstr("instrret disabled, should not change.\n");
        return 12;
    }
    
    __wrmcountinhibit(0x0);

    return 0;

}
