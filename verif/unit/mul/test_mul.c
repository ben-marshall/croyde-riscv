
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
INSTR_INLINE(mulw  )

//
// 64-bit instructions.
INSTR_INLINE(mul   )
INSTR_INLINE(mulh  )
INSTR_INLINE(mulhu )
INSTR_INLINE(mulhsu)

#define CHECK_IS(FN, EXP, rs1, rs2) {                           \
    uint64_t grm    = EXP;                                      \
    uint64_t dut    = FN(rs1,rs2);                              \
    if(grm  !=   dut){                                          \
        __putstr(#FN       );                  __putchar('\n'); \
        __putstr("RS1   : "); __puthex64(rs1); __putchar('\n'); \
        __putstr("RS2   : "); __puthex64(rs2); __putchar('\n'); \
        __putstr("Expect: "); __puthex64(grm); __putchar('\n'); \
        __putstr("Got   : "); __puthex64(dut); __putchar('\n'); \
        test_fail();                                            \
    }                                                           \
}


#define CHECK_LO_SS(FN, rs1, rs2) {                             \
    int64_t grm    = (int64_t)rs1 * (int64_t)rs2;               \
    int64_t dut    = FN(rs1,rs2);                               \
    if(grm  !=   dut){                                          \
        test_fail();                                            \
    }                                                           \
}

#define CHECK_HI_SS(FN, rs1, rs2) {                             \
    __int128 result = (int64_t)rs1 * (int64_t)rs2;              \
    int64_t grm    = result >> 64;                              \
    int64_t dut    = FN(rs1,rs2);                               \
    if(grm    != dut){                                          \
        test_fail();                                            \
    }                                                           \
}

#define CHECK_HI_UU(FN, rs1, rs2, EXP) {                        \
    uint64_t          grm    = EXP;                             \
    uint64_t          dut    = FN(rs1,rs2);                     \
    if(grm    != dut){                                          \
        __putstr("Expect: "); __puthex64(grm); __putchar('\n'); \
        __putstr("Got   : "); __puthex64(dut); __putchar('\n'); \
        test_fail();                                            \
    }                                                           \
}


int test_mulw () {

    CHECK_IS(mulw, 0                    , 0x0       , 0x0       )
    CHECK_IS(mulw, 0                    , 0x0       , 0x1       )
    CHECK_IS(mulw, 0                    , 0x0       , -0x1      )
    CHECK_IS(mulw, 0                    , 0x0       , 0x7fffffff)
    CHECK_IS(mulw, 0                    , 0x0       , 0x80000000)

    CHECK_IS(mulw, 0                    , 0x1       , 0x0       )
    CHECK_IS(mulw, 0x0000000000000001   , 0x1       , 0x1       )
    CHECK_IS(mulw, 0xffffffffffffffff   , 0x1       , -0x1      )
    CHECK_IS(mulw, 0x000000007fffffff   , 0x1       , 0x7fffffff)
    CHECK_IS(mulw, 0xffffffff80000000   , 0x1       , 0x80000000)

    CHECK_IS(mulw, 0                    , -0x1      , 0x0       )
    CHECK_IS(mulw, 0xffffffffffffffff   , -0x1      , 0x1       )
    CHECK_IS(mulw, 0x0000000000000001   , -0x1      , -0x1      )
    CHECK_IS(mulw, 0xffffffff80000001   , -0x1      , 0x7fffffff)
    CHECK_IS(mulw, 0xffffffff80000000   , -0x1      , 0x80000000)

    CHECK_IS(mulw, 0                    , 0x7fffffff, 0x0       )
    CHECK_IS(mulw, 0x000000007fffffff   , 0x7fffffff, 0x1       )
    CHECK_IS(mulw, 0xffffffff80000001   , 0x7fffffff, -0x1      )
    CHECK_IS(mulw, 0x0000000000000001   , 0x7fffffff, 0x7fffffff)
    CHECK_IS(mulw, 0xffffffff80000000   , 0x7fffffff, 0x80000000)

    CHECK_IS(mulw, 0                    , 0x80000000, 0x0       )
    CHECK_IS(mulw, 0xffffffff80000000   , 0x80000000, 0x1       )
    CHECK_IS(mulw, 0xffffffff80000000   , 0x80000000, -0x1      )
    CHECK_IS(mulw, 0xffffffff80000000   , 0x80000000, 0x7fffffff)
    CHECK_IS(mulw, 0                    , 0x80000000, 0x80000000)

    return 0;
}

