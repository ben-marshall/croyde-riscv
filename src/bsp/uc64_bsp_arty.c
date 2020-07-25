
#include "uc64_bsp.h"

static volatile uint32_t * const uart_rx    = (uint32_t*)0x001B0000;
static volatile uint32_t * const uart_tx    = (uint32_t*)0x001B0004;
static volatile uint32_t * const uart_stat  = (uint32_t*)0x001B0008;
static volatile uint32_t * const uart_ctrl  = (uint32_t*)0x001B000C;

#define BF_UART_STAT_TX_FULL    (0x1 << 3)
#define BF_UART_STAT_RX_VALID   (0x1 << 0)

int  uc64_bsp_putc_b    (char   c) {
    while(*uart_stat & BF_UART_STAT_TX_FULL){
        // Do Nothing.
    }
    *uart_tx = c;
    return 0;
}

int  uc64_bsp_putc_nb   (char   c) {
    *uart_tx = c;
    return 0;
}

int  uc64_bsp_getc_b    (char * c) {
    while((*uart_stat & BF_UART_STAT_RX_VALID) == 0) {
        // Do nothing.
    }
    uint32_t rx = *uart_rx;
    *c          = (char)rx;
    return 0;
}

int  uc64_bsp_getc_nb   (char * c) {
    int rx_avail    = *uart_stat & BF_UART_STAT_RX_VALID;
    uint32_t rx     = *uart_rx;
    *c              = (char)rx;
    return rx_avail;
}

