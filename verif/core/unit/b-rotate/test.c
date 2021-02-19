
#include "unit_test.h"

#define SRL(a,b) ((uint64_t)a >> (b&0x3F))
inline int64_t srl  (uint64_t rs1, uint64_t rs2) {
    uint64_t rd;
    asm ("srl  %0, %1, %2" : "=r"(rd) : "r"(rs1), "r"(rs2));
    return rd;
}

#define SRLW(a,b) ((uint32_t)a >> b)
inline int64_t srlw (uint64_t rs1, uint64_t rs2) {
    uint64_t rd;
    asm ("srlw  %0, %1, %2" : "=r"(rd) : "r"(rs1), "r"(rs2));
    return rd;
}

#define SRA(a,b) ((int64_t)a >> (b&0x3F))
inline int64_t sra  (uint64_t rs1, uint64_t rs2) {
    uint64_t rd;
    asm ("sra  %0, %1, %2" : "=r"(rd) : "r"(rs1), "r"(rs2));
    return rd;
}

#define SRAW(a,b) (((int32_t)a >> b)| ((int64_t)(((int64_t)a>>31) << 63)>>32))
inline int64_t sraw (uint64_t rs1, uint64_t rs2) {
    uint64_t rd;
    asm ("sraw  %0, %1, %2" : "=r"(rd) : "r"(rs1), "r"(rs2));
    return rd;
}

#define SLL(a,b) ((uint64_t)a << (b&0x3F))
inline int64_t sll  (uint64_t rs1, uint64_t rs2) {
    uint64_t rd;
    asm ("sll  %0, %1, %2" : "=r"(rd) : "r"(rs1), "r"(rs2));
    return rd;
}

#define SLLW(a,b) (((uint32_t)a << b) | ((int64_t)(((int64_t)a>>31) << 63)>>32))
inline int64_t sllw (uint64_t rs1, uint64_t rs2) {
    uint64_t rd;
    asm ("sllw  %0, %1, %2" : "=r"(rd) : "r"(rs1), "r"(rs2));
    return rd;
}

#define ROR(a,b) (((uint64_t)a >> b) | ((uint64_t)a<<((64-(b&0x3f))&0x3f)))
inline int64_t ror  (uint64_t rs1, uint64_t rs2) {
    uint64_t rd;
    asm ("ror  %0, %1, %2" : "=r"(rd) : "r"(rs1), "r"(rs2));
    return rd;
}

#define RORW(a,b) (((uint32_t)a >> b) | ((int64_t)(((int64_t)a>>31) << 63)>>32) | ((uint32_t)a<<((32-b)&0x1F)))
inline int64_t rorw (uint64_t rs1, uint64_t rs2) {
    uint64_t rd;
    asm ("rorw %0, %1, %2" : "=r"(rd) : "r"(rs1), "r"(rs2));
    return rd;
}

inline int64_t rori (uint64_t rs1, uint64_t shamt) {
    uint64_t rd;
    asm ("rori %0, %1, %2" : "=r"(rd) : "r"(rs1), "i"(shamt));
    return rd;
}

inline int64_t roriw (uint64_t rs1, uint64_t shamt) {
    uint64_t rd;
    asm ("roriw %0, %1, %2" : "=r"(rd) : "r"(rs1), "i"(shamt));
    return rd;
}

#define ROL(a,b) (((uint64_t)a << b) | ((uint64_t)a>>((64-(b&0x3f))&0x3f)))
inline int64_t rol  (uint64_t rs1, uint64_t rs2) {
    uint64_t rd;
    asm ("rol  %0, %1, %2" : "=r"(rd) : "r"(rs1), "r"(rs2));
    return rd;
}

#define ROLW(a,b) (((uint32_t)a << b) | ((uint32_t)a>>((32-b)&0x1F))| ((int64_t)(((int64_t)a<<b >>31) << 63)>>32))
inline int64_t rolw (uint64_t rs1, uint64_t rs2) {
    uint64_t rd;
    asm ("rolw %0, %1, %2" : "=r"(rd) : "r"(rs1), "r"(rs2));
    return rd;
}

#define TEST(INSN, FUNC ,RS1,RS2) {     \
    uint64_t rd = INSN(RS1,RS2);        \
    if(rd != FUNC(RS1,RS2)) {          \
        test_fail();                    \
    }                                   \
}

