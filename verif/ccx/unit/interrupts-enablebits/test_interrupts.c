
#include "croyde_csp.h"
#include "unit_test.h"

#include "test_interrupts.h"

volatile int interrupt_seen = 0;

//! Check interrupts can be enabled / disabled globally.
int test_global_interrupt_enable() {

    // Make sure mtimecmp is at it's maximum value.
    croyde_csp_mtimecmp[0] = 0xFFFFFFFFFFFFFFFF;
    
    uint64_t mstatus    = __rd_mstatus();

    uint64_t mie= mstatus & MSTATUS_MIE;
    uint64_t sie= mstatus & MSTATUS_SIE;
    uint64_t uie= mstatus & MSTATUS_UIE;

    // U/S mode not implemented. uie/sie should never be set.
    if(sie) {test_fail();}
    if(uie) {test_fail();}

    // Writes should be ignored to UIE / SIE
    __set_mstatus(MSTATUS_SIE | MSTATUS_UIE);
    
    mstatus     = __rd_mstatus();
    sie         = mstatus & MSTATUS_SIE;
    uie         = mstatus & MSTATUS_UIE;

    if(sie) {test_fail(); }
    if(uie) {test_fail(); }
    
    // Clear MIE bit. No interrupts enabled.
    __clr_mstatus(MSTATUS_MIE);

    mstatus     = __rd_mstatus();
    mie         = mstatus & MSTATUS_MIE;

    // MIE should be zero now.
    if(mie) {test_fail();}

    // Set MIE bit.
    __set_mstatus(MSTATUS_MIE);

    mstatus     = __rd_mstatus();
    mie         = mstatus & MSTATUS_MIE;

    // MIE should be set now.
    if(!mie){test_fail();}

    // Leave interrupts disabled.
    __clr_mstatus(MSTATUS_MIE);

    return 0;
}

//! Check external/software/timer interrupts can be enabled/disabled
int test_individual_interrupt_enable() {
    
    // Start by clearing all interrupt enable bits.
    __clr_mstatus(MSTATUS_MIE | MSTATUS_SIE | MSTATUS_UIE);
    __clr_mie(MIE_MEIE | MIE_MTIE | MIE_MSIE);

    // Check they are all zeroe'd appropriately
    uint64_t mstatus = __rd_mstatus();
    uint64_t mie     = __rd_mie();

    if(mstatus & MSTATUS_MIE){test_fail();}
    if(mstatus & MSTATUS_SIE){test_fail();}
    if(mstatus & MSTATUS_UIE){test_fail();}
    
    if(mie     & MIE_MEIE){test_fail();}
    if(mie     & MIE_MTIE){test_fail();}
    if(mie     & MIE_MSIE){test_fail();}

    // Check we can enable them one by one.

    // External interrupts
    __set_mie(MIE_MEIE);
    mie     = __rd_mie();
    if(!(mie & MIE_MEIE)){test_fail();}
    __clr_mie(MIE_MEIE);

    __putchar('.');

    // Software interrupts
    __set_mie(MIE_MSIE);
    mie     = __rd_mie();
    if(!(mie & MIE_MSIE)){test_fail();}
    __clr_mie(MIE_MSIE);
    
    __putchar('.');

    // Timer interrupts
    __set_mie(MIE_MTIE);
    mie     = __rd_mie();
    if(!(mie & MIE_MTIE)){test_fail();}
    __clr_mie(MIE_MTIE);
    __putchar('.');
    __putchar('\n');

    return 0;

}
    

//! Used to communicate status codes between mtvec trap handler and test code.
volatile char mtvec_test_code = 0;

//! Vectored interrupt table.
extern void vector_interrupt_table();

//! Handler for mtvec related exceptions - aligned to 64b boundary.
extern void mtvec_trap_handler_aligned();

//! Handler for mtvec related exceptions - aligned to 64b boundary.
extern void mtvec_trap_handler_unaligned();


//! Check that mtvec can be set correctly wrt. vectored/direct interrupts.
int test_mtvec_fields() {

    uint64_t save   = 0;
    mtvec_test_code = 0; // No traps taken.

    //
    // Set to direct interrupt mode, handler = mtvec_trap_handler.
    save = mtvec(&mtvec_trap_handler_unaligned, 0);
    if(mtvec_test_code != 0){return 1;} // Expect not to have trapped.
    
    //
    // Set to vectored interrupt mode, handler = mtvec_trap_handler.
    mtvec(&mtvec_trap_handler_aligned, 1);
    if(mtvec_test_code != 0){return 2;} // Expect not to have trapped.
    
    //
    // Set to invalid interrupt mode, handler = mtvec_trap_handler.
    mtvec_test_code = 0;
    mtvec(&mtvec_trap_handler_unaligned, 2);
    if(mtvec_test_code != 1){return 3;} // Expect to have trapped.
    mtvec_test_code = 0;

    //
    // Set to invalid interrupt mode, handler = mtvec_trap_handler.
    mtvec_test_code = 0;
    mtvec(&mtvec_trap_handler_unaligned, 3);
    if(mtvec_test_code != 1){return 4;} // Expect to have trapped.
    
    // Restore the original trap handler before returning.
    mtvec((void*)save,0);
    
    return 0;
}



/*!
@brief Test for interrupt control.
*/
int test_main() {

    int fail;

    __putstr("Test Global Interrupt Enable...\n");
    fail = test_global_interrupt_enable();
    if(fail){return fail;}


    __putstr("Test Individual Interrupt Enable...\n");
    fail = test_individual_interrupt_enable();
    if(fail){return fail;}


    __putstr("Test MTVEC Fields...\n");
    fail = test_mtvec_fields();
    if(fail){return fail;}

    return 0;
}