int test_mul() {

    CHECK_IS(mul , 0                 , 0x0               , 0x0               )
    CHECK_IS(mul , 0                 , 0x0               , 0x1               )
    CHECK_IS(mul , 0                 , 0x0               , -0x1              )
    CHECK_IS(mul , 0                 , 0x0               , 0x7fffffffffffffff)
    CHECK_IS(mul , 0                 , 0x0               , 0x8000000000000000)

    CHECK_IS(mul , 0                 , 0x1               , 0x0               )
    CHECK_IS(mul , 0x0000000000000001, 0x1               , 0x1               )
    CHECK_IS(mul , 0xffffffffffffffff, 0x1               , -0x1              )
    CHECK_IS(mul , 0x7fffffffffffffff, 0x1               , 0x7fffffffffffffff)
    CHECK_IS(mul , 0x8000000000000000, 0x1               , 0x8000000000000000)

    CHECK_IS(mul , 0                 , -0x1              , 0x0               )
    CHECK_IS(mul , 0xffffffffffffffff, -0x1              , 0x1               )
    CHECK_IS(mul , 0x0000000000000001, -0x1              , -0x1              )
    CHECK_IS(mul , 0x8000000000000001, -0x1              , 0x7fffffffffffffff)
    CHECK_IS(mul , 0x8000000000000000, -0x1              , 0x8000000000000000)

    CHECK_IS(mul , 0                 , 0x7fffffffffffffff, 0x0               )
    CHECK_IS(mul , 0x7fffffffffffffff, 0x7fffffffffffffff, 0x1               )
    CHECK_IS(mul , 0x8000000000000001, 0x7fffffffffffffff, -0x1              )
    CHECK_IS(mul , 0x0000000000000001, 0x7fffffffffffffff, 0x7fffffffffffffff)
    CHECK_IS(mul , 0x8000000000000000, 0x7fffffffffffffff, 0x8000000000000000)

    CHECK_IS(mul , 0                 , 0x8000000000000000, 0x0               )
    CHECK_IS(mul , 0x8000000000000000, 0x8000000000000000, 0x1               )
    CHECK_IS(mul , 0x8000000000000000, 0x8000000000000000, -0x1              )
    CHECK_IS(mul , 0x8000000000000000, 0x8000000000000000, 0x7fffffffffffffff)
    CHECK_IS(mul , 0                 , 0x8000000000000000, 0x8000000000000000)

    return 0;

}


int test_mulh () {

    CHECK_IS(mulh, 0                 , 0x0               , 0x0               )
	CHECK_IS(mulh, 0                 , 0x0               , 0x1               )
	CHECK_IS(mulh, 0                 , 0x0               , -0x1              )
	CHECK_IS(mulh, 0                 , 0x0               , 0x7fffffffffffffff)
	CHECK_IS(mulh, 0                 , 0x0               , 0x8000000000000000)

	CHECK_IS(mulh, 0                 , 0x1               , 0x0               )
	CHECK_IS(mulh, 0                 , 0x1               , 0x1               )
	CHECK_IS(mulh, 0xffffffffffffffff, 0x1               , -0x1              )
	CHECK_IS(mulh, 0                 , 0x1               , 0x7fffffffffffffff)
	CHECK_IS(mulh, 0xffffffffffffffff, 0x1               , 0x8000000000000000)

	CHECK_IS(mulh, 0                 , -0x1              , 0x0               )
	CHECK_IS(mulh, 0xffffffffffffffff, -0x1              , 0x1               )
	CHECK_IS(mulh, 0                 , -0x1              , -0x1              )
	CHECK_IS(mulh, 0xffffffffffffffff, -0x1              , 0x7fffffffffffffff)
	CHECK_IS(mulh, 0                 , -0x1              , 0x8000000000000000)

	CHECK_IS(mulh, 0                 , 0x7fffffffffffffff, 0x0               )
	CHECK_IS(mulh, 0                 , 0x7fffffffffffffff, 0x1               )
	CHECK_IS(mulh, 0xffffffffffffffff, 0x7fffffffffffffff, -0x1              )
	CHECK_IS(mulh, 0x3fffffffffffffff, 0x7fffffffffffffff, 0x7fffffffffffffff)
	CHECK_IS(mulh, 0xc000000000000000, 0x7fffffffffffffff, 0x8000000000000000)

	CHECK_IS(mulh, 0                 , 0x8000000000000000, 0x0               )
	CHECK_IS(mulh, 0xffffffffffffffff, 0x8000000000000000, 0x1               )
	CHECK_IS(mulh, 0                 , 0x8000000000000000, -0x1              )
	CHECK_IS(mulh, 0xc000000000000000, 0x8000000000000000, 0x7fffffffffffffff)
	CHECK_IS(mulh, 0x4000000000000000, 0x8000000000000000, 0x8000000000000000)

    return 0;

}


