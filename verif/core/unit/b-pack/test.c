
#include "unit_test.h"


inline uint64_t pack(uint64_t rs1, uint64_t rs2) {
    uint64_t rd;
    asm ("pack %0, %1, %2" : "=r"(rd) : "r"(rs1), "r"(rs2));
    return rd;
}

inline uint64_t packh(uint64_t rs1, uint64_t rs2) {
    uint64_t rd;
    asm ("packh %0, %1, %2" : "=r"(rd) : "r"(rs1), "r"(rs2));
    return rd;
}

inline uint64_t packu(uint64_t rs1, uint64_t rs2) {
    uint64_t rd;
    asm ("packu %0, %1, %2" : "=r"(rd) : "r"(rs1), "r"(rs2));
    return rd;
}

//inline uint64_t packw(uint64_t rs1, uint64_t rs2) {
//    uint64_t rd;
//    asm ("packw %0, %1, %2" : "=r"(rd) : "r"(rs1), "r"(rs2));
//    return rd;
//}
//
//inline uint64_t packuw(uint64_t rs1, uint64_t rs2) {
//    uint64_t rd;
//    asm ("packuw %0, %1, %2" : "=r"(rd) : "r"(rs1), "r"(rs2));
//    return rd;
//}

#define TEST(FUNC,EXP,RS1,RS2) {        \
    uint64_t rd = FUNC(RS1,RS2);        \
    if(rd != EXP) {                     \
        test_fail();                    \
    }                                   \
}

int test_main() {

    TEST(pack  , 0x0000000000000000, 0x0000000000000000, 0x0000000000000000)
    TEST(pack  , 0xDDDDDDDDBBBBBBBB, 0xAAAAAAAABBBBBBBB, 0xCCCCCCCCDDDDDDDD)
    
    TEST(packh , 0x0000000000000000, 0x0000000000000000, 0x0000000000000000)
    TEST(packh , 0x000000000000DDBB, 0xAAAAAAAABBBBBBBB, 0xCCCCCCCCDDDDDDDD)
    
    TEST(packu , 0x0000000000000000, 0x0000000000000000, 0x0000000000000000)
    TEST(packu , 0xCCCCCCCCAAAAAAAA, 0xAAAAAAAABBBBBBBB, 0xCCCCCCCCDDDDDDDD)
    
    //TEST(packw , 0x0000000000000000, 0x0000000000000000, 0x0000000000000000)
    //TEST(packw , 0x000000002222DDDD, 0xAAAABBBBCCCCDDDD, 0xEEEEFFFF11112222)
    //
    //TEST(packuw, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000)
    //TEST(packuw, 0x00000000CCCC1111, 0xAAAABBBBCCCCDDDD, 0xEEEEFFFF11112222)

    return 0;

}
