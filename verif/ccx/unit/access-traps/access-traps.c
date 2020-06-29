

#include "unit_test.h"


extern void __access_traps_trap_handler();

// Provided by the linker script.
extern uint64_t __rom_begin   ;
extern uint64_t __rom_end     ;
extern uint64_t __ram_begin   ;
extern uint64_t __ram_end     ;
extern uint64_t __ext_begin   ;
extern uint64_t __ext_end     ;

//
// Control fields for test_trap_handler
int             expect_trap     =   0;
int             expect_cause    =   0;
int             step_over       =   1;
volatile int    trap_seen       =   0;

void test_trap_handler() {

    if(expect_trap == 0){ 
        __putstr("Unexpected trap.\n");
        test_fail();
    }

    int cause = rd_mcause();

    if(cause < 0) {
        __putstr("Unexpected interrupt\n");
        test_fail();
    }

    if(cause != expect_cause) {
        __putstr("Unexpected cause code\n");
        test_fail();
    }

    if(step_over) {
        // Step over the faulting instruction.
        uint64_t mepc = rd_mepc();
        uint8_t  ib   = ((uint8_t*)mepc)[0];
        mepc         += 2;
        if((ib & 0x3) == 0x3) {
            mepc += 2;
        }
        wr_mepc(mepc);
    }

    expect_trap = 0;
    expect_cause= 0;
    trap_seen  += 1;

    return;
}

/*!
@brief Perform several memory accesses to just inside/outside the
       supplied ranges and check we get the expected errors.
*/
int test_address (
    volatile uint64_t* addr    ,
    int                readable,
    int                writeable
) {

    int sum = 0;

    uint64_t    old_mtvec = rd_mtvec();

    if (readable) {

        // Don't expect any traps while loading inside the range.
        // So set mtvec to test fail.
        wr_mtvec((uint64_t)&test_fail);
        
        expect_trap =  0;
        expect_cause= -1;

    } else {

        // Do expect a trap for these, so set to our custom trap handler.
        wr_mtvec((uint64_t)&__access_traps_trap_handler);

        expect_trap = 1;
        expect_cause= CAUSE_CODE_LDACCESS;

    }
    
    // Perform the access
    sum += addr[0];

    if(readable) {
        
        // Do nothing

    } else {
        
        // If we didn't trap but expected to, then fail.
        if(trap_seen != 1) {
            test_fail();
        }

    }
    
    trap_seen = 0;

    // Restore original trap handler address.
    wr_mtvec (old_mtvec);

    return sum;
}


int test_main() {

    //           Address            , R,  W
    test_address(&__rom_begin       , 1 , 0);
    test_address(&__rom_begin - 1   , 0 , 0);

    test_address(&__rom_end         , 0 , 0);
    test_address(&__rom_end   - 1   , 1 , 0);
    
    test_address(&__ram_begin       , 1 , 1);
    test_address(&__ram_begin - 1   , 0 , 0);

    // RAM end address is base of MMIO region, so should be readable.
    test_address(&__ram_end         , 1 , 1);
    test_address(&__ram_end   - 1   , 1 , 0);
    
    test_address(&__ext_begin       , 1 , 1);
    test_address(&__ext_begin - 1   , 0 , 0);

    test_address(&__ext_end         , 0 , 0);
    test_address(&__ext_end   - 1   , 1 , 1);

    test_pass();
    return 0;

}

