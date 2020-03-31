
#include "unit_test.h"

int test_main() {

    __putstr("--- Begin test ---\n");

    int sum = 0;

    for(int i = 0; i < 100; i ++) {

        sum += 1 + i * 2;

    }
    
    __putstr("--- End test ---\n");

    return 0;

}
