
#include "unit_test.h"

// Taken from rvintrin.h
// https://github.com/riscv/riscv-bitmanip/blob/522b9a52655d0df7962b5bdd11b326c8f5ffeec8/cproofs/rvintrin.h#L635
static inline int64_t _rv64_clmul(int64_t rs1, int64_t rs2)
{
	uint64_t a = rs1, b = rs2, x = 0;
	for (int i = 0; i < 64; i++)
		if ((b >> i) & 1)
			x ^= a << i;
	return x;
}

// Taken from rvintrin.h
// https://github.com/riscv/riscv-bitmanip/blob/522b9a52655d0df7962b5bdd11b326c8f5ffeec8/cproofs/rvintrin.h#L644
static inline int64_t _rv64_clmulh(int64_t rs1, int64_t rs2)
{
	uint64_t a = rs1, b = rs2, x = 0;
	for (int i = 1; i < 64; i++)
		if ((b >> i) & 1)
			x ^= a >> (64-i);
	return x;
}

inline uint64_t clmul (uint64_t rs1, uint64_t rs2) {
    uint64_t rd;
    asm ("clmul %0, %1, %2" : "=r"(rd) : "r"(rs1), "r"(rs2));
    return rd;
}

inline uint64_t clmulh(uint64_t rs1, uint64_t rs2) {
    uint64_t rd;
    asm ("clmulh %0, %1, %2" : "=r"(rd) : "r"(rs1), "r"(rs2));
    return rd;
}


#define TEST(INS,CHECK,RS1,RS2) {   \
    uint64_t rd = INS(RS1, RS2);    \
    if(rd != CHECK(RS1,RS2)) {      \
        test_fail();                \
    }                               \
}

int test_main() {

    TEST(clmul , _rv64_clmul , 0x0000000000000001, 0x0000000000000111)
    TEST(clmul , _rv64_clmul , 0x0123456789abcdef, 0x0123456789abcdef)
    TEST(clmul , _rv64_clmul , 0xefcdab8967452301, 0x0123456789abcdef)

    TEST(clmulh, _rv64_clmulh, 0x0123456789abcdef, 0x0706050403020100)
    TEST(clmulh, _rv64_clmulh, 0xefcdab8967452301, 0x07060504030C0B0A)

    for(int i = 0; i < 2; i ++) {
        TEST(clmulh, _rv64_clmulh, 0x0123456789abcdef, i)
        TEST(clmulh, _rv64_clmulh, 0xefcdab8967452301, i)
    }

    return 0;

}
