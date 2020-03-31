
#include "unit_test.h"

/*!
@brief Test reading of the standard performance counters/timers.
@note Assumes that all counters are reset to zero and do not roll over during
the test.
*/
int test_main() {


    // We should be able to read/write mtimecmp
    uint64_t new_mtimecmp_value = 0xABCD000012340000;
    __mtimecmp[0] = new_mtimecmp_value;

    if(__rd_mtimecmp() != new_mtimecmp_value) {
        return 6;
    }

    for(int i = 0; i < 10; i ++) {

        new_mtimecmp_value = __rd_mtime() * 20;

        __mtimecmp[0] = new_mtimecmp_value;
    
        if(__rd_mtimecmp() != new_mtimecmp_value) {
            return 7;
        }
    }

    __mtimecmp[0] = -1;

    // We should be able to read/write mtime
    uint64_t new_mtime_value = 0xF000000000000000;

    __mtime[0] = new_mtime_value;
    
    uint64_t nxt_mtime_value = __rd_mtime() - new_mtime_value;

    if(nxt_mtime_value > new_mtimecmp_value) {
        return 8;
    }

    return 0;

}
