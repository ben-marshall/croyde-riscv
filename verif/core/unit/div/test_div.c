
#include <stdint.h>

#include "unit_test.h"

#define INSTR_INLINE(INSTR)                                                 \
    volatile inline uint64_t INSTR(int64_t rs1, int64_t rs2) {              \
        uint64_t rd;                                                        \
        asm volatile(#INSTR " %0, %1, %2" : "=r"(rd) : "r"(rs1), "r"(rs2)); \
        return  rd;                                                         \
    }

//
// 32-bit instructions.
INSTR_INLINE(divw  )
INSTR_INLINE(divuw )
INSTR_INLINE(remw  )
INSTR_INLINE(remuw )

//
// 64-bit instructions.
INSTR_INLINE(div   )
INSTR_INLINE(divu  )
INSTR_INLINE(rem   )
INSTR_INLINE(remu  )

#define CHECK_IS(FN, EXP, rs1, rs2) {                           \
    uint64_t grm    = EXP;                                      \
    uint64_t dut    = FN(rs1,rs2);                              \
    if(grm  !=   dut){                                          \
        __putstr("RS1   : "); __puthex64(rs1); __putchar('\n'); \
        __putstr("RS2   : "); __puthex64(rs2); __putchar('\n'); \
        __putstr("Expect: "); __puthex64(grm); __putchar('\n'); \
        __putstr("Got   : "); __puthex64(dut); __putchar('\n'); \
        test_fail();                                            \
    }                                                           \
}


int test_divw() {

    //
    //       func, expected          , rs1       , rs2
    CHECK_IS(divw ,0xffffffffffffffff, 0x0       , 0x0       )
    CHECK_IS(divw ,0                 , 0x0       , 0x1       )
    CHECK_IS(divw ,0                 , 0x0       , -0x1      )
    CHECK_IS(divw ,0                 , 0x0       , 0x7fffffff)
    CHECK_IS(divw ,0                 , 0x0       , 0x80000000)

    CHECK_IS(divw ,0xffffffffffffffff, 0x1       , 0x0       )
    CHECK_IS(divw ,0x0000000000000001, 0x1       , 0x1       )
    CHECK_IS(divw ,0xffffffffffffffff, 0x1       , -0x1      )
    CHECK_IS(divw ,0                 , 0x1       , 0x7fffffff)
    CHECK_IS(divw ,0                 , 0x1       , 0x80000000)

    CHECK_IS(divw ,0xffffffffffffffff, -0x1      , 0x0       )
    CHECK_IS(divw ,0xffffffffffffffff, -0x1      , 0x1       )
    CHECK_IS(divw ,0x0000000000000001, -0x1      , -0x1      )
    CHECK_IS(divw ,0                 , -0x1      , 0x7fffffff)
    CHECK_IS(divw ,0                 , -0x1      , 0x80000000)

    CHECK_IS(divw ,0xffffffffffffffff, 0x7fffffff, 0x0       )
    CHECK_IS(divw ,0x000000007fffffff, 0x7fffffff, 0x1       )
    CHECK_IS(divw ,0xffffffff80000001, 0x7fffffff, -0x1      )
    CHECK_IS(divw ,0x0000000000000001, 0x7fffffff, 0x7fffffff)
    CHECK_IS(divw ,0                 , 0x7fffffff, 0x80000000)

    CHECK_IS(divw ,0xffffffffffffffff, 0x80000000, 0x0       )
    CHECK_IS(divw ,0xffffffff80000000, 0x80000000, 0x1       )
    CHECK_IS(divw ,0xffffffff80000000, 0x80000000, -0x1      )
    CHECK_IS(divw ,0xffffffffffffffff, 0x80000000, 0x7fffffff)
    CHECK_IS(divw ,0x0000000000000001, 0x80000000, 0x80000000)

    return 0;

}

