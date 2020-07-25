
#include <stdint.h>

#ifndef UNIT_TEST_H
#define UNIT_TEST_H

// ----------- CSR Read / Write --------------------

#define DECL_RD_CSR(CSR) volatile inline uint64_t rd_##CSR() { \
    uint64_t rd; asm volatile ("csrr %0, " #CSR : "=r"(rd)); return rd; \
}

#define DECL_WR_CSR(CSR) volatile inline void wr_##CSR(uint64_t rs1) { \
    asm volatile ("csrw " #CSR ", %0" : : "r"(rs1));   \
}

#define DECL_CLR_CSR(CSR) volatile inline void clr_##CSR(uint64_t rs1) { \
    asm volatile ("csrc " #CSR ", %0" : : "r"(rs1));   \
}

#define DECL_SET_CSR(CSR) volatile inline void set_##CSR(uint64_t rs1) { \
    asm volatile ("csrs " #CSR ", %0" : : "r"(rs1));   \
}

DECL_RD_CSR(mepc)
DECL_WR_CSR(mepc)

DECL_RD_CSR(mcause)

DECL_RD_CSR(mtvec)
DECL_WR_CSR(mtvec)

DECL_RD_CSR(mstatus)
DECL_WR_CSR(mstatus)
DECL_CLR_CSR(mstatus)
DECL_SET_CSR(mstatus)

DECL_RD_CSR(mie)
DECL_WR_CSR(mie)
DECL_CLR_CSR(mie)
DECL_SET_CSR(mie)

#define MSTATUS_MIE   ( 0b1 << 3 )
#define MIE_MTIE      ( 0b1 << 7 )

#define MCAUSE_MACHINE_TIMER_INTERRUPT ( 0x7)

volatile inline void __wfi() {
    asm volatile ("wfi");
}

// ----------- Defined in boot.S -------------------

//! Called if the test fails
void test_fail();


//! Called if the test passes
void test_pass();

// ----------- Defined in util.S -------------------


//! Get the mcountinhibit CSR value
volatile uint32_t __rdmcountinhibit();

//! Set the mcountinhibit CSR value to a new one, and get the original value.
volatile uint32_t __wrmcountinhibit(uint32_t toset);

//! Read the mstatus CSR
inline volatile uint64_t __rd_mstatus() {
    uint64_t rd;
    asm volatile("csrr %0, mstatus" : "=r"(rd));
    return rd;
}

//! Write the mstatus CSR and return it's original value.
inline volatile uint64_t __wr_mstatus(uint64_t n){
    uint64_t rd;
    asm volatile("csrrw %0, %1, mstatus" : "=r"(rd) : "r"(n));
    return rd;
}

//! Set bits in the mstatus CSR
inline volatile void __set_mstatus(uint64_t mask) {
    asm volatile("csrs mstatus, %0" : : "r"(mask));
}

//! Clear bits in the mstatus CSR
inline volatile void __clr_mstatus(uint64_t mask) {
    asm volatile("csrc mstatus, %0" : : "r"(mask));
}

//! Read the mie CSR
inline volatile uint64_t __rd_mie() {
    uint64_t rd;
    asm volatile("csrr %0, mie" : "=r"(rd));
    return rd;
}

//! Write the mie CSR and return it's original value.
inline volatile uint64_t __wr_mie(uint64_t n){
    uint64_t rd;
    asm volatile("csrrw %0, %1, mie" : "=r"(rd) : "r"(n));
    return rd;
}

//! Set bits in the mie CSR
inline volatile void __set_mie(uint64_t mask) {
    asm volatile("csrs mie, %0" : : "r"(mask));
}

//! Clear bits in the mie CSR
inline volatile void __clr_mie(uint64_t mask) {
    asm volatile("csrc mie, %0" : : "r"(mask));
}

//! Write a character to the uart.
void __putchar(char c) ;

//! Write a null terminated string to the uart.
void __putstr(char *s) ;

//! Print a 64-bit number as hex
void __puthex64(uint64_t w);

//! Print a 64-bit number as hex, no leading zeros.
void __puthex64_nlz(uint64_t w);

//! Print a 32-bit number as hex
void __puthex32(uint32_t w);

//! Print an 8-bit number as hex
void __puthex8(uint8_t w);

#define CAUSE_CODE_IACCESS  0x1l
#define CAUSE_CODE_LDACCESS 0x5l
#define CAUSE_CODE_STACCESS 0x7l

#endif