int test_main() {
    
    TEST(srl  , SRL , 0x0000000000000000, 0x00)
    TEST(srl  , SRL , 0x0123456789ABCDEF, 0x08)
    TEST(srl  , SRL , 0x0123456789ABCDEF, 0x07)
    TEST(srl  , SRL , 0x0123456789ABCDEF, 0x0F)
    TEST(srl  , SRL , 0x0123456789ABCDEF, 0x28)
    
    TEST(srlw , SRLW, 0x0000000000000000, 0x00)
    TEST(srlw , SRLW, 0x0123456789ABCDEF, 0x08)
    TEST(srlw , SRLW, 0x0123456789ABCDEF, 0x07)
    TEST(srlw , SRLW, 0x0123456789ABCDEF, 0x0F)
    
    TEST(sra  , SRA , 0x0000000000000000, 0x00)
    TEST(sra  , SRA , 0x0123456789ABCDEF, 0x08)
    TEST(sra  , SRA , 0x0123456789ABCDEF, 0x07)
    TEST(sra  , SRA , 0x0123456789ABCDEF, 0x0F)
    TEST(sra  , SRA , 0x0123456789ABCDEF, 0x28)
    
    TEST(sraw , SRAW, 0x0000000000000000, 0x00)
    TEST(sraw , SRAW, 0x0123456789ABCDEF, 0x08)
    TEST(sraw , SRAW, 0x0123456789ABCDEF, 0x07)
    TEST(sraw , SRAW, 0x0123456789ABCDEF, 0x0F)
    
    TEST(sra  , SRA , 0x0000000000000000<<1, 0x00)
    TEST(sra  , SRA , 0x0123456789ABCDEF<<1, 0x08)
    TEST(sra  , SRA , 0x0123456789ABCDEF<<1, 0x07)
    TEST(sra  , SRA , 0x0123456789ABCDEF<<1, 0x0F)
    TEST(sra  , SRA , 0x0123456789ABCDEF<<1, 0x28)
    
    TEST(sraw , SRAW, 0x0000000000000000<<1, 0x00)
    TEST(sraw , SRAW, 0x0123456789ABCDEF<<1, 0x08)
    TEST(sraw , SRAW, 0x0123456789ABCDEF<<1, 0x07)
    TEST(sraw , SRAW, 0x0123456789ABCDEF<<1, 0x0F)
    
    TEST(sll  , SLL , 0x0000000000000000, 0x00)
    TEST(sll  , SLL , 0x0123456789ABCDEF, 0x08)
    TEST(sll  , SLL , 0x0123456789ABCDEF, 0x07)
    TEST(sll  , SLL , 0x0123456789ABCDEF, 0x0F)
    TEST(sll  , SLL , 0x0123456789ABCDEF, 0x28)
    
    TEST(sllw , SLLW, 0x0000000000000000, 0x00)
    TEST(sllw , SLLW, 0x0123456789ABCDEF, 0x08)
    TEST(sllw , SLLW, 0x0123456789ABCDEF, 0x07)
    TEST(sllw , SLLW, 0x0123456789ABCDEF, 0x0F)

    TEST(ror  , ROR , 0x0000000000000000, 0x00)
    TEST(ror  , ROR , 0x0123456789ABCDEF, 0x08)
    TEST(ror  , ROR , 0x0123456789ABCDEF, 0x07)
    TEST(ror  , ROR , 0x0123456789ABCDEF, 0x0F)
    TEST(ror  , ROR , 0x0123456789ABCDEF, 0x28)
    
    TEST(rorw , RORW, 0x0000000000000000, 0x00)
    TEST(rorw , RORW, 0x0123456789ABCDEF, 0x08)
    TEST(rorw , RORW, 0x0123456789ABCDEF, 0x07)
    TEST(rorw , RORW, 0x0123456789ABCDEF, 0x0F)
    
    TEST(rori , ROR , 0x0000000000000000, 0x00)
    TEST(rori , ROR , 0x0123456789ABCDEF, 0x08)
    TEST(rori , ROR , 0x0123456789ABCDEF, 0x07)
    TEST(rori , ROR , 0x0123456789ABCDEF, 0x0F)
    TEST(rori , ROR , 0x0123456789ABCDEF, 0x28)
    
    TEST(roriw, RORW, 0x0000000000000000, 0x00)
    TEST(roriw, RORW, 0x0123456789ABCDEF, 0x08)
    TEST(roriw, RORW, 0x0123456789ABCDEF, 0x07)
    TEST(roriw, RORW, 0x0123456789ABCDEF, 0x0F)
    
    TEST(rol  , ROL , 0x0000000000000000, 0x00)
    TEST(rol  , ROL , 0x0123456789ABCDEF, 0x08)
    TEST(rol  , ROL , 0x0123456789ABCDEF, 0x07)
    TEST(rol  , ROL , 0x0123456789ABCDEF, 0x0F)
    TEST(rol  , ROL , 0x0123456789ABCDEF, 0x28)
    
    TEST(rolw , ROLW, 0x0000000000000000, 0x00)
    TEST(rolw , ROLW, 0x0123456789ABCDEF, 0x08)
    TEST(rolw , ROLW, 0x0123456789ABCDEF, 0x07)
    TEST(rolw , ROLW, 0x0123456789ABCDEF, 0x0F)
    
    return 0;

}
