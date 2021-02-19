
#include "unit_test.h"


inline uint64_t xperm_b(uint64_t rs1, uint64_t rs2) {
    uint64_t rd;
    asm (".insn r 0x33, 4, 20, %0, %1, %2" : "=r"(rd) : "r"(rs1), "r"(rs2));
    return rd;
}

inline uint64_t xperm_n(uint64_t rs1, uint64_t rs2) {
    uint64_t rd;
    asm (".insn r 0x33, 2, 20, %0, %1, %2" : "=r"(rd) : "r"(rs1), "r"(rs2));
    return rd;
}


#define TEST(FUNC,EXP,RS1,RS2) {    \
    uint64_t rd = FUNC(RS1, RS2);   \
    if(rd != EXP) {                 \
        test_fail();                \
    }                               \
}

int test_main() {

    TEST(xperm_n, 0xFEDCBA9876543210, 0x0123456789abcdef, 0x0123456789abcdef)
    TEST(xperm_n, 0x1032547698badcfe, 0xefcdab8967452301, 0x0123456789abcdef)

    TEST(xperm_b, 0x0123456789abcdef, 0x0123456789abcdef, 0x0706050403020100)
    TEST(xperm_b, 0xefcdab8967000000, 0xefcdab8967452301, 0x07060504030C0B0A)

    return 0;

}
