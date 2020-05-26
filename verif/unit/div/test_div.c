
#include <stdint.h>

#include "unit_test.h"

volatile inline int64_t in_div(int64_t rs1, int64_t rs2) {
    int64_t rd;
    asm volatile("div %0, %1, %2" : "=r"(rd) : "r"(rs1), "r"(rs2));
    return  rd;
}

volatile inline int64_t in_rem(int64_t rs1, int64_t rs2) {
    int64_t rd;
    asm volatile("rem %0, %1, %2" : "=r"(rd) : "r"(rs1), "r"(rs2));
    return  rd;
}

#define CHECK_IS(FN, rs1, rs2, EXP) {                           \
    int grm    = EXP;                                           \
    int dut    = FN(rs1,rs2);                                   \
    if(grm  !=   dut){                                          \
        __putstr("Expect: "); __puthex64(grm); __putchar('\n'); \
        __putstr("Got   : "); __puthex64(dut); __putchar('\n'); \
        test_fail();                                            \
    }                                                           \
}

#define CHECK_D64_SS(FN, rs1, rs2) {                            \
    int grm    = (int64_t)rs1 / (int64_t)rs2;                   \
    int dut    = FN(rs1,rs2);                                   \
    if(grm  !=   dut){                                          \
        __putstr("Expect: "); __puthex64(grm); __putchar('\n'); \
        __putstr("Got   : "); __puthex64(dut); __putchar('\n'); \
        test_fail();                                            \
    }                                                           \
}

#define CHECK_R64_SS(FN, rs1, rs2) {                            \
    int grm    = (int64_t)rs1 % (int64_t)rs2;                   \
    int dut    = FN(rs1,rs2);                                   \
    if(grm  !=   dut){                                          \
        __putstr("Expect: "); __puthex64(grm); __putchar('\n'); \
        __putstr("Got   : "); __puthex64(dut); __putchar('\n'); \
        test_fail();                                            \
    }                                                           \
}


int test_main() {

    CHECK_D64_SS(in_div, 197, 10)
    CHECK_IS    (in_div,   0,  0, -1)
    CHECK_IS    (in_div,   1,  0, -1)
    CHECK_D64_SS(in_div,   0,  1)
    CHECK_D64_SS(in_div,  10,  1)
    CHECK_D64_SS(in_div,   1, 10)
    CHECK_D64_SS(in_div,  -1,  1)
    CHECK_D64_SS(in_div,   1, -1)
    CHECK_D64_SS(in_div,   0, -1)
    CHECK_IS    (in_div,  -1,  0, -1)
    
    CHECK_R64_SS(in_rem, 197,  7)
    CHECK_IS    (in_rem,   0,  0,  0)
    CHECK_IS    (in_rem,   1,  0,  1)
    CHECK_D64_SS(in_rem,   0,  1)
    CHECK_IS    (in_rem,  10,  1,  0)
    CHECK_IS    (in_rem,   1, 10,  1)
    CHECK_IS    (in_rem,  -1,  1,  0)
    CHECK_IS    (in_rem,   1, -1,  0)
    CHECK_D64_SS(in_rem,   0, -1)
    CHECK_IS    (in_rem,  -1,  0, -1)

    return 0;

}

