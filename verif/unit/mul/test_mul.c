
#include "unit_test.h"

volatile inline int in_mul(int rs1, int rs2) {
    int     rd;
    asm volatile("mul %0, %1, %2" : "=r"(rd) : "r"(rs1), "r"(rs2));
    return  rd;
}

#define CHECK(FN, rs1, rs2) if((rs1*rs2) != FN(rs1,rs2)){test_fail();}

int test_main() {

    CHECK(in_mul,  0,  0);
    CHECK(in_mul,  1,  0);
    CHECK(in_mul,  0,  1);
    CHECK(in_mul,  1,  1);
    CHECK(in_mul,  2,  1);
    CHECK(in_mul,  1,  2);
    CHECK(in_mul,  0, -1);
    CHECK(in_mul, -1,  0);
    CHECK(in_mul, -1,  1);
    CHECK(in_mul,  1, -1);
    CHECK(in_mul, -1, -1);

    return 0;

}