int test_divuw (){

    //
    //       func, expected          , rs1       , rs2
    CHECK_IS(divuw, 0xffffffffffffffff, 0x0       , 0x0       )
    CHECK_IS(divuw, 0                 , 0x0       , 0x1       )
    CHECK_IS(divuw, 0                 , 0x0       , -0x1      )
    CHECK_IS(divuw, 0                 , 0x0       , 0x7fffffff)
    CHECK_IS(divuw, 0                 , 0x0       , 0x80000000)

    CHECK_IS(divuw, 0xffffffffffffffff, 0x1       , 0x0       )
    CHECK_IS(divuw, 0x0000000000000001, 0x1       , 0x1       )
    CHECK_IS(divuw, 0                 , 0x1       , -0x1      )
    CHECK_IS(divuw, 0                 , 0x1       , 0x7fffffff)
    CHECK_IS(divuw, 0                 , 0x1       , 0x80000000)

    CHECK_IS(divuw, 0xffffffffffffffff, -0x1      , 0x0       )
    CHECK_IS(divuw, 0xffffffffffffffff, -0x1      , 0x1       )
    CHECK_IS(divuw, 0x0000000000000001, -0x1      , -0x1      )
    CHECK_IS(divuw, 0x0000000000000002, -0x1      , 0x7fffffff)
    CHECK_IS(divuw, 0x0000000000000001, -0x1      , 0x80000000)

    CHECK_IS(divuw, 0xffffffffffffffff, 0x7fffffff, 0x0       )
    CHECK_IS(divuw, 0x000000007fffffff, 0x7fffffff, 0x1       )
    CHECK_IS(divuw, 0                 , 0x7fffffff, -0x1      )
    CHECK_IS(divuw, 0x0000000000000001, 0x7fffffff, 0x7fffffff)
    CHECK_IS(divuw, 0                 , 0x7fffffff, 0x80000000)

    CHECK_IS(divuw, 0xffffffffffffffff, 0x80000000, 0x0       )
    CHECK_IS(divuw, 0xffffffff80000000, 0x80000000, 0x1       )
    CHECK_IS(divuw, 0                 , 0x80000000, -0x1      )
    CHECK_IS(divuw, 0x0000000000000001, 0x80000000, 0x7fffffff)
    CHECK_IS(divuw, 0x0000000000000001, 0x80000000, 0x80000000)

    return 0;
}


int test_remw (){

    //
    //       func, expected          , rs1       , rs2
    CHECK_IS(remw, 0                 , 0x0       , 0x0       )
    CHECK_IS(remw, 0                 , 0x0       , 0x1       )
    CHECK_IS(remw, 0                 , 0x0       , -0x1      )
    CHECK_IS(remw, 0                 , 0x0       , 0x7fffffff)
    CHECK_IS(remw, 0                 , 0x0       , 0x80000000)

    CHECK_IS(remw, 0x0000000000000001, 0x1       , 0x0       )
    CHECK_IS(remw, 0                 , 0x1       , 0x1       )
    CHECK_IS(remw, 0                 , 0x1       , -0x1      )
    CHECK_IS(remw, 0x0000000000000001, 0x1       , 0x7fffffff)
    CHECK_IS(remw, 0x0000000000000001, 0x1       , 0x80000000)

    CHECK_IS(remw, 0xffffffffffffffff, -0x1      , 0x0       )
    CHECK_IS(remw, 0                 , -0x1      , 0x1       )
    CHECK_IS(remw, 0                 , -0x1      , -0x1      )
    CHECK_IS(remw, 0xffffffffffffffff, -0x1      , 0x7fffffff)
    CHECK_IS(remw, 0xffffffffffffffff, -0x1      , 0x80000000)

    CHECK_IS(remw, 0x000000007fffffff, 0x7fffffff, 0x0       )
    CHECK_IS(remw, 0                 , 0x7fffffff, 0x1       )
    CHECK_IS(remw, 0                 , 0x7fffffff, -0x1      )
    CHECK_IS(remw, 0                 , 0x7fffffff, 0x7fffffff)
    CHECK_IS(remw, 0x000000007fffffff, 0x7fffffff, 0x80000000)

    CHECK_IS(remw, 0xffffffff80000000, 0x80000000, 0x0       )
    CHECK_IS(remw, 0                 , 0x80000000, 0x1       )
    CHECK_IS(remw, 0                 , 0x80000000, -0x1      )
    CHECK_IS(remw, 0xffffffffffffffff, 0x80000000, 0x7fffffff)
    CHECK_IS(remw, 0                 , 0x80000000, 0x80000000)

    return 0;
}


