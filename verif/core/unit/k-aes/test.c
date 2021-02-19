
#include "unit_test.h"

inline uint64_t aes64es (uint64_t rs1, uint64_t rs2) {
    uint64_t rd;
    asm ("aes64es %0, %1, %2" : "=r"(rd) : "r"(rs1), "r"(rs2));
    return rd;
}

inline uint64_t aes64esm(uint64_t rs1, uint64_t rs2) {
    uint64_t rd;
    asm ("aes64esm %0, %1, %2" : "=r"(rd) : "r"(rs1), "r"(rs2));
    return rd;
}


#define TEST(INS,EXP,RS1,RS2) {   \
    uint64_t rd = INS(RS1, RS2);    \
    if(rd != EXP) {      \
        test_fail();                \
    }                               \
}

int test_main() {

    TEST(aes64es , 0x6363636363636363, 0x0000000000000000, 0x0000000000000000)
    TEST(aes64esm, 0x6363636363636363, 0x0000000000000000, 0x0000000000000000)
    TEST(aes64es , 0x63fbfb63fbfb6363, 0x0000000000000000, 0x6363636363636363)

    return 0;

}
