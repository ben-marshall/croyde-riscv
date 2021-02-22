
#include "croyde_csp.h"
#include "unit_test.h"

//! Place we go when any traps occur.
extern void test_trap_handler();

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

    if(was_interrupt && !expect_interrupt) {__putstr("A\n"); test_fail();}
    if(was_exception && !expect_exception) {__putstr("B\n"); test_fail();}
    if(cause         !=  expect_cause    ) {__putstr("C\n"); test_fail();}

    trap_handler_seen = expect_code;

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
    disable_mtie        = 0;

    uint64_t mepc_pre   = rd_mepc();
    
    // Setup timer interrupt for a short time in the future.
    uint64_t  delay     = 500;
    uint64_t  mtime     = croyde_csp_rd_mtime();
    croyde_csp_wr_mtimecmp(mtime + delay);

    // Read number of instructions retired.
    uint64_t iret_pre   = croyde_csp_rdinstret();
    uint64_t time_pre   = croyde_csp_rdtime   ();
    
    // Go to sleep here waiting for an interrupt.
    __wfi();

    // Wake up again and check instructions retired.
    uint64_t iret_post  = croyde_csp_rdinstret();
    uint64_t time_post  = croyde_csp_rdtime   ();
    uint64_t mepc_post  = rd_mepc();

    uint64_t iret_total = iret_post - iret_pre;
    uint64_t time_total = time_post - time_pre;

    // Check we didn't trap.
    if(trap_handler_seen == expect_code){
        __putstr("D\n");
        test_fail();
    }

    // Check mepc did not change.
    if(mepc_pre != mepc_post) {
        __putstr("E\n");
        test_fail();
    }

    // Check very few instructions were retired.
    if(iret_total        >   5) {
        __putstr("F\n");
        test_fail();
    }

    // Check elapsed cycles is about what we expect.
    if(time_total        >  delay) {
        __putstr("G\n");
        test_fail();
    }

    // Clean up - put mtimecmp back to something enormous.
    croyde_csp_wr_mtimecmp(-1);

    return 0;
}


/*
@detail
- Enabled timer interrupts.
- Sets up a timer interrupt for 50 ticks into the future.
- Executes a WFI instruction.
- Checks that instret counter has only incremented very slightly, indicating
  that the core halted.
- Check that we did trap* on the interrupt. only that the core woke
  up and resumed execution.
*/
int test_wfi_interrupts_enabled() {

    // Disable interrupts.
    clr_mstatus (MSTATUS_MIE);
    clr_mie     (MIE_MTIE   );

    // Enable timer interrupts and global interrupts only.
    set_mie     (MIE_MTIE   );
    set_mstatus (MSTATUS_MIE);

    // Get old mtvec value to restore after the test.
    uint64_t mtvec_pre  = rd_mtvec();

    // Set trap handler address.
    wr_mtvec((uint64_t)&test_trap_handler);

    // Setup expectations for an interrupt.
    expect_exception    = 0;
    expect_interrupt    = 1;
    expect_cause        = MCAUSE_MACHINE_TIMER_INTERRUPT;
    expect_code         = 200;
    disable_mtie        = 1;

    uint64_t mepc_pre   = rd_mepc();
    
    // Setup timer interrupt for a short time in the future.
    uint64_t  delay     = 500;
    uint64_t  mtime     = croyde_csp_rd_mtime();
    croyde_csp_wr_mtimecmp(mtime + delay);

    // Read number of instructions retired.
    uint64_t iret_pre   = croyde_csp_rdinstret();
    uint64_t time_pre   = croyde_csp_rdtime   ();
    
    // Go to sleep here waiting for an interrupt.
    __wfi();

    // Wake up again and check instructions retired.
    uint64_t iret_post  = croyde_csp_rdinstret();
    uint64_t time_post  = croyde_csp_rdtime   ();
    uint64_t mepc_post  = rd_mepc();

    uint64_t iret_total = iret_post - iret_pre;
    uint64_t time_total = time_post - time_pre;

    // Check trapped
    if(trap_handler_seen != expect_code){test_fail();}

    // Check mepc changed.
    if(mepc_pre == mepc_post) {test_fail();}

    // Check very few instructions were retired.
    if(iret_total        >  100) {__putstr("X\n");test_fail();}

    // Check elapsed cycles is about what we expect.
    if(time_total        <  100) {__putstr("Y\n");test_fail();}

    // Clean up - put mtimecmp back to something enormous.
    croyde_csp_wr_mtimecmp(-1);
    
    // Disable interrupts.
    clr_mstatus (MSTATUS_MIE);
    clr_mie     (MIE_MTIE   );

    // Set old mtvec value again
    wr_mtvec(mtvec_pre);

    return 0;
}

int test_main() {

    test_wfi_interrupts_disabled();
    
    test_wfi_interrupts_enabled();

    return 0;

}
