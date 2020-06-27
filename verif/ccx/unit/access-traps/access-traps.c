

#include "unit_test.h"


extern void __access_traps_trap_handler();

// Provided by the linker script.
extern uint64_t __rom_begin   ;
extern uint64_t __rom_end     ;
extern uint64_t __ram_begin   ;
extern uint64_t __ram_end     ;

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
int test_data_range(
    volatile uint64_t * base    ,
    volatile uint64_t * top     ,
    int                readable,
    int                writeable
) {

    int sum = 0;

    uint64_t    old_mtvec = rd_mtvec();

    // Don't expect any traps while loading inside the range.
    // So set mtvec to test fail.
    wr_mtvec((uint64_t)&test_fail);
    
    sum += base[ 0];
    sum += top [-1];

    // Do expect a trap for these, so set to our custom trap handler.
    wr_mtvec((uint64_t)&__access_traps_trap_handler);

    trap_seen   = 0;
    expect_trap = 1;
    expect_cause= CAUSE_CODE_LDACCESS;

    // Bottom of range.
    sum += base[-1];

    if(trap_seen != 1) {
        test_fail();
    }
    
    trap_seen   = 0;
    expect_trap = 1;
    expect_cause= CAUSE_CODE_LDACCESS;

    // Top of range.
    sum += top [ 0];

    if(trap_seen != 1) {
        test_fail();
    }

    wr_mtvec (old_mtvec);

    return sum;
}


int test_main() {

    test_data_range(&__rom_begin, &__rom_end, 1, 0);
    //test_data_range(&__ram_begin, &__ram_end, 1, 1);
    test_pass();
    return 0;

}

