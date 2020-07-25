
#include "unit_test.h"

// Used by __puthex*
char * lut = "0123456789ABCDEF";

volatile uint32_t * UART = (volatile uint32_t*)0x11000000;

//! Write a character to the uart.
void __putchar(char c) {
    UART[0] = c;
}

//! Write a null terminated string to the uart.
void __putstr(char *s) {
    int i = 0;
    if(s[0] == 0) {
        return;
    }
    do {
        uint32_t tw = s[i];
        UART[0]     = tw;
        i++;
    } while(s[i] != 0) ;
}

//! Print a 64-bit number as hex
void __puthex64(uint64_t w) {
    for(int i =  7; i >= 0; i --) {
        uint8_t b_0 = (w >> (8*i    )) & 0xF;
        uint8_t b_1 = (w >> (8*i + 4)) & 0xF;
        __putchar(lut[b_1]);
        __putchar(lut[b_0]);
    }
}

//! Print a 64-bit number as hex. No leading zeros.
void __puthex64_nlz(uint64_t w) {
    char nz_seen = 0;
    for(int i =  7; i >= 0; i --) {
        uint8_t b_0 = (w >> (8*i    )) & 0xF;
        uint8_t b_1 = (w >> (8*i + 4)) & 0xF;
        if(b_1 > 0 || nz_seen) {
            nz_seen = 1;
            __putchar(lut[b_1]);
        }
        if(b_0 > 0 || nz_seen) {
            nz_seen = 1;
            __putchar(lut[b_0]);
        }
    }
}

//! Print a 32-bit number as hex
void __puthex32(uint32_t w) {
    for(int i =  3; i >= 0; i --) {
        uint8_t b_0 = (w >> (8*i    )) & 0xF;
        uint8_t b_1 = (w >> (8*i + 4)) & 0xF;
        __putchar(lut[b_1]);
        __putchar(lut[b_0]);
    }
}

//! Print an 8-bit number as hex
void __puthex8(uint8_t w) {
    uint8_t b_0 = (w >> ( 0)) & 0xF;
    uint8_t b_1 = (w >> ( 4)) & 0xF;
    __putchar(lut[b_1]);
    __putchar(lut[b_0]);
}