int test_remuw (){

    //
    //       func, expected          , rs1       , rs2
    CHECK_IS(remuw, 0                 , 0x0       , 0x0       )
    CHECK_IS(remuw, 0                 , 0x0       , 0x1       )
    CHECK_IS(remuw, 0                 , 0x0       , -0x1      )
    CHECK_IS(remuw, 0                 , 0x0       , 0x7fffffff)
    CHECK_IS(remuw, 0                 , 0x0       , 0x80000000)

    CHECK_IS(remuw, 0x0000000000000001, 0x1       , 0x0       )
    CHECK_IS(remuw, 0                 , 0x1       , 0x1       )
    CHECK_IS(remuw, 0x0000000000000001, 0x1       , -0x1      )
    CHECK_IS(remuw, 0x0000000000000001, 0x1       , 0x7fffffff)
    CHECK_IS(remuw, 0x0000000000000001, 0x1       , 0x80000000)

    CHECK_IS(remuw, 0xffffffffffffffff, -0x1      , 0x0       )
    CHECK_IS(remuw, 0                 , -0x1      , 0x1       )
    CHECK_IS(remuw, 0                 , -0x1      , -0x1      )
    CHECK_IS(remuw, 0x0000000000000001, -0x1      , 0x7fffffff)
    CHECK_IS(remuw, 0x000000007fffffff, -0x1      , 0x80000000)

    CHECK_IS(remuw, 0x000000007fffffff, 0x7fffffff, 0x0       )
    CHECK_IS(remuw, 0                 , 0x7fffffff , 0x1      )
    CHECK_IS(remuw, 0x000000007fffffff, 0x7fffffff, -0x1      )
    CHECK_IS(remuw, 0                 , 0x7fffffff, 0x7fffffff)
    CHECK_IS(remuw, 0x000000007fffffff, 0x7fffffff, 0x80000000)

    CHECK_IS(remuw, 0xffffffff80000000, 0x80000000, 0x0       )
    CHECK_IS(remuw, 0                 , 0x80000000, 0x1       )
    CHECK_IS(remuw, 0xffffffff80000000, 0x80000000, -0x1      )
    CHECK_IS(remuw, 0x0000000000000001, 0x80000000, 0x7fffffff)
    CHECK_IS(remuw, 0                 , 0x80000000, 0x80000000)

    return 0;

}


int test_div() {

    //
    //       func, expected          , rs1               , rs2
    CHECK_IS(div  ,0xffffffffffffffff, 0x0               , 0x0               )
    CHECK_IS(div  ,0                 , 0x0               , 0x1               )
    CHECK_IS(div  ,0                 , 0x0               , -0x1              )
    CHECK_IS(div  ,0                 , 0x0               , 0x7fffffffffffffff)
    CHECK_IS(div  ,0                 , 0x0               , 0x8000000000000000)

    CHECK_IS(div  ,0xffffffffffffffff, 0x1               , 0x0               )
    CHECK_IS(div  ,0x0000000000000001, 0x1               , 0x1               )
    CHECK_IS(div  ,0xffffffffffffffff, 0x1               , -0x1              )
    CHECK_IS(div  ,0                 , 0x1               , 0x7fffffffffffffff)
    CHECK_IS(div  ,0                 , 0x1               , 0x8000000000000000)

    CHECK_IS(div  ,0xffffffffffffffff, -0x1              , 0x0               )
    CHECK_IS(div  ,0xffffffffffffffff, -0x1              , 0x1               )
    CHECK_IS(div  ,0x0000000000000001, -0x1              , -0x1              )
    CHECK_IS(div  ,0                 , -0x1              , 0x7fffffffffffffff)
    CHECK_IS(div  ,0                 , -0x1              , 0x8000000000000000)

    CHECK_IS(div  ,0xffffffffffffffff, 0x7fffffffffffffff, 0x0               )
    CHECK_IS(div  ,0x7fffffffffffffff, 0x7fffffffffffffff, 0x1               )
    CHECK_IS(div  ,0x8000000000000001, 0x7fffffffffffffff, -0x1              )
    CHECK_IS(div  ,0x0000000000000001, 0x7fffffffffffffff, 0x7fffffffffffffff)
    CHECK_IS(div  ,0                 , 0x7fffffffffffffff, 0x8000000000000000)

    CHECK_IS(div  ,0xffffffffffffffff, 0x8000000000000000, 0x0               )
    CHECK_IS(div  ,0x8000000000000000, 0x8000000000000000, 0x1               )
    CHECK_IS(div  ,0x8000000000000000, 0x8000000000000000, -0x1              )
    CHECK_IS(div  ,0xffffffffffffffff, 0x8000000000000000, 0x7fffffffffffffff)
    CHECK_IS(div  ,0x0000000000000001, 0x8000000000000000, 0x8000000000000000)

    return 0;

}


