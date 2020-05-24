
#include <stdint.h>

#include "unit_test.h"

volatile inline int64_t in_mul(int64_t rs1, int64_t rs2) {
    int64_t rd;
    asm volatile("mul %0, %1, %2" : "=r"(rd) : "r"(rs1), "r"(rs2));
    return  rd;
}

volatile inline int64_t in_mulh(int64_t rs1, int64_t rs2) {
    int64_t rd;
    asm volatile("mulh %0, %1, %2" : "=r"(rd) : "r"(rs1), "r"(rs2));
    return  rd;
}

volatile inline uint64_t in_mulhu(uint64_t rs1, uint64_t rs2) {
    uint64_t rd;
    asm volatile("mulhu %0, %1, %2" : "=r"(rd) : "r"(rs1), "r"(rs2));
    return  rd;
}

volatile inline int32_t in_mulw(int32_t rs1, int32_t rs2) {
    int32_t rd;
    asm volatile("mulw %0, %1, %2" : "=r"(rd) : "r"(rs1), "r"(rs2));
    return  rd;
}

#define CHECK_LO_SS(FN, rs1, rs2) {                             \
    int grm    = (int64_t)rs1 * (int64_t)rs2;                   \
    int dut    = FN(rs1,rs2);                                   \
    if(grm  !=   dut){                                          \
        test_fail();                                            \
    }                                                           \
}

#define CHECK_HI_SS(FN, rs1, rs2) {                             \
    __int128 result = (int64_t)rs1 * (int64_t)rs2;              \
      int    grm    = result >> 64;                             \
      int    dut    = FN(rs1,rs2);                              \
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

int test_main() {

    CHECK_LO_SS(in_mul   ,  0,  0);
    CHECK_LO_SS(in_mul   ,  1,  0);
    CHECK_LO_SS(in_mul   ,  0,  1);
    CHECK_LO_SS(in_mul   ,  1,  1);
    CHECK_LO_SS(in_mul   ,  2,  1);
    CHECK_LO_SS(in_mul   ,  1,  2);
    CHECK_LO_SS(in_mul   ,  0, -1);
    CHECK_LO_SS(in_mul   , -1,  0);
    CHECK_LO_SS(in_mul   , -1,  1);
    CHECK_LO_SS(in_mul   ,  1, -1);
    CHECK_LO_SS(in_mul   , -1, -1);
    
    CHECK_LO_SS(in_mulw  ,  0,  0);
    CHECK_LO_SS(in_mulw  ,  1,  0);
    CHECK_LO_SS(in_mulw  ,  0,  1);
    CHECK_LO_SS(in_mulw  ,  1,  1);
    CHECK_LO_SS(in_mulw  ,  2,  1);
    CHECK_LO_SS(in_mulw  ,  1,  2);
    CHECK_LO_SS(in_mulw  ,  0, -1);
    CHECK_LO_SS(in_mulw  , -1,  0);
    CHECK_LO_SS(in_mulw  , -1,  1);
    CHECK_LO_SS(in_mulw  ,  1, -1);
    CHECK_LO_SS(in_mulw  , -1, -1);
    
    CHECK_HI_SS(in_mulh  ,  0,  0);
    CHECK_HI_SS(in_mulh  ,  1,  0);
    CHECK_HI_SS(in_mulh  ,  0,  1);
    CHECK_HI_SS(in_mulh  ,  1,  1);
    CHECK_HI_SS(in_mulh  ,  2,  1);
    CHECK_HI_SS(in_mulh  ,  1,  2);
    CHECK_HI_SS(in_mulh  ,  0, -1);
    CHECK_HI_SS(in_mulh  , -1,  0);
    CHECK_HI_SS(in_mulh  , -1,  1);
    CHECK_HI_SS(in_mulh  ,  1, -1);
    CHECK_HI_SS(in_mulh  , -1, -1);
    CHECK_HI_SS(in_mulh  , -1, -1);
    
    CHECK_HI_UU(in_mulhu ,  0,  0, 0);
    CHECK_HI_UU(in_mulhu ,  1,  0, 0);
    CHECK_HI_UU(in_mulhu ,  0,  1, 0);
    CHECK_HI_UU(in_mulhu ,  1,  1, 0);
    CHECK_HI_UU(in_mulhu ,  2,  1, 0);
    CHECK_HI_UU(in_mulhu ,  1,  2, 0);
    CHECK_HI_UU(in_mulhu ,  0, -1, 0);
    CHECK_HI_UU(in_mulhu , -1,  0, 0);
    CHECK_HI_UU(in_mulhu , -1,  1, 0);
    CHECK_HI_UU(in_mulhu ,  1, -1, 0);
    CHECK_HI_UU(in_mulhu , -1, -1, 0xFFFFFFFFFFFFFFFE);

    return 0;

}

