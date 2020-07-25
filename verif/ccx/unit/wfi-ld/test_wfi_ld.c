
#include "uc64_csp.h"
#include "unit_test.h"

//! Place we go when any traps occur.
extern void     test_trap_handler();
extern uint64_t do_wfi_load(uint64_t * addr);

uint64_t val_to_load= 0xdeadbeefbadf00d5;

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

    if(was_interrupt && !expect_interrupt) {test_fail();}
    if(was_exception && !expect_exception) {test_fail();}
    if(cause         !=  expect_cause    ) {test_fail();}

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
- Check that we loaded the expected value from memory.
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
    uint64_t  mtime     = uc64_csp_rd_mtime();
    uc64_csp_wr_mtimecmp(mtime + delay);

    // Read number of instructions retired.
    uint64_t iret_pre   = uc64_csp_rdinstret();
    uint64_t time_pre   = uc64_csp_rdtime   ();
    
    // Go to sleep here waiting for an interrupt.
    uint64_t loaded_value = do_wfi_load(&val_to_load);

    // Wake up again and check instructions retired.
    uint64_t iret_post  = uc64_csp_rdinstret();
    uint64_t time_post  = uc64_csp_rdtime   ();
    uint64_t mepc_post  = rd_mepc();

    uint64_t iret_total = iret_post - iret_pre;
    uint64_t time_total = time_post - time_pre;

    // Check we didn't trap.
    if(trap_handler_seen == expect_code){
        __putstr("A\n");
        test_fail();
    }

    // Check mepc did not change.
    if(mepc_pre != mepc_post) {
        __putstr("B\n");
        test_fail();
    }

    // Check very few instructions were retired.
    if(iret_total        >   25) {
        __putstr("C\n");
        test_fail();
    }

    // Check we loaded the right value.
    if(loaded_value != val_to_load){
        __putstr("E\n");
        test_fail();
    }

    // Clean up - put mtimecmp back to something enormous.
    uc64_csp_wr_mtimecmp(-1);

    return 0;
}


int test_main() {

    test_wfi_interrupts_disabled();

    return 0;

}
