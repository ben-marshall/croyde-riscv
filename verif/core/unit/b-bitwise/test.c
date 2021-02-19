
#include "unit_test.h"


inline uint64_t andn (uint64_t rs1, uint64_t rs2) {
    uint64_t rd;
    asm ("andn %0, %1, %2" : "=r"(rd) : "r"(rs1), "r"(rs2));
    return rd;
}

inline uint64_t orn(uint64_t rs1, uint64_t rs2) {
    uint64_t rd;
    asm ("orn %0, %1, %2" : "=r"(rd) : "r"(rs1), "r"(rs2));
    return rd;
}

inline uint64_t xnor (uint64_t rs1, uint64_t rs2) {
    uint64_t rd;
    asm ("xnor %0, %1, %2" : "=r"(rd) : "r"(rs1), "r"(rs2));
    return rd;
}

#define TEST(INSN, FUNC ,RS1,RS2) {     \
    uint64_t rd = INSN(RS1,RS2);        \
    if(rd != (RS1 FUNC RS2)) {          \
        test_fail();                    \
    }                                   \
}

int test_main() {

    TEST(andn, &~, 0x0000000000000000, 0x0000000000000000)
    TEST(andn, &~, 0x0123456789ABCDEF, 0xFEDCBA9876543210)
    TEST(andn, &~, 0x0000000000000000, 0xFEDCBA9876543210)
    TEST(andn, &~, 0x0123456789ABCDEF, 0x0000000000000000)
    
    TEST(orn , |~, 0x0000000000000000, 0x0000000000000000)
    TEST(orn , |~, 0x0123456789ABCDEF, 0xFEDCBA9876543210)
    TEST(orn , |~, 0x0000000000000000, 0xFEDCBA9876543210)
    TEST(orn , |~, 0x0123456789ABCDEF, 0x0000000000000000)
    
    TEST(xnor, ^~, 0x0000000000000000, 0x0000000000000000)
    TEST(xnor, ^~, 0x0123456789ABCDEF, 0xFEDCBA9876543210)
    TEST(xnor, ^~, 0x0000000000000000, 0xFEDCBA9876543210)
    TEST(xnor, ^~, 0x0123456789ABCDEF, 0x0000000000000000)
    
    return 0;

}
