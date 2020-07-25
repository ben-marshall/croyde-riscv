
#include "uc64_csp.h"
#include "unit_test.h"

#include "test_interrupts.h"

volatile int interrupt_seen = 0;

//! Used to communicate status codes between mtvec trap handler and test code.
volatile char mtvec_test_code = 0;

//! Vectored interrupt table.
extern void vector_interrupt_table();

//! Handler for mtvec related exceptions - aligned to 64b boundary.
extern void mtvec_trap_handler_aligned();

//! Handler for mtvec related exceptions - aligned to 64b boundary.
extern void mtvec_trap_handler_unaligned;
    
int trigger_timer_interrupt(volatile int * interrupt_seen, int delay) {

    // Add a big value to mtime and set mtimecmp to this.
    uc64_csp_mtimecmp[0] = uc64_csp_mtime[0] + delay;

    // Re-enable interrupts.
    __set_mstatus(MSTATUS_MIE);

    int spins = 0;

    for(int i = 0; i < 200; i ++) {
        // Spin round doing nothing, waiting to see the interrupt.
        if(*interrupt_seen) {
            break;
        }
        spins ++;
    }

    // Disable timer interrupts.
    __clr_mie(MIE_MTIE);
    
    // Globally Disable interrupts again.
    __clr_mstatus(MSTATUS_MIE);

    return spins;
}

//! Check that we can cause a timer interrupt.
int test_timer_interupt() {

    // Globally Disable interrupts
    __clr_mstatus(MSTATUS_MIE);

    // Disable all other interrupt sources.
    __clr_mie(MIE_MEIE | MIE_MSIE);

    // Enable timer interrupts.
    __set_mie(MIE_MTIE);

    // Setup the interrupt handler vector.
    setup_timer_interrupt_handler(
        &interrupt_seen
    );

    int spins = trigger_timer_interrupt(&interrupt_seen, 400);

    __putstr("- Spins: "); __puthex32(spins); __putchar('\n');

    if(interrupt_seen) {
        return 0;
    } else {
        return 1;
    }
}


/*!
@brief Test for interrupt control.
*/
int test_main() {

    int fail;

    __putstr("Test Timer Interrupt...\n");
    fail = test_timer_interupt();
    if(fail){return fail;}

    return 0;
}
