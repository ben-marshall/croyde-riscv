

#include "unit_test.h"

//! Place we go when any traps occur.
extern void test_trap_handler();

int expect_cause    = 0;
int expect_exception= 0;
int expect_interrupt= 0;
int expect_code     = 0;

int trap_handler_seen = 0;

//! C-code trap handler, called by test_trap_handler
void c_trap_handler() {

    int mcause         = rd_mcause();
    int was_interrupt  = mcause <  0;
    int was_exception  = mcause >= 0;
    int cause          = mcause & 0x7FFFFFFFFFFFFFFFL;
    trap_handler_seen  = -1;

    if(was_interrupt && !expect_interrupt) {test_fail();}
    if(was_exception && !expect_exception) {test_fail();}
    if(cause         !=  expect_cause    ) {test_fail();}

    trap_handler_seen = expect_code;

    return;
}


/*
@detail
- Disables all interrupts: mie = mtie = 0
- Sets up a timer interrupt for 50 ticks into the future.
- Executes a WFI instruction.
- Checks that instret counter has only incremented very slightly, indicating
  that the core halted.
- Check that we *did not* trap on the interrupt. only that the core woke
  up and resumed execution.
*/
int test_wfi_interrupts_disabled() {

    // Disable interrupts.
    clr_mstatus(MSTATUS_MIE);
    clr_mie    (MIE_MTIE   );

    // Setup expectations for an interrupt.
    expect_exception    = 0;
    expect_interrupt    = 0;
    expect_cause        = 0;
    expect_code         = 100;
    
    // Setup timer interrupt for a short time in the future.
    uint64_t  delay     = 100;
    uint64_t  mtime     = __rd_mtime();
    __wr_mtimecmp(mtime + delay);

    // Read number of instructions retired.
    uint64_t iret_pre   = __rdinstret();
    uint64_t time_pre   = __rdtime   ();
    
    // Go to sleep here waiting for an interrupt.
    __wfi();

    // Wake up again and check instructions retired.
    uint64_t iret_post  = __rdinstret();
    uint64_t time_post  = __rdtime   ();

    uint64_t iret_total = iret_post - iret_pre;
    uint64_t time_total = time_post - time_pre;

    // Check we didn't trap.
    if(trap_handler_seen == expect_code){test_fail();}

    // Check very few instructions were retired.
    if(iret_total        >   20) {test_fail();}

    // Check elapsed cycles is about what we expect.
    if(time_total        <  100) {test_fail();}

    // Clean up - put mtimecmp back to something enormous.
    __wr_mtimecmp(-1);

    return 0;
}

int test_main() {

    test_wfi_interrupts_disabled();

    return 0;

}
