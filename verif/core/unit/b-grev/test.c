
#include "unit_test.h"


inline uint64_t rev_b(uint64_t rs1) {
    uint64_t rd;
    asm ("rev.b %0, %1" : "=r"(rd) : "r"(rs1));
    return rd;
}

inline uint64_t rev8(uint64_t rs1) {
    uint64_t rd;
    asm ("rev8 %0, %1" : "=r"(rd) : "r"(rs1));
    return rd;
}

inline uint64_t rev8_w(uint64_t rs1) {
    uint64_t rd;
    asm ("rev8.w %0, %1" : "=r"(rd) : "r"(rs1));
    return rd;
}


#define TEST(FUNC,EXP,RS1) {        \
    uint64_t rd = FUNC(RS1);        \
    if(rd != EXP) {                 \
        test_fail();                \
    }                               \
}

int test_main() {

    TEST(rev_b ,  0x80c4a2e691d5b3f7, 0x0123456789abcdef)
    
    TEST(rev8  ,  0xefcdab8967452301, 0x0123456789abcdef)
    
    TEST(rev8_w,  0x67452301efcdab89, 0x0123456789abcdef)

    return 0;

}
