
#include "croyde_csp.h"
#include "unit_test.h"

#include "test_timer.h"

// Interrupt handler table.
extern void         vector_interrupt_table   ;

static volatile int interrupt_count     =   0;
const           int max_interrupt_count =   5;
const           int interrupt_period    = 400;


//! Called when a machine timer interrupt occurs.
void handler_machine_timer() {

    uint64_t mtime      = croyde_csp_rd_mtime()      ;
    uint64_t mtime_cmp  = croyde_csp_rd_mtimecmp()   ;

    interrupt_count ++;

     __puthex64(mtime);
     __putchar(' '); __puthex64(mtime_cmp); __putchar('\n');
    
    uint64_t mtime_cmpn = croyde_csp_rd_mtime() + interrupt_period;

    croyde_csp_wr_mtimecmp(mtime_cmpn);

    // Disable the machine timer interrupt.
    if(interrupt_count >= max_interrupt_count) {
        __clr_mie(MIE_MTIE);
    }

    return;
}


void start_machine_timer() {

    mtvec(&vector_interrupt_table, 1);

    uint64_t mtime      = croyde_csp_rd_mtime();
    uint64_t mtime_cmpn = mtime + interrupt_period;

    croyde_csp_wr_mtimecmp(mtime_cmpn);

    __set_mie(MIE_MTIE);
    __set_mstatus(MSTATUS_MIE);

}


/*!
@brief Test for timer interrupts.
*/
int test_main() {
    
    interrupt_count = 0;

    uint64_t counter = 0;

    start_machine_timer();

    while(interrupt_count < max_interrupt_count) {
        counter ++;
        if((counter & 0xFFF) == 0) {
            __putchar('#');
        }
    }

    return 0;
}
