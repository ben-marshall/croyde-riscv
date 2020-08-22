

#include "uc64_csp.h"
#include "unit_test.h"

int test_main() {

    uint64_t pmpaddr0_r;
    uint64_t pmpaddr0_w;

    //
    // Prelude - make sure region 0 is turned off.
    uc64_pmpcfg_t       pmpcfg0;
    uc64_pmpregion_t    pmpregion0 = uc64_set_pmpregion_mode(0, PMPCFG_OFF);
    pmpcfg0     |= pmpregion0;
    uc64_set_pmpcfg0(pmpcfg0);

    // Check 1 - Are any bits of pmpaddr writable/readable?
    pmpaddr0_r  = uc64_get_pmpaddr0();
    pmpaddr0_w  = 0xABCDEF01;
    uc64_set_pmpaddr0(pmpaddr0_w);
    pmpaddr0_r  = uc64_get_pmpaddr0();

    if(pmpaddr0_r != pmpaddr0_w) {
        __putstr("F1\n");
        test_fail();
    }
    
    // Check 2 - Are the right bits of pmpaddr writable/readable?

    pmpaddr0_w  = -1;
    uc64_set_pmpaddr0(pmpaddr0_w);
    pmpaddr0_r  = uc64_get_pmpaddr0();

    if(pmpaddr0_r != 0x7FFFFFFFFF) {
        __putstr("F2\n");
        test_fail();
    }

    return 0;

}
