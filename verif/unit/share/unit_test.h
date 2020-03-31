
#include <stdint.h>

#ifndef UNIT_TEST_H
#define UNIT_TEST_H


// ----------- Defined in boot.S -------------------

//! Called if the test fails
void test_fail();


//! Called if the test passes
void test_pass();

// ----------- Defined in util.S -------------------

// Base address of the memory mapped IO region
volatile uint64_t * __mmio_base;

//! Direct access to mtime
volatile uint64_t * __mtime    ;

//! Direct access to mtimecmp
volatile uint64_t * __mtimecmp ;

//! Read the memory mapped mtime register
volatile uint64_t __rd_mtime();

//! Read the memory mapped mtimecmp register
volatile uint64_t __rd_mtimecmp();

//! Read the memory mapped mtimecmp register
volatile void     __wr_mtimecmp(uint64_t mtc);

//! Intrisic for the `rdcycle` assembly instruction
volatile uint64_t __rdcycle();

//! Intrisic for the `rdtime` assembly instruction
volatile uint64_t __rdtime();

//! Intrisic for the `rdinstret` assembly instruction
volatile uint64_t __rdinstret();

//! Get the mcountinhibit CSR value
volatile uint32_t __rdmcountinhibit();

//! Set the mcountinhibit CSR value to a new one, and get the original value.
volatile uint32_t __wrmcountinhibit(uint32_t toset);

//! Read the mstatus CSR
volatile uint32_t __rd_mstatus();

//! Write the mstatus CSR and return it's original value.
volatile uint32_t __wr_mstatus(uint32_t n);

//! Set bits in the mstatus CSR
volatile void __set_mstatus(uint32_t mask);

//! Clear bits in the mstatus CSR
volatile void __clr_mstatus(uint32_t mask);

//! Read the mie CSR
volatile uint32_t __rd_mie();

//! Write the mie CSR and return it's original value.
volatile uint32_t __wr_mie(uint32_t n);

//! Set bits in the mie CSR
volatile void __set_mie(uint32_t mask);

//! Clear bits in the mie CSR
volatile void __clr_mie(uint32_t mask);

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

#endif

