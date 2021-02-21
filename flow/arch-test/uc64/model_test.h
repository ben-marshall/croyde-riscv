#ifndef _COMPLIANCE_MODEL_H
#define _COMPLIANCE_MODEL_H

// Base address of simulation environment uart.
#define SIM_UART_BASE 0x11000000

#define RVMODEL_DATA_SECTION \
        .pushsection .tohost,"aw",@progbits;                            \
        .align 8; .global tohost; tohost: .dword 0;                     \
        .align 8; .global fromhost; fromhost: .dword 0;                 \
        .popsection;                                                    \
        .align 8; .global begin_regstate; begin_regstate:               \
        .word 128;                                                      \
        .align 8; .global end_regstate; end_regstate:                   \
        .word 4;


//TODO: Add code here to run after all tests have been run
// The .align 4 ensures that the signature begins at a 16-byte boundary
#define RVMODEL_HALT                          \
  li  t0, SIM_UART_BASE;                      \
  li  t1, '\n';  sw  t1, 0(t0);               \
  li  t1, 'D';  sw  t1, 0(t0);                \
  li  t1, 'O';  sw  t1, 0(t0);                \
  li  t1, 'N';  sw  t1, 0(t0);                \
  li  t1, 'E';  sw  t1, 0(t0);                \
  li  t1, '\n';  sw  t1, 0(t0);               \
  uc64_halt:  j uc64_halt;

//TODO: declare the start of your signature region here. Nothing else to be used here.
// The .align 4 ensures that the signature ends at a 16-byte boundary
#define RVMODEL_DATA_BEGIN                                              \
  .align 4; .global begin_signature; begin_signature:

//TODO: declare the end of the signature region here. Add other target specific contents here.
#define RVMODEL_DATA_END                                                \
  .align 4; .global end_signature; end_signature:                       \
  RVMODEL_DATA_SECTION                                                        


//RVMODEL_BOOT
//TODO:Any specific target init code should be put here or the macro can be left empty
#define RVMODEL_BOOT    \
    nop;nop;nop;nop;    \
uc64_boot:              \
    la  t0, uc64_fail;  \
    csrw    mtvec, t0;  \
    j   rvtest_init;    \
    nop;nop;nop;nop;    \
.align 8;               \
uc64_fail:              \
    j uc64_fail;
    //RVTEST_IO_INIT

// _SP = (volatile register)
//TODO: Macro to output a string to IO
#define LOCAL_IO_WRITE_STR(_STR) RVMODEL_IO_WRITE_STR(x31, _STR)
#define RVMODEL_IO_WRITE_STR(_SP, _STR)                                 \
    .section .data.string;                                              \
20001:                                                                  \
    .string _STR;                                                       \
    .section .text.init;                                                \
    la a0, 20001b;                                                      \
    jal FN_WriteStr;

#define RSIZE 8
// _SP = (volatile register)
#define LOCAL_IO_PUSH(_SP)                                              \
    la      _SP,  begin_regstate;                                       \
    sd      t0,   (1*RSIZE)(_SP);                                       \
    sd      t1,   (2*RSIZE)(_SP);                                       \

// _SP = (volatile register)
#define LOCAL_IO_POP(_SP)                                               \
    la      _SP,   begin_regstate;                                      \
    ld      t0,   (1*RSIZE)(_SP);                                       \
    ld      t1,   (2*RSIZE)(_SP);                                       \

//RVMODEL_IO_ASSERT_GPR_EQ
// _SP = (volatile register)
// _R = GPR
// _I = Immediate
// This code will check a test to see if the results 
// match the expected value.
// It can also be used to tell if a set of tests is still running or has crashed
// Test to see if a specific test has passed or not.  Can assert or not.
#define RVMODEL_IO_ASSERT_GPR_EQ(_SP, _R, _I)   \
    LOCAL_IO_PUSH(_SP)                          \
    li  t0, _I ;                                \
    bne _R, t0, rvtest_code_end  ;              \
    li  t0, SIM_UART_BASE;                      \
    li  t1, '.';                                \
    sw  t1, 0(t0);                              \
    LOCAL_IO_POP(_SP)

.section .text
// FN_WriteStr: Add code here to write a string to IO
// FN_WriteNmbr: Add code here to write a number (32/64bits) to IO
FN_WriteStr: \
    ret; \
FN_WriteNmbr: \
    ret;

//RVTEST_IO_ASSERT_SFPR_EQ
#define RVMODEL_IO_ASSERT_SFPR_EQ(_F, _R, _I)
//RVTEST_IO_ASSERT_DFPR_EQ
#define RVMODEL_IO_ASSERT_DFPR_EQ(_D, _R, _I)

// TODO: specify the routine for setting machine software interrupt
#define RVMODEL_SET_MSW_INT

// TODO: specify the routine for clearing machine software interrupt
#define RVMODEL_CLEAR_MSW_INT

// TODO: specify the routine for clearing machine timer interrupt
#define RVMODEL_CLEAR_MTIMER_INT

// TODO: specify the routine for clearing machine external interrupt
#define RVMODEL_CLEAR_MEXT_INT

#endif // _COMPLIANCE_MODEL_H