int test_divu  (){

    //
    //       func, expected          , rs1       , rs2
    CHECK_IS(divu, 0xffffffffffffffff, 0x0               , 0x0               )
    CHECK_IS(divu, 0                 , 0x0               , 0x1               )
    CHECK_IS(divu, 0                 , 0x0               , -0x1              )
    CHECK_IS(divu, 0                 , 0x0               , 0x7fffffffffffffff)
    CHECK_IS(divu, 0                 , 0x0               , 0x8000000000000000)

    CHECK_IS(divu, 0xffffffffffffffff, 0x1               , 0x0               )
    CHECK_IS(divu, 0x0000000000000001, 0x1               , 0x1               )
    CHECK_IS(divu, 0                 , 0x1               , -0x1              )
    CHECK_IS(divu, 0                 , 0x1               , 0x7fffffffffffffff)
    CHECK_IS(divu, 0                 , 0x1               , 0x8000000000000000)

    CHECK_IS(divu, 0xffffffffffffffff, -0x1              , 0x0               )
    CHECK_IS(divu, 0xffffffffffffffff, -0x1              , 0x1               )
    CHECK_IS(divu, 0x0000000000000001, -0x1              , -0x1              )
    CHECK_IS(divu, 0x0000000000000002, -0x1              , 0x7fffffffffffffff)
    CHECK_IS(divu, 0x0000000000000001, -0x1              , 0x8000000000000000)

    CHECK_IS(divu, 0xffffffffffffffff, 0x7fffffffffffffff, 0x0               )
    CHECK_IS(divu, 0x7fffffffffffffff, 0x7fffffffffffffff, 0x1               )
    CHECK_IS(divu, 0                 , 0x7fffffffffffffff, -0x1              )
    CHECK_IS(divu, 0x0000000000000001, 0x7fffffffffffffff, 0x7fffffffffffffff)
    CHECK_IS(divu, 0                 , 0x7fffffffffffffff, 0x8000000000000000)

    CHECK_IS(divu, 0xffffffffffffffff, 0x8000000000000000, 0x0               )
    CHECK_IS(divu, 0x8000000000000000, 0x8000000000000000, 0x1               )
    CHECK_IS(divu, 0                 , 0x8000000000000000, -0x1              )
    CHECK_IS(divu, 0x0000000000000001, 0x8000000000000000, 0x7fffffffffffffff)
    CHECK_IS(divu, 0x0000000000000001, 0x8000000000000000, 0x8000000000000000)

    return 0;
}