int test_mulhsu () {

    CHECK_IS(mulhsu, 0                 ,0x0               , 0x0               )
	CHECK_IS(mulhsu, 0                 ,0x0               , 0x1               )
	CHECK_IS(mulhsu, 0                 ,0x0               , -0x1              )
	CHECK_IS(mulhsu, 0                 ,0x0               , 0x7fffffffffffffff)
	CHECK_IS(mulhsu, 0                 ,0x0               , 0x8000000000000000)

	CHECK_IS(mulhsu, 0                 ,0x1               , 0x0               )
	CHECK_IS(mulhsu, 0                 ,0x1               , 0x1               )
	CHECK_IS(mulhsu, 0                 ,0x1               , -0x1              )
	CHECK_IS(mulhsu, 0                 ,0x1               , 0x7fffffffffffffff)
	CHECK_IS(mulhsu, 0                 ,0x1               , 0x8000000000000000)

	CHECK_IS(mulhsu, 0                 ,-0x1              , 0x0               )
	CHECK_IS(mulhsu, 0xffffffffffffffff,-0x1              , 0x1               )
	CHECK_IS(mulhsu, 0xffffffffffffffff,-0x1              , -0x1              )
	CHECK_IS(mulhsu, 0xffffffffffffffff,-0x1              , 0x7fffffffffffffff)
	CHECK_IS(mulhsu, 0xffffffffffffffff,-0x1              , 0x8000000000000000)

	CHECK_IS(mulhsu, 0                 ,0x7fffffffffffffff, 0x0               )
	CHECK_IS(mulhsu, 0                 ,0x7fffffffffffffff, 0x1               )
	CHECK_IS(mulhsu, 0x7ffffffffffffffe,0x7fffffffffffffff, -0x1              )
	CHECK_IS(mulhsu, 0x3fffffffffffffff,0x7fffffffffffffff, 0x7fffffffffffffff)
	CHECK_IS(mulhsu, 0x3fffffffffffffff,0x7fffffffffffffff, 0x8000000000000000)

	CHECK_IS(mulhsu, 0                 ,0x8000000000000000, 0x0               )
	CHECK_IS(mulhsu, 0xffffffffffffffff,0x8000000000000000, 0x1               )
	CHECK_IS(mulhsu, 0x8000000000000000,0x8000000000000000, -0x1              )
	CHECK_IS(mulhsu, 0xc000000000000000,0x8000000000000000, 0x7fffffffffffffff)
	CHECK_IS(mulhsu, 0xc000000000000000,0x8000000000000000, 0x8000000000000000)

    return 0;

}


int test_mulhu () {

    CHECK_IS(mulhu, 0                 ,0x0               , 0x0               )
	CHECK_IS(mulhu, 0                 ,0x0               , 0x1               )
	CHECK_IS(mulhu, 0                 ,0x0               , -0x1              )
	CHECK_IS(mulhu, 0                 ,0x0               , 0x7fffffffffffffff)
	CHECK_IS(mulhu, 0                 ,0x0               , 0x8000000000000000)

	CHECK_IS(mulhu, 0                 ,0x1               , 0x0               )
	CHECK_IS(mulhu, 0                 ,0x1               , 0x1               )
	CHECK_IS(mulhu, 0                 ,0x1               , -0x1              )
	CHECK_IS(mulhu, 0                 ,0x1               , 0x7fffffffffffffff)
	CHECK_IS(mulhu, 0                 ,0x1               , 0x8000000000000000)

	CHECK_IS(mulhu, 0                 ,-0x1              , 0x0               )
	CHECK_IS(mulhu, 0                 ,-0x1              , 0x1               )
	CHECK_IS(mulhu, 0xfffffffffffffffe,-0x1              , -0x1              )
	CHECK_IS(mulhu, 0x7ffffffffffffffe,-0x1              , 0x7fffffffffffffff)
	CHECK_IS(mulhu, 0x7fffffffffffffff,-0x1              , 0x8000000000000000)

	CHECK_IS(mulhu, 0                 ,0x7fffffffffffffff, 0x0               )
	CHECK_IS(mulhu, 0                 ,0x7fffffffffffffff, 0x1               )
	CHECK_IS(mulhu, 0x7ffffffffffffffe,0x7fffffffffffffff, -0x1              )
	CHECK_IS(mulhu, 0x3fffffffffffffff,0x7fffffffffffffff, 0x7fffffffffffffff)
	CHECK_IS(mulhu, 0x3fffffffffffffff,0x7fffffffffffffff, 0x8000000000000000)

	CHECK_IS(mulhu, 0                 ,0x8000000000000000, 0x0               )
	CHECK_IS(mulhu, 0                 ,0x8000000000000000, 0x1               )
	CHECK_IS(mulhu, 0x7fffffffffffffff,0x8000000000000000, -0x1              )
	CHECK_IS(mulhu, 0x3fffffffffffffff,0x8000000000000000, 0x7fffffffffffffff)
	CHECK_IS(mulhu, 0x4000000000000000,0x8000000000000000, 0x8000000000000000)

    return 0;

}

int test_main() {

    test_mulw  ();
    test_mul   ();
    test_mulh  ();
    test_mulhsu();
    test_mulhu ();

    return 0;

}

