
#include "memory_device_uart.hpp"

#include <iostream>


/*!
*/
bool memory_device_uart::read_word (
    memory_address addr,
    uint32_t     * dout
){
    if (addr == addr_tx) {
        dout = &reg_tx;
    }
    else if (addr == addr_rx) {
        dout = &reg_rx;
    }
    else if(addr == addr_ctrl) {
        dout = &reg_ctrl;
    }
    else if(addr == addr_status) {
        dout = &reg_status;
    }
    else {
        return false;
    }

    return true;
}


/*!
*/
bool memory_device_uart::write_byte (
    memory_address addr,
    uint8_t        data
){

    memory_address word_addr = addr & ~(0b11);
    
    if(addr == addr_tx){
        if((addr & 0b11) == 0) {
            // Only send iff writing to lowest byte of the register.
            write_to_tx_buffer(data);
        }
    }
    else if (addr == addr_rx){
        // Do nothing. It makes no sense to write to the RX buffer.
    }
    else if (addr == addr_ctrl){
        std::cerr << "__FILE__:__LINE__ - UART Register not implemented."
                  << std::endl;
        return false;
    }
    else if (addr == addr_status){
        std::cerr << "__FILE__:__LINE__ - UART Register not implemented."
                  << std::endl;
        return false;
    }
    else {
        return false;
    }

    return true;
}


/*!
@brief Return a single byte from the device.
*/
uint8_t memory_device_uart::read_byte (
    memory_address addr
){
    memory_address word_addr = addr & ~(0b11);
    memory_address byte_off  = addr &  (0b11);

    if(addr == addr_tx){
        
        if(addr & 0b11 == 0) {
            
            return reg_tx&0xFF;

        }

        return 0;

    }
    else if(addr == addr_rx){
        
        return get_from_rx_buffer();

    }
    else if(addr == addr_ctrl){

        std::cerr << "__FILE__:__LINE__ - UART Register not implemented."
                  << std::endl;

        return 0;

    }
    else if(addr == addr_status){

        std::cerr << "__FILE__:__LINE__ - UART Register not implemented."
                  << std::endl;

        return 0;

    }
    else {

        return 0;

    }
}

//! Get the next char from the rx buffer and pop it from the buffer.
uint8_t memory_device_uart::get_from_rx_buffer() {

    if(rx_buffer.size() > 0) {

        uint8_t tr = rx_buffer.front();
        rx_buffer.pop();
        return tr;

    } else {

        return 0;

    }

}

//! Get the next char from the rx buffer and pop it from the buffer.
void memory_device_uart::write_to_tx_buffer(uint8_t data) {
    
    tx_buffer.push(data);

    // Line buffered - so if we see a newline, print and empty the buffer.
    if(data == '\n') {

        std::cout << "$ ";
        
        while(tx_buffer.size() > 0) {
            std::cout << tx_buffer.front();
            tx_buffer.pop();
        }

        tx_buffer.empty();
    }

}
