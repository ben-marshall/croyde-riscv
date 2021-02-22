
#include <stdint.h>

#include "croyde_csp.h"
#include "croyde_bsp.h"

/*!
@brief First stage boot loader main function.
*/
void
__attribute__((__noreturn__))
__fsbl_main() {

    char * msg = "Hello, World!\n";
    
    char * msg2= "Hello, Again!\n";
   

   for(int i = 0; msg[i]; i++) {
       croyde_bsp_putc_b(msg[i]);
   }
       
   croyde_csp_wr_mtimecmp(croyde_csp_rd_mtime() + 100000);
   croyde_csp_wfi();
   
   for(int i = 0; msg2[i]; i++) {
       croyde_bsp_putc_b(msg2[i]);
   }
       
   croyde_csp_wr_mtimecmp(-1);
   croyde_csp_wfi();
    
}
