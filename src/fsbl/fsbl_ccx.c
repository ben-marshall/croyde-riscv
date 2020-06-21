
#include <stdint.h>

/*!
@brief First stage boot loader main function.
*/
void
__attribute__((__noreturn__))
__fsbl_main() {

    while(1) {
        asm volatile ("nop");
    }
    
}