int test_rem (){

    //
    //       func, expected          , rs1       , rs2
    CHECK_IS(rem , 0                 , 0x0               , 0x0               )
    CHECK_IS(rem , 0                 , 0x0               , 0x1               )
    CHECK_IS(rem , 0                 , 0x0               , -0x1              )
    CHECK_IS(rem , 0                 , 0x0               , 0x7fffffffffffffff)
    CHECK_IS(rem , 0                 , 0x0               , 0x8000000000000000)

    CHECK_IS(rem , 0x0000000000000001, 0x1               , 0x0               )
    CHECK_IS(rem , 0                 , 0x1               , 0x1               )
    CHECK_IS(rem , 0                 , 0x1               , -0x1              )
    CHECK_IS(rem , 0x0000000000000001, 0x1               , 0x7fffffffffffffff)
    CHECK_IS(rem , 0x0000000000000001, 0x1               , 0x8000000000000000)

    CHECK_IS(rem , 0xffffffffffffffff, -0x1              , 0x0               )
    CHECK_IS(rem , 0                 , -0x1              , 0x1               )
    CHECK_IS(rem , 0                 , -0x1              , -0x1              )
    CHECK_IS(rem , 0xffffffffffffffff, -0x1              , 0x7fffffffffffffff)
    CHECK_IS(rem , 0xffffffffffffffff, -0x1              , 0x8000000000000000)

    CHECK_IS(rem , 0x7fffffffffffffff, 0x7fffffffffffffff, 0x0               )
    CHECK_IS(rem , 0                 , 0x7fffffffffffffff, 0x1               )
    CHECK_IS(rem , 0                 , 0x7fffffffffffffff, -0x1              )
    CHECK_IS(rem , 0                 , 0x7fffffffffffffff, 0x7fffffffffffffff)
    CHECK_IS(rem , 0x7fffffffffffffff, 0x7fffffffffffffff, 0x8000000000000000)

    CHECK_IS(rem , 0x8000000000000000, 0x8000000000000000, 0x0               )
    CHECK_IS(rem , 0                 , 0x8000000000000000, 0x1               )
    CHECK_IS(rem , 0                 , 0x8000000000000000, -0x1              )
    CHECK_IS(rem , 0xffffffffffffffff, 0x8000000000000000, 0x7fffffffffffffff)
    CHECK_IS(rem , 0                 , 0x8000000000000000, 0x8000000000000000)

    return 0;
}


int test_remu (){

    //
    //       func, expected          , rs1       , rs2
    CHECK_IS(remu, 0                 , 0x0               , 0x0               )
    CHECK_IS(remu, 0                 , 0x0               , 0x1               )
    CHECK_IS(remu, 0                 , 0x0               , -0x1              )
    CHECK_IS(remu, 0                 , 0x0               , 0x7fffffffffffffff)
    CHECK_IS(remu, 0                 , 0x0               , 0x8000000000000000)
                                                                             
    CHECK_IS(remu, 0x0000000000000001, 0x1               , 0x0               )
    CHECK_IS(remu, 0                 , 0x1               , 0x1               )
    CHECK_IS(remu, 0x0000000000000001, 0x1               , -0x1              )
    CHECK_IS(remu, 0x0000000000000001, 0x1               , 0x7fffffffffffffff)
    CHECK_IS(remu, 0x0000000000000001, 0x1               , 0x8000000000000000)
                                                                             
    CHECK_IS(remu, 0xffffffffffffffff, -0x1              , 0x0               )
    CHECK_IS(remu, 0                 , -0x1              , 0x1               )
    CHECK_IS(remu, 0                 , -0x1              , -0x1              )
    CHECK_IS(remu, 0x0000000000000001, -0x1              , 0x7fffffffffffffff)
    CHECK_IS(remu, 0x7fffffffffffffff, -0x1              , 0x8000000000000000)
                                                                             
    CHECK_IS(remu, 0x7fffffffffffffff, 0x7fffffffffffffff, 0x0               )
    CHECK_IS(remu, 0                 , 0x7fffffffffffffff , 0x1              )
    CHECK_IS(remu, 0x7fffffffffffffff, 0x7fffffffffffffff, -0x1              )
    CHECK_IS(remu, 0                 , 0x7fffffffffffffff, 0x7fffffffffffffff)
    CHECK_IS(remu, 0x7fffffffffffffff, 0x7fffffffffffffff, 0x8000000000000000)
                                                                             
    CHECK_IS(remu, 0x8000000000000000, 0x8000000000000000, 0x0               )
    CHECK_IS(remu, 0                 , 0x8000000000000000, 0x1               )
    CHECK_IS(remu, 0x8000000000000000, 0x8000000000000000, -0x1              )
    CHECK_IS(remu, 0x0000000000000001, 0x8000000000000000, 0x7fffffffffffffff)
    CHECK_IS(remu, 0                 , 0x8000000000000000, 0x8000000000000000)

    return 0;

}


int test_main() {
    
    test_div  ();
    test_divu ();
    test_rem  ();
    test_remu ();

    test_divw ();
    test_divuw();
    test_remw ();
    test_remuw();

    return 0;

}


