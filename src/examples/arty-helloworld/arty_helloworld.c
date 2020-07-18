
#include <stdint.h>

#include "uc64_csp.h"
#include "uc64_bsp.h"

/*!
@brief First stage boot loader main function.
*/
void
__attribute__((__noreturn__))
__fsbl_main() {

    char * msg = "Hello, World!\n";
    
    while(1) {
        for(int i = 0; msg[i]; i++) {
            uc64_bsp_putc_b(msg[i]);
            uint64_t mtime = uc64_csp_rd_mtime();
            uc64_csp_wr_mtimecmp(mtime + 10000);
            uc64_csp_wfi();
        }
    }
    
}
