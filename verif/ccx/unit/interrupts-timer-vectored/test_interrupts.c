

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

    __putstr("Triggering interrupt...\n");

    // Add a big value to mtime and set mtimecmp to this.
    __mtimecmp[0] = __mtime[0] + delay;

    // Re-enable interrupts.
    __set_mstatus(MSTATUS_MIE);

    int spins = 0;

    for(int i = 0; i < 200; i ++) {
        // Spin round doing nothing, waiting to see the interrupt.
        if(*interrupt_seen) {
            __putstr("Seen\n");
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


int test_vectored_timer_interrupt() {
    uint64_t save   = 0;
    
    //
    // Set to vectored interrupt mode, handler = vector_interrupt_table.
    save = mtvec(&vector_interrupt_table, 1);
    
    // Globally Disable interrupts
    __clr_mstatus(MSTATUS_MIE);

    // Disable all other interrupt sources.
    __clr_mie(MIE_MEIE | MIE_MSIE);

    // Enable timer interrupts.
    __set_mie(MIE_MTIE);

    // Enable timer interrupts.
    __set_mie(MIE_MTIE);

    int spins = trigger_timer_interrupt(&interrupt_seen, 400);

    // Restore the original trap handler before returning.
    mtvec((void*)save, 0);

    if(interrupt_seen) {
        __putstr("Seen int\n");
        __puthex32(spins); __putchar('\n');
        return 0;
    } else {
        __putstr("- Never saw expected interrupt.\n");
        return 1;
    }
}


/*!
@brief Test for interrupt control.
*/
int test_main() {

    int fail;

    __putstr("Test Vectored Timer Interrupt...\n");
    fail = test_vectored_timer_interrupt();
    if(fail){
        __putstr("Failed\n");
        return fail;
    } else {
        __putstr("Pass\n");
    }

    return 0;
}
