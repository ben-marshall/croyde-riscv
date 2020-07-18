
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
    
    char * msg2= "Hello, Again!\n";
   

   for(int i = 0; msg[i]; i++) {
       uc64_bsp_putc_b(msg[i]);
   }
       
   uc64_csp_wr_mtimecmp(uc64_csp_rd_mtime() + 100000);
   uc64_csp_wfi();
   
   for(int i = 0; msg2[i]; i++) {
       uc64_bsp_putc_b(msg2[i]);
   }
       
   uc64_csp_wr_mtimecmp(-1);
   uc64_csp_wfi();
    
}
