
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

#define CHECK_D_SS(FN, rs1, rs2) {                              \
    int grm    = (int64_t)rs1 / (int64_t)rs2;                   \
    int dut    = FN(rs1,rs2);                                   \
    if(grm  !=   dut){                                          \
        test_fail();                                            \
    }                                                           \
}

#define CHECK_R_SS(FN, rs1, rs2) {                              \
    int grm    = (int64_t)rs1 % (int64_t)rs2;                   \
    int dut    = FN(rs1,rs2);                                   \
    if(grm  !=   dut){                                          \
        test_fail();                                            \
    }                                                           \
}


int test_main() {

    CHECK_D_SS(in_div, 197, 10)
    
    CHECK_R_SS(in_rem, 197,  7)

    return 0;

}

