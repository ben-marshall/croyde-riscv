
#include <stdint.h>

#include "unit_test.h"

volatile inline int in_mul(int rs1, int rs2) {
    int     rd;
    asm volatile("mul %0, %1, %2" : "=r"(rd) : "r"(rs1), "r"(rs2));
    return  rd;
}

volatile inline int in_mulh(int rs1, int rs2) {
    int     rd;
    asm volatile("mulh %0, %1, %2" : "=r"(rd) : "r"(rs1), "r"(rs2));
    return  rd;
}

volatile inline int32_t in_mulw(int32_t rs1, int32_t rs2) {
    int     rd;
    asm volatile("mulw %0, %1, %2" : "=r"(rd) : "r"(rs1), "r"(rs2));
    return  rd;
}

#define CHECK_LO(FN, rs1, rs2) {    \
    int grm    = rs1 * rs2;         \
    int dut    = FN(rs1,rs2);       \
    if(grm  !=   dut){              \
        test_fail();                \
    }                               \
}

#define CHECK_HI(FN, rs1, rs2) {    \
    __int128 result = rs1 * rs2;    \
      int    grm    = result >> 64; \
      int    dut    = FN(rs1,rs2);  \
    if(grm    != dut){              \
        test_fail();                \
    }                               \
}

int test_main() {

    CHECK_LO(in_mul   ,  0,  0);
    CHECK_LO(in_mul   ,  1,  0);
    CHECK_LO(in_mul   ,  0,  1);
    CHECK_LO(in_mul   ,  1,  1);
    CHECK_LO(in_mul   ,  2,  1);
    CHECK_LO(in_mul   ,  1,  2);
    CHECK_LO(in_mul   ,  0, -1);
    CHECK_LO(in_mul   , -1,  0);
    CHECK_LO(in_mul   , -1,  1);
    CHECK_LO(in_mul   ,  1, -1);
    CHECK_LO(in_mul   , -1, -1);
    
    CHECK_LO(in_mulw  ,  0,  0);
    CHECK_LO(in_mulw  ,  1,  0);
    CHECK_LO(in_mulw  ,  0,  1);
    CHECK_LO(in_mulw  ,  1,  1);
    CHECK_LO(in_mulw  ,  2,  1);
    CHECK_LO(in_mulw  ,  1,  2);
    CHECK_LO(in_mulw  ,  0, -1);
    CHECK_LO(in_mulw  , -1,  0);
    CHECK_LO(in_mulw  , -1,  1);
    CHECK_LO(in_mulw  ,  1, -1);
    CHECK_LO(in_mulw  , -1, -1);
    
    CHECK_HI(in_mulh  ,  0,  0);
    CHECK_HI(in_mulh  ,  1,  0);
    CHECK_HI(in_mulh  ,  0,  1);
    CHECK_HI(in_mulh  ,  1,  1);
    CHECK_HI(in_mulh  ,  2,  1);
    CHECK_HI(in_mulh  ,  1,  2);
    CHECK_HI(in_mulh  ,  0, -1);
    CHECK_HI(in_mulh  , -1,  0);
    CHECK_HI(in_mulh  , -1,  1);
    CHECK_HI(in_mulh  ,  1, -1);
    CHECK_HI(in_mulh  , -1, -1);

    return 0;

}

