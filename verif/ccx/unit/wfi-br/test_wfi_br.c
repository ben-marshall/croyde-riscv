

#include "unit_test.h"

//! Place we go when any traps occur.
extern void test_trap_handler();
extern void do_wfi_br();

int expect_cause    = 0;
int expect_exception= 0;
int expect_interrupt= 0;
int expect_code     = 0;

// Should the trap handler disable machine timer interrupts?
int disable_mtie    = 0;

int trap_handler_seen = 0;

//! C-code trap handler, called by test_trap_handler
void c_trap_handler() {

    int64_t mcause         = rd_mcause();
    int64_t was_interrupt  = mcause <  0;
    int64_t was_exception  = mcause >= 0;
    int64_t cause          = mcause & 0x7FFFFFFFFFFFFFFFL;
    trap_handler_seen  = -1;

    if(was_interrupt && !expect_interrupt) {__putstr("C\n"); test_fail();}
    if(was_exception && !expect_exception) {__putstr("D\n"); test_fail();}
    if(cause         !=  expect_cause    ) {__putstr("E\n"); test_fail();}
    
    trap_handler_seen = expect_code;
    
    __wr_mtimecmp(-1);

    if(disable_mtie) {
        clr_mie(MIE_MTIE);
    }

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
- Check that the store succeeded, and did not occur before the WFI retired.
*/
int test_wfi_interrupts_enabled() {

    // Disable interrupts.
    set_mstatus(MSTATUS_MIE);
    set_mie    (MIE_MTIE   );

    // Setup expectations for an interrupt.
    expect_exception    = 0;
    expect_interrupt    = 1;
    expect_cause        = MCAUSE_MACHINE_TIMER_INTERRUPT;
    expect_code         = 100;
    disable_mtie        = 0;
    
    // Get old mtvec value to restore after the test.
    uint64_t mtvec_pre  = rd_mtvec();

    // Set trap handler address.
    wr_mtvec((uint64_t)&test_trap_handler);

    uint64_t mepc_pre   = rd_mepc();
    
    // Setup timer interrupt for a short time in the future.
    uint64_t  delay     = 500;
    uint64_t  mtime     = __rd_mtime();
    __wr_mtimecmp(mtime + delay);

    // Read number of instructions retired.
    uint64_t iret_pre   = __rdinstret();
    uint64_t time_pre   = __rdtime   ();
    
    // Go to sleep here waiting for an interrupt.
    do_wfi_br();

    // Wake up again and check instructions retired.
    uint64_t iret_post  = __rdinstret();
    uint64_t time_post  = __rdtime   ();
    uint64_t mepc_post  = rd_mepc();

    uint64_t iret_total = iret_post - iret_pre;
    uint64_t time_total = time_post - time_pre;

    // Check we trapped.
    if(trap_handler_seen != expect_code){
        __putstr("A\n");
        test_fail();
    }

    // Clean up - put mtimecmp back to something enormous.
    __wr_mtimecmp(-1);
    
    // Set old mtvec value again
    wr_mtvec(mtvec_pre);

    return 0;
}


int test_main() {

    test_wfi_interrupts_enabled();

    return 0;

}
